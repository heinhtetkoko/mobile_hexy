import 'package:mobile_hexy/data/models/onboarding_slide.dart';

abstract interface class OnboardingRepository {
  List<OnboardingSlide> getSlides();
}
