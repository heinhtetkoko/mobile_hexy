import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/routes/app_routes.dart';
import 'package:mobile_hexy/app/theme/app_colors.dart';
import 'package:mobile_hexy/presentation/view/cart_page.dart';
import 'package:mobile_hexy/presentation/viewmodel/checkout_view_model.dart';

class CheckoutPage extends GetView<CheckoutViewModel> {
  const CheckoutPage({super.key});

  static const _border = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          const _CheckoutHeader(),
          const _ProgressSteps(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const _DeliveryInformation(),
                SizedBox(height: 10),
                const _DeliveryMethod(),
                SizedBox(height: 10),
                _PaymentMethod(controller: controller),
                SizedBox(height: 10),
                _ItemsSummary(controller: controller),
                SizedBox(height: 10),
                _PriceBreakdown(controller: controller),
                SizedBox(height: 10),
                _DeliveryNotes(controller: controller),
                SizedBox(height: 12),
                _TermsRow(controller: controller),
              ],
            ),
          ),
          Obx(
            () => _PlaceOrderBar(
              total: controller.cart.grandTotal,
              enabled: controller.termsAccepted.value,
              onPressed: controller.placeOrder,
            ),
          ),
        ],
      ),
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
              color: AppColors.surface,
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
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
    child: Row(
      children: [
        _Step(
          icon: Icons.check_rounded,
          label: 'Cart',
          color: AppColors.success,
        ),
        Expanded(child: Divider(color: AppColors.primary, thickness: 2)),
        _Step(number: '2', label: 'Checkout', color: AppColors.primary),
        Expanded(child: Divider(color: Color(0xFFF3F4F6), thickness: 2)),
        _Step(
          number: '3',
          label: 'Confirm',
          color: Color(0xFF9CA3AF),
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
          color: pale ? const Color(0xFFF3F4F6) : color,
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
  const _DeliveryInformation();

  @override
  Widget build(BuildContext context) => _Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          emoji: '📍',
          title: 'Delivery Information',
          action: 'Edit',
          onAction: () =>
              Get.toNamed<void>('${AppRoutes.addressForm}?mode=edit'),
        ),
        SizedBox(height: 14),
        Text(
          'John Smith'.tr,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 4),
        Text(
          '09-123456789'.tr,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        SizedBox(height: 4),
        Text(
          'No.25, Main Street, Sanchaung Township, Yangon'.tr,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    ),
  );
}

class _DeliveryMethod extends StatelessWidget {
  const _DeliveryMethod();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFEEF2FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🚚 Standard Delivery'.tr,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Estimated: 2–3 business days'.tr,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          '3,000 Ks'.tr,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
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
                          ? const BorderSide(color: AppColors.primary, width: 4)
                          : BorderSide.none,
                      bottom: const BorderSide(color: Color(0xFFF3F4F6)),
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
                            ? AppColors.primary
                            : const Color(0xFF9CA3AF),
                      ),
                      SizedBox(width: 10),
                      Text(
                        method,
                        style: TextStyle(
                          color: selected
                              ? Theme.of(context).colorScheme.onSurface
                              : AppColors.textSecondary,
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
                          color: AppColors.primary,
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
                    child: Image.asset(
                      item.id == 'STA-1001'
                          ? 'assets/images/checkout/notebook.png'
                          : item.imageAsset,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
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
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CartPage.money(item.quantity * item.unitPrice),
                    style: TextStyle(
                      color: AppColors.primary,
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
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
            ),
        ],
      ),
    );
  });
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.controller});
  final CheckoutViewModel controller;

  @override
  Widget build(BuildContext context) => Obx(
    () => _Panel(
      child: Column(
        children: [
          _PriceRow('Product Total', CartPage.money(controller.cart.subtotal)),
          _PriceRow('Shipping', CartPage.money(controller.cart.shipping)),
          _PriceRow(
            'Discount',
            '−${CartPage.money(controller.cart.discount)}',
            green: true,
          ),
          const Divider(height: 18, color: CheckoutPage._border),
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
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
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
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: green ? AppColors.success : Colors.black,
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
        SizedBox(height: 14),
        TextField(
          controller: controller.notesController,
          minLines: 3,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add delivery instructions...'.tr,
            hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: CheckoutPage._border),
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
            color: AppColors.primary,
            size: 20,
          ),
          SizedBox(width: 10),
          const Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                children: [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
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
    required this.onPressed,
  });
  final int total;
  final bool enabled;
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
          key: const Key('place-order'),
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: enabled
                ? AppColors.accent
                : const Color(0xFF9CA3AF),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          label: Text('Place Order'.tr),
          iconAlignment: IconAlignment.end,
          icon: Icon(Icons.bolt_rounded, size: 18),
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
      border: Border.all(color: CheckoutPage._border),
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
