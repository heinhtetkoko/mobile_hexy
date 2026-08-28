import 'package:mobile_hexy/data/models/onboarding_slide.dart';
import 'package:mobile_hexy/domain/repositories/onboarding_repository.dart';

class GetOnboardingSlides {
  const GetOnboardingSlides(this._repository);
  final OnboardingRepository _repository;
  List<OnboardingSlide> call() => _repository.getSlides();
}
