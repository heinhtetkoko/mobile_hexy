import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/routes/app_routes.dart';
import 'package:mobile_hexy/core/navigation/app_navigator.dart';

class SplashViewModel extends GetxController {
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
