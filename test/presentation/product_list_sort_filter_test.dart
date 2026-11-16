import 'package:mobile_hexy/data/models/catalog_category.dart';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/category_products_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/collections_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/home_products_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/wishlist_remote_data_source.dart';
import 'package:mobile_hexy/data/models/product_list_request.dart';
import 'package:mobile_hexy/presentation/viewmodel/product_list_view_model.dart';

class MemoryStorage implements SecureStorage {
  @override
  Future<String?> read(String key) async => null;
  @override
  Future<void> write(String key, String value) async {}
  @override
  Future<void> remove(String key) async {}
}

class Call {
  Call(this.path, this.query, this.options);
  final String path;
  final Map<String, dynamic> query;
  final Options? options;
  final completion = Completer<Response<dynamic>>();
  void succeed({int? id, List<int>? ids, bool hasNext = true}) {
    completion.complete(
      Response(
        requestOptions: RequestOptions(path: path),
        data: {
          'success': true,
          'data': [
            for (final productId in ids ?? [?id])
              {
                'id': productId,
                'name': 'Product $productId',
                'price': 1250000,
                'currency': {'symbol': 'Ks'},
              },
          ],
          'meta': {'page': query['page'], 'has_next': hasNext},
        },
      ),
    );
  }

  void fail() => completion.completeError(Exception('Offline'));
}

