import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/services/app_config.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/secure_storage_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0x00000000),
      systemNavigationBarDividerColor: Color(0x00000000),
      systemNavigationBarContrastEnforced: false,
    ),
  );
  AppConfig.initialize(environment: AppEnvironment.development);

  const storage = SecureStorageImpl(FlutterSecureStorage());
  final savedTheme = await storage.read(AppConstants.themeModeKey);
  final savedLanguage = await storage.read(AppConstants.languageCodeKey);
  final themeMode = switch (savedTheme) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };
  final locale = savedLanguage == 'my'
      ? const Locale('my', 'MM')
      : const Locale('en', 'US');

  runApp(HexyApp(initialThemeMode: themeMode, initialLocale: locale));
}
