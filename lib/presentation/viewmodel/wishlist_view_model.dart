import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/wishlist_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/models/wishlist_item.dart';

class WishlistViewModel extends BaseViewModel {
  WishlistViewModel(this._remoteDataSource, this._cartRemoteDataSource);

  final WishlistRemoteDataSource _remoteDataSource;
  final CartRemoteDataSource _cartRemoteDataSource;
  final items = <WishlistItem>[].obs;
  final isLoading = false.obs;
  final updatingIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _remoteDataSource.fetchWishlist();
      items.assignAll(result.items);
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeItem(WishlistItem item) async {
    if (updatingIds.contains(item.id)) return;
    updatingIds.add(item.id);
    try {
      final result = await _remoteDataSource.remove(
        wishlistId: item.id,
        productId: item.productId,
      );
      items.assignAll(result.items);
    } catch (error) {
      _showError(error);
    } finally {
      updatingIds.remove(item.id);
    }
  }

  Future<void> addToCart(WishlistItem item) async {
    if (updatingIds.contains(item.id)) return;
    updatingIds.add(item.id);
    try {
      final result = await _remoteDataSource.moveToCart(item.productId);
      items.assignAll(result.items);
      await _cartRemoteDataSource.fetchCart();
      Get.snackbar(
        'Added to cart',
        item.name,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(error);
    } finally {
      updatingIds.remove(item.id);
    }
  }

  void _showError(Object error) {
    if (Get.currentRoute == '/login') return;
    Get.snackbar(
      'Could not update wishlist',
      error.toString().replaceFirst('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
