class PaymentCheckoutSession {
  const PaymentCheckoutSession({required this.url, required this.title});

  final Uri url;
  final String title;

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
      title: data['payment_method']?.toString().toLowerCase() == 'mpu'
          ? 'MPU Payment'
          : 'Payment',
    );
  }
}
