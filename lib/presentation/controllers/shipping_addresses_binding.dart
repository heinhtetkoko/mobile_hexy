import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/shipping_addresses_view_model.dart';

class ShippingAddressesBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut(() => ShippingAddressesViewModel(Get.find()));
}
