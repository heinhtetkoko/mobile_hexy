import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/product_detail_view_model.dart';

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(ProductDetailViewModel.new);
}
