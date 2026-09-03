import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/services/app_navigator.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/data/models/onboarding_slide.dart';
import 'package:mobile_hexy/domain/usecases/get_onboarding_slides.dart';

class OnboardingViewModel extends BaseViewModel {
  OnboardingViewModel({
    required GetOnboardingSlides getSlides,
    required AppNavigator navigator,
    required SecureStorage storage,
  }) : _getSlides = getSlides,
       _navigator = navigator,
       _storage = storage;
  final GetOnboardingSlides _getSlides;
  final AppNavigator _navigator;
  final SecureStorage _storage;
  final pageController = PageController();
  final currentPage = 0.obs;
  final slides = <OnboardingSlide>[].obs;
  @override
  void onInit() {
    super.onInit();
    slides.assignAll(_getSlides());
  }

  void updatePage(int page) => currentPage.value = page;
  Future<void> continueOnboarding() async {
    if (currentPage.value == slides.length - 1) {
      try {
        await _storage.write(AppConstants.onboardingCompletedKey, 'true');
      } catch (_) {
        // Continue to the app even if preference storage is unavailable.
      }
      _navigator.clearAndNavigate(AppRoutes.home);
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
