import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/product_list_view_model.dart';

class ProductListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ProductListViewModel(
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
      ),
    );
  }
}
