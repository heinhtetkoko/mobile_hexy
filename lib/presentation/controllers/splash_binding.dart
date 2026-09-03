import 'package:get/get.dart';
import 'package:mobile_hexy/core/services/app_navigator.dart';
import 'package:mobile_hexy/presentation/viewmodel/splash_view_model.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => SplashViewModel(Get.find<AppNavigator>(), Get.find()));
}
