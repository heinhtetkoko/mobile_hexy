import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/presentation/viewmodel/main_view_model.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/orders_remote_data_source.dart';
import 'package:mobile_hexy/presentation/view/my_orders_page.dart';
import 'package:mobile_hexy/presentation/viewmodel/my_orders_view_model.dart';

class _CartApi extends CartRemoteDataSource {
  _CartApi() : super(ApiService(Dio()));
  int reloads = 0;
  @override
  Future<Map<String, dynamic>> fetchCart() async {
    reloads++;
    return {};
  }
}

class _OrdersApi extends OrdersRemoteDataSource {
  _OrdersApi([this.action = 'Reorder']) : super(ApiService(Dio()));
  final String action;
  final ids = <String>[];
  final release = Completer<void>();
  @override
  Future<Map<String, dynamic>> fetchOrders({
    required String status,
    required String sort,
    required int page,
    int limit = 10,
  }) async => {
    'orders': [
      for (final row in [
        (11, 'processing'),
        (22, action == 'Buy Again' ? 'delivered' : 'cancelled'),
      ])
        {
          'id': row.$1,
          'number': '${row.$1}',
          'status': row.$2,
          'actions': [action],
        },
    ],
  };
  @override
  Future<Map<String, dynamic>> reorder(Object orderId) async {
    ids.add(orderId.toString());
    if (ids.length == 1) await release.future;
    return {'items': []};
  }
}

class _MainViewModel extends MainViewModel {
  int? openedTab;
  @override
  Future<void> changePage(int index) async {
    openedTab = index;
    selectedIndex.value = index;
  }
}

void main() {
  tearDown(() => Get.reset());
  testWidgets('Contact Support on either card opens Contact Us', (
    tester,
  ) async {
    final api = _OrdersApi('Contact Support');
    Get.put(MyOrdersViewModel(api));
    await tester.pumpWidget(
      GetMaterialApp(
        home: const MyOrdersPage(),
        getPages: [
          GetPage(
            name: AppRoutes.contactUs,
            page: () => const Scaffold(body: Text('Contact Us')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    for (final index in [0, 1]) {
      await tester.tap(find.text('Contact Support').at(index));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.contactUs);
      expect(find.text('Contact Us'), findsOneWidget);
      expect(api.ids, isEmpty);
      Get.back<void>();
      await tester.pumpAndSettle();
      expect(find.byType(MyOrdersPage), findsOneWidget);
    }
  });

  for (final action in ['Reorder', 'Buy Again']) {
    testWidgets(
      '$action blocks repeat taps, refreshes cart and opens cart tab',
      (tester) async {
        final api = _OrdersApi(action);
        final index = action == 'Buy Again' ? 1 : 0;
        final expectedId = index == 1 ? '22' : '11';
        final main = Get.put<MainViewModel>(_MainViewModel()) as _MainViewModel;
        final cart = Get.put<CartRemoteDataSource>(_CartApi()) as _CartApi;
        final controller = Get.put(MyOrdersViewModel(api));
        await tester.pumpWidget(
          GetMaterialApp(
            home: const MyOrdersPage(),
            getPages: [
              GetPage(
                name: AppRoutes.home,
                page: () => Scaffold(
                  body: Text('Cart tab ${Get.arguments['tabIndex']}'),
                ),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(action).at(index));
        await tester.pump();
        expect(api.ids, [expectedId]);
        expect(controller.reorderingOrderIds, contains(expectedId));
        expect(
          tester
              .widget<ButtonStyleButton>(
                find
                    .ancestor(
                      of: find.text(action).at(index),
                      matching: find.byWidgetPredicate(
                        (widget) => widget is ButtonStyleButton,
                      ),
                    )
                    .first,
              )
              .onPressed,
          isNull,
        );
        await controller.performAction(action, controller.orders[index]);
        expect(api.ids, [expectedId]);
        api.release.complete();
        await tester.pumpAndSettle();
        expect(controller.reorderingOrderIds, isEmpty);
        expect(cart.reloads, 1);
        expect(Get.currentRoute, AppRoutes.home);
        expect(find.text('Cart tab 3'), findsOneWidget);
        expect(main.openedTab, 3);
        Get.closeAllSnackbars();
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
      },
    );
  }

  test('reorder uses authenticated POST and preserves existing cart', () async {
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
                'data': {'items': []},
              },
              statusCode: 200,
            ),
          );
        },
      ),
    );
    final api = OrdersRemoteDataSource(ApiService(dio));
    await api.reorder('11');
    await api.reorder('22');
    expect(requests.map((r) => r.path), [
      'api/v1/orders/11/reorder',
      'api/v1/orders/22/reorder',
    ]);
    for (final request in requests) {
      expect(request.method, 'POST');
      expect(request.data, {'replace_cart': false});
      expect(request.extra[ApiEndpoints.redirectOnUnauthorizedKey], isTrue);
    }
  });

  test('reorder rejects backend failures and malformed responses', () async {
    for (final body in [
      {'success': false, 'message': 'Order unavailable'},
      {'data': null},
    ]) {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            handler.resolve(
              Response(requestOptions: request, data: body, statusCode: 200),
            );
          },
        ),
      );
      await expectLater(
        OrdersRemoteDataSource(ApiService(dio)).reorder('11'),
        throwsFormatException,
      );
    }
  });
}
