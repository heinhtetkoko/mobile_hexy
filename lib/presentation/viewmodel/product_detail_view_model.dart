import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/product_detail_remote_data_source.dart';
import 'package:mobile_hexy/data/models/product_detail.dart';

class ProductDetailViewModel extends BaseViewModel {
  ProductDetailViewModel(this._remoteDataSource);

  final ProductDetailRemoteDataSource _remoteDataSource;
  final selectedImage = 0.obs;
  final selectedVariantId = RxnInt();
  final selectedVariantValues = <String, int>{}.obs;
  final quantity = 1.obs;
  final isFavorite = false.obs;
  final product = Rxn<ProductDetail>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProduct();
  }

  Future<void> loadProduct() async {
    final id = int.tryParse(Get.arguments?.toString() ?? '');
    if (id == null || id <= 0) {
      errorMessage.value = 'No product selected.';
      return;
    }
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _remoteDataSource.fetch(id);
      product.value = result;
      selectedImage.value = 0;
      final variantValues = result.variantSections.expand(
        (section) => section.values,
      );
      final selectedValues = variantValues.where((value) => value.selected);
      selectedVariantId.value = selectedValues.isNotEmpty
          ? selectedValues.first.variantId
          : variantValues.isEmpty
          ? null
          : variantValues.first.variantId;
      selectedVariantValues.assignAll({
        for (final section in result.variantSections)
          if (section.values.any((value) => value.available))
            section.key:
                section.values
                    .firstWhereOrNull(
                      (value) => value.selected && value.available,
                    )
                    ?.id ??
                section.values.firstWhere((value) => value.available).id,
      });
      quantity.value = result.defaultQuantity;
      isFavorite.value = result.wishlist;
    } catch (_) {
      errorMessage.value = 'Could not load product details. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void increment() {
    final detail = product.value;
    if (detail == null) return;
    final next = quantity.value + detail.quantityStep;
    if (next <= detail.quantityMax) quantity.value = next;
  }

  void decrement() {
    final detail = product.value;
    if (detail == null) return;
    final next = quantity.value - detail.quantityStep;
    if (next >= detail.quantityMin) quantity.value = next;
  }

  void selectVariantValue(String sectionKey, ProductVariantValue value) {
    if (!value.available) return;
    selectedVariantValues[sectionKey] = value.id;
    if (value.variantId != null) selectedVariantId.value = value.variantId;
  }
}
