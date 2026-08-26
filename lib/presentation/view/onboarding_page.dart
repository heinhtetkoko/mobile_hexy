import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/onboarding_view_model.dart';

class OnboardingPage extends GetView<OnboardingViewModel> {
  const OnboardingPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      top: false,
      bottom: false,
      child: Stack(
        children: [
          Obx(
            () => PageView.builder(
              controller: controller.pageController,
              itemCount: controller.slides.length,
              onPageChanged: controller.updatePage,
              itemBuilder: (context, index) => Image.asset(
                controller.slides[index].imageAsset,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 152,
            child: Semantics(
              button: true,
              label: 'Continue onboarding',
              child: TextButton(
                onPressed: controller.continueOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
