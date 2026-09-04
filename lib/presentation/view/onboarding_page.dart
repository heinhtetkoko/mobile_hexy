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
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            Obx(
              () => PageView.builder(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.slides.length,
                onPageChanged: controller.updatePage,
                itemBuilder: (context, index) => SingleChildScrollView(
                  reverse: true,
                  child: Image.asset(
                    controller.slides[index].imageAsset,
                    fit: BoxFit.fitWidth,
                    width: constraints.maxWidth,
                  ),
                ),
              ),
            ),
            Obx(() {
              final rect = _buttonRect(
                constraints.biggest,
                controller.currentPage.value,
              );
              return Positioned.fromRect(
                rect: rect,
                child: Semantics(
                  button: true,
                  label: controller.currentPage.value == 2
                      ? 'Get Started'
                      : 'Next',
                  child: TextButton(
                    key: const Key('onboarding-next-button'),
                    onPressed: controller.continueOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: const StadiumBorder(),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ),
  );

  Rect _buttonRect(Size viewport, int page) {
    const imageSize = Size(1560, 3376);
    const imageButtonRects = [
      Rect.fromLTRB(380, 2932, 1180, 3124),
      Rect.fromLTRB(380, 2788, 1180, 2980),
      Rect.fromLTRB(380, 2848, 1180, 3040),
    ];
    final sourceRect = imageButtonRects[page.clamp(0, 2)];
    final scale = viewport.width / imageSize.width;
    final renderedSize = Size(
      imageSize.width * scale,
      imageSize.height * scale,
    );
    final offset = Offset(
      (viewport.width - renderedSize.width) / 2,
      viewport.height - renderedSize.height,
    );
    return Rect.fromLTRB(
      offset.dx + sourceRect.left * scale,
      offset.dy + sourceRect.top * scale,
      offset.dx + sourceRect.right * scale,
      offset.dy + sourceRect.bottom * scale,
    );
  }
}
