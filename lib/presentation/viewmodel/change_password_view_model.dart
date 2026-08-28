import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/models/request/change_password_request.dart';
import 'package:mobile_hexy/domain/usecases/change_password.dart';
import 'package:mobile_hexy/extensions/show_change_password_dialog.dart';

class ChangePasswordViewModel extends BaseViewModel {
  ChangePasswordViewModel(this._changePassword);

  final ChangePassword _changePassword;
  final current = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  final currentHidden = true.obs;
  final passwordHidden = true.obs;
  final confirmHidden = true.obs;
  final isSaving = false.obs;
  final revision = 0.obs;
  bool _isConfirmationOpen = false;

  bool get hasLength => password.text.length >= 8;
  bool get hasUppercase => password.text.contains(RegExp('[A-Z]'));
  bool get hasNumber => password.text.contains(RegExp('[0-9]'));
  bool get hasSpecial => password.text.contains(RegExp(r'[^A-Za-z0-9]'));
  bool get matches => password.text.isNotEmpty && password.text == confirm.text;
  int get strength => [
    hasLength,
    hasUppercase,
    hasNumber,
    hasSpecial,
  ].where((value) => value).length;

  void updateRequirements(String _) => revision.value++;

  Future<void> save() async {
    if (current.text.isEmpty ||
        !hasLength ||
        !hasUppercase ||
        !hasNumber ||
        !hasSpecial ||
        !matches) {
      return _showError(
        'Complete all password requirements and make sure passwords match.',
      );
    }
    if (current.text == password.text) {
      return _showError('Your new password must be different.');
    }
    if (isSaving.value || _isConfirmationOpen) return;

    _isConfirmationOpen = true;
    final confirmed = await showChangePasswordDialog();
    _isConfirmationOpen = false;
    if (!confirmed) return;

    isSaving.value = true;
    try {
      await _changePassword(
        ChangePasswordRequest(
          currentPassword: current.text,
          newPassword: password.text,
        ),
      );
      current.clear();
      password.clear();
      confirm.clear();
      revision.value++;
      Get.back<void>();
      Get.snackbar(
        'Password changed',
        'Your password has been updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSaving.value = false;
    }
  }

  void _showError(String message) => Get.snackbar(
    'Check your password',
    message,
    snackPosition: SnackPosition.BOTTOM,
  );

  @override
  void onClose() {
    current.dispose();
    password.dispose();
    confirm.dispose();
    super.onClose();
  }
}
