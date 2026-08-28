import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/services/app_config.dart';

void main() {
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
  runApp(const HexyApp());
}
