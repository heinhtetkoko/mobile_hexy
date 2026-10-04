import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/checkout_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/shipping_address_remote_data_source.dart';
import 'package:mobile_hexy/data/models/shipping_address.dart';
import 'package:mobile_hexy/presentation/view/checkout_page.dart';
import 'package:mobile_hexy/presentation/viewmodel/checkout_view_model.dart';
import 'package:mobile_hexy/presentation/view/cart_page.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';

class CartApi extends CartRemoteDataSource {
  CartApi() : super(ApiService(Dio()));
  @override
  Future<Map<String, dynamic>> fetchCart() async => data;
  Map<String, dynamic> data = payload;
}

class CheckoutApi extends CheckoutRemoteDataSource {
  CheckoutApi() : super(ApiService(Dio()));
  Map<String, dynamic> data = payload;

  @override
  Future<Map<String, dynamic>> fetchCheckout({String? orderId}) async => data;

  @override
  Future<List<Map<String, dynamic>>> fetchDeliveryMethods({
    String? orderId,
  }) async => [];
}

class AddressApi extends ShippingAddressRemoteDataSource {
  AddressApi() : super(ApiService(Dio()));

  @override
  Future<List<ShippingAddress>> fetchAddresses() async => [];
}

final payload = <String, dynamic>{
  'currency': {'symbol': 'K'},
  'items': [
    {
      'line_id': 1,
      'product_name': 'Paid pen',
      'quantity': 1,
      'unit_price': 5500,
    },
  ],
  'free_products': [
    {
      'line_id': 2,
      'name': 'Long reward description',
      'product_name': 'Free pen',
      'quantity': 2,
      'unit_price': 5500,
      'free_product_value': 11000,
      'discount_percentage': 100,
      'currency': {'symbol': 'K'},
      'program_name': 'Buy 2 Get 1',
      'program_type': 'buy_x_get_y',
    },
  ],
};

void main() {
  tearDown(() => Get.reset());

  test('maps rewards and clears omitted or null checkout rewards', () {
    final vm = CartViewModel(CartApi());
    vm.applyCheckoutPayload(payload);
    final item = vm.freeProducts.single;
    expect(item.name, 'Free pen');
    expect(item.displayQuantity, 2);
    expect(item.unitPrice, 5500);
    expect(item.freeProductValue, 11000);
    expect(item.discountPercentage, 100);
    expect(item.currency, 'K');
    expect(item.programType, 'buy_x_get_y');
    expect(vm.items.single.isFreeProduct, false);
    vm.applyCheckoutPayload({...payload, 'free_products': null});
    expect(vm.freeProducts, isEmpty);
    vm.applyCheckoutPayload(payload);
    vm.applyCheckoutPayload({'items': payload['items']});
    expect(vm.freeProducts, isEmpty);
    vm.onClose();
  });

  test('fresh cart response without rewards clears previous rewards', () async {
    final api = CartApi();
    final vm = CartViewModel(api);
    vm.applyCheckoutPayload(payload);
    api.data = {'items': payload['items']};
    await vm.loadCart();
    expect(vm.freeProducts, isEmpty);
    vm.onClose();
  });

  testWidgets('reuses card above coupon with read-only reward quantity', (
    tester,
  ) async {
    final vm = Get.put(CartViewModel(CartApi()));
    await tester.pumpWidget(const GetMaterialApp(home: CartPage()));
    await tester.pumpAndSettle();
    expect(find.text('Long reward description'), findsNothing);
    expect(find.text('Free pen'), findsOneWidget);
    expect(find.text('Qty: 2'), findsOneWidget);
    expect(find.text('5,500 K'), findsNWidgets(2));
    expect(find.text('Free value: 11,000 K'), findsOneWidget);
    final card = find.byKey(const Key('free-product-2'));
    expect(find.descendant(of: card, matching: find.text('+')), findsNothing);
    expect(find.descendant(of: card, matching: find.text('−')), findsNothing);
    expect(
      find.descendant(
        of: card,
        matching: find.byIcon(Icons.delete_outline_rounded),
      ),
      findsNothing,
    );
    expect(find.byKey(const Key('remove-cart-1')), findsOneWidget);
    expect(
      tester.getTopLeft(card).dy,
      lessThan(tester.getTopLeft(find.text('Coupon Code')).dy),
    );
    vm.applyCheckoutPayload({...payload, 'free_products': []});
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('free-product-2')), findsNothing);
    expect(find.text('Coupon Code'), findsOneWidget);
  });
  testWidgets('checkout only shows rewards included in its detail API', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final cart = Get.put(CartViewModel(CartApi()));
    await cart.loadCart();
    final api = CheckoutApi()
      ..data = (Map<String, dynamic>.from(payload)..remove('free_products'));
    final checkout = Get.put(CheckoutViewModel(cart, api, AddressApi()));
    await tester.pumpWidget(const GetMaterialApp(home: CheckoutPage()));
    await tester.pumpAndSettle();
    final card = find.byKey(const Key('checkout-free-product-2'));
    expect(cart.freeProducts, isEmpty);
    expect(card, findsNothing);
    expect(find.text('Free Products'), findsNothing);
    api.data = payload;
    await checkout.loadCheckout();
    await tester.pumpAndSettle();
    expect(card, findsOneWidget);
    expect(find.text('Free pen'), findsOneWidget);
    expect(find.text('Long reward description'), findsNothing);
    expect(
      find.descendant(of: card, matching: find.text('Qty: 2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('5,500 K')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('Free value: 11,000 K')),
      findsOneWidget,
    );
    expect(find.descendant(of: card, matching: find.text('+')), findsNothing);
    expect(find.descendant(of: card, matching: find.text('−')), findsNothing);
    expect(
      find.descendant(
        of: card,
        matching: find.byIcon(Icons.delete_outline_rounded),
      ),
      findsNothing,
    );
    expect(
      tester.getTopLeft(card).dy,
      lessThan(tester.getTopLeft(find.text('Product Total')).dy),
    );
    api.data = {
      ...payload,
      'free_products': [
        {
          ...(payload['free_products'] as List).single as Map,
          'quantity': 3,
          'free_product_value': 16500,
        },
      ],
    };
    await checkout.loadCheckout();
    await tester.pumpAndSettle();
    expect(find.text('Qty: 3'), findsOneWidget);
    expect(find.text('Free value: 16,500 K'), findsOneWidget);
    api.data = Map<String, dynamic>.from(payload)..remove('free_products');
    await checkout.loadCheckout();
    await tester.pumpAndSettle();
    expect(card, findsNothing);
    expect(find.text('Free Products'), findsNothing);
    api.data = {...payload, 'free_products': []};
    await checkout.loadCheckout();
    await tester.pumpAndSettle();
    expect(find.text('Free Products'), findsNothing);
    api.data = {...payload, 'free_products': null};
    await checkout.loadCheckout();
    await tester.pumpAndSettle();
    expect(find.text('Free Products'), findsNothing);
    expect(card, findsNothing);
    expect(find.text('Order Items (1)'), findsOneWidget);
  });
}
