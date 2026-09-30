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
import 'package:mobile_hexy/presentation/viewmodel/main_view_model.dart';
import 'package:mobile_hexy/presentation/widgets/add_to_cart_success_dialog.dart';
import 'package:mobile_hexy/presentation/widgets/wishlist_success_dialog.dart';
import 'package:mobile_hexy/presentation/widgets/out_of_stock_dialog.dart';
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
  final isLoadingVariant = false.obs;
  final variantError = RxnString();
  int _detailRevision = 0;
  final isAddingToCart = false.obs;
  final isBuyingNow = false.obs;
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
    final revision = ++_detailRevision;
    isLoadingVariant.value = false;
    variantError.value = null;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _remoteDataSource.fetch(id);
      if (revision != _detailRevision) return;
      _applyVariantDetail(result);
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
      if (revision != _detailRevision) return;
      errorMessage.value = 'Could not load product details. Please try again.';
    } finally {
      if (revision == _detailRevision) isLoading.value = false;
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
    _detailRevision++;
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

  void _applyVariantDetail(ProductDetail result) {
    selectedImage.value = 0;
    final variantValues = result.variantSections.expand(
      (section) => section.values,
    );
    final selectedValues = variantValues.where((value) => value.selected);
    selectedVariantId.value =
        result.selectedVariantId ??
        (selectedValues.isNotEmpty
            ? _firstVariantId(selectedValues) ?? _firstVariantId(variantValues)
            : _firstVariantId(variantValues));
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
    product.value = result;
    isFavorite.value = result.wishlist;
  }

  Future<void> selectVariantValue(
    String sectionKey,
    ProductVariantValue value,
  ) async {
    final detail = product.value;
    if (detail == null ||
        !value.available ||
        isLoading.value ||
        isLoadingVariant.value ||
        isAddingToCart.value ||
        isBuyingNow.value ||
        isUpdatingWishlist.value) {
      return;
    }
    if (selectedVariantValues[sectionKey] == value.id) return;
    final selectedOptions = <String, ProductVariantValue>{};
    for (final section in detail.variantSections) {
      final option = section.key == sectionKey
          ? value
          : section.values.firstWhereOrNull(
              (option) => option.id == selectedVariantValues[section.key],
            );
      if (option != null) selectedOptions[section.key] = option;
    }
    final variantId = value.variantId;
    var ptavIds = <int>[];
    var attributeIds = <int>[];
    String? color;
    String? size;
    if (variantId == null) {
      if (value.nextPtavIds.isNotEmpty) {
        ptavIds = value.nextPtavIds;
      } else if (value.nextAttributeValueIds.isNotEmpty) {
        attributeIds = value.nextAttributeValueIds;
      } else if (selectedOptions.length == detail.variantSections.length &&
          selectedOptions.values.every((option) => option.ptavId != null)) {
        ptavIds = selectedOptions.values
            .map((option) => option.ptavId!)
            .toList();
      } else if (selectedOptions.length == detail.variantSections.length &&
          selectedOptions.values.every(
            (option) => option.attributeValueId != null,
          )) {
        attributeIds = selectedOptions.values
            .map((option) => option.attributeValueId!)
            .toList();
      } else if (selectedOptions.keys.every(
        (key) => key == 'color' || key == 'size',
      )) {
        color = selectedOptions['color']?.name;
        size = selectedOptions['size']?.name;
      }
      if (ptavIds.isEmpty &&
          attributeIds.isEmpty &&
          color == null &&
          size == null) {
        variantError.value =
            'This option has no variant selector. Please try another option.';
        return;
      }
    }
    final revision = ++_detailRevision;
    isLoadingVariant.value = true;
    variantError.value = null;
    try {
      final result = await _remoteDataSource.fetch(
        detail.id,
        productVariantId: variantId,
        ptavIds: ptavIds,
        attributeValueIds: attributeIds,
        color: color,
        size: size,
      );
      if (revision != _detailRevision) return;
      _applyVariantDetail(result);
      quantity.value = quantity.value.clamp(
        result.quantityMin,
        effectiveQuantityMaximum,
      );
    } catch (_) {
      if (revision != _detailRevision) return;
      variantError.value =
          'Could not load this variant. Tap the option to try again.';
    } finally {
      if (revision == _detailRevision) isLoadingVariant.value = false;
    }
  }

  Future<void> addToCart() async {
    await _addCurrentProductToCart(
      pendingAction: 'add_to_cart',
      isBuyNowAction: false,
    );
  }

  Future<void> buyNow() async {
    final added = await _addCurrentProductToCart(
      pendingAction: 'buy_now',
      isBuyNowAction: true,
    );
    if (!added) return;

    Get.until(
      (route) => route.settings.name == AppRoutes.home || route.isFirst,
    );
    if (Get.isRegistered<MainViewModel>()) {
      await Get.find<MainViewModel>().changePage(3);
    } else {
      await Get.offAllNamed<void>(
        AppRoutes.home,
        arguments: const {'tabIndex': 3},
      );
    }
  }

  Future<bool> _addCurrentProductToCart({
    required String pendingAction,
    required bool isBuyNowAction,
  }) async {
    final detail = product.value;
    if (detail == null ||
        isLoadingVariant.value ||
        isLoading.value ||
        isAddingToCart.value ||
        isBuyingNow.value) {
      return false;
    }
    if (!detail.inStock || detail.availableQuantity <= 0) {
      await showOutOfStockDialog(productName: detail.name);
      return false;
    }
    if (!await _ensureAuthenticated(pendingAction)) return false;
    final loadingState = isBuyNowAction ? isBuyingNow : isAddingToCart;
    loadingState.value = true;
    try {
      await _cartRemoteDataSource.addProduct(
        productId: detail.id,
        productVariantId: selectedVariantId.value,
        quantity: quantity.value,
      );
      if (!isBuyNowAction) {
        await showAddToCartSuccessDialog(
          productName: detail.name,
          quantity: quantity.value,
        );
      }
      return true;
    } catch (error) {
      if (isOutOfStockError(error)) {
        await showOutOfStockDialog(productName: detail.name);
        return false;
      }
      if (Get.currentRoute != '/login') {
        Get.snackbar(
          'Could not add to cart',
          error.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    } finally {
      loadingState.value = false;
    }
  }

  Future<void> toggleWishlist() async {
    final detail = product.value;
    if (detail == null ||
        isLoadingVariant.value ||
        isLoading.value ||
        isUpdatingWishlist.value) {
      return;
    }
    if (!await _ensureAuthenticated('wishlist')) return;
    final wasFavorite = isFavorite.value;
    isUpdatingWishlist.value = true;
    try {
      final firstVariantId = _firstVariantId(
        detail.variantSections.expand((section) => section.values),
      );
      final result = await _wishlistRemoteDataSource.toggle(
        detail.id,
        variantId: selectedVariantId.value ?? firstVariantId,
      );
      isFavorite.value = result.items.any(
        (item) => item.productId == detail.id,
      );
      if (!wasFavorite && isFavorite.value) {
        await showWishlistSuccessDialog(productName: detail.name);
      }
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

  int? _firstVariantId(Iterable<ProductVariantValue> values) {
    for (final value in values) {
      if (value.variantId != null && value.variantId! > 0) {
        return value.variantId;
      }
    }
    return null;
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

    final wasFavorite = recommendationFavoriteIds.contains(item.id);
    updatingRecommendationIds.add(item.id);
    try {
      final result = await _wishlistRemoteDataSource.toggle(item.id);
      final isFavorite = result.items.any(
        (wishlistItem) => wishlistItem.productId == item.id,
      );
      if (isFavorite) {
        recommendationFavoriteIds.add(item.id);
        if (!wasFavorite) {
          await showWishlistSuccessDialog(productName: item.name);
        }
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
      case 'buy_now':
        await buyNow();
      case 'wishlist':
        await toggleWishlist();
    }
  }
}
