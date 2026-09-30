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
  void succeed({int? id, bool hasNext = true}) {
    completion.complete(
      Response(
        requestOptions: RequestOptions(path: path),
        data: {
          'success': true,
          'data': [
            if (id != null)
              {
                'id': id,
                'name': 'Product $id',
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

  test(
    'recommendations send only page and limit and preserve pagination',
    () async {
      start(const ProductListRequest.recommended());
      expect(vm.supportsSortFilter, false);
      expect(api.calls.single.path, ApiEndpoints.recommendedProducts);
      expect(api.calls.single.query, {'page': 1, 'limit': 10});
      api.calls.last.succeed(id: 1);
      await flush();
      await vm.applySort();
      await vm.applyFilters();
      expect(api.calls.length, 1);
      final more = vm.loadMore();
      expect(api.calls.last.query, {'page': 2, 'limit': 10});
      api.calls.last.succeed(id: 2);
      await more;
      expect(vm.products.length, 2);
    },
  );
}
