import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/routes/app_routes.dart';

class ProfileViewModel extends GetxController {
  final darkModeEnabled = Get.isDarkMode.obs;
  final currentLanguage = 'English'.obs;

  void toggleDarkMode(bool enabled) {
    darkModeEnabled.value = enabled;
    Get.changeThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  void openItem(String label) {
    if (label == 'Language') {
      _showLanguagePicker();
      return;
    }
    final route = switch (label) {
      'Personal Information' => AppRoutes.personalInformation,
      'Change Password' => AppRoutes.changePassword,
      'Contact Us' => AppRoutes.contactUs,
      'My Orders' => AppRoutes.myOrders,
      'Pending' => AppRoutes.myOrders,
      'Processing' => AppRoutes.myOrders,
      'Refunded' => AppRoutes.myOrders,
      'Delivered' => AppRoutes.myOrders,
      'Cancelled' => AppRoutes.myOrders,
      _ => null,
    };
    if (route != null) {
      Get.toNamed<void>(
        route,
        arguments: route == AppRoutes.myOrders && label != 'My Orders'
            ? label
            : null,
      );
      return;
    }
    if (label == 'Shipping Addresses') {
      Get.toNamed<void>(AppRoutes.addressForm);
      return;
    }
    Get.snackbar(
      label,
      '$label is coming soon.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _showLanguagePicker() {
    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('English'.tr),
                trailing: currentLanguage.value == 'English'
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => _setLanguage('English', const Locale('en', 'US')),
              ),
              ListTile(
                title: Text('Myanmar'.tr),
                trailing: currentLanguage.value == 'Myanmar'
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => _setLanguage('Myanmar', const Locale('my', 'MM')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setLanguage(String language, Locale locale) {
    currentLanguage.value = language;
    Get.updateLocale(locale);
    Get.back<void>();
  }

  void logOut() {
    Get.snackbar(
      'Log out',
      'Log out action selected.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
