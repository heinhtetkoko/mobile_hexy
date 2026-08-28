import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showLogoutSheet() async {
  final result = await Get.bottomSheet<bool>(
    const _LogoutSheet(),
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
  );
  return result ?? false;
}

class _LogoutSheet extends StatelessWidget {
  const _LogoutSheet();

  static const _danger = Color(0xFFEF4444);
  static const _dangerSurface = Color(0xFFFFEDED);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 28,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: _dangerSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: _danger, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              'Log out of Hexy?'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can sign back in anytime with your account.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        side: BorderSide(color: colors.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text('Stay Logged In'.tr),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => Get.back(result: true),
                      style: FilledButton.styleFrom(
                        backgroundColor: _danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 19),
                      label: Text('Log Out'.tr),
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
