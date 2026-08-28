import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/categories_view_model.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CategoriesViewModel(Get.find()));
  }
}
