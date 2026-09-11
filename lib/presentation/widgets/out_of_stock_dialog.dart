import 'package:flutter/material.dart';
import 'package:get/get.dart';

bool isOutOfStockError(Object error) {
  final message = error.toString().toLowerCase();
  return message.contains('out of stock') ||
      message.contains('insufficient stock') ||
      message.contains('not enough stock') ||
      message.contains('available quantity');
}

Future<void> showOutOfStockDialog({String? productName}) => Get.dialog<void>(
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
            color: const Color(0xFFEF4444).withValues(alpha: .12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFFEF4444),
            size: 36,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Product is out of stock'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        if (productName?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            productName!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Get.theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ],
    ),
    actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
    actions: [
      SizedBox(
        width: double.infinity,
        child: FilledButton(onPressed: Get.back, child: Text('OK'.tr)),
      ),
    ],
  ),
);
