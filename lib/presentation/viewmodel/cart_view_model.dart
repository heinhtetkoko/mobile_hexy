import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/data/models/cart_item.dart';

class CartViewModel extends BaseViewModel {
  final items = <CartItem>[
    const CartItem(
      id: 'STA-1001',
      name: 'Notebook A5 Premium',
      sku: 'STA-1001',
      variant: 'Blue',
      variantColor: 0xFF1E3A8A,
      unitPrice: 8500,
      quantity: 2,
      imageAsset: 'assets/images/cart/notebook.png',
    ),
    const CartItem(
      id: 'PIL-G2-12',
      name: 'Pilot G-2 Gel Pen 12pk',
      sku: 'PIL-G2-12',
      variant: 'Black',
      variantColor: 0xFF111827,
      unitPrice: 15000,
      quantity: 1,
      imageAsset: 'assets/images/cart/gel_pens.png',
    ),
    const CartItem(
      id: 'STD-FL10',
      name: 'Staedtler Fineliner Set',
      sku: 'STD-FL10',
      variant: 'Mixed',
      variantColor: 0xFFDB2777,
      unitPrice: 8500,
      quantity: 1,
      imageAsset: 'assets/images/cart/fineliner_set.png',
    ),
    const CartItem(
      id: 'HP-A4-80',
      name: 'HP A4 Paper 500sh',
      sku: 'HP-A4-80',
      variant: 'White',
      variantColor: 0xFFE5E7EB,
      unitPrice: 4500,
      quantity: 2,
      imageAsset: 'assets/images/cart/a4_paper.png',
    ),
  ].obs;

  final couponController = TextEditingController();
  final couponApplied = true.obs;
  final deliverySelected = true.obs;

  int get subtotal =>
      items.fold(0, (sum, item) => sum + (item.unitPrice * item.quantity));
  int get shipping => deliverySelected.value ? 3000 : 0;
  int get discount => couponApplied.value ? (subtotal * .10).round() : 0;
  int get grandTotal => subtotal + shipping - discount;

  void increment(CartItem item) => _setQuantity(item, item.quantity + 1);

  void decrement(CartItem item) {
    if (item.quantity > 1) _setQuantity(item, item.quantity - 1);
  }

  void _setQuantity(CartItem item, int quantity) {
    final index = items.indexWhere((entry) => entry.id == item.id);
    if (index >= 0) items[index] = item.copyWith(quantity: quantity);
  }

  void remove(CartItem item) =>
      items.removeWhere((entry) => entry.id == item.id);

  void applyCoupon() {
    couponApplied.value = couponController.text.trim().isNotEmpty;
    Get.snackbar(
      couponApplied.value ? 'Coupon applied' : 'Enter a coupon',
      couponApplied.value
          ? 'Your 10% discount is active.'
          : 'Add a code first.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void checkout() => Get.toNamed<void>(AppRoutes.checkout);

  @override
  void onClose() {
    couponController.dispose();
    super.onClose();
  }
}
