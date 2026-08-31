import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/checkout_view_model.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CartViewModel>()) {
      Get.put(CartViewModel(Get.find()), permanent: true);
    }
    Get.lazyPut(() => CheckoutViewModel(Get.find()));
  }
}
