import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/order_detail_view_model.dart';

class OrderDetailBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => OrderDetailViewModel(Get.find()));
}
