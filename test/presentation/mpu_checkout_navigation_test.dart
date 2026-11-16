import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/checkout_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/shipping_address_remote_data_source.dart';
import 'package:mobile_hexy/data/models/checkout_payment_provider.dart';
import 'package:mobile_hexy/data/models/payment_checkout_session.dart';
import 'package:mobile_hexy/data/models/shipping_address.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/checkout_view_model.dart';

const checkoutUrl =
    'https://paymentaggregatoruat.kbzbank.com/Payment/CheckoutV2?PgTxnId=xx123';
void main() {
  tearDown(() => Get.reset());
  for (final code in ['mpu', 'cod']) {
    testWidgets('$code response navigates to the correct payment screen', (
      tester,
    ) async {
      final calls = <RequestOptions>[];
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            calls.add(request);
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: {
                  'success': true,
                  'message': 'Payment initiated',
                  'data': {
                    'transaction_id': 436,
                    'order_id': 10278,
                    'payment_method': code,
                    'status': 'pending',
                    if (code == 'mpu') 'checkout_url': checkoutUrl,
                  },
                },
              ),
            );
          },
        ),
      );
      final api = ApiService(dio);
      final cart = CartViewModel(CartRemoteDataSource(api));
      final vm = CheckoutViewModel(
        cart,
        CheckoutRemoteDataSource(api),
        ShippingAddressRemoteDataSource(api),
      );
      vm.paymentProviders.add(
        CheckoutPaymentProvider(
          key: code,
          code: code,
          label: code,
          id: code == 'mpu' ? 23 : null,
          enabled: true,
          selected: true,
        ),
      );
      vm.selectPayment(code);
      vm.selectedAddress.value = ShippingAddress.fromJson({'id': 8576});
      vm.selectedDeliveryMethod.value = const CheckoutDeliveryMethod(
        id: '6',
        name: 'Delivery',
        price: 0,
        selected: true,
      );
      vm.termsAccepted.value = true;
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: vm.placeOrder,
              child: const Text('Submit'),
            ),
          ),
          getPages: [
            GetPage(
              name: AppRoutes.paymentCheckout,
              page: () {
                final session = Get.arguments as PaymentCheckoutSession;
                return Scaffold(body: Text(session.url.toString()));
              },
            ),
            GetPage(
              name: AppRoutes.paymentSuccess,
              page: () => const Scaffold(body: Text('Order confirmed')),
            ),
          ],
        ),
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(calls.single.path, ApiEndpoints.checkoutPlaceOrder);
      expect(calls.single.data['payment_method'], code);
      if (code == 'mpu') {
        expect(Get.currentRoute, AppRoutes.paymentCheckout);
        expect(find.text(checkoutUrl), findsOneWidget);
        expect(find.text('Order confirmed'), findsNothing);
      } else {
        expect(Get.currentRoute, AppRoutes.paymentSuccess);
        expect(find.text('Order confirmed'), findsOneWidget);
      }
      vm.onClose();
      cart.onClose();
    });
  }
  test('missing or unsafe payment URLs never create checkout sessions', () {
    for (final url in [
      null,
      '',
      'http://bank.example/pay',
      'javascript:alert(1)',
    ]) {
      expect(
        () => PaymentCheckoutSession.fromJson({'checkout_url': url}),
        throwsFormatException,
      );
    }
    expect(
      PaymentCheckoutSession.fromJson({
        'checkout_url': checkoutUrl,
        'payment_method': 'mpu',
      }).title,
      'MPU Payment',
    );
  });
}
