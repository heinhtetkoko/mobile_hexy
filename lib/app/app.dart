import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/routes/app_pages.dart';
import 'package:mobile_hexy/app/routes/app_routes.dart';
import 'package:mobile_hexy/app/theme/app_theme.dart';
import 'package:mobile_hexy/injection/dependency_injection.dart';
import 'package:mobile_hexy/app/localization/app_translations.dart';

class HexyApp extends StatelessWidget {
  const HexyApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    title: 'Hexy Megastore',
    debugShowCheckedModeBanner: false,
    initialBinding: DependencyInjection(),
    initialRoute: AppRoutes.splash,
    getPages: AppPages.pages,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.system,
    translations: AppTranslations(),
    locale: const Locale('en', 'US'),
    fallbackLocale: const Locale('en', 'US'),
  );
}
