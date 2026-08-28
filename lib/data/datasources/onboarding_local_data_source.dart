import 'package:mobile_hexy/data/models/onboarding_slide.dart';

class OnboardingLocalDataSource {
  const OnboardingLocalDataSource();
  List<OnboardingSlide> getSlides() => const [
    OnboardingSlide(imageAsset: 'assets/images/onboarding_1.png'),
    OnboardingSlide(imageAsset: 'assets/images/onboarding_2.png'),
    OnboardingSlide(imageAsset: 'assets/images/onboarding_3.png'),
  ];
}
