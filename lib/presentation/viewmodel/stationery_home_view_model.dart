import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/best_sellers_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/brands_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/categories_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/home_products_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/new_arrivals_remote_data_source.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/data/models/home_catalog.dart';
import 'package:mobile_hexy/data/models/catalog_brand.dart';
import 'package:mobile_hexy/data/models/catalog_category.dart';
import 'package:mobile_hexy/domain/usecases/get_home_catalog.dart';

class StationeryHomeViewModel extends BaseViewModel {
  StationeryHomeViewModel(
    this._getHomeCatalog,
    this._bestSellersDataSource,
    this._newArrivalsDataSource,
    this._homeProductsDataSource,
    this._categoriesDataSource,
    this._brandsDataSource,
  );

  final GetHomeCatalog _getHomeCatalog;
  final BestSellersRemoteDataSource _bestSellersDataSource;
  final NewArrivalsRemoteDataSource _newArrivalsDataSource;
  final HomeProductsRemoteDataSource _homeProductsDataSource;
  final CategoriesRemoteDataSource _categoriesDataSource;
  final BrandsRemoteDataSource _brandsDataSource;
  final activeBanner = 0.obs;
  final searchQuery = ''.obs;
  final bannerController = PageController(viewportFraction: .94);
  late final HomeCatalog catalog;
  final homeCategories = <CatalogCategory>[].obs;
  final isCategoriesLoading = false.obs;
  final categoriesError = RxnString();
  final brands = <CatalogBrand>[].obs;
  final isBrandsLoading = false.obs;
  final brandsError = RxnString();
  final bestSellers = <HomeProduct>[].obs;
  final isBestSellersLoading = false.obs;
  final isBestSellersLoadingMore = false.obs;
  final bestSellersError = RxnString();
  final hasMoreBestSellers = false.obs;
  static const bestSellersPageLimit = 10;
  int _bestSellersPage = 1;
  final newArrivals = <HomeProduct>[].obs;
  final isNewArrivalsLoading = false.obs;
  final isNewArrivalsLoadingMore = false.obs;
  final newArrivalsError = RxnString();
  final hasMoreNewArrivals = false.obs;
  static const newArrivalsPageLimit = 10;
  int _newArrivalsPage = 1;
  final flashSaleProducts = <HomeProduct>[].obs;
  final isFlashSaleLoading = false.obs;
  final isFlashSaleLoadingMore = false.obs;
  final flashSaleError = RxnString();
  final hasMoreFlashSale = false.obs;
  int _flashSalePage = 1;
  final recommendedProducts = <HomeProduct>[].obs;
  final isRecommendedLoading = false.obs;
  final isRecommendedLoadingMore = false.obs;
  final recommendedError = RxnString();
  final hasMoreRecommended = false.obs;
  int _recommendedPage = 1;
  static const remoteProductPageLimit = 10;

  @override
  void onInit() {
    super.onInit();
    catalog = _getHomeCatalog();
    loadCategories();
    loadBrands();
    loadBestSellers();
    loadNewArrivals();
    loadFlashSale();
    loadRecommendedProducts();
  }

