import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';
import 'package:mobile_hexy/data/models/shipping_address.dart';
import 'package:mobile_hexy/presentation/view/cart_page.dart';
import 'package:mobile_hexy/presentation/viewmodel/checkout_view_model.dart';
import 'package:mobile_hexy/presentation/widgets/shimmer_skeletons.dart';
import 'package:mobile_hexy/app.dart';

const _addShippingAddressAction = 'add_shipping_address';

class CheckoutPage extends GetView<CheckoutViewModel> {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(
      child: Column(
        children: [
          const _CheckoutHeader(),
          const _ProgressSteps(),
          Expanded(child: Obx(() => _content(context))),
          Obx(
            () => _PlaceOrderBar(
              total: controller.cart.grandTotal,
              enabled:
                  controller.termsAccepted.value &&
                  !controller.isPlacingOrder.value,
              loading: controller.isPlacingOrder.value,
              onPressed: controller.placeOrder,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _content(BuildContext context) {
    if (controller.isLoading.value && !controller.hasCheckoutData.value) {
      return const _CheckoutShimmer();
    }
    final error = controller.errorMessage.value;
    if (error != null && !controller.hasCheckoutData.value) {
      return RefreshIndicator(
        onRefresh: controller.loadCheckout,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * .55,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error, textAlign: TextAlign.center),
                  ),
                  FilledButton(
                    onPressed: controller.loadCheckout,
                    child: Text('Try Again'.tr),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.loadCheckout,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _DeliveryInformation(
            address: controller.selectedAddress.value,
            updating: controller.isUpdatingAddress.value,
            onEdit: () => _showAddressDialog(context),
            onAdd: _addShippingAddress,
          ),
          const SizedBox(height: 10),
          _DeliveryMethod(controller: controller),
          const SizedBox(height: 10),
          _PaymentMethod(controller: controller),
          const SizedBox(height: 10),
          _ItemsSummary(controller: controller),
          const SizedBox(height: 10),
          _PriceBreakdown(controller: controller),
          const SizedBox(height: 10),
          _DeliveryNotes(controller: controller),
          const SizedBox(height: 12),
          _TermsRow(controller: controller),
        ],
      ),
    );
  }

  Future<void> _showAddressDialog(BuildContext context) async {
    final result = await showDialog<Object>(
      context: context,
      builder: (_) => _AddressSelectDialog(controller: controller),
    );
    if (result == _addShippingAddressAction) {
      final saved = await _addShippingAddress();
      if (saved == true) {
        if (context.mounted) await _showAddressDialog(context);
      }
      return;
    }
    if (result is ShippingAddress) await controller.selectAddress(result);
  }

  Future<bool> _addShippingAddress() async {
    final saved = await Get.toNamed<dynamic>(
      '${AppRoutes.addressForm}?mode=new',
    );
    if (saved == true) await controller.loadCheckout();
    return saved == true;
  }
}

class _CheckoutShimmer extends StatelessWidget {
  const _CheckoutShimmer();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: const [
        ShimmerBox(width: double.infinity, height: 128, radius: 16),
        SizedBox(height: 10),
        ShimmerBox(width: double.infinity, height: 86, radius: 16),
        SizedBox(height: 10),
        ShimmerBox(width: double.infinity, height: 116, radius: 16),
        SizedBox(height: 10),
        ShimmerBox(width: double.infinity, height: 142, radius: 16),
        SizedBox(height: 10),
        ShimmerBox(width: double.infinity, height: 166, radius: 16),
      ],
    ),
  );
}

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader();

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
      ],
      color: Theme.of(context).colorScheme.surface,
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
                key: const Key('checkout-back'),
                onPressed: Get.back,
                icon: Icon(Icons.arrow_back_rounded, size: 18),
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Checkout'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          width: 70,
          child: Text(
            'Step 2/3'.tr,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
    child: Row(
      children: [
        const _Step(
          icon: Icons.check_rounded,
          label: 'Cart',
          color: AppColors.success,
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.primary,
            thickness: 2,
          ),
        ),
        _Step(
          number: '2',
          label: 'Checkout',
          color: Theme.of(context).colorScheme.primary,
        ),
        Expanded(
          child: Divider(color: Theme.of(context).dividerColor, thickness: 2),
        ),
        _Step(
          number: '3',
          label: 'Confirm',
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          pale: true,
        ),
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  const _Step({
    this.icon,
    this.number,
    required this.label,
    required this.color,
    this.pale = false,
  });
  final IconData? icon;
  final String? number;
  final String label;
  final Color color;
  final bool pale;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: pale
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : color,
          shape: BoxShape.circle,
        ),
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 14)
            : Text(
                number!,
                style: TextStyle(
                  color: pale ? color : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
      SizedBox(height: 7),
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

class _DeliveryInformation extends StatelessWidget {
  const _DeliveryInformation({
    required this.address,
    required this.onEdit,
    required this.onAdd,
    required this.updating,
  });
  final ShippingAddress? address;
  final VoidCallback onEdit;
  final VoidCallback onAdd;
  final bool updating;

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return _MissingShippingAddress(
        onAdd: updating ? null : onAdd,
        updating: updating,
      );
    }
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            emoji: '📍',
            title: 'Delivery Information',
            action: 'Edit',
            onAction: updating ? null : onEdit,
          ),
          SizedBox(height: 14),
          Text(
            address!.name.tr,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4),
          Text(
            address!.phone,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _addressText(address!).tr,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _addressText(ShippingAddress value) => [
    value.building,
    value.streetAddress,
    value.cityTownship,
    value.stateRegion,
  ].where((part) => part.trim().isNotEmpty).join(', ');
}

class _MissingShippingAddress extends StatelessWidget {
  const _MissingShippingAddress({required this.onAdd, required this.updating});

  final VoidCallback? onAdd;
  final bool updating;

  static const _danger = Color(0xFFEF4444);
  static const _paleDanger = Color(0xFFFFF5F5);
  static const _dashColor = Color(0xFFFCA5A5);

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 4, color: _danger),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 22,
                        color: Color(0xFF111827),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              'Shipping Address'.tr,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _paleDanger,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                'REQUIRED'.tr,
                                style: const TextStyle(
                                  color: _danger,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        key: const Key('checkout-add-address-link'),
                        onTap: onAdd,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Add Address'.tr,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: AppColors.accent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    key: const Key('checkout-add-address-warning'),
                    onTap: onAdd,
                    borderRadius: BorderRadius.circular(13),
                    child: CustomPaint(
                      foregroundPainter: const _DashedRoundedRectPainter(
                        color: _dashColor,
                        radius: 13,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: _paleDanger,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: _danger,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Shipping address is required to proceed'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _danger,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Tap here to add your address'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      key: const Key('checkout-add-shipping-address-empty'),
                      onPressed: onAdd,
                      style: FilledButton.styleFrom(
                        backgroundColor: _danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: updating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Add Shipping Address'.tr),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DashedRoundedRectPainter extends CustomPainter {
  const _DashedRoundedRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 7), paint);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}

class _DeliveryMethod extends StatelessWidget {
  const _DeliveryMethod({required this.controller});
  final CheckoutViewModel controller;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(emoji: '🚚', title: 'Delivery Method'),
        const SizedBox(height: 8),
        Obx(() {
          final methods = controller.deliveryMethods;
          if (methods.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'No delivery methods are available for this address.'.tr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            );
          }
          final updating = controller.isUpdatingDeliveryMethod.value;
          return Column(
            children: methods.map((method) {
              final selected =
                  controller.selectedDeliveryMethod.value?.id == method.id;
              return InkWell(
                key: Key('checkout-delivery-method-${method.id}'),
                onTap: updating
                    ? null
                    : () => controller.selectDeliveryMethod(method),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      left: selected
                          ? BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 4,
                            )
                          : BorderSide.none,
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 18,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method.name,
                              style: TextStyle(
                                color: selected
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                            if (method.description?.isNotEmpty == true) ...[
                              const SizedBox(height: 2),
                              Text(
                                method.description!,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (updating && selected)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Text(
                          method.formattedPrice?.isNotEmpty == true
                              ? method.formattedPrice!
                              : CartPage.money(method.price),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    ),
  );
}

class _AddressSelectDialog extends StatelessWidget {
  const _AddressSelectDialog({required this.controller});
  final CheckoutViewModel controller;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Select Shipping Address'.tr),
    contentPadding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
    content: SizedBox(
      width: double.maxFinite,
      child: controller.addresses.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No shipping addresses found.'.tr,
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: controller.addresses.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final address = controller.addresses[index];
                final selected =
                    address.id == controller.selectedAddress.value?.id;
                final detail = [
                  address.building,
                  address.streetAddress,
                  address.cityTownship,
                  address.stateRegion,
                ].where((value) => value.trim().isNotEmpty).join(', ');
                return ListTile(
                  key: Key('checkout-address-${address.id}'),
                  onTap: () => Navigator.of(context).pop(address),
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    address.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    [
                      address.phone,
                      detail,
                    ].where((value) => value.trim().isNotEmpty).join('\n'),
                  ),
                  isThreeLine: address.phone.isNotEmpty && detail.isNotEmpty,
                );
              },
            ),
    ),
    actions: [
      TextButton(onPressed: Get.back, child: Text('Cancel'.tr)),
      FilledButton.icon(
        key: const Key('checkout-add-shipping-address'),
        onPressed: () => Navigator.of(context).pop(_addShippingAddressAction),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text('Add Address'.tr),
      ),
    ],
  );
}

class _PaymentMethod extends StatelessWidget {
  const _PaymentMethod({required this.controller});
  final CheckoutViewModel controller;
  static const methods = [
    'Cash on Delivery',
    'KBZPay',
    'WavePay',
    'Visa/Master',
    'MPU',
  ];

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(emoji: '💳', title: 'Payment Method'),
        SizedBox(height: 8),
        Obx(
          () => Column(
            children: methods.map((method) {
              final selected = controller.selectedPayment.value == method;
              return InkWell(
                key: Key('payment-$method'),
                onTap: () => controller.selectPayment(method),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    border: Border(
                      left: selected
                          ? BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 4,
                            )
                          : BorderSide.none,
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 18,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 10),
                      Text(
                        method,
                        style: TextStyle(
                          color: selected
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (selected)
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}

class _ItemsSummary extends StatelessWidget {
  const _ItemsSummary({required this.controller});
  final CheckoutViewModel controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final items = controller.cart.items;
    final visible = controller.itemsExpanded.value
        ? items
        : items.take(1).toList();
    return _Panel(
      child: Column(
        children: [
          _SectionTitle(
            title: 'Order Items (${items.length})',
            action: controller.itemsExpanded.value ? 'Collapse' : 'Expand',
            onAction: () => controller.itemsExpanded.toggle(),
          ),
          SizedBox(height: 14),
          ...visible.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.imageUrl?.isNotEmpty == true
                        ? Image.network(
                            item.imageUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const _CheckoutImageFallback(),
                          )
                        : item.imageAsset.isNotEmpty
                        ? Image.asset(
                            item.imageAsset,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const _CheckoutImageFallback(),
                          )
                        : const _CheckoutImageFallback(),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${item.quantity} x ${CartPage.money(item.unitPrice)}'
                              .tr,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CartPage.money(item.quantity * item.unitPrice),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!controller.itemsExpanded.value && items.length > 1)
            Text(
              '+${items.length - 1} more items'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  });
}

class _CheckoutImageFallback extends StatelessWidget {
  const _CheckoutImageFallback();

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    alignment: Alignment.center,
    child: const Icon(Icons.image_not_supported_outlined, size: 20),
  );
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.controller});
  final CheckoutViewModel controller;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      children: [
        _PriceRow('Product Total', CartPage.money(controller.cart.subtotal)),
        _PriceRow('Shipping', CartPage.money(controller.cart.shipping)),
        _PriceRow(
          'Discount',
          '−${CartPage.money(controller.cart.discount)}',
          green: true,
        ),
        Divider(height: 18, color: Theme.of(context).dividerColor),
        Row(
          children: [
            Text(
              'Grand Total'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            Text(
              CartPage.money(controller.cart.grandTotal),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(this.label, this.value, {this.green = false});
  final String label;
  final String value;
  final bool green;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Text(
          label.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: green
                ? AppColors.success
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

class _DeliveryNotes extends StatelessWidget {
  const _DeliveryNotes({required this.controller});
  final CheckoutViewModel controller;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(emoji: '📝', title: 'Delivery Notes'),
        const SizedBox(height: 14),
        TextField(
          controller: controller.notesController,
          minLines: 3,
          maxLines: 3,
          onEditingComplete: controller.updateDeliveryNotes,
          onTapOutside: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
            controller.updateDeliveryNotes();
          },
          decoration: InputDecoration(
            hintText: 'Add delivery instructions...'.tr,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
        ),
      ],
    ),
  );
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.controller});
  final CheckoutViewModel controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => InkWell(
      onTap: () => controller.termsAccepted.toggle(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            controller.termsAccepted.value
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PlaceOrderBar extends StatelessWidget {
  const _PlaceOrderBar({
    required this.total,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });
  final int total;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    height: 82,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 6,
          offset: Offset(0, -4),
        ),
      ],
    ),
    child: Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grand Total'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            Text(
              CartPage.money(total),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const Spacer(),
        FilledButton.icon(
          key: const Key('place-order'),
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: enabled
                ? AppColors.accent
                : Theme.of(context).disabledColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          label: Text((loading ? 'Placing Order...' : 'Place Order').tr),
          iconAlignment: IconAlignment.end,
          icon: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.bolt_rounded, size: 18),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.emoji,
    this.action,
    this.onAction,
  });
  final String title;
  final String? emoji;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (emoji != null) ...[
        Text(emoji!, style: TextStyle(fontSize: 14)),
        SizedBox(width: 8),
      ],
      Text(
        title.tr,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      const Spacer(),
      if (action != null)
        InkWell(
          onTap: onAction,
          child: Text(
            action!,
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ],
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}
