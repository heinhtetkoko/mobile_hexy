import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/data/models/payment_checkout_session.dart';

void main() {
  final session = PaymentCheckoutSession.fromJson({
    'checkout_url':
        'https://paymentaggregatoruat.kbzbank.com/Payment/CheckoutV2?PgTxnId=test',
    'order_id': 10290,
    '_checkout_payment_method': 'MPU',
    '_checkout_delivery_notes': 'Testing',
    '_checkout_grand_total': 297000,
  });
  test(
    'recognizes the completion endpoint with extra and reordered parameters',
    () {
      expect(
        session.isCompletionUrl(
          'https://paymentaggregatoruat.kbzbank.com/Payment/Complete?MerchantId=M003022',
        ),
        true,
      );
      expect(
        session.isCompletionUrl(
          'https://paymentaggregatoruat.kbzbank.com/Payment/Complete?PgTxnId=abc&MerchantId=M003022&Status=Success',
        ),
        true,
      );
    },
  );
  test('rejects unrelated pages, nested URLs and the wrong merchant', () {
    for (final url in [
      'https://paymentaggregatoruat.kbzbank.com/Payment/Complete?MerchantId=M999999',
      'https://paymentaggregatoruat.kbzbank.com.evil.example/Payment/Complete?MerchantId=M003022',
      'http://paymentaggregatoruat.kbzbank.com/Payment/Complete?MerchantId=M003022',
      'https://paymentaggregatoruat.kbzbank.com/Payment/CheckoutV2?MerchantId=M003022',
      'https://example.com/?next=https://paymentaggregatoruat.kbzbank.com/Payment/Complete?MerchantId=M003022',
      'https://paymentaggregatoruat.kbzbank.com/Payment/Complete?MerchantId=M003022&MerchantId=other',
    ]) {
      expect(session.isCompletionUrl(url), false, reason: url);
    }
  });
  test('retains real order details for the existing confirmation screen', () {
    expect(session.orderDetails['order_id'], 10290);
    expect(session.orderDetails['_checkout_payment_method'], 'MPU');
    expect(session.orderDetails['_checkout_delivery_notes'], 'Testing');
    expect(session.orderDetails['_checkout_grand_total'], 297000);
  });
  test('only successful completion opens order confirmation', () {
    const base =
        'https://paymentaggregatoruat.kbzbank.com/Payment/Complete?MerchantId=M003022';
    expect(
      session.completionStatus('$base&Status=Success'),
      PaymentCompletionStatus.success,
    );
    expect(
      session.completionStatus('$base&Status=Cancelled'),
      PaymentCompletionStatus.cancelled,
    );
    for (final suffix in [
      '',
      '&Status=Pending',
      '&Status=Fail',
      '&Status=',
      '&Status=Success&Status=Cancelled',
    ]) {
      expect(session.completionStatus('$base$suffix'), isNull);
    }
    expect(
      session.completionStatus(
        'https://example.com/Payment/Complete?MerchantId=M003022&Status=Success',
      ),
      isNull,
    );
  });
}
