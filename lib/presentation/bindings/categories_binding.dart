import 'package:get/get.dart';
import 'package:mobile_hexy/data/datasources/categories_remote_data_source.dart';
import 'package:mobile_hexy/presentation/viewmodel/categories_view_model.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CategoriesRemoteDataSource(Get.find()));
    Get.lazyPut(() => CategoriesViewModel(Get.find()));
  }
}
