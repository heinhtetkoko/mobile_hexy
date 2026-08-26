import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AddressFormViewModel extends GetxController {
  bool get isEditing => Get.parameters['mode'] == 'edit';

  final addressType = 'Home'.obs;
  final region = 'Yangon Region'.obs;
  final township = RxnString();
  final isDefault = true.obs;
  final streetController = TextEditingController(text: 'No.25, Main Street');
  final buildingController = TextEditingController(text: 'Block A, Floor 3');

  static const regions = ['Yangon Region', 'Mandalay Region', 'Naypyidaw'];
  static const townships = [
    'Sanchaung Township',
    'Kamayut Township',
    'Bahan Township',
    'Hlaing Township',
  ];

  @override
  void onInit() {
    if (isEditing) township.value = 'Sanchaung Township';
    super.onInit();
  }

  void save() {
    if (township.value == null || streetController.text.trim().isEmpty) {
      Get.snackbar(
        'Missing information',
        'Please select a township and enter a street address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.back<Map<String, Object?>>(
      result: {
        'type': addressType.value,
        'region': region.value,
        'township': township.value,
        'street': streetController.text.trim(),
        'building': buildingController.text.trim(),
        'isDefault': isDefault.value,
      },
    );
    Get.snackbar(
      isEditing ? 'Address updated' : 'Address saved',
      'Your delivery address has been saved.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    streetController.dispose();
    buildingController.dispose();
    super.onClose();
  }
}
