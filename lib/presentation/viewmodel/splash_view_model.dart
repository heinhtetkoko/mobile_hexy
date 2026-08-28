import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/services/app_navigator.dart';

class SplashViewModel extends BaseViewModel {
  SplashViewModel(this._navigator);
  final AppNavigator _navigator;
  Timer? _timer;
  @override
  void onInit() {
    super.onInit();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _timer = Timer(
      const Duration(seconds: 3),
      () => _navigator.replaceWith(AppRoutes.onboarding),
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onClose();
  }
}
