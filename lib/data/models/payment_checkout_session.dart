enum PaymentCompletionStatus { success, cancelled }

class PaymentCheckoutSession {
  const PaymentCheckoutSession({
    required this.url,
    required this.title,
    this.orderDetails = const {},
  });

  final Uri url;
  final String title;
  final Map<String, dynamic> orderDetails;

  bool isCompletionUrl(String value) {
    final candidate = Uri.tryParse(value);
    return candidate != null &&
        candidate.scheme == 'https' &&
        candidate.host.toLowerCase() == 'paymentaggregatoruat.kbzbank.com' &&
        candidate.port == 443 &&
        candidate.userInfo.isEmpty &&
        candidate.path == '/Payment/Complete' &&
        candidate.queryParametersAll['MerchantId']?.length == 1 &&
        candidate.queryParameters['MerchantId'] == 'M003022';
  }

  PaymentCompletionStatus? completionStatus(String value) {
    if (!isCompletionUrl(value)) return null;
    final uri = Uri.parse(value);
    if (uri.queryParametersAll['Status']?.length != 1) return null;
    return switch (uri.queryParameters['Status']?.trim().toLowerCase()) {
      'success' => PaymentCompletionStatus.success,
      'cancelled' => PaymentCompletionStatus.cancelled,
      _ => null,
    };
  }

  factory PaymentCheckoutSession.fromJson(Map<String, dynamic> data) {
    final url = Uri.tryParse(data['checkout_url']?.toString().trim() ?? '');
    if (url == null ||
        url.scheme != 'https' ||
        url.host.isEmpty ||
        url.userInfo.isNotEmpty) {
      throw const FormatException(
        'The payment checkout URL is unavailable or invalid.',
      );
    }
    return PaymentCheckoutSession(
      url: url,
      orderDetails: Map<String, dynamic>.unmodifiable(data),
      title: data['payment_method']?.toString().toLowerCase() == 'mpu'
          ? 'MPU Payment'
          : 'Payment',
    );
  }
}
