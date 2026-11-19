enum PaymentCompletionStatus { success, cancelled }

class PaymentCheckoutSession {
  const PaymentCheckoutSession({
    required this.url,
    required this.title,
    this.orderDetails = const {},
    this.kbzPayArguments,
  });

  final Uri? url;
  final String title;
  final Map<String, dynamic> orderDetails;
  final Map<String, String>? kbzPayArguments;

  static bool isKbzPay(Object? method) => const {
    'kpay',
    'kbzpay',
  }.contains(method?.toString().trim().toLowerCase());

  static bool isKbzPayUatOrigin(Uri uri) =>
      uri.scheme == 'https' &&
      uri.host == 'paymentaggregatoruat.kbzbank.com' &&
      uri.port == 443 &&
      uri.userInfo.isEmpty;

  bool isCompletionUrl(String value) {
    final candidate = Uri.tryParse(value);
    return candidate != null &&
        isKbzPayUatOrigin(candidate) &&
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
    final method = data['payment_method']?.toString().trim().toLowerCase();
    final native = data['kbzpay_native'];
    final Map<String, String>? nativeArguments;
    if (native
        case {
          'environment': 'uat',
          'sign_type': 'SHA256',
          'order_info': final String info,
          'sign': final String sign,
          'merchant_order_id': final String orderId,
        }
        when isKbzPay(method) &&
            orderId.trim().isNotEmpty &&
            RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(sign) &&
            RegExp(
              r'^appid=[^&#=]+&merch_code=[^&#=]+&nonce_str=[^&#=]+&prepay_id=[^&#=]+&timestamp=[0-9]+$',
            ).hasMatch(info)) {
      nativeArguments = {'orderInfo': info, 'sign': sign, 'orderId': orderId};
    } else {
      nativeArguments = null;
    }

    final candidate = Uri.tryParse(
      data['checkout_url']?.toString().trim() ?? '',
    );
    final url =
        candidate != null &&
            candidate.scheme == 'https' &&
            candidate.host.isNotEmpty &&
            candidate.userInfo.isEmpty
        ? candidate
        : null;
    if (url == null && nativeArguments == null) {
      throw const FormatException(
        'The payment checkout URL is unavailable or invalid.',
      );
    }
    return PaymentCheckoutSession(
      url: url,
      orderDetails: Map<String, dynamic>.unmodifiable(
        {...data}..remove('kbzpay_native'),
      ),
      kbzPayArguments: nativeArguments,
      title: isKbzPay(method)
          ? 'KBZPay'
          : method == 'mpu'
          ? 'MPU Payment'
          : 'Payment',
    );
  }
}