class RecordingApi extends ApiService {
  RecordingApi() : super(Dio());
  final calls = <Call>[];
  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final call = Call(path, Map.of(queryParameters ?? {}), options);
    calls.add(call);
    return await call.completion.future as Response<T>;
  }
}

Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RecordingApi api;
  late ProductListViewModel vm;
  setUp(() {
    Get.testMode = true;
    Get.put<SecureStorage>(MemoryStorage());
    api = RecordingApi();
  });
  tearDown(() async {
    vm.onClose();
    Get.reset();
  });
  void start(ProductListRequest request) {
    vm = ProductListViewModel(
      CategoryProductsRemoteDataSource(api),
      HomeProductsRemoteDataSource(api),
      CartRemoteDataSource(api),
      WishlistRemoteDataSource(api),
      CollectionsRemoteDataSource(api),
      request: request,
    );
    vm.onInit();
  }

  final sections = [
    (const ProductListRequest.bestSellers(), 'best_sellers', 'popular'),
    (const ProductListRequest.newArrivals(), 'new_arrivals', 'new_arrivals'),
    (const ProductListRequest.flashSale(), 'flash_sale', 'highest_discount'),
  ];
  for (final (request, section, sort) in sections) {
    test(
      '$section defaults, filters, sort and pagination preserve constraints',
      () async {
        start(request);
        final first = api.calls.single;
        expect(first.path, ApiEndpoints.productFilter);
        expect(first.query, containsPair('section', section));
        expect(first.query, containsPair('sort', sort));
        expect(first.query, containsPair('page', 1));
        expect(first.options?.extra?[ApiEndpoints.requiresAuthKey], false);
        first.succeed(id: 1);
        await flush();
        expect(vm.products.single.price, '1,250,000.00 Ks');
        vm.beginFilter();
        vm.togglePendingCategory(1);
        vm.togglePendingCategory(2);
        vm.togglePendingBrand(3);
        vm.togglePendingBrand(4);
        vm.minPriceInput.text = '5,000';
        vm.maxPriceInput.text = '50000';
        vm.pendingInStockOnly.value = true;
        final applying = vm.applyFilters();
        final filtered = api.calls.last;
        expect(filtered.query, containsPair('category_ids', '1,2'));
        expect(filtered.query, containsPair('brand_ids', '3,4'));
        expect(filtered.query, containsPair('min_price', 5000.0));
        expect(filtered.query, containsPair('max_price', 50000.0));
        expect(filtered.query, containsPair('in_stock', true));
        filtered.succeed(id: 2);
        await applying;
        final more = vm.loadMore();
        expect(api.calls.last.query, {...filtered.query, 'page': 2});
        api.calls.last.succeed(id: 3);
        await more;
        expect(vm.products.map((p) => p.id), ['2', '3']);
        vm.pendingSort.value = 'Price: Low to High';
        final sorting = vm.applySort();
        expect(api.calls.last.query, {
          ...filtered.query,
          'sort': 'price_asc',
          'page': 1,
        });
        if (section == 'flash_sale') {
          expect(api.calls.last.query['flash_sale'], true);
          expect(api.calls.last.query['program_type'], 'promotion');
        }
        api.calls.last.succeed(id: 4, hasNext: false);
        await sorting;
        expect(vm.products.single.id, '4');
        expect(vm.hasNextPage.value, false);
        vm.beginFilter();
        vm.resetPendingFilters();
        final resetting = vm.applyFilters();
        expect(api.calls.last.query.keys, isNot(contains('min_price')));
        expect(api.calls.last.query.keys, isNot(contains('category_ids')));
        expect(api.calls.last.query['section'], section);
        api.calls.last.succeed();
        await resetting;
        expect(vm.activeFilters.value, 0);
      },
    );
  }

  test('all documented sort choices and singular filters', () async {
    start(const ProductListRequest.bestSellers());
    api.calls.last.succeed();
    await flush();
    vm.pendingCategories.add(7);
    vm.pendingBrands.add(9);
    final filter = vm.applyFilters();
    expect(api.calls.last.query['category_id'], 7);
    expect(api.calls.last.query['brand_id'], 9);
    api.calls.last.succeed();
    await filter;
    for (final entry in {
      'Default Sorting': 'default',
      'Popular': 'popular',
      'New Arrivals': 'new_arrivals',
      'Price: Low to High': 'price_asc',
      'Price: High to Low': 'price_desc',
      'Highest Rating': 'highest_rating',
      'Biggest Discount': 'highest_discount',
      'A–Z': 'a_z',
      'Z–A': 'z_a',
    }.entries) {
      vm.pendingSort.value = entry.key;
      final pending = vm.applySort();
      expect(api.calls.last.query['sort'], entry.value);
      expect(api.calls.last.query['category_id'], 7);
      api.calls.last.succeed();
      await pending;
    }
    final alias = CategoryProductsRemoteDataSource(api).fetchFilteredProducts(
      section: 'flash_sale',
      sort: 'biggest_discount',
      page: 1,
      limit: 10,
    );
    expect(api.calls.last.query['sort'], 'highest_discount');
    api.calls.last.succeed();
    await alias;
  });

  test(
    'stale page and stale reload cannot overwrite newest selection',
    () async {
      start(const ProductListRequest.bestSellers());
      api.calls.last.succeed(id: 1);
      await flush();
      final more = vm.loadMore();
      final oldPage = api.calls.last;
      final reload = vm.loadProducts();
      final oldReload = api.calls.last;
      final newest = vm.loadProducts();
      api.calls.last.succeed(id: 9);
      await newest;
      oldPage.succeed(id: 2);
      oldReload.fail();
      await Future.wait([more, reload]);
      expect(vm.products.single.id, '9');
      expect(vm.errorMessage.value, isNull);
      expect(vm.isLoading.value, false);
      expect(vm.isLoadingMore.value, false);
    },
  );

  test('reload and pagination errors retry the right page', () async {
    start(const ProductListRequest.newArrivals());
    await vm.loadMore();
    expect(api.calls.length, 1);
    api.calls.last.fail();
    await flush();
    expect(vm.errorMessage.value, isNotNull);
    final retry = vm.loadProducts();
    expect(api.calls.last.query['page'], 1);
    api.calls.last.succeed(id: 1);
    await retry;
    final more = vm.loadMore();
    await vm.loadMore();
    expect(api.calls.length, 3);
    api.calls.last.fail();
    await more;
    expect(vm.loadMoreError.value, isNotNull);
    expect(vm.products.single.id, '1');
    final retryMore = vm.loadMore();
    expect(api.calls.last.query['page'], 2);
    api.calls.last.succeed(id: 2, hasNext: false);
    await retryMore;
    expect(vm.loadMoreError.value, isNull);
    await vm.loadMore();
    expect(api.calls.length, 4);
  });

  test(
    'invalid prices do not send a request or commit pending filters',
    () async {
      start(const ProductListRequest.flashSale());
      api.calls.last.succeed();
      await flush();
      for (final values in [
        ('500', '100'),
        ('abc', ''),
        ('-1', ''),
        ('NaN', ''),
      ]) {
        vm.minPriceInput.text = values.$1;
        vm.maxPriceInput.text = values.$2;
        await vm.applyFilters();
        expect(vm.priceError.value, isNotNull);
        expect(api.calls.length, 1);
      }
    },
  );

  for (final entry in [
    (
      const ProductListRequest.collection(id: 7, name: 'Office'),
      'api/v1/collections/7/products',
    ),
    (const ProductListRequest.recommended(), ApiEndpoints.recommendedProducts),
    (
      const ProductListRequest.discountProducts(),
      ApiEndpoints.discountProducts,
    ),
  ]) {
    test(
      '${entry.$1.mode} filters and sorts without leaking other products',
      () async {
        start(entry.$1);
        expect(vm.supportsSortFilter, true);
        expect(api.calls.single.path, entry.$2);
        api.calls.last.succeed(ids: [2, 4], hasNext: false);
        await flush();
        expect(api.calls.last.path, ApiEndpoints.productFilter);
        api.calls.last.succeed(ids: [99, 4, 2], hasNext: false);
        await flush();
        expect(vm.products.map((p) => p.id), ['4', '2']);
        vm.beginFilter();
        vm.togglePendingCategory(3);
        vm.togglePendingBrand(9);
        vm.minPriceInput.text = '100';
        vm.maxPriceInput.text = '2000000';
        vm.pendingInStockOnly.value = true;
        final filtering = vm.applyFilters();
        await flush();
        final filtered = api.calls.last;
        expect(filtered.query['category_id'], 3);
        expect(filtered.query['brand_id'], 9);
        expect(filtered.query['min_price'], 100);
        expect(filtered.query['max_price'], 2000000);
        expect(filtered.query['in_stock'], true);
        filtered.succeed(ids: [99, 2], hasNext: false);
        await filtering;
        expect(vm.products.map((p) => p.id), ['2']);
        vm.pendingSort.value = 'Price: Low to High';
        final sorting = vm.applySort();
        await flush();
        expect(api.calls.last.query['sort'], 'price_asc');
        expect(api.calls.last.query['category_id'], 3);
        api.calls.last.succeed(ids: [2, 99, 4], hasNext: false);
        await sorting;
        expect(vm.products.map((p) => p.id), ['2', '4']);
        vm.beginFilter();
        vm.resetPendingFilters();
        final resetting = vm.applyFilters();
        await flush();
        expect(api.calls.last.query.keys, isNot(contains('min_price')));
        api.calls.last.succeed(ids: [4], hasNext: false);
        await resetting;
        expect(vm.activeFilters.value, 0);
        expect(api.calls.where((c) => c.path == entry.$2).length, 1);
      },
    );
  }

  test(
    'collection membership and visible results both paginate correctly',
    () async {
      start(const ProductListRequest.collection(id: 7, name: 'Office'));
      api.calls.last.succeed(ids: [1, 2, 3, 4, 5, 6]);
      await flush();
      expect(api.calls.last.query['page'], 2);
      api.calls.last.succeed(ids: [7, 8, 9, 10, 11, 12], hasNext: false);
      await flush();
      final ids = List.generate(12, (i) => i + 1);
      api.calls.last.succeed(ids: [99, ...ids], hasNext: false);
      await flush();
      expect(vm.products.length, 10);
      expect(vm.hasNextPage.value, true);
      final more = vm.loadMore();
      await flush();
      api.calls.last.succeed(ids: [99, ...ids], hasNext: false);
      await more;
      expect(vm.products.map((p) => p.id), ids.map((id) => '$id'));
      expect(vm.hasNextPage.value, false);
    },
  );

  test(
    'category browsing applies sort, filters and reset to its requests',
    () async {
      Get.routing.args = const CatalogCategory(
        id: 7,
        name: 'Pens',
        imageUrl: '',
        productCount: 10,
        hasChildren: false,
        next: '',
      );
      vm = ProductListViewModel(
        CategoryProductsRemoteDataSource(api),
        HomeProductsRemoteDataSource(api),
        CartRemoteDataSource(api),
        WishlistRemoteDataSource(api),
        CollectionsRemoteDataSource(api),
      );
      vm.onInit();
      expect(api.calls.single.path, ApiEndpoints.productFilter);
      expect(api.calls.single.query['category_id'], 7);
      api.calls.last.succeed(hasNext: false);
      await flush();
      vm.pendingBrands.add(9);
      vm.minPriceInput.text = '20000';
      final filtering = vm.applyFilters();
      expect(api.calls.last.query['min_price'], 20000);
      expect(api.calls.last.query['brand_id'], 9);
      expect(api.calls.last.query['category_id'], 7);
      api.calls.last.succeed(hasNext: false);
      await filtering;
      vm.pendingSort.value = 'Price: High to Low';
      final sorting = vm.applySort();
      expect(api.calls.last.query['sort'], 'price_desc');
      api.calls.last.succeed(hasNext: false);
      await sorting;
      vm.beginFilter();
      vm.resetPendingFilters();
      final resetting = vm.applyFilters();
      expect(api.calls.last.query['category_id'], 7);
      expect(api.calls.last.query.keys, isNot(contains('brand_id')));
      api.calls.last.succeed(hasNext: false);
      await resetting;
      Get.routing.args = null;
    },
  );

  test('failed collection membership can be retried', () async {
    start(const ProductListRequest.collection(id: 7, name: 'Office'));
    api.calls.last.fail();
    await flush();
    expect(vm.errorMessage.value, isNotNull);
    final retry = vm.loadProducts();
    expect(api.calls.last.path, 'api/v1/collections/7/products');
    api.calls.last.succeed(ids: [2], hasNext: false);
    await flush();
    api.calls.last.succeed(ids: [99, 2], hasNext: false);
    await retry;
    expect(vm.products.single.id, '2');
    expect(vm.errorMessage.value, isNull);
  });

  for (final entry in [
    (const ProductListRequest.brand(id: 82, name: 'Brand'), 82),
    (const ProductListRequest.search(query: 'pen'), null),
  ]) {
    test(
      '${entry.$1.mode} sends active filters and retains base scope',
      () async {
        start(entry.$1);
        expect(api.calls.single.path, ApiEndpoints.productFilter);
        if (entry.$2 != null) {
          expect(api.calls.single.query['brand_id'], entry.$2);
        }
        if (entry.$2 == null) expect(api.calls.single.query['q'], 'pen');
        api.calls.last.succeed(hasNext: false);
        await flush();
        vm.pendingCategories.add(5);
        vm.maxPriceInput.text = '40000';
        vm.pendingInStockOnly.value = true;
        final filter = vm.applyFilters();
        expect(api.calls.last.query['category_id'], 5);
        expect(api.calls.last.query['max_price'], 40000);
        expect(api.calls.last.query['in_stock'], true);
        if (entry.$2 != null) {
          expect(api.calls.last.query['brand_id'], entry.$2);
        }
        api.calls.last.succeed(hasNext: false);
        await filter;
      },
    );
  }
}