  Future<void> loadCategories() async {
    isCategoriesLoading.value = true;
    categoriesError.value = null;
    try {
      homeCategories.assignAll(await _categoriesDataSource.fetchCategories());
    } catch (_) {
      categoriesError.value = 'Could not load categories.';
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> loadBrands() async {
    isBrandsLoading.value = true;
    brandsError.value = null;
    try {
      brands.assignAll(await _brandsDataSource.fetchBrands());
    } catch (_) {
      brandsError.value = 'Could not load brands.';
    } finally {
      isBrandsLoading.value = false;
    }
  }

  Future<void> loadFlashSale() async {
    isFlashSaleLoading.value = true;
    flashSaleError.value = null;
    try {
      final result = await _homeProductsDataSource.fetch(
        path: ApiEndpoints.flashSale,
        programType: '',
        page: 1,
        limit: remoteProductPageLimit,
      );
      flashSaleProducts.assignAll(result.products);
      _flashSalePage = result.page;
      hasMoreFlashSale.value = result.hasNext;
    } catch (_) {
      flashSaleError.value = 'Could not load flash sale.';
    } finally {
      isFlashSaleLoading.value = false;
    }
  }

  Future<void> loadMoreFlashSale() async {
    if (!hasMoreFlashSale.value || isFlashSaleLoadingMore.value) return;
    isFlashSaleLoadingMore.value = true;
    try {
      final result = await _homeProductsDataSource.fetch(
        path: ApiEndpoints.flashSale,
        programType: '',
        page: _flashSalePage + 1,
        limit: remoteProductPageLimit,
      );
      flashSaleProducts.addAll(result.products);
      _flashSalePage = result.page;
      hasMoreFlashSale.value = result.hasNext;
    } catch (_) {
      Get.snackbar('Could not load flash sale', 'Please try again.');
    } finally {
      isFlashSaleLoadingMore.value = false;
    }
  }

  Future<void> loadRecommendedProducts() async {
    isRecommendedLoading.value = true;
    recommendedError.value = null;
    try {
      final result = await _homeProductsDataSource.fetch(
        path: ApiEndpoints.recommendedProducts,
        page: 1,
        limit: remoteProductPageLimit,
      );
      recommendedProducts.assignAll(result.products);
      _recommendedPage = result.page;
      hasMoreRecommended.value = result.hasNext;
    } catch (_) {
      recommendedError.value = 'Could not load recommended products.';
    } finally {
      isRecommendedLoading.value = false;
    }
  }

  Future<void> loadMoreRecommendedProducts() async {
    if (!hasMoreRecommended.value || isRecommendedLoadingMore.value) return;
    isRecommendedLoadingMore.value = true;
    try {
      final result = await _homeProductsDataSource.fetch(
        path: ApiEndpoints.recommendedProducts,
        page: _recommendedPage + 1,
        limit: remoteProductPageLimit,
      );
      recommendedProducts.addAll(result.products);
      _recommendedPage = result.page;
      hasMoreRecommended.value = result.hasNext;
    } catch (_) {
      Get.snackbar('Could not load recommended products', 'Please try again.');
    } finally {
      isRecommendedLoadingMore.value = false;
    }
  }

  Future<void> loadNewArrivals() async {
    isNewArrivalsLoading.value = true;
    newArrivalsError.value = null;
    try {
      final result = await _newArrivalsDataSource.fetch(
        page: 1,
        limit: newArrivalsPageLimit,
      );
      newArrivals.assignAll(result.products);
      _newArrivalsPage = result.page;
      hasMoreNewArrivals.value = result.hasNext;
    } catch (_) {
      newArrivalsError.value = 'Could not load new arrivals.';
    } finally {
      isNewArrivalsLoading.value = false;
    }
  }

  Future<void> loadMoreNewArrivals() async {
    if (!hasMoreNewArrivals.value || isNewArrivalsLoadingMore.value) return;
    isNewArrivalsLoadingMore.value = true;
    try {
      final result = await _newArrivalsDataSource.fetch(
        page: _newArrivalsPage + 1,
        limit: newArrivalsPageLimit,
      );
      newArrivals.addAll(result.products);
      _newArrivalsPage = result.page;
      hasMoreNewArrivals.value = result.hasNext;
    } catch (_) {
      Get.snackbar(
        'Could not load new arrivals',
        'Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isNewArrivalsLoadingMore.value = false;
    }
  }

  Future<void> loadBestSellers() async {
    isBestSellersLoading.value = true;
    bestSellersError.value = null;
    try {
      final result = await _bestSellersDataSource.fetch(
        page: 1,
        limit: bestSellersPageLimit,
      );
      bestSellers.assignAll(result.products);
      _bestSellersPage = result.page;
      hasMoreBestSellers.value = result.hasNext;
    } catch (_) {
      bestSellersError.value = 'Could not load best sellers.';
    } finally {
      isBestSellersLoading.value = false;
    }
  }

  Future<void> loadMoreBestSellers() async {
    if (!hasMoreBestSellers.value || isBestSellersLoadingMore.value) return;
    isBestSellersLoadingMore.value = true;
    try {
      final result = await _bestSellersDataSource.fetch(
        page: _bestSellersPage + 1,
        limit: bestSellersPageLimit,
      );
      bestSellers.addAll(result.products);
      _bestSellersPage = result.page;
      hasMoreBestSellers.value = result.hasNext;
    } catch (_) {
      Get.snackbar(
        'Could not load best sellers',
        'Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isBestSellersLoadingMore.value = false;
    }
  }

  void updateBanner(int index) => activeBanner.value = index;
  void updateSearch(String value) => searchQuery.value = value;

  @override
  void onClose() {
    bannerController.dispose();
    super.onClose();
  }
}
