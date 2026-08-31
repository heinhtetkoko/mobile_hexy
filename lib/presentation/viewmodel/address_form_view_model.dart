import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/shipping_address_remote_data_source.dart';
import 'package:mobile_hexy/data/models/shipping_address.dart';

class AddressFormViewModel extends BaseViewModel {
  AddressFormViewModel(this._remoteDataSource);
  final ShippingAddressRemoteDataSource _remoteDataSource;
  bool get isEditing => Get.parameters['mode'] == 'edit';
  final addressType = 'Home'.obs;
  final region = RxnString();
  final township = RxnString();
  final isDefault = true.obs;
  final states = <AddressOption>[].obs;
  final cities = <AddressOption>[].obs;
  final isSaving = false.obs;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final buildingController = TextEditingController();
  ShippingAddress? _address;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    setLoading();
    try {
      if (isEditing) {
        final addresses = await _remoteDataSource.fetchAddresses();
        final requestedId = int.tryParse(Get.parameters['id'] ?? '');
        _address =
            addresses.firstWhereOrNull(
              (item) =>
                  requestedId != null ? item.id == requestedId : item.isDefault,
            ) ??
            addresses.firstOrNull;
        _fill(_address);
      }
      states.assignAll(await _remoteDataSource.fetchStates());
      region.value ??= states.firstOrNull?.name;
      final selectedState =
          states.firstWhereOrNull((item) => item.id == _address?.stateId) ??
          states.firstWhereOrNull((item) => item.name == region.value);
      if (selectedState?.id != null) {
        cities.assignAll(
          await _remoteDataSource.fetchCities(selectedState!.id!),
        );
      }
      setSuccess();
    } catch (error) {
      setError(error);
    }
  }

  void _fill(ShippingAddress? value) {
    if (value == null) return;
    nameController.text = value.name;
    phoneController.text = value.phone;
    addressType.value = value.addressType.capitalizeFirst ?? 'Home';
    region.value = value.stateRegion;
    township.value = value.cityTownship;
    streetController.text = value.streetAddress;
    buildingController.text = value.building;
    isDefault.value = value.isDefault;
  }

  Future<void> selectRegion(String? value) async {
    region.value = value;
    township.value = null;
    final selected = states.firstWhereOrNull((item) => item.name == value);
    if (selected?.id == null) return;
    try {
      cities.assignAll(await _remoteDataSource.fetchCities(selected!.id!));
    } catch (error) {
      Get.snackbar(
        'Could not load townships',
        _message(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> save() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        region.value == null ||
        township.value == null ||
        streetController.text.trim().isEmpty) {
      Get.snackbar(
        'Missing information',
        'Please complete all required address fields.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isSaving.value = true;
    try {
      final state = states.firstWhereOrNull(
        (item) => item.name == region.value,
      );
      final body = <String, dynamic>{
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address_type': addressType.value.toLowerCase(),
        'state_region': region.value,
        'city_township': township.value,
        'street_address': streetController.text.trim(),
        'building': buildingController.text.trim(),
        'is_default': isDefault.value,
        'country_id': 145,
        'state_id': state?.id,
      };
      if (isEditing && _address != null) {
        await _remoteDataSource.update(_address!.id, body);
      } else {
        await _remoteDataSource.create(body);
      }
      Get.back(result: true);
      Get.snackbar(
        isEditing ? 'Address updated' : 'Address saved',
        'Your delivery address has been saved.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Could not save address',
        _message(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  String _message(Object error) => error
      .toString()
      .replaceFirst('Exception: ', '')
      .replaceFirst('FormatException: ', '');

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    streetController.dispose();
    buildingController.dispose();
    super.onClose();
  }
}
