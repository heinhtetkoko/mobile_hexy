import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';
import 'package:mobile_hexy/data/models/cart_item.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';

class CartPage extends GetView<CartViewModel> {
  const CartPage({super.key});

  static const _border = Color(0xFFE5E7EB);

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
              () => controller.items.isEmpty
                  ? const _EmptyCart()
                  : ListView(
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
                        const SizedBox(height: 12),
                        _AddressCard(
                          onEdit: () => Get.toNamed<void>(
                            '${AppRoutes.addressForm}?mode=edit',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ShippingMethod(controller: controller),
                      ],
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
      boxShadow: [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
      ],
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
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count ${count == 1 ? 'Item'.tr : 'Items'.tr}',
                style: TextStyle(
                  color: AppColors.primary,
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
      border: Border.all(color: CartPage._border),
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
              child: Image.asset(
                item.imageAsset,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
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
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
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
                          border: Border.all(color: CartPage._border),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.variant,
                        style: TextStyle(
                          color: AppColors.textSecondary,
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
                          color: AppColors.primary,
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
        const Divider(height: 24, color: CartPage._border),
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
        color: filled ? AppColors.primary : AppColors.surface,
        border: filled ? null : Border.all(color: CartPage._border),
        shape: BoxShape.circle,
      ),
      child: Text(
        symbol,
        style: TextStyle(
          color: filled
              ? Colors.white
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
      color: AppColors.surface,
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
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(color: Color(0xFF9CA3AF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                        color: Color(0xFF9CA3AF),
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
  Widget build(BuildContext context) => _Panel(
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
        _SummaryRow('Subtotal', CartPage.money(controller.subtotal)),
        _SummaryRow('Shipping', CartPage.money(controller.shipping)),
        _SummaryRow(
          'Discount',
          '−${CartPage.money(controller.discount)}',
          green: true,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Row(
            children: [
              Text(
                'Grand Total'.tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                CartPage.money(controller.grandTotal),
                style: TextStyle(
                  color: AppColors.primary,
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
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.green = false});
  final String label;
  final String value;
  final bool green;

  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
    ),
    child: Row(
      children: [
        Text(
          label.tr,
          style: TextStyle(
            color: green ? AppColors.success : AppColors.textSecondary,
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

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.onEdit});
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
                      'John Smith'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '09-123456789'.tr,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No.25, Main Street, Sanchaung Township, Yangon'.tr,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
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
            children: [
              _MethodTile(
                selected: controller.deliverySelected.value,
                title: 'Delivery',
                subtitle: 'Est. 2-3 days',
                price: '3,000 Ks',
                onTap: () => controller.deliverySelected.value = true,
              ),
              _MethodTile(
                selected: !controller.deliverySelected.value,
                title: 'Pickup at Store',
                onTap: () => controller.deliverySelected.value = false,
              ),
            ],
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
      border: Border.all(color: CartPage._border),
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
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            Text(
              CartPage.money(total),
              style: TextStyle(
                color: AppColors.primary,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          label: Text('Proceed to Checkout'.tr),
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
          color: AppColors.textSecondary,
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
