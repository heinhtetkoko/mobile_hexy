class CheckoutPaymentProvider {
  const CheckoutPaymentProvider({
    required this.key,
    required this.code,
    required this.label,
    required this.enabled,
    required this.selected,
    this.id,
  });

  final String key, code, label;
  final int? id;
  final bool enabled, selected;

  factory CheckoutPaymentProvider.fromJson(Map<dynamic, dynamic> json) =>
      CheckoutPaymentProvider(
        key: (json['key'] ?? json['code'] ?? '').toString(),
        code: (json['code'] ?? json['key'] ?? '').toString(),
        label: (json['label'] ?? json['name'] ?? '').toString(),
        id: int.tryParse((json['provider_id'] ?? json['id'])?.toString() ?? ''),
        enabled: json['enabled'] == true,
        selected: json['selected'] == true,
      );
}

class CheckoutPaymentProviders {
  const CheckoutPaymentProviders({required this.items, this.selectedKey});
  final List<CheckoutPaymentProvider> items;
  final String? selectedKey;
}
