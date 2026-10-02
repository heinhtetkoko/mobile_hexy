import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/product_detail_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/wishlist_remote_data_source.dart';
import 'package:mobile_hexy/presentation/view/product_detail_page.dart';
import 'package:mobile_hexy/presentation/viewmodel/product_detail_view_model.dart';

class PriceApi extends ApiService {
  PriceApi(this.data) : super(Dio());
  final Map<String, dynamic> data;
  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async => Response<T>(
    requestOptions: RequestOptions(path: path),
    data: {'success': true, 'data': data} as T,
  );
}

final sample = <String, dynamic>{
  'id': 31543,
  'name': 'E-Yooso 2.4G Wireless Mouse - USB Dongle (E-1141-BK)',
  'current_price': 36900,
  'original_price': 41000,
  'list_price': 41000,
  'discount_percentage': 10,
  'price': {
    'current': 36900,
    'original_price': 41000,
    'discount_percentage': 10,
    'currency': {'symbol': 'K', 'code': 'MMK'},
  },
  'currency': {'symbol': 'K', 'code': 'MMK'},
  'stock': {'qty': 9, 'in_stock': true},
};

void main() {
  tearDown(() => Get.reset());
  test(
    'maps current and original prices from supplied response fields',
    () async {
      final product = await ProductDetailRemoteDataSource(
        PriceApi(sample),
      ).fetch(31543);
      expect(product.formattedPrice, '36,900 K');
      expect(product.formattedCompareAtPrice, '41,000 K');
      expect(product.discountPercent, 10);
    },
  );
  test(
    'nested prices work and explicit null original price stays hidden',
    () async {
      final nested = Map<String, dynamic>.from(sample)
        ..remove('current_price')
        ..remove('original_price')
        ..remove('discount_percentage');
      final product = await ProductDetailRemoteDataSource(
        PriceApi(nested),
      ).fetch(31543);
      expect(product.formattedPrice, '36,900 K');
      expect(product.formattedCompareAtPrice, '41,000 K');
      expect(product.discountPercent, 10);
      final noOriginal = await ProductDetailRemoteDataSource(
        PriceApi({...sample, 'original_price': null}),
      ).fetch(31543);
      expect(noOriginal.formattedCompareAtPrice, isNull);
    },
  );
  testWidgets('screen displays current price and crossed-out original price', (
    tester,
  ) async {
    final api = PriceApi(sample);
    final vm = Get.put(
      ProductDetailViewModel(
        ProductDetailRemoteDataSource(api),
        CartRemoteDataSource(api),
        WishlistRemoteDataSource(api),
      ),
    );
    await vm.loadProduct(productId: 31543);
    await tester.pumpWidget(const GetMaterialApp(home: ProductDetailPage()));
    await tester.pumpAndSettle();
    final current = find.byKey(const Key('product-current-price'));
    await tester.scrollUntilVisible(
      current,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    final original = find.byKey(const Key('product-original-price'));
    expect(tester.widget<Text>(current).data, '36,900 K');
    expect(tester.widget<Text>(original).data, '41,000 K');
    expect(
      tester.widget<Text>(original).style?.decoration,
      TextDecoration.lineThrough,
    );
    expect(tester.takeException(), isNull);
  });
}
