import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';
import 'package:mobile_hexy/presentation/viewmodel/checkout_view_model.dart';

class PaymentSuccessPage extends GetView<CheckoutViewModel> {
  const PaymentSuccessPage({super.key});

  void _trackOrder() {
    final orderId = _orderId(Get.arguments);
    if (orderId == null || orderId.isEmpty) {
      Get.snackbar(
        'Order unavailable',
        'The order number was not returned. Please open it from My Orders.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed<void>(AppRoutes.orderDetail, arguments: {'id': orderId});
  }

  String? _orderId(Object? source) {
    if (source is! Map) return null;
    for (final key in const ['order_id', 'sale_order_id', 'id']) {
      final value = source[key];
      if (value != null && value != false && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    for (final key in const ['order', 'sale_order', 'data', 'result']) {
      final value = _orderId(source[key]);
      if (value != null) return value;
    }
    return null;
  }

  List<Map<String, dynamic>> _purchasedItems(Object? source) {
    if (source is! Map) return const [];
    for (final key in const [
      '_checkout_items',
      'order_items',
      'items',
      'lines',
    ]) {
      final value = source[key];
      final raw = value is Map
          ? value['data'] ?? value['items'] ?? value['lines']
          : value;
      if (raw is List) {
        final items = raw
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
        if (items.isNotEmpty) return items;
      }
    }
    for (final key in const ['order', 'sale_order', 'data', 'result']) {
      final items = _purchasedItems(source[key]);
      if (items.isNotEmpty) return items;
    }
    return const [];
  }

  int _purchasedItemCount(Object? source, List<Map<String, dynamic>> items) {
    if (source is Map) {
      for (final key in const [
        '_checkout_item_count',
        'item_count',
        'total_quantity',
        'total_qty',
      ]) {
        final parsed = _positiveInt(source[key]);
        if (parsed != null) return parsed;
      }
    }
    return items.fold<int>(
      0,
      (total, item) =>
          total +
          (_positiveInt(
                item['quantity'] ??
                    item['qty'] ??
                    item['product_uom_qty'] ??
                    item['ordered_qty'],
              ) ??
              1),
    );
  }

  int? _positiveInt(Object? value) {
    final parsed = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '');
    return parsed != null && parsed > 0 ? parsed : null;
  }

  Map<String, dynamic> _deliveryAddress(Object? source) {
    if (source is! Map) return const {};
    for (final key in const [
      '_checkout_address',
      'shipping_address',
      'delivery_address',
      'delivery_information',
      'address',
    ]) {
      final value = source[key];
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    for (final key in const ['order', 'sale_order', 'data', 'result']) {
      final address = _deliveryAddress(source[key]);
      if (address.isNotEmpty) return address;
    }
    return const {};
  }

  void _showAction(String title) => Get.snackbar(
    title,
    '$title is coming soon.',
    snackPosition: SnackPosition.BOTTOM,
  );

  @override
  Widget build(BuildContext context) {
    final purchasedItems = _purchasedItems(Get.arguments);
    final purchasedItemCount = _purchasedItemCount(
      Get.arguments,
      purchasedItems,
    );
    final deliveryAddress = _deliveryAddress(Get.arguments);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const _SuccessCheckoutHeader(),
            const _ConfirmationProgressSteps(),
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(child: _CelebrationBackground()),
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    children: [
                      const _SuccessHeader(),
                      const SizedBox(height: 24),
                      _OrderReceipt(data: Get.arguments),
                      const SizedBox(height: 24),
                      _DeliveryDestination(address: deliveryAddress),
                      const SizedBox(height: 24),
                      _ItemPreview(
                        items: purchasedItems,
                        itemCount: purchasedItemCount,
                        onViewOrder: _trackOrder,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          key: const Key('track-order'),
                          onPressed: _trackOrder,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: Icon(Icons.inventory_2_outlined, size: 20),
                          label: Text('Track My Order'.tr),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          key: const Key('continue-shopping'),
                          onPressed: () =>
                              Get.offAllNamed<void>(AppRoutes.home),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                            shape: const StadiumBorder(),
                            textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          iconAlignment: IconAlignment.end,
                          icon: Icon(Icons.arrow_forward_rounded, size: 18),
                          label: Text('Continue Shopping'.tr),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SecondaryActions(onTap: _showAction),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessCheckoutHeader extends StatelessWidget {
  const _SuccessCheckoutHeader();

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 70,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: const CircleBorder(),
              child: IconButton(
                key: const Key('payment-success-back'),
                onPressed: () => Get.offAllNamed<void>(AppRoutes.home),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Checkout'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(
          width: 70,
          child: Text(
            'Step 3/3'.tr,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ConfirmationProgressSteps extends StatelessWidget {
  const _ConfirmationProgressSteps();

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surface,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
    child: Row(
      children: [
        const _ConfirmationStep(label: 'Cart', completed: true),
        const Expanded(child: Divider(color: AppColors.success, thickness: 2)),
        const _ConfirmationStep(label: 'Checkout', completed: true),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.primary,
            thickness: 2,
          ),
        ),
        const _ConfirmationStep(label: 'Confirm', number: '3'),
      ],
    ),
  );
}

class _ConfirmationStep extends StatelessWidget {
  const _ConfirmationStep({
    required this.label,
    this.completed = false,
    this.number,
  });

  final String label;
  final bool completed;
  final String? number;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? AppColors.success
        : Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: completed
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
              : Text(
                  number!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
        const SizedBox(height: 7),
        Text(
          label.tr,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CelebrationBackground extends StatelessWidget {
  const _CelebrationBackground();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: .65,
          colors: [
            AppColors.success.withValues(alpha: .08),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Stack(
        children: const [
          _Confetti(left: 40, top: 42, color: AppColors.success),
          _Confetti(right: 44, top: 66, color: AppColors.accent),
          _Confetti(left: 56, top: 170, color: Color(0xFFF59E0B)),
          _Confetti(right: 52, top: 190, color: AppColors.primary),
          _Confetti(left: 20, top: 265, color: AppColors.primary),
          _Confetti(right: 24, top: 300, color: AppColors.success),
        ],
      ),
    ),
  );
}

class _Confetti extends StatelessWidget {
  const _Confetti({
    this.left,
    this.right,
    required this.top,
    required this.color,
  });
  final double? left;
  final double? right;
  final double top;
  final Color color;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    right: right,
    top: top,
    child: Transform.rotate(
      angle: .55,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    ),
  );
}

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 120,
        height: 120,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.success, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1822C55E),
              blurRadius: 28,
              spreadRadius: 8,
            ),
          ],
        ),
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFFC7F4D7),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, color: AppColors.success, size: 62),
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Order Placed Successfully!'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Your order has been placed successfully.'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 15,
        ),
      ),
    ],
  );
}

