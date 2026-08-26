import 'package:get/get.dart';
import 'package:mobile_hexy/app/routes/app_routes.dart';
import 'package:mobile_hexy/core/constants/app_constants.dart';
import 'package:mobile_hexy/core/storage/secure_storage.dart';

class MainViewModel extends GetxController {
  final selectedIndex = 0.obs;

  Future<void> changePage(int index) async {
    const protectedTabs = {3, 4};
    if (protectedTabs.contains(index)) {
      final token = await Get.find<SecureStorage>().read(
        AppConstants.accessTokenKey,
      );
      if (token == null || token.trim().isEmpty) {
        await Get.toNamed<void>(AppRoutes.login);
        return;
      }
    }

    if (selectedIndex.value != index) selectedIndex.value = index;
  }
}
