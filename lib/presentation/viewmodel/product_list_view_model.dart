import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/category_products_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/best_sellers_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/home_products_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/new_arrivals_remote_data_source.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/data/models/catalog_category.dart';
import 'package:mobile_hexy/data/models/catalog_product.dart';
import 'package:mobile_hexy/data/models/product_list_request.dart';
import 'package:mobile_hexy/data/models/home_catalog.dart';

class ProductListViewModel extends BaseViewModel {
  ProductListViewModel(
    this._remoteDataSource,
    this._bestSellersDataSource,
    this._newArrivalsDataSource,
    this._homeProductsDataSource,
  );

  final CategoryProductsRemoteDataSource _remoteDataSource;
  final BestSellersRemoteDataSource _bestSellersDataSource;
  final NewArrivalsRemoteDataSource _newArrivalsDataSource;
  final HomeProductsRemoteDataSource _homeProductsDataSource;
  static const pageLimit = 10;

  final query = ''.obs;
  final searching = false.obs;
  final sortLabel = 'Sort by'.obs;
  final pendingSort = 'Default Sorting'.obs;
  final activeFilters = 3.obs;
  final selectedCategory = ''.obs;
  final pendingCategory = ''.obs;
  final selectedBrands = <String>{}.obs;
  final pendingBrands = <String>{}.obs;
  final priceRange = const RangeValues(1000, 10000).obs;
  final pendingPriceRange = const RangeValues(1000, 10000).obs;
  final favorites = <String>{}.obs;
  final products = <CatalogProduct>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasNextPage = false.obs;
  final categoryName = 'Products'.obs;
  int _categoryId = 0;
  int _page = 1;
  ProductListMode? _mode;

  @override
  void onInit() {
    super.onInit();
    final category = Get.arguments;
    if (category is CatalogCategory) {
      _categoryId = category.id;
      categoryName.value = category.name;
      selectedCategory.value = category.name;
      pendingCategory.value = category.name;
      loadProducts();
    } else if (category is ProductListRequest) {
      _mode = category.mode;
      categoryName.value = switch (category.mode) {
        ProductListMode.bestSellers => 'Best Sellers',
        ProductListMode.newArrivals => 'New Arrivals',
        ProductListMode.flashSale => 'Flash Sale',
        ProductListMode.recommended => 'Recommended For You',
      };
      activeFilters.value = 0;
      loadProducts();
    } else {
      errorMessage.value = 'No category selected.';
    }
  }

