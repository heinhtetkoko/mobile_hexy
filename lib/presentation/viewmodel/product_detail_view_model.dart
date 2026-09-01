import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/data/datasources/product_detail_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/wishlist_remote_data_source.dart';
import 'package:mobile_hexy/data/models/product_detail.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailViewModel extends BaseViewModel {
  ProductDetailViewModel(
    this._remoteDataSource,
    this._cartRemoteDataSource,
    this._wishlistRemoteDataSource,
  );

  final ProductDetailRemoteDataSource _remoteDataSource;
  final CartRemoteDataSource _cartRemoteDataSource;
  final WishlistRemoteDataSource _wishlistRemoteDataSource;
  final selectedImage = 0.obs;
  final selectedVariantId = RxnInt();
  final selectedVariantValues = <String, int>{}.obs;
  final quantity = 1.obs;
  final isFavorite = false.obs;
  final product = Rxn<ProductDetail>();
  final isLoading = false.obs;
  final isAddingToCart = false.obs;
  final isUpdatingWishlist = false.obs;
  final recommendationFavoriteIds = <int>{}.obs;
  final updatingRecommendationIds = <int>{}.obs;
  final scrollController = ScrollController();
  bool _resumedPendingAction = false;

  int get effectiveQuantityMaximum {
    final detail = product.value;
    if (detail == null) return 1;
    final stockMaximum = detail.availableQuantity.floor();
    if (detail.quantityMax > detail.quantityMin) return detail.quantityMax;
    if (stockMaximum > detail.quantityMin) return stockMaximum;
    return detail.quantityMin;
  }

  @override
  void onInit() {
    super.onInit();
    loadProduct().then((_) => _resumePendingAction());
  }

  Future<void> loadProduct({int? productId}) async {
    final arguments = Get.arguments;
    final argumentProductId = arguments is Map
        ? int.tryParse(arguments['productId']?.toString() ?? '')
        : int.tryParse(arguments?.toString() ?? '');
    final id = productId ?? argumentProductId;
    if (id == null || id <= 0) {
      errorMessage.value = 'No product selected.';
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _remoteDataSource.fetch(id);
      product.value = result;
      selectedImage.value = 0;
      final variantValues = result.variantSections.expand(
        (section) => section.values,
      );
      final selectedValues = variantValues.where((value) => value.selected);
      selectedVariantId.value = selectedValues.isNotEmpty
          ? selectedValues.first.variantId
          : variantValues.isEmpty
          ? null
          : variantValues.first.variantId;
      selectedVariantValues.assignAll({
        for (final section in result.variantSections)
          if (section.values.any((value) => value.available))
            section.key:
                section.values
                    .firstWhereOrNull(
                      (value) => value.selected && value.available,
                    )
                    ?.id ??
                section.values.firstWhere((value) => value.available).id,
      });
      quantity.value = result.defaultQuantity;
      if (arguments is Map && arguments['quantity'] is int) {
        quantity.value = (arguments['quantity'] as int).clamp(
          result.quantityMin,
          result.quantityMax,
        );
      }
      isFavorite.value = result.wishlist;
      recommendationFavoriteIds
        ..clear()
        ..addAll(
          [
            ...result.relatedProducts,
            ...result.youMightAlsoLike,
          ].where((item) => item.wishlist).map((item) => item.id),
        );
    } catch (_) {
      errorMessage.value = 'Could not load product details. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openProduct(int id) async {
    if (id <= 0 || product.value?.id == id) return;
    await loadProduct(productId: id);
    if (scrollController.hasClients) {
      await scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void increment() {
    final detail = product.value;
    if (detail == null) return;
    final step = detail.quantityStep > 0 ? detail.quantityStep : 1;
    final next = quantity.value + step;
    if (next <= effectiveQuantityMaximum) quantity.value = next;
  }

  void decrement() {
    final detail = product.value;
    if (detail == null) return;
    final step = detail.quantityStep > 0 ? detail.quantityStep : 1;
    final next = quantity.value - step;
    if (next >= detail.quantityMin) quantity.value = next;
  }

  Future<void> shareProduct(BuildContext context) async {
    final detail = product.value;
    if (detail == null) return;
    final box = context.findRenderObject() as RenderBox?;
    final shareText = '${detail.name}\n${detail.shareUrl}';
    try {
      await SharePlus.instance.share(
        ShareParams(
          subject: detail.name,
          text: shareText,
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: shareText));
      Get.snackbar(
        'Link copied',
        'Restart the app completely to enable the share menu.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PlatformException catch (error) {
      Get.snackbar(
        'Could not share product',
        error.message ?? 'Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void selectVariantValue(String sectionKey, ProductVariantValue value) {
    if (!value.available) return;
    selectedVariantValues[sectionKey] = value.id;
    if (value.variantId != null) selectedVariantId.value = value.variantId;
  }

  Future<void> addToCart() async {
    final detail = product.value;
    if (detail == null || isAddingToCart.value) return;
    if (!await _ensureAuthenticated('add_to_cart')) return;
    isAddingToCart.value = true;
    try {
      await _cartRemoteDataSource.addProduct(
        productId: detail.id,
        quantity: quantity.value,
      );
      Get.snackbar(
        'Added to cart',
        '${detail.name} × ${quantity.value}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      if (Get.currentRoute != '/login') {
        Get.snackbar(
          'Could not add to cart',
          error.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isAddingToCart.value = false;
    }
  }

  Future<void> toggleWishlist() async {
    final detail = product.value;
    if (detail == null || isUpdatingWishlist.value) return;
    if (!await _ensureAuthenticated('wishlist')) return;
    isUpdatingWishlist.value = true;
    try {
      final result = await _wishlistRemoteDataSource.toggle(detail.id);
      isFavorite.value = result.items.any(
        (item) => item.productId == detail.id,
      );
    } catch (error) {
      if (Get.currentRoute != '/login') {
        Get.snackbar(
          'Could not update wishlist',
          error.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isUpdatingWishlist.value = false;
    }
  }

  Future<void> toggleRecommendationWishlist(ProductDetailCard item) async {
    if (item.id <= 0 || updatingRecommendationIds.contains(item.id)) return;
    final token = await Get.find<SecureStorage>().read(
      AppConstants.accessTokenKey,
    );
    if (token == null || token.trim().isEmpty) {
      await Get.toNamed<dynamic>(
        AppRoutes.login,
        arguments: {'returnProductId': product.value?.id},
      );
      return;
    }

    updatingRecommendationIds.add(item.id);
    try {
      final result = await _wishlistRemoteDataSource.toggle(item.id);
      final isFavorite = result.items.any(
        (wishlistItem) => wishlistItem.productId == item.id,
      );
      if (isFavorite) {
        recommendationFavoriteIds.add(item.id);
      } else {
        recommendationFavoriteIds.remove(item.id);
      }
    } catch (error) {
      Get.snackbar(
        'Could not update wishlist',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      updatingRecommendationIds.remove(item.id);
    }
  }

  Future<bool> _ensureAuthenticated(String pendingAction) async {
    final token = await Get.find<SecureStorage>().read(
      AppConstants.accessTokenKey,
    );
    if (token != null && token.trim().isNotEmpty) return true;
    final detail = product.value;
    if (detail == null) return false;
    await Get.toNamed<dynamic>(
      AppRoutes.login,
      arguments: {
        'returnProductId': detail.id,
        'pendingAction': pendingAction,
        'quantity': quantity.value,
      },
    );
    return false;
  }

  Future<void> _resumePendingAction() async {
    if (_resumedPendingAction || product.value == null) return;
    _resumedPendingAction = true;
    final arguments = Get.arguments;
    if (arguments is! Map) return;
    switch (arguments['pendingAction']) {
      case 'add_to_cart':
        await addToCart();
      case 'wishlist':
        await toggleWishlist();
    }
  }
}
