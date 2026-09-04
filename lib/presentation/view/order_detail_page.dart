import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/order_detail_view_model.dart';
import 'package:mobile_hexy/presentation/widgets/clean_app_bar.dart';

class OrderDetailPage extends GetView<OrderDetailViewModel> {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CleanAppBar(title: 'Order Detail'),
    body: SafeArea(
      top: false,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final error = controller.errorMessage.value;
        if (error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(error, textAlign: TextAlign.center),
                ),
                FilledButton(
                  onPressed: controller.loadDetail,
                  child: Text('Try Again'.tr),
                ),
              ],
            ),
          );
        }
        final number = controller.text(const [
          'number',
          'name',
          'order_number',
        ], fallback: controller.orderId);
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _Panel(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #$number',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          controller.text(const [
                            'order_date',
                            'date_order',
                            'date',
                          ]),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(
                    label: controller.text(const [
                      'status_label',
                      'status',
                      'state',
                    ], fallback: 'Pending'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Order Items',
              child: controller.items.isEmpty
                  ? Text('No order items found.'.tr)
                  : Column(
                      children: controller.items
                          .map((item) => _OrderItemRow(item: item))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Delivery Information',
              child: _AddressBlock(address: controller.address),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Delivery & Payment',
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Delivery Method',
                    value: _nestedText(controller.detail['delivery_method']),
                  ),
                  _DetailRow(
                    label: 'Payment Method',
                    value: _nestedText(controller.detail['payment_method']),
                  ),
                  _DetailRow(
                    label: 'Delivery Notes',
                    value: _nestedText(controller.detail['delivery_notes']),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Order Summary',
              child: controller.summaryRows.isEmpty
                  ? _DetailRow(
                      label: 'Grand Total',
                      value: controller.text(const [
                        'formatted_total',
                        'grand_total',
                        'amount_total',
                        'total',
                      ]),
                      bold: true,
                    )
                  : Column(
                      children: controller.summaryRows
                          .map(
                            (row) => _DetailRow(
                              label:
                                  (row['label'] ?? row['name'] ?? row['key'])
                                      ?.toString() ??
                                  '',
                              value: _amountText(row),
                              bold:
                                  row['is_total'] == true ||
                                  row['key']?.toString() == 'grand_total',
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        );
      }),
    ),
  );

  static String _nestedText(Object? value) {
    if (value is Map) {
      return (value['label'] ??
                  value['name'] ??
                  value['value'] ??
                  value['text'] ??
                  value['delivery_notes'])
              ?.toString() ??
          '';
    }
    return value?.toString() ?? '';
  }

  static String _amountText(Map<String, dynamic> row) =>
      (row['formatted_value'] ??
              row['formatted_amount'] ??
              row['display_value'] ??
              row['amount'] ??
              row['value'])
          ?.toString() ??
      '';
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.tr,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});
  final Map<String, dynamic> item;
  @override
  Widget build(BuildContext context) {
    final image = (item['image_url'] ?? item['image'])?.toString() ?? '';
    final quantity = item['quantity'] ?? item['qty'] ?? 1;
    final price =
        item['formatted_subtotal'] ??
        item['subtotal'] ??
        item['line_total'] ??
        '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: image.isEmpty
                ? Container(
                    width: 56,
                    height: 56,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image_outlined),
                  )
                : Image.network(
                    image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['name'] ?? item['product_name'])?.toString() ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: $quantity',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  const _AddressBlock({required this.address});
  final Map<dynamic, dynamic> address;
  @override
  Widget build(BuildContext context) {
    final lines = [
      address['name'] ?? address['recipient_name'],
      address['phone'] ?? address['mobile'],
      address['full_address'] ??
          address['formatted_address'] ??
          [
                address['building'],
                address['street_address'] ?? address['street'],
                address['city_township'] ?? address['city'],
                address['state_region'] ?? address['state'],
              ]
              .where((value) => value != null && value.toString().isNotEmpty)
              .join(', '),
    ].where((value) => value != null && value.toString().isNotEmpty).join('\n');
    return Text(lines.isEmpty ? 'No delivery address found.'.tr : lines);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label;
  final String value;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label.tr,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      label.tr,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: child,
  );
}
