import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/presentation/viewmodel/categories_view_model.dart';

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
  }

  Future<void> changePage(int index) async {
    const protectedTabs = {2, 3, 4};
    if (protectedTabs.contains(index)) {
      final token = await Get.find<SecureStorage>().read(
        AppConstants.accessTokenKey,
      );
      if (token == null || token.trim().isEmpty) {
        await Get.toNamed<void>(
          AppRoutes.login,
          arguments: {'tabIndex': index},
        );
        return;
      }
    }

    if (selectedIndex.value != index) selectedIndex.value = index;
  }

  Future<void> openCategories({String? categoryName}) async {
    selectedIndex.value = 1;
    if (categoryName != null && categoryName.trim().isNotEmpty) {
      await Get.find<CategoriesViewModel>().selectCategoryByName(categoryName);
    }
  }
}
