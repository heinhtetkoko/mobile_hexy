import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/address_form_view_model.dart';

class AddressFormBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(AddressFormViewModel.new);
}
