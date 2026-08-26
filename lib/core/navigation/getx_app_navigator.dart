import 'package:get/get.dart';
import 'package:mobile_hexy/core/navigation/app_navigator.dart';

class GetXAppNavigator implements AppNavigator {
  @override
  void replaceWith(String route) => Get.offNamed(route);
  @override
  void clearAndNavigate(String route) => Get.offAllNamed(route);
}
