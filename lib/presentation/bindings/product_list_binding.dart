import 'package:get/get.dart';
import 'package:mobile_hexy/data/datasources/category_products_remote_data_source.dart';
import 'package:mobile_hexy/presentation/viewmodel/product_list_view_model.dart';

class ProductListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CategoryProductsRemoteDataSource(Get.find()));
    Get.lazyPut(() => ProductListViewModel(Get.find()));
  }
}
