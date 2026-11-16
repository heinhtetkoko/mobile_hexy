import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/data/models/payment_checkout_session.dart';
import 'package:mobile_hexy/presentation/view/payment_checkout_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  tearDown(() => Get.reset());
  final session = PaymentCheckoutSession(
    url: Uri.parse(
      'https://paymentaggregatoruat.kbzbank.com/Payment/CheckoutV2?PgTxnId=test',
    ),
    title: 'MPU Payment',
  );
  testWidgets(
    'payment route renders before native initialization and stalled startup offers retry',
    (tester) async {
      final controller = Completer<WebViewController>();
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: TextButton(
              onPressed: () => Get.offNamed('/payment-checkout'),
              child: const Text('Place Order'),
            ),
          ),
          getPages: [
            GetPage(
              name: '/payment-checkout',
              page: () => PaymentCheckoutPage(
                session: session,
                controllerFactory: () => controller.future,
              ),
            ),
          ],
        ),
      );
      await tester.tap(find.text('Place Order'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('MPU Payment'), findsOneWidget);
      expect(find.text('Place Order'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 21));
      await tester.pump();
      expect(
        find.text('The payment page took too long to open. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('initialization errors show a visible error and retry works', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: PaymentCheckoutPage(
          session: session,
          controllerFactory: () async {
            attempts++;
            throw StateError('native initialization failed');
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('MPU Payment'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(attempts, 2);
    expect(tester.takeException(), isNull);
  });
}
