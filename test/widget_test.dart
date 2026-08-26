import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/app.dart';
import 'package:mobile_hexy/app/routes/app_pages.dart';
import 'package:mobile_hexy/app/routes/app_routes.dart';
import 'package:mobile_hexy/presentation/view/stationery_home_page.dart';
import 'package:mobile_hexy/presentation/view/onboarding_page.dart';
import 'package:mobile_hexy/presentation/view/splash_page.dart';
import 'package:mobile_hexy/injection/dependency_injection.dart';

void main() {
  setUp(Get.reset);

  testWidgets('shows splash for three seconds before onboarding', (
    tester,
  ) async {
    await tester.pumpWidget(const HexyApp());
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingPage), findsOneWidget);
  });

  testWidgets('opens stationery home after Get Started', (tester) async {
    await tester.pumpWidget(_testApp(AppRoutes.onboarding));

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
    }

    expect(find.byType(StationeryHomePage), findsOneWidget);
  });

  testWidgets('updates the selected bottom navigation tab', (tester) async {
    await tester.pumpWidget(_testApp(AppRoutes.home));

    expect(find.byKey(const Key('active-tab-home')), findsOneWidget);

    await tester.tap(find.byKey(const Key('bottom-nav-cart')));
    await tester.pump();

    expect(find.byKey(const Key('active-tab-cart')), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
  });
}

Widget _testApp(String initialRoute) {
  return GetMaterialApp(
    initialBinding: DependencyInjection(),
    initialRoute: initialRoute,
    getPages: AppPages.pages,
  );
}
