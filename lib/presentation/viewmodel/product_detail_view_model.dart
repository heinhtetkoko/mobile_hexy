import 'package:get/get.dart';

class ProductDetailViewModel extends GetxController {
  final selectedImage = 0.obs;
  final selectedColor = 'Blue'.obs;
  final selectedInkType = 'Gel Ink'.obs;
  final quantity = 1.obs;
  final isFavorite = false.obs;

  final gallery = const [
    'assets/images/product_detail/main.png',
    'assets/images/product_detail/thumb_1.png',
    'assets/images/product_detail/thumb_2.png',
    'assets/images/product_detail/thumb_3.png',
    'assets/images/product_detail/thumb_4.png',
  ];

  void increment() => quantity.value++;
  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }
}
