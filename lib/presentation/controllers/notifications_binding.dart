import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/notifications_view_model.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => NotificationsViewModel(Get.find()));
}
