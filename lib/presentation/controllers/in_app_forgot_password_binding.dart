import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/in_app_forgot_password_view_model.dart';

class InAppForgotPasswordBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => InAppForgotPasswordViewModel(Get.find(), Get.find()));
}