class _OrderReceipt extends StatelessWidget {
  const _OrderReceipt({required this.data});
  final Object? data;

  @override
  Widget build(BuildContext context) {
    final orderNumber = _text(const [
      'order_number',
      'number',
      'name',
      'reference',
      'sale_order_id',
      'order_id',
      'id',
    ]);
    final orderDate = _text(const [
      'formatted_order_date',
      'order_date',
      'date_order',
      'created_at',
      'date',
    ]);
    final paymentMethod = _text(const [
      'payment_method',
      'payment_method_name',
      'payment_method_code',
      '_checkout_payment_method',
    ]);
    final deliveryMethod = _text(const [
      'delivery_method',
      'delivery_method_name',
      'shipping_method',
      'carrier_name',
      '_checkout_delivery_method',
    ]);
    final deliveryNotes = _text(const [
      'delivery_notes',
      'delivery_note',
      '_checkout_delivery_notes',
    ]);
    final estimatedDelivery = _text(const [
      'formatted_estimated_delivery',
      'estimated_delivery',
      'delivery_estimate',
      'expected_delivery_date',
      'commitment_date',
    ]);
    final grandTotal = _moneyText();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1422C55E),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (orderNumber.isNotEmpty)
            _ReceiptRow('Order Number', orderNumber, bold: true),
          if (orderDate.isNotEmpty) _ReceiptRow('Order Date', orderDate),
          if (paymentMethod.isNotEmpty)
            _ReceiptRow(
              'Payment Method',
              paymentMethod,
              icon: Icons.account_balance_wallet_outlined,
            ),
          if (deliveryMethod.isNotEmpty)
            _ReceiptRow('Delivery Method', deliveryMethod),
          if (deliveryNotes.isNotEmpty)
            _ReceiptRow('Delivery Notes', deliveryNotes),
          if (estimatedDelivery.isNotEmpty)
            _ReceiptRow(
              'Estimated Delivery',
              estimatedDelivery,
              green: true,
              bold: true,
            ),
          if (grandTotal.isNotEmpty) ...[
            Divider(height: 22, color: Theme.of(context).dividerColor),
            Row(
              children: [
                Text(
                  'Grand Total'.tr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  grandTotal,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _text(List<String> keys) {
    final value = _find(data, keys);
    if (value is Map) {
      return (value['display_name'] ??
                  value['label'] ??
                  value['name'] ??
                  value['value'] ??
                  value['code'])
              ?.toString()
              .trim() ??
          '';
    }
    return value == null || value == false ? '' : value.toString().trim();
  }

  Object? _find(Object? source, List<String> keys) {
    if (source is! Map) return null;
    for (final key in keys) {
      final value = source[key];
      if (value != null && value != false && value.toString().isNotEmpty) {
        return value;
      }
    }
    for (final key in const ['order', 'sale_order', 'data', 'result']) {
      final value = _find(source[key], keys);
      if (value != null) return value;
    }
    return null;
  }

  String _moneyText() {
    final formatted = _text(const [
      'formatted_total',
      'formatted_grand_total',
      'amount_total_formatted',
    ]);
    if (formatted.isNotEmpty) return formatted;
    final raw = _find(data, const [
      'grand_total',
      'amount_total',
      'total',
      '_checkout_grand_total',
    ]);
    if (raw == null) return '';
    final currency = _text(const [
      'currency_symbol',
      '_checkout_currency_symbol',
    ]);
    final amount = raw is num
        ? raw.toDouble()
        : double.tryParse(raw.toString().replaceAll(',', ''));
    if (amount == null) return raw.toString();
    final amountText = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '$amountText $currency'.trim();
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(
    this.label,
    this.value, {
    this.bold = false,
    this.green = false,
    this.icon,
  });
  final String label;
  final String value;
  final bool bold;
  final bool green;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Text(
          label.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        if (icon != null) ...[
          Icon(icon, size: 15, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 4),
        ],
        Text(
          value,
          style: TextStyle(
            color: green
                ? AppColors.success
                : (bold
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface),
            fontSize: 13,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

class _DeliveryDestination extends StatelessWidget {
  const _DeliveryDestination({required this.address});

  final Map<String, dynamic> address;

  @override
  Widget build(BuildContext context) {
    final name = _text(const ['name', 'recipient_name', 'contact_name']);
    final phone = _text(const ['phone', 'mobile']);
    final addressLine = [
      _text(const ['building', 'building_name', 'apartment']),
      _text(const ['street_address', 'street', 'address_line_1']),
      _text(const ['street2', 'address_line_2']),
      _text(const ['city_township', 'city', 'township']),
      _text(const ['state_region', 'state', 'region']),
      _text(const ['country_name', 'country']),
    ].where((value) => value.isNotEmpty).join(', ');
    final lines = [
      if (name.isNotEmpty) name,
      if (addressLine.isNotEmpty) addressLine,
      if (phone.isNotEmpty) phone,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📍 Delivering to'.tr,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            lines.isEmpty ? 'No delivery address found.'.tr : lines.join('\n'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _text(List<String> keys) {
    for (final key in keys) {
      final value = address[key];
      if (value is Map) {
        final nested = value['name'] ?? value['display_name'] ?? value['label'];
        if (nested != null && nested != false) return nested.toString().trim();
      } else if (value != null && value != false) {
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
    }
    return '';
  }
}

class _ItemPreview extends StatelessWidget {
  const _ItemPreview({
    required this.items,
    required this.itemCount,
    required this.onViewOrder,
  });
  final List<Map<String, dynamic>> items;
  final int itemCount;
  final VoidCallback onViewOrder;

  @override
  Widget build(BuildContext context) {
    final previewItems = items.take(3).toList(growable: false);
    final remaining = itemCount > previewItems.length
        ? itemCount - previewItems.length
        : 0;
    return Column(
      children: [
        Row(
          children: [
            Text(
              '$itemCount ${itemCount == 1 ? 'item' : 'items'}'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onViewOrder,
              child: Row(
                children: [
                  Text(
                    'View Order'.tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (previewItems.isNotEmpty)
          Row(
            children: [
              for (final item in previewItems) ...[
                _PurchasedItemImage(item: item),
                const SizedBox(width: 12),
              ],
              if (remaining > 0)
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Text(
                    '+$remaining',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _PurchasedItemImage extends StatelessWidget {
  const _PurchasedItemImage({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final rawImage =
        item['image_url'] ?? item['image'] ?? item['thumbnail_url'];
    final imageUrl = rawImage is Map
        ? (rawImage['url'] ?? rawImage['src'] ?? rawImage['image_url'])
                  ?.toString() ??
              ''
        : rawImage?.toString() ?? '';
    final imageAsset = item['image_asset']?.toString() ?? '';
    final fallback = Container(
      width: 52,
      height: 52,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.image_outlined),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            )
          : imageAsset.isNotEmpty
          ? Image.asset(
              imageAsset,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            )
          : fallback,
    );
  }
}

class _SecondaryActions extends StatelessWidget {
  const _SecondaryActions({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _SmallAction(
        icon: Icons.share_outlined,
        label: 'Share Receipt',
        color: Color(0xFFEEF2FF),
        onTap: onTap,
      ),
      _SmallAction(
        icon: Icons.star_outline_rounded,
        label: 'Rate Order',
        color: Color(0xFFFEF3C7),
        onTap: onTap,
      ),
      _SmallAction(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Need Help?',
        color: Color(0xFFFDF2F8),
        onTap: onTap,
      ),
    ],
  );
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onTap(label),
    borderRadius: BorderRadius.circular(12),
    child: Column(
      children: [
        Container(
          width: 48,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
