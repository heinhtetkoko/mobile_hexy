import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/shipping_address_remote_data_source.dart';
import 'package:mobile_hexy/data/models/shipping_address.dart';

class ShippingAddressesViewModel extends BaseViewModel {
  ShippingAddressesViewModel(this._remoteDataSource);
  final ShippingAddressRemoteDataSource _remoteDataSource;
  final addresses = <ShippingAddress>[].obs;
  final deletingId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    setLoading();
    try {
      addresses.assignAll(await _remoteDataSource.fetchAddresses());
      setSuccess();
    } catch (error) {
      setError(error);
    }
  }

  Future<void> addNew() async {
    final saved = await Get.toNamed<dynamic>(
      '${AppRoutes.addressForm}?mode=new',
    );
    if (saved == true) await loadAddresses();
  }

  Future<void> edit(ShippingAddress address) async {
    final saved = await Get.toNamed<dynamic>(
      '${AppRoutes.addressForm}?mode=edit&id=${address.id}',
    );
    if (saved == true) await loadAddresses();
  }

  Future<void> confirmDelete(ShippingAddress address) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete address?'),
        content: Text('Remove ${address.name} from your shipping addresses?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    deletingId.value = address.id;
    try {
      await _remoteDataSource.delete(address.id);
      addresses.removeWhere((item) => item.id == address.id);
      Get.snackbar(
        'Address deleted',
        'The shipping address was removed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Could not delete address',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      deletingId.value = null;
    }
  }
}
