import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/my_orders_view_model.dart';

class MyOrdersBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => MyOrdersViewModel(Get.find()));
}
