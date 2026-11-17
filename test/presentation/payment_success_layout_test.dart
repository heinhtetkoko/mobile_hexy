import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/view/payment_success_page.dart';

void main() {
  tearDown(() => Get.reset());
  const reference = 'KBZ-00785439245b423682c33281134a94abcdef123456789';
  for (final withOrderId in [true, false]) {
    testWidgets(
      'receipt fits narrow screen with long reference and order ID $withOrderId',
      (tester) async {
        tester.view.physicalSize = const Size(320, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
        Get.routing.args = {
          if (withOrderId) 'order_id': 10290,
          'reference': reference,
          'payment_method': 'MPU',
          'delivery_notes':
              'A long delivery instruction that should wrap inside the receipt card.',
          'amount': 297000,
        };
        await tester.pumpWidget(
          const GetMaterialApp(home: PaymentSuccessPage()),
        );
        await tester.pumpAndSettle();
        expect(find.text(withOrderId ? '10290' : reference), findsOneWidget);
        if (withOrderId) expect(find.text(reference), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
