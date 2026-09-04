import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/services/asset_paths.dart';
import 'package:mobile_hexy/presentation/viewmodel/splash_view_model.dart';

class SplashPage extends GetView<SplashViewModel> {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) => GetBuilder<SplashViewModel>(
    builder: (_) => Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage(AssetPaths.splashBackground),
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: const IntrinsicHeight(
                    child: Column(
                      children: [
                        Spacer(flex: 3),
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          child: Image(
                            image: AssetImage(AssetPaths.appLogo),
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 28),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'HEXY MEGASTORE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .4,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Everything for School, Office & Creativity',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFD5D2E4),
                              fontSize: 17,
                              height: 1.2,
                            ),
                          ),
                        ),
                        Spacer(flex: 2),
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Preparing your workspace...',
                          style: TextStyle(
                            color: Color(0xFFAAA6C1),
                            fontSize: 15,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: Color(0xFFAAA6C1),
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '© 2026 StationeryHub. All rights reserved.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFAAA6C1),
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
