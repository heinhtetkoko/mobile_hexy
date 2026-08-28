import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/categories_remote_data_source.dart';
import 'package:mobile_hexy/data/models/catalog_category.dart';

class CategoriesViewModel extends BaseViewModel {
  CategoriesViewModel(this._remoteDataSource);

  final CategoriesRemoteDataSource _remoteDataSource;
  final selectedIndex = 0.obs;
  final categories = <CatalogCategory>[].obs;
  final subcategories = <CatalogCategory>[].obs;
  final isLoading = false.obs;
  final isSubcategoriesLoading = false.obs;
  String? _pendingCategoryName;

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
      if (result.isNotEmpty && _pendingCategoryName != null) {
        final pendingName = _pendingCategoryName!;
        _pendingCategoryName = null;
        await selectCategoryByName(pendingName);
      } else if (result.isNotEmpty) {
        await selectCategory(0);
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

  Future<void> selectCategoryByName(String name) async {
    if (categories.isEmpty) {
      _pendingCategoryName = name;
      if (!isLoading.value) await loadCategories();
      return;
    }

    final target = _normalize(name);
    var index = categories.indexWhere(
      (category) => _normalize(category.name) == target,
    );
    if (index < 0) {
      index = categories.indexWhere((category) {
        final candidate = _normalize(category.name);
        return candidate.contains(target) || target.contains(candidate);
      });
    }
    if (index >= 0) await selectCategory(index);
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

  String _normalize(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (normalized.endsWith('ies')) {
      return '${normalized.substring(0, normalized.length - 3)}y';
    }
    return normalized.replaceFirst(RegExp(r's$'), '');
  }
}
