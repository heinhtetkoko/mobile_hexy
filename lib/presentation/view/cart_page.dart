import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';
import 'package:mobile_hexy/data/models/cart_item.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';

class CartPage extends GetView<CartViewModel> {
  const CartPage({super.key});

  static String money(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
      buffer.write(digits[index]);
    }
    return '$buffer Ks';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Obx(() => _CartHeader(count: controller.items.length)),
          Expanded(
            child: Obx(
              () => controller.isLoading.value && controller.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : controller.errorMessage.value != null &&
                        controller.items.isEmpty
                  ? _CartError(
                      message: controller.errorMessage.value!,
                      onRetry: controller.loadCart,
                    )
                  : controller.items.isEmpty
                  ? const _EmptyCart()
                  : RefreshIndicator(
                      onRefresh: controller.loadCart,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        children: [
                          ...controller.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CartItemCard(
                                item: item,
                                onIncrement: () => controller.increment(item),
                                onDecrement: () => controller.decrement(item),
                                onRemove: () => controller.remove(item),
                              ),
                            ),
                          ),
                          _CouponCard(controller: controller),
                          const SizedBox(height: 12),
                          _OrderSummary(controller: controller),
                        ],
                      ),
                    ),
            ),
          ),
          Obx(
            () => controller.items.isEmpty
                ? const SizedBox.shrink()
                : _CheckoutBar(
                    total: controller.grandTotal,
                    onCheckout: controller.checkout,
                  ),
          ),
        ],
      ),
    ),
  );
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.count});
  final int count;

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
        const SizedBox(width: 70),
        Expanded(
          child: Text(
            'Shopping Cart'.tr,
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
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count ${count == 1 ? 'Item'.tr : 'Items'.tr}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
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
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _CartImageFallback(),
                    )
                  : item.imageAsset.isNotEmpty
                  ? Image.asset(
                      item.imageAsset,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    )
                  : const _CartImageFallback(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'SKU: ${item.sku}'.tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(item.variantColor),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.variant,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        CartPage.money(item.unitPrice),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      _QuantityButton(
                        symbol: '−',
                        onTap: onDecrement,
                        filled: false,
                      ),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${item.quantity}'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _QuantityButton(
                        symbol: '+',
                        onTap: onIncrement,
                        filled: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: ${CartPage.money(item.unitPrice * item.quantity)}'
                          .tr,
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(height: 24, color: Theme.of(context).dividerColor),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            key: Key('remove-cart-${item.id}'),
            onTap: onRemove,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 15,
                ),
                SizedBox(width: 5),
                Text(
                  'Remove'.tr,
                  style: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.symbol,
    required this.onTap,
    required this.filled,
  });
  final String symbol;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: filled
            ? null
            : Border.all(color: Theme.of(context).dividerColor),
        shape: BoxShape.circle,
      ),
      child: Text(
        symbol,
        style: TextStyle(
          color: filled
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.controller});
  final CartViewModel controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coupon Code'.tr,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: controller.couponController,
                  decoration: InputDecoration(
                    hintText: 'Enter Code'.tr,
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: controller.applyCoupon,
              child: Text('Apply'.tr),
            ),
          ],
        ),
      ],
    ),
  );
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.controller});
  final CartViewModel controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final apiRows = controller.orderSummaryRows.toList(growable: false);
    final rows = apiRows.isNotEmpty
        ? apiRows
        : [
            CartSummaryRow(
              key: 'subtotal',
              label: 'Subtotal',
              amount: controller.subtotal,
              isTotal: false,
              isDiscount: false,
            ),
            CartSummaryRow(
              key: 'shipping',
              label: 'Shipping',
              amount: controller.shipping,
              isTotal: false,
              isDiscount: false,
            ),
            CartSummaryRow(
              key: 'discount',
              label: 'Discount',
              amount: controller.discount,
              isTotal: false,
              isDiscount: true,
            ),
            CartSummaryRow(
              key: 'grand_total',
              label: 'Grand Total',
              amount: controller.grandTotal,
              isTotal: true,
              isDiscount: false,
            ),
          ];
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary'.tr,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          for (final row in rows.where((row) => !row.isTotal))
            _SummaryRow(row.label, _summaryDisplay(row), green: row.isDiscount),
          for (final row in rows.where((row) => row.isTotal))
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    _summaryDisplay(row),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  });

  String _summaryDisplay(CartSummaryRow row) {
    final formatted = row.formattedValue?.trim();
    if (formatted != null && formatted.isNotEmpty) return formatted;
    final value = CartPage.money(row.amount.abs());
    return row.isDiscount && row.amount != 0 ? '−$value' : value;
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.green = false});
  final String label;
  final String value;
  final bool green;

  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Row(
      children: [
        Text(
          label.tr,
          style: TextStyle(
            color: green
                ? AppColors.success
                : Theme.of(context).colorScheme.onSurfaceVariant,
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

// Retained for a possible checkout-address step; intentionally hidden in cart.
// ignore: unused_element
class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onEdit});
  final CartShippingAddress? address;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('🏠'.tr, style: TextStyle(fontSize: 14)),
            SizedBox(width: 8),
            Text(
              'Shipping Address'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Spacer(),
            InkWell(
              onTap: onEdit,
              child: Text(
                'Change'.tr,
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address?.name.isNotEmpty == true
                          ? address!.name
                          : 'Select a shipping address'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (address?.phone.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        address!.phone,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (address?.address.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        address!.address,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                color: AppColors.textSecondary,
                size: 17,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Retained for a possible checkout-delivery step; intentionally hidden in cart.
// ignore: unused_element
class _ShippingMethod extends StatelessWidget {
  const _ShippingMethod({required this.controller});
  final CartViewModel controller;

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping Method'.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Column(
            children: controller.shippingMethods
                .map(
                  (method) => _MethodTile(
                    selected:
                        controller.selectedShippingMethodId.value == method.id,
                    title: method.name,
                    subtitle: method.description,
                    price: method.price > 0
                        ? CartPage.money(method.price)
                        : null,
                    onTap: () => controller.selectShippingMethod(method),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.selected,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.price,
  });
  final bool selected;
  final String title;
  final String? subtitle;
  final String? price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.primary : const Color(0xFF9CA3AF),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.tr,
                  style: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (price != null)
            Text(
              price!,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    ),
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

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.total, required this.onCheckout});
  final int total;
  final VoidCallback onCheckout;

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
              'Total'.tr,
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
          key: const Key('proceed-to-checkout'),
          onPressed: onCheckout,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          label: Text(
            'Proceed to Checkout'.tr,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconAlignment: IconAlignment.end,
          icon: Icon(Icons.arrow_forward_rounded, size: 18),
        ),
      ],
    ),
  );
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.shopping_cart_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 56,
        ),
        SizedBox(height: 12),
        Text(
          'Your cart is empty'.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _CartImageFallback extends StatelessWidget {
  const _CartImageFallback();

  @override
  Widget build(BuildContext context) => Container(
    width: 72,
    height: 72,
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    alignment: Alignment.center,
    child: Icon(
      Icons.inventory_2_outlined,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      size: 28,
    ),
  );
}

class _CartError extends StatelessWidget {
  const _CartError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: Color(0xFF9CA3AF),
            size: 52,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    ),
  );
}
