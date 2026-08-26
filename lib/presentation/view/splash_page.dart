import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/constants/asset_paths.dart';
import 'package:mobile_hexy/presentation/viewmodel/splash_view_model.dart';

class SplashPage extends GetView<SplashViewModel> {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) => GetBuilder<SplashViewModel>(
    builder: (_) => const Scaffold(
      body: SizedBox.expand(
        child: Image(
          image: AssetImage(AssetPaths.splashScreen),
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}
