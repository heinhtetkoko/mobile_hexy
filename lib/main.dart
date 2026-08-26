import 'package:flutter/widgets.dart';
import 'package:mobile_hexy/app/app.dart';
import 'package:mobile_hexy/app/config/app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initialize(environment: AppEnvironment.development);
  runApp(const HexyApp());
}
