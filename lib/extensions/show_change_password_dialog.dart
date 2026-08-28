import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';

Future<bool> showChangePasswordDialog() async {
  final result = await Get.dialog<bool>(
    const _ChangePasswordDialog(),
    barrierDismissible: false,
  );
  return result ?? false;
}

class _ChangePasswordDialog extends StatelessWidget {
  const _ChangePasswordDialog();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.password_rounded,
                color: AppColors.primary,
                size: 31,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Change your password?'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use your new password the next time you sign in.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        side: BorderSide(color: colors.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text('Cancel'.tr),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      key: const Key('confirm-change-password'),
                      onPressed: () => Get.back(result: true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text('Change'.tr),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
