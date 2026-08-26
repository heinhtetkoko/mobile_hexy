import 'package:get/get.dart';
import 'package:mobile_hexy/data/datasources/auth_remote_data_source.dart';
import 'package:mobile_hexy/data/repositories/auth_repository_impl.dart';
import 'package:mobile_hexy/domain/repositories/auth_repository.dart';
import 'package:mobile_hexy/domain/usecases/login_user.dart';
import 'package:mobile_hexy/presentation/viewmodel/auth_view_model.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthRemoteDataSource(Get.find()));
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find(), Get.find()),
    );
    Get.lazyPut(() => LoginUser(Get.find()));
    Get.lazyPut(() => AuthViewModel(Get.find()));
  }
}
