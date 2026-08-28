import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/domain/usecases/logout_user.dart';
import 'package:mobile_hexy/domain/usecases/get_profile.dart';
import 'package:mobile_hexy/extensions/show_logout_sheet.dart';
import 'package:mobile_hexy/data/models/profile_summary.dart';

class ProfileViewModel extends BaseViewModel {
  ProfileViewModel(this._logoutUser, this._getProfile);

  final LogoutUser _logoutUser;
  final GetProfile _getProfile;
  final darkModeEnabled = Get.isDarkMode.obs;
  final currentLanguage = 'English'.obs;
  final isLoggingOut = false.obs;
  final profile = Rxn<ProfileSummary>();
  final isProfileLoading = false.obs;
  final profileError = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isProfileLoading.value = true;
    profileError.value = null;
    try {
      profile.value = await _getProfile();
    } catch (_) {
      profileError.value = 'Could not load your profile.';
    } finally {
      isProfileLoading.value = false;
    }
  }

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

  Future<void> confirmLogout() async {
    if (isLoggingOut.value) return;
    final confirmed = await showLogoutSheet();
    if (confirmed) await logout();
  }

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      await _logoutUser();
      Get.offAllNamed<void>(AppRoutes.login);
    } catch (_) {
      Get.snackbar(
        'Unable to log out',
        'Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoggingOut.value = false;
    }
  }
}
