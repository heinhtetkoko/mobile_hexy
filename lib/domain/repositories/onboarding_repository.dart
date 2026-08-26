import 'package:mobile_hexy/domain/entities/onboarding_slide.dart';

abstract interface class OnboardingRepository {
  List<OnboardingSlide> getSlides();
}
