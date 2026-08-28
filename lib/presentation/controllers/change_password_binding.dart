import 'package:get/get.dart';
import 'package:mobile_hexy/domain/usecases/change_password.dart';
import 'package:mobile_hexy/presentation/viewmodel/change_password_view_model.dart';

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => ChangePasswordViewModel(Get.find<ChangePassword>()));
}
