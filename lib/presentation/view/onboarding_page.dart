import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/onboarding_view_model.dart';

class OnboardingPage extends GetView<OnboardingViewModel> {
  const OnboardingPage({super.key});

  // Native size of the onboarding slide artwork. The Next / Get Started
  // buttons are part of the artwork, so taps are mapped onto these rects.
  static const _imageSize = Size(1560, 3376);
  static const _imageButtonRects = [
    Rect.fromLTRB(380, 2932, 1180, 3124),
    Rect.fromLTRB(380, 2788, 1180, 2980),
    Rect.fromLTRB(380, 2848, 1180, 3040),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageRect = _imageRect(constraints.biggest);
          return Stack(
            children: [
              Obx(
                () => PageView.builder(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.slides.length,
                  onPageChanged: controller.updatePage,
                  itemBuilder: (context, index) {
                    final asset = controller.slides[index].imageAsset;
                    // On wide screens (iPad) the artwork is centred on the
                    // white scaffold background instead of being cropped.
                    return Stack(
                      children: [
                        Positioned.fromRect(
                          rect: imageRect,
                          child: Image.asset(asset, fit: BoxFit.fill),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Obx(() {
                final rect = _buttonRect(
                  imageRect,
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
          );
        },
      ),
    ),
  );

  /// Where the slide artwork is drawn inside [viewport].
  ///
  /// Phones (viewport narrower than the artwork's aspect ratio) keep the
  /// original behaviour: fit the width and anchor to the bottom, cropping the
  /// top. Wider viewports such as iPad fit the height instead and centre the
  /// artwork horizontally, so nothing is cropped.
  Rect _imageRect(Size viewport) {
    final viewportAspect = viewport.width / viewport.height;
    final imageAspect = _imageSize.width / _imageSize.height;
    final scale = viewportAspect <= imageAspect
        ? viewport.width / _imageSize.width
        : viewport.height / _imageSize.height;
    final rendered = _imageSize * scale;
    return Rect.fromLTWH(
      (viewport.width - rendered.width) / 2,
      viewport.height - rendered.height,
      rendered.width,
      rendered.height,
    );
  }

  Rect _buttonRect(Rect imageRect, int page) {
    final source = _imageButtonRects[page.clamp(0, 2)];
    final scale = imageRect.width / _imageSize.width;
    return Rect.fromLTRB(
      imageRect.left + source.left * scale,
      imageRect.top + source.top * scale,
      imageRect.left + source.right * scale,
      imageRect.top + source.bottom * scale,
    );
  }
}
