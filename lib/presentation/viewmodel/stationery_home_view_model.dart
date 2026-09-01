import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/best_sellers_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/banners_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/brands_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/categories_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/home_products_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/new_arrivals_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/wishlist_remote_data_source.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
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
    this._bannersDataSource,
    this._cartRemoteDataSource,
    this._wishlistRemoteDataSource,
  );

  final GetHomeCatalog _getHomeCatalog;
  final BestSellersRemoteDataSource _bestSellersDataSource;
  final NewArrivalsRemoteDataSource _newArrivalsDataSource;
  final HomeProductsRemoteDataSource _homeProductsDataSource;
  final CategoriesRemoteDataSource _categoriesDataSource;
  final BrandsRemoteDataSource _brandsDataSource;
  final BannersRemoteDataSource _bannersDataSource;
  final CartRemoteDataSource _cartRemoteDataSource;
  final WishlistRemoteDataSource _wishlistRemoteDataSource;
  final addingToCartIds = <String>{}.obs;
  final recommendedFavoriteIds = <String>{}.obs;
  final updatingRecommendedWishlistIds = <String>{}.obs;
  final activeBanner = 0.obs;
  final searchQuery = ''.obs;
  final bannerController = PageController();
  Timer? _bannerTimer;
  late final HomeCatalog catalog;
  final banners = <HomeBanner>[].obs;
  final isBannersLoading = false.obs;
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

  Future<void> addToCart(HomeProduct product) async {
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

  Future<void> toggleRecommendedWishlist(HomeProduct product) async {
    final productId = int.tryParse(product.id);
    if (productId == null ||
        productId <= 0 ||
        updatingRecommendedWishlistIds.contains(product.id)) {
      return;
    }
    final token = await Get.find<SecureStorage>().read(
      AppConstants.accessTokenKey,
    );
    if (token == null || token.trim().isEmpty) {
      await Get.toNamed<dynamic>(AppRoutes.login);
      return;
    }

    updatingRecommendedWishlistIds.add(product.id);
    try {
      final result = await _wishlistRemoteDataSource.toggle(productId);
      final isFavorite = result.items.any(
        (item) => item.productId == productId,
      );
      if (isFavorite) {
        recommendedFavoriteIds.add(product.id);
      } else {
        recommendedFavoriteIds.remove(product.id);
      }
    } catch (error) {
      Get.snackbar(
        'Could not update wishlist',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      updatingRecommendedWishlistIds.remove(product.id);
    }
  }

  @override
  void onInit() {
    super.onInit();
    catalog = _getHomeCatalog();
    loadBanners();
    loadCategories();
    loadBrands();
    loadBestSellers();
    loadNewArrivals();
    loadFlashSale();
    loadRecommendedProducts();
  }

  Future<void> loadBanners() async {
    isBannersLoading.value = true;
    try {
      final result = await _bannersDataSource.fetchBanners();
      if (result.isNotEmpty) {
        activeBanner.value = 0;
        banners.assignAll(result);
        if (bannerController.hasClients) bannerController.jumpToPage(0);
        _startBannerAutoplay();
      }
    } catch (_) {
      banners.clear();
    } finally {
      isBannersLoading.value = false;
    }
  }

  Future<void> refreshHome() async {
    await Future.wait([
      loadBanners(),
      loadCategories(),
      loadBrands(),
      loadBestSellers(),
      loadNewArrivals(),
      loadFlashSale(),
      loadRecommendedProducts(),
    ]);
  }

  void _startBannerAutoplay() {
    _bannerTimer?.cancel();
    if (banners.length < 2) return;
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!bannerController.hasClients || banners.length < 2) return;
      final nextPage = (activeBanner.value + 1) % banners.length;
      bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
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
      recommendedFavoriteIds.addAll(
        result.products.where((item) => item.wishlist).map((item) => item.id),
      );
      await _syncRecommendedWishlist();
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
      recommendedFavoriteIds.addAll(
        result.products.where((item) => item.wishlist).map((item) => item.id),
      );
      _recommendedPage = result.page;
      hasMoreRecommended.value = result.hasNext;
    } catch (_) {
      Get.snackbar('Could not load recommended products', 'Please try again.');
    } finally {
      isRecommendedLoadingMore.value = false;
    }
  }

  Future<void> _syncRecommendedWishlist() async {
    final token = await Get.find<SecureStorage>().read(
      AppConstants.accessTokenKey,
    );
    if (token == null || token.trim().isEmpty) return;
    try {
      final result = await _wishlistRemoteDataSource.fetchWishlist();
      recommendedFavoriteIds
        ..clear()
        ..addAll(result.items.map((item) => item.productId.toString()));
    } catch (_) {
      // Keep the wishlist values returned with recommended products.
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
    _bannerTimer?.cancel();
    bannerController.dispose();
    super.onClose();
  }
}
