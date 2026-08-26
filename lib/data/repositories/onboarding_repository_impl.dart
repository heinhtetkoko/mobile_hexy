import 'package:mobile_hexy/data/datasources/onboarding_local_data_source.dart';
import 'package:mobile_hexy/domain/entities/onboarding_slide.dart';
import 'package:mobile_hexy/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  const OnboardingRepositoryImpl(this._localDataSource);
  final OnboardingLocalDataSource _localDataSource;
  @override
  List<OnboardingSlide> getSlides() => _localDataSource.getSlides();
}
