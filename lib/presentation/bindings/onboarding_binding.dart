import 'package:get/get.dart';
import 'package:mobile_hexy/core/navigation/app_navigator.dart';
import 'package:mobile_hexy/data/datasources/onboarding_local_data_source.dart';
import 'package:mobile_hexy/data/repositories/onboarding_repository_impl.dart';
import 'package:mobile_hexy/domain/repositories/onboarding_repository.dart';
import 'package:mobile_hexy/domain/usecases/get_onboarding_slides.dart';
import 'package:mobile_hexy/presentation/viewmodel/onboarding_view_model.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => const OnboardingLocalDataSource());
    Get.lazyPut<OnboardingRepository>(
      () => OnboardingRepositoryImpl(Get.find()),
    );
    Get.lazyPut(() => GetOnboardingSlides(Get.find()));
    Get.lazyPut(
      () => OnboardingViewModel(
        getSlides: Get.find(),
        navigator: Get.find<AppNavigator>(),
      ),
    );
  }
}
