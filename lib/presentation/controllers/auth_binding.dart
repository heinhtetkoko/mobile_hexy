import 'package:get/get.dart';
import 'package:mobile_hexy/domain/usecases/login_user.dart';
import 'package:mobile_hexy/domain/usecases/register_user.dart';
import 'package:mobile_hexy/presentation/viewmodel/auth_view_model.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AuthViewModel(
        Get.find<LoginUser>(),
        Get.find<RegisterUser>(),
        Get.find<SecureStorage>(),
      ),
    );
  }
}
