import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';
import 'package:mobile_hexy/presentation/view/cart_page.dart';
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

  void _showAction(String title) => Get.snackbar(
    title,
    '$title is coming soon.',
    snackPosition: SnackPosition.BOTTOM,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
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
                    _OrderReceipt(controller: controller),
                    const SizedBox(height: 24),
                    const _DeliveryDestination(),
                    const SizedBox(height: 24),
                    _ItemPreview(onViewOrder: () => _showAction('View Order')),
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
                        onPressed: () => Get.offAllNamed<void>(AppRoutes.home),
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
        'Payment Successful!'.tr,
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
  const _OrderReceipt({required this.controller});
  final CheckoutViewModel controller;

  @override
  Widget build(BuildContext context) => Container(
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
        const _ReceiptRow('Order Number', '#STA-2025-08742', bold: true),
        const _ReceiptRow('Order Date', '02 Jul 2025, 14:32'),
        _ReceiptRow(
          'Payment Method',
          controller.selectedPayment.value,
          icon: Icons.account_balance_wallet_outlined,
        ),
        const _ReceiptRow(
          'Estimated Delivery',
          '4–5 Jul 2025',
          green: true,
          bold: true,
        ),
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
              CartPage.money(controller.cart.grandTotal),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    ),
  );
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
  const _DeliveryDestination();

  @override
  Widget build(BuildContext context) => Container(
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
          'John Smith · No.25, Main Street, Sanchaung, Yangon'.tr,
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

class _ItemPreview extends StatelessWidget {
  const _ItemPreview({required this.onViewOrder});
  final VoidCallback onViewOrder;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Text(
            '2 of 4 items'.tr,
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
      Row(
        children: [
          for (var index = 1; index <= 3; index++) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/payment_success/item_$index.png',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
          ],
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
              '+1'.tr,
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
