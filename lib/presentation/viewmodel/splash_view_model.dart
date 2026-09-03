import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/app_navigator.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';

class SplashViewModel extends BaseViewModel {
  SplashViewModel(this._navigator, this._storage);
  final AppNavigator _navigator;
  final SecureStorage _storage;
  Timer? _timer;
  @override
  void onInit() {
    super.onInit();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _timer = Timer(
      const Duration(seconds: 3),
      () => unawaited(_continueFromSplash()),
    );
  }

  Future<void> _continueFromSplash() async {
    var onboardingCompleted = false;
    try {
      onboardingCompleted =
          await _storage.read(AppConstants.onboardingCompletedKey) == 'true';
    } catch (_) {
      // If storage is unavailable, onboarding is the safest default route.
    }
    _navigator.replaceWith(
      onboardingCompleted ? AppRoutes.home : AppRoutes.onboarding,
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }
}
