import 'package:get/get.dart';
import 'package:mobile_hexy/data/datasources/product_detail_remote_data_source.dart';
import 'package:mobile_hexy/presentation/viewmodel/product_detail_view_model.dart';

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductDetailRemoteDataSource(Get.find()));
    Get.lazyPut(() => ProductDetailViewModel(Get.find()));
  }
}
