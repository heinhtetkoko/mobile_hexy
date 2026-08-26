import 'package:get/get.dart';
import 'package:mobile_hexy/data/datasources/product_detail_remote_data_source.dart';
import 'package:mobile_hexy/domain/entities/product_detail.dart';

class ProductDetailViewModel extends GetxController {
  ProductDetailViewModel(this._remoteDataSource);

  final ProductDetailRemoteDataSource _remoteDataSource;
  final selectedImage = 0.obs;
  final selectedVariantId = RxnInt();
  final quantity = 1.obs;
  final isFavorite = false.obs;
  final product = Rxn<ProductDetail>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

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
      selectedVariantId.value = result.variants.isEmpty
          ? null
          : result.variants.first.id;
    } catch (_) {
      errorMessage.value = 'Could not load product details. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void increment() => quantity.value++;
  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }
}
