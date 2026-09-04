import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/category_products_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/best_sellers_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/home_products_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/new_arrivals_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/brands_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/categories_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/collections_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/wishlist_remote_data_source.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/data/models/catalog_category.dart';
import 'package:mobile_hexy/data/models/catalog_product.dart';
import 'package:mobile_hexy/data/models/product_list_request.dart';
import 'package:mobile_hexy/data/models/home_catalog.dart';
import 'package:mobile_hexy/data/models/catalog_brand.dart';

class ProductListViewModel extends BaseViewModel {
  ProductListViewModel(
    this._remoteDataSource,
    this._bestSellersDataSource,
    this._newArrivalsDataSource,
    this._homeProductsDataSource,
    this._cartRemoteDataSource,
    this._wishlistRemoteDataSource,
    this._collectionsRemoteDataSource,
  );

  final CategoryProductsRemoteDataSource _remoteDataSource;
  final BestSellersRemoteDataSource _bestSellersDataSource;
  final NewArrivalsRemoteDataSource _newArrivalsDataSource;
  final HomeProductsRemoteDataSource _homeProductsDataSource;
  final CartRemoteDataSource _cartRemoteDataSource;
  final WishlistRemoteDataSource _wishlistRemoteDataSource;
  final CollectionsRemoteDataSource _collectionsRemoteDataSource;
  static const pageLimit = 10;

