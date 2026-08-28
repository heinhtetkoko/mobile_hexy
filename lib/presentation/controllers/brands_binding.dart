import 'package:get/get.dart';
import 'package:mobile_hexy/data/datasources/brands_remote_data_source.dart';
import 'package:mobile_hexy/presentation/viewmodel/brands_view_model.dart';

class BrandsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BrandsViewModel(Get.find<BrandsRemoteDataSource>()));
  }
}
