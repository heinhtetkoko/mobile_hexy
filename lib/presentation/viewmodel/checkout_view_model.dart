import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/routes/app_routes.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';

class CheckoutViewModel extends GetxController {
  CheckoutViewModel(this.cart);

  final CartViewModel cart;
  final selectedPayment = 'Cash on Delivery'.obs;
  final termsAccepted = true.obs;
  final itemsExpanded = false.obs;
  final notesController = TextEditingController();

  void selectPayment(String payment) => selectedPayment.value = payment;

  void placeOrder() {
    if (!termsAccepted.value) {
      Get.snackbar(
        'Agreement required',
        'Please accept the Terms & Conditions and Privacy Policy.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.offNamed<void>(AppRoutes.paymentSuccess);
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