  final query = ''.obs;
  final searching = false.obs;
  final sortLabel = 'Sort by'.obs;
  final pendingSort = 'Default Sorting'.obs;
  final activeFilters = 0.obs;
  final selectedCategory = ''.obs;
  final pendingCategory = ''.obs;
  final selectedBrands = <String>{}.obs;
  final pendingBrands = <String>{}.obs;
  final priceRange = const RangeValues(0, 15000).obs;
  final pendingPriceRange = const RangeValues(0, 15000).obs;
  final inStockOnly = false.obs;
  final pendingInStockOnly = false.obs;
  final filterCategories = <CatalogCategory>[].obs;
  final filterBrands = <CatalogBrand>[].obs;
  final favorites = <String>{}.obs;
  final updatingFavoriteIds = <String>{}.obs;
  final addingToCartIds = <String>{}.obs;
  final products = <CatalogProduct>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasNextPage = false.obs;
  final categoryName = 'Products'.obs;
  int _categoryId = 0;
  int? _collectionId;
  int _page = 1;
  ProductListMode? _mode;
  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();
    _loadFilterOptions();
    _loadWishlistState();
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
        ProductListMode.discountProducts => 'Promo Products',
        ProductListMode.collection => category.collectionName ?? 'Collection',
        ProductListMode.search => 'All Products',
      };
      _collectionId = category.collectionId;
      activeFilters.value = 0;
      if (_mode == ProductListMode.search) {
        query.value = category.query;
        searching.value = true;
        _searchWorker = debounce<String>(
          query,
          (_) => loadProducts(),
          time: const Duration(milliseconds: 400),
        );
      }
      loadProducts();
    } else {
      errorMessage.value = 'No category selected.';
    }
  }

  Future<void> _loadWishlistState() async {
    final token = await Get.find<SecureStorage>().read(
      AppConstants.accessTokenKey,
    );
    if (token == null || token.trim().isEmpty) return;
    try {
      final result = await _wishlistRemoteDataSource.fetchWishlist();
      favorites.assignAll(
        result.items
            .where((item) => item.productId > 0)
            .map((item) => item.productId.toString()),
      );
    } catch (_) {
      // Product browsing remains available if wishlist loading fails.
    }
  }

  Future<void> _loadFilterOptions() async {
    try {
      final results = await Future.wait([
        Get.find<CategoriesRemoteDataSource>().fetchCategories(),
        Get.find<BrandsRemoteDataSource>().fetchBrands(),
      ]);
      filterCategories.assignAll(results[0] as List<CatalogCategory>);
      filterBrands.assignAll(results[1] as List<CatalogBrand>);
    } catch (_) {
      // Product loading remains available if filter metadata cannot be loaded.
    }
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    super.onClose();
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
    if (_mode == ProductListMode.search) return products;
    final value = query.value.trim().toLowerCase();
    return products.where((product) {
      final matchesQuery =
          value.isEmpty || product.name.toLowerCase().contains(value);
      return matchesQuery;
    }).toList();
  }

  Future<void> toggleFavorite(String id) async {
    final productId = int.tryParse(id);
    if (productId == null ||
        productId <= 0 ||
        updatingFavoriteIds.contains(id)) {
      return;
    }
    final token = await Get.find<SecureStorage>().read(
      AppConstants.accessTokenKey,
    );
    if (token == null || token.trim().isEmpty) {
      await Get.toNamed<dynamic>(
        AppRoutes.login,
        arguments: {'returnProductId': productId, 'pendingAction': 'wishlist'},
      );
      return;
    }

    final wasFavorite = favorites.contains(id);
    updatingFavoriteIds.add(id);
    _setFavorite(id, !wasFavorite);
    try {
      await _wishlistRemoteDataSource.toggle(productId);
    } catch (error) {
      _setFavorite(id, wasFavorite);
      if (Get.currentRoute != '/login') {
        Get.snackbar(
          'Could not update wishlist',
          error.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      updatingFavoriteIds.remove(id);
    }
  }

  void _setFavorite(String id, bool favorite) {
    final updated = Set<String>.from(favorites);
    favorite ? updated.add(id) : updated.remove(id);
    favorites.assignAll(updated);
    favorites.refresh();
  }

  Future<void> addToCart(CatalogProduct product) async {
    final productId = int.tryParse(product.id);
    if (productId == null ||
        productId <= 0 ||
        addingToCartIds.contains(product.id)) {
      return;
    }
    addingToCartIds.add(product.id);
    try {
      await _cartRemoteDataSource.addProduct(productId: productId, quantity: 1);
      Get.snackbar(
        'Added to cart',
        product.name,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      if (Get.currentRoute != '/login') {
        Get.snackbar(
          'Could not add to cart',
          error.toString().replaceFirst('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      addingToCartIds.remove(product.id);
    }
  }

  void beginSort() {
    pendingSort.value = sortLabel.value == 'Sort by'
        ? 'Default Sorting'
        : sortLabel.value;
  }

  Future<void> applySort() async {
    sortLabel.value = pendingSort.value == 'Default Sorting'
        ? 'Sort by'
        : pendingSort.value;
    Get.back<void>();
    await loadProducts();
  }

  void beginFilter() {
    pendingCategory.value = selectedCategory.value;
    pendingBrands.assignAll(selectedBrands);
    pendingPriceRange.value = priceRange.value;
    pendingInStockOnly.value = inStockOnly.value;
  }

  void togglePendingBrand(String brand) => pendingBrands.contains(brand)
      ? pendingBrands.remove(brand)
      : pendingBrands.assignAll([brand]);

  void resetPendingFilters() {
    pendingCategory.value = '';
    pendingBrands.clear();
    pendingPriceRange.value = const RangeValues(0, 15000);
    pendingInStockOnly.value = false;
  }

  int get pendingFilterCount =>
      (pendingCategory.value.isEmpty ? 0 : 1) +
      pendingBrands.length +
      (pendingPriceRange.value == const RangeValues(0, 15000) ? 0 : 1) +
      (pendingInStockOnly.value ? 1 : 0);

  Future<void> applyFilters() async {
    selectedCategory.value = pendingCategory.value;
    selectedBrands.assignAll(pendingBrands);
    priceRange.value = pendingPriceRange.value;
    inStockOnly.value = pendingInStockOnly.value;
    activeFilters.value = pendingFilterCount;
    Get.back<void>();
    await loadProducts();
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
      case ProductListMode.discountProducts:
        final result = await _remoteDataSource.fetchDiscountProducts(
          page: page,
          limit: pageLimit,
        );
        return (
          products: result.products,
          page: result.page,
          hasNext: result.hasNext,
        );
      case ProductListMode.collection:
        final collectionId = _collectionId;
        if (collectionId == null || collectionId <= 0) {
          throw const FormatException('Collection information is incomplete.');
        }
        final result = await _collectionsRemoteDataSource.fetchCollection(
          collectionId,
        );
        if (result.name.isNotEmpty) categoryName.value = result.name;
        return (products: result.products, page: 1, hasNext: false);
      case ProductListMode.search:
        final selectedCategoryId = filterCategories
            .firstWhereOrNull((item) => item.name == selectedCategory.value)
            ?.id;
        final selectedBrandId = filterBrands
            .firstWhereOrNull((item) => selectedBrands.contains(item.name))
            ?.id;
        final result = await _remoteDataSource.fetchAllProducts(
          query: query.value.trim(),
          categoryId: selectedCategoryId,
          brandId: selectedBrandId,
          minPrice: priceRange.value.start <= 0 ? null : priceRange.value.start,
          maxPrice: priceRange.value.end >= 15000 ? null : priceRange.value.end,
          inStock: inStockOnly.value ? true : null,
          sort: _sortValue,
          page: page,
          limit: pageLimit,
        );
        return (
          products: result.products,
          page: result.page,
          hasNext: result.hasNext,
        );
    }
  }

  String get _sortValue => switch (sortLabel.value) {
    'Popular' => 'popular',
    'New Arrivals' => 'new_arrivals',
    'Price: Low to High' => 'price_asc',
    'Price: High to Low' => 'price_desc',
    'Biggest Discount' => 'highest_discount',
    'A–Z' => 'name',
    _ => 'default',
  };

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
              discount:
                  product.discountPercent != null &&
                      product.discountPercent! > 0
                  ? '-${_formatDiscount(product.discountPercent!)}%'
                  : null,
            ),
          )
          .toList(growable: false),
      page: page,
      hasNext: hasNext,
    );
  }

  String _formatDiscount(double value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
}
