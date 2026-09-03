import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';

class CheckoutViewModel extends BaseViewModel {
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
    Get.offNamed<dynamic>(AppRoutes.paymentSuccess);
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
