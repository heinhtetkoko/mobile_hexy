import 'package:get/get.dart';
import 'package:mobile_hexy/core/services/app_navigator.dart';
import 'package:mobile_hexy/presentation/viewmodel/onboarding_view_model.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => OnboardingViewModel(
        getSlides: Get.find(),
        navigator: Get.find<AppNavigator>(),
      ),
    );
  }
}
