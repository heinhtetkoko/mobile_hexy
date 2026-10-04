import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/shipping_address_remote_data_source.dart';
import 'package:mobile_hexy/presentation/controllers/checkout_binding.dart';
import 'package:mobile_hexy/presentation/viewmodel/checkout_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/datasources/checkout_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/orders_remote_data_source.dart';
import 'package:mobile_hexy/presentation/view/my_orders_page.dart';
import 'package:mobile_hexy/presentation/viewmodel/my_orders_view_model.dart';

class _OrdersApi extends OrdersRemoteDataSource {
  _OrdersApi() : super(ApiService(Dio()));

  @override
  Future<Map<String, dynamic>> fetchOrders({
    required String status,
    required String sort,
    required int page,
    int limit = 10,
  }) async => {
    'orders': [
      for (final id in [11, 22])
        {
          'id': id,
          'number': 'ORDER-$id',
          'status': 'pending',
          'actions': ['Proceed to Checkout'],
        },
      for (final status in ['delivered', 'cancelled'])
        {
          'id': status,
          'number': status,
          'status': status,
          'actions': ['Proceed to Checkout'],
        },
    ],
  };
}

void main() {
  tearDown(() => Get.reset());

  testWidgets('each pending card opens checkout with its own order ID', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          handler.resolve(
            Response(
              requestOptions: request,
              data: {
                'data': {
                  'order_id': request.queryParameters['order_id'],
                  'items': [
                    {
                      'id': 1,
                      'product_name':
                          'item:${request.queryParameters['order_id']}',
                      'quantity': 1,
                    },
                  ],
                },
              },
              statusCode: 200,
            ),
          );
        },
      ),
    );
    final api = ApiService(dio);
    Get.put(CartRemoteDataSource(api));
    Get.put(CheckoutRemoteDataSource(api));
    Get.put(ShippingAddressRemoteDataSource(api));
    final cart = CartViewModel(Get.find());
    cart.applyCheckoutPayload({
      'items': [
        {'id': 9, 'product_name': 'original cart', 'quantity': 1},
      ],
    });
    Get.put(cart);
    await tester.pump();
    // Restore the fixture after the normal cart's initial API load.
    cart.applyCheckoutPayload({
      'items': [
        {'id': 9, 'product_name': 'original cart', 'quantity': 1},
      ],
    });
    Get.put(MyOrdersViewModel(_OrdersApi()));
    await tester.pumpWidget(
      GetMaterialApp(
        home: const MyOrdersPage(),
        getPages: [
          GetPage(
            name: AppRoutes.checkout,
            binding: CheckoutBinding(),
            page: () {
              final checkout = Get.find<CheckoutViewModel>();
              return Scaffold(
                body: Obx(
                  () => Text(
                    checkout.isLoading.value
                        ? 'Loading'
                        : 'order:${checkout.orderId} item:${checkout.cart.items.single.name}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proceed to Checkout').first);
    await tester.pumpAndSettle();
    expect(find.text('order:11 item:item:11'), findsOneWidget);
    Get.back<void>();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proceed to Checkout').at(1));
    await tester.pumpAndSettle();
    expect(find.text('order:22 item:item:22'), findsOneWidget);
    expect(cart.items.single.name, 'original cart');
    Get.back<void>();
    await tester.pumpAndSettle();
    for (final index in [2, 3]) {
      await tester.ensureVisible(find.text('Proceed to Checkout').at(index));
      await tester.tap(find.text('Proceed to Checkout').at(index));
      await tester.pumpAndSettle();
      expect(find.byType(MyOrdersPage), findsOneWidget);
      expect(Get.currentRoute, isNot(AppRoutes.checkout));
      Get.closeAllSnackbars();
      await tester.pumpAndSettle();
    }
  });

  test(
    'checkout requests retain order ID and omit it for cart checkout',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            requests.add(request);
            handler.resolve(
              Response(
                requestOptions: request,
                data: {
                  'data': <String, dynamic>{
                    'order_id': request.queryParameters['order_id'],
                  },
                },
                statusCode: 200,
              ),
            );
          },
        ),
      );
      final api = CheckoutRemoteDataSource(ApiService(dio));
      for (final id in ['11', '22', null]) {
        await api.fetchCheckout(orderId: id);
        await api.fetchDeliveryMethods(orderId: id);
        await api.updateCheckout(orderId: id, shippingAddressId: 3);
        await api.placeOrder(
          orderId: id,
          shippingAddressId: 3,
          deliveryMethodId: 4,
          paymentMethod: 'cod',
          termsAccepted: true,
          deliveryNotes: '',
        );
      }
      for (var i = 0; i < requests.length; i++) {
        final fields = i % 4 < 2
            ? requests[i].queryParameters
            : requests[i].data as Map;
        if (i < 8) {
          expect(fields['order_id'], i < 4 ? 11 : 22);
        } else {
          expect(fields.containsKey('order_id'), isFalse);
        }
      }
    },
  );
  test(
    'pending checkout rejects missing or different returned order IDs',
    () async {
      for (final returnedId in [null, 99]) {
        final dio = Dio();
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              handler.resolve(
                Response(
                  requestOptions: request,
                  data: {
                    'data': {'order_id': returnedId},
                  },
                  statusCode: 200,
                ),
              );
            },
          ),
        );
        await expectLater(
          CheckoutRemoteDataSource(
            ApiService(dio),
          ).fetchCheckout(orderId: '11'),
          throwsFormatException,
        );
      }
    },
  );
}
