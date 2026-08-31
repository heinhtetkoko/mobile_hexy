import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/presentation/viewmodel/categories_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/wishlist_view_model.dart';

class MainViewModel extends BaseViewModel {
  final selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Map && arguments['tabIndex'] is int) {
      final tabIndex = arguments['tabIndex'] as int;
      if (tabIndex >= 0 && tabIndex <= 4) selectedIndex.value = tabIndex;
    }
    if (selectedIndex.value == 3) {
      Future<void>.microtask(Get.find<CartViewModel>().loadCart);
    } else if (selectedIndex.value == 2) {
      Future<void>.microtask(Get.find<WishlistViewModel>().loadWishlist);
    }
  }

  Future<void> changePage(int index) async {
    const protectedTabs = {2, 3, 4};
    if (protectedTabs.contains(index)) {
      final token = await Get.find<SecureStorage>().read(
        AppConstants.accessTokenKey,
      );
      if (token == null || token.trim().isEmpty) {
        await Get.toNamed<dynamic>(
          AppRoutes.login,
          arguments: {'tabIndex': index},
        );
        return;
      }
    }

    if (selectedIndex.value != index) selectedIndex.value = index;
    if (index == 2) await Get.find<WishlistViewModel>().loadWishlist();
    if (index == 3) await Get.find<CartViewModel>().loadCart();
  }

  Future<void> openCategories({String? categoryName}) async {
    selectedIndex.value = 1;
    if (categoryName != null && categoryName.trim().isNotEmpty) {
      await Get.find<CategoriesViewModel>().selectCategoryByName(categoryName);
    }
  }
}
