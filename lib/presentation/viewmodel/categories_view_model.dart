import 'package:get/get.dart';
import 'package:mobile_hexy/data/datasources/categories_remote_data_source.dart';
import 'package:mobile_hexy/domain/entities/catalog_category.dart';

class CategoriesViewModel extends GetxController {
  CategoriesViewModel(this._remoteDataSource);

  final CategoriesRemoteDataSource _remoteDataSource;
  final selectedIndex = 0.obs;
  final categories = <CatalogCategory>[].obs;
  final subcategories = <CatalogCategory>[].obs;
  final isLoading = false.obs;
  final isSubcategoriesLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _remoteDataSource.fetchCategories();
      categories.assignAll(result);
      selectedIndex.value = 0;
      if (result.isNotEmpty) {
        await _loadSubcategories(result.first);
      } else {
        subcategories.clear();
      }
    } catch (_) {
      errorMessage.value = 'Could not load categories. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectCategory(int index) async {
    if (index < 0 || index >= categories.length) return;
    selectedIndex.value = index;
    await _loadSubcategories(categories[index]);
  }

  Future<void> _loadSubcategories(CatalogCategory category) async {
    subcategories.clear();
    if (!category.hasChildren || category.next.isEmpty) return;
    isSubcategoriesLoading.value = true;
    try {
      final result = await _remoteDataSource.fetchCategories(
        path: category.next,
      );
      if (_isSelected(category)) subcategories.assignAll(result);
    } catch (_) {
      if (_isSelected(category)) subcategories.clear();
    } finally {
      if (_isSelected(category)) isSubcategoriesLoading.value = false;
    }
  }

  bool _isSelected(CatalogCategory category) =>
      categories.length > selectedIndex.value &&
      categories[selectedIndex.value].id == category.id;
}
