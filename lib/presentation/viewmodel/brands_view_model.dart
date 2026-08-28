import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/brands_remote_data_source.dart';
import 'package:mobile_hexy/data/models/catalog_brand.dart';

class BrandsViewModel extends BaseViewModel {
  BrandsViewModel(this._remoteDataSource);

  final BrandsRemoteDataSource _remoteDataSource;

  final brands = <CatalogBrand>[].obs;
  final isLoading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadBrands();
  }

  Future<void> loadBrands() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = null;
    try {
      brands.assignAll(await _remoteDataSource.fetchBrands());
    } catch (_) {
      error.value = 'Could not load brands.';
    } finally {
      isLoading.value = false;
    }
  }
}