  Future<void> loadProducts() async {
    if (_categoryId <= 0 && _mode == null) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _fetchPage(1);
      products.assignAll(result.products);
      _page = result.page;
      hasNextPage.value = result.hasNext;
    } catch (_) {
      errorMessage.value = 'Could not load products. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /*
  final sampleProducts = const [
    CatalogProduct(
      id: '1',
      name: 'Pilot G-2 Gel Pen 0.7mm Blue',
      price: '2,100 Ks',
      imageAsset: 'assets/images/product_list/product_01.png',
    ),
    CatalogProduct(
      id: '2',
      name: 'Zebra Sarasa Clip 0.5mm Black',
      price: '1,800 Ks',
      originalPrice: '2,200 Ks',
      imageAsset: 'assets/images/product_list/product_02.png',
    ),
    CatalogProduct(
      id: '3',
      name: 'Staedtler Triplus Fineliner Set',
      price: '8,500 Ks',
      originalPrice: '10,000 Ks',
      discount: '-15%',
      imageAsset: 'assets/images/product_list/product_03.png',
    ),
    CatalogProduct(
      id: '4',
      name: 'Faber-Castell Grip Pen Set',
      price: '12,000 Ks',
      imageAsset: 'assets/images/product_list/product_04.png',
    ),
    CatalogProduct(
      id: '5',
      name: 'Pentel EnerGel 0.5mm',
      price: '1,500 Ks',
      originalPrice: '1,800 Ks',
      discount: '-17%',
      imageAsset: 'assets/images/product_list/product_05.png',
    ),
    CatalogProduct(
      id: '6',
      name: 'Uni-ball Signo 207 Retractable',
      price: '1,900 Ks',
      originalPrice: '2,200 Ks',
      discount: '-14%',
      imageAsset: 'assets/images/product_list/product_06.png',
    ),
    CatalogProduct(
      id: '7',
      name: 'Deli Mechanical Pencil 0.5mm',
      price: '1,500 Ks',
      imageAsset: 'assets/images/product_list/product_07.png',
    ),
    CatalogProduct(
      id: '8',
      name: 'Staedtler 2B Pencil Set 12pcs',
      price: '4,500 Ks',
      discount: '-18%',
      imageAsset: 'assets/images/product_list/product_08.png',
    ),
    CatalogProduct(
      id: '9',
      name: 'MICRON Pigment Pen Set',
      price: '5,800 Ks',
      imageAsset: 'assets/images/product_list/product_09.png',
    ),
    CatalogProduct(
      id: '10',
      name: 'Faber-Castell Colour Set 24',
      price: '11,500 Ks',
      originalPrice: '13,500 Ks',
      discount: '-15%',
      imageAsset: 'assets/images/product_list/product_10.png',
    ),
    CatalogProduct(
      id: '11',
      name: 'Zebra Fountain Pen Zensation',
      price: '4,200 Ks',
      originalPrice: '5,000 Ks',
      discount: '-16%',
      imageAsset: 'assets/images/product_list/product_11.png',
    ),
    CatalogProduct(
      id: '12',
      name: 'Pentel Brush Sign Pen Artist',
      price: '2,800 Ks',
      originalPrice: '3,500 Ks',
      discount: '-20%',
      imageAsset: 'assets/images/product_list/product_12.png',
    ),
  ];
  */

  List<CatalogProduct> get filteredProducts {
    final value = query.value.trim().toLowerCase();
    return products.where((product) {
      final matchesQuery =
          value.isEmpty || product.name.toLowerCase().contains(value);
      return matchesQuery;
    }).toList();
  }

  void toggleFavorite(String id) =>
      favorites.contains(id) ? favorites.remove(id) : favorites.add(id);

  void addToCart(CatalogProduct product) => Get.snackbar(
    'Added to cart',
    product.name,
    snackPosition: SnackPosition.BOTTOM,
  );

  void beginSort() {
    pendingSort.value = sortLabel.value == 'Sort by'
        ? 'Default Sorting'
        : sortLabel.value;
  }

  void applySort() {
    sortLabel.value = pendingSort.value == 'Default Sorting'
        ? 'Sort by'
        : pendingSort.value;
    Get.back<void>();
  }

  void beginFilter() {
    pendingCategory.value = selectedCategory.value;
    pendingBrands.assignAll(selectedBrands);
    pendingPriceRange.value = priceRange.value;
  }

  void togglePendingBrand(String brand) => pendingBrands.contains(brand)
      ? pendingBrands.remove(brand)
      : pendingBrands.add(brand);

  void resetPendingFilters() {
    pendingCategory.value = '';
    pendingBrands.clear();
    pendingPriceRange.value = const RangeValues(0, 15000);
  }

  int get pendingFilterCount =>
      (pendingCategory.value.isEmpty ? 0 : 1) + pendingBrands.length;

  void applyFilters() {
    selectedCategory.value = pendingCategory.value;
    selectedBrands.assignAll(pendingBrands);
    priceRange.value = pendingPriceRange.value;
    activeFilters.value = pendingFilterCount;
    Get.back<void>();
  }

  Future<void> loadMore() async {
    if ((_categoryId <= 0 && _mode == null) ||
        !hasNextPage.value ||
        isLoadingMore.value) {
      return;
    }
    isLoadingMore.value = true;
    try {
      final result = await _fetchPage(_page + 1);
      products.addAll(result.products);
      _page = result.page;
      hasNextPage.value = result.hasNext;
    } catch (_) {
      Get.snackbar(
        'Could not load products',
        'Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<({List<CatalogProduct> products, int page, bool hasNext})> _fetchPage(
    int page,
  ) async {
    if (_mode == null) {
      final result = await _remoteDataSource.fetchProducts(
        categoryId: _categoryId,
        page: page,
        limit: pageLimit,
      );
      return (
        products: result.products,
        page: result.page,
        hasNext: result.hasNext,
      );
    }

    switch (_mode!) {
      case ProductListMode.bestSellers:
        final result = await _bestSellersDataSource.fetch(
          page: page,
          limit: pageLimit,
        );
        return _catalogResult(result.products, result.page, result.hasNext);
      case ProductListMode.newArrivals:
        final result = await _newArrivalsDataSource.fetch(
          page: page,
          limit: pageLimit,
        );
        return _catalogResult(result.products, result.page, result.hasNext);
      case ProductListMode.flashSale:
        final result = await _homeProductsDataSource.fetch(
          path: ApiEndpoints.flashSale,
          programType: '',
          page: page,
          limit: pageLimit,
        );
        return _catalogResult(result.products, result.page, result.hasNext);
      case ProductListMode.recommended:
        final result = await _homeProductsDataSource.fetch(
          path: ApiEndpoints.recommendedProducts,
          page: page,
          limit: pageLimit,
        );
        return _catalogResult(result.products, result.page, result.hasNext);
    }
  }

  ({List<CatalogProduct> products, int page, bool hasNext}) _catalogResult(
    List<HomeProduct> products,
    int page,
    bool hasNext,
  ) {
    return (
      products: products
          .map(
            (product) => CatalogProduct(
              id: product.id,
              name: product.name,
              price: product.price,
              imageAsset: product.imageAsset,
              imageUrl: product.imageUrl,
            ),
          )
          .toList(growable: false),
      page: page,
      hasNext: hasNext,
    );
  }
}
