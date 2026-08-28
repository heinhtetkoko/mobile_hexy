import 'package:get/get.dart';
import 'package:mobile_hexy/core/services/ui_service.dart';

class UiServiceImpl implements UiService {
  @override
  void showError(String message) =>
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);

  @override
  void showSuccess(String message) =>
      Get.snackbar('Success', message, snackPosition: SnackPosition.BOTTOM);
}
