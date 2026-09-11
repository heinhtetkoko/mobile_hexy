import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showAddToCartSuccessDialog({
  required String productName,
  int quantity = 1,
}) => Get.dialog<void>(
  AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF22C55E),
            size: 40,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Added to Cart'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          quantity > 1 ? '$productName × $quantity' : productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Get.theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    ),
    actionsAlignment: MainAxisAlignment.center,
    actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
    actions: [
      SizedBox(
        width: double.infinity,
        child: FilledButton(onPressed: Get.back, child: Text('OK'.tr)),
      ),
    ],
  ),
  barrierDismissible: true,
);
