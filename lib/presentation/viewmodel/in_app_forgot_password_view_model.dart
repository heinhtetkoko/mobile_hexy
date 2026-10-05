import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/core/base/exceptions.dart';
import 'package:mobile_hexy/data/datasources/auth_remote_data_source.dart';
import 'package:mobile_hexy/domain/usecases/logout_user.dart';

class InAppForgotPasswordViewModel extends BaseViewModel {
  InAppForgotPasswordViewModel(this._authRemoteDataSource, this._logoutUser);

  final AuthRemoteDataSource _authRemoteDataSource;
  final LogoutUser _logoutUser;
  final email = TextEditingController();
  final isSubmitting = false.obs;

  Future<void> submit() async {
    if (isSubmitting.value) return;
    final value = email.text.trim();
    if (!GetUtils.isEmail(value)) {
      _showError('Please enter a valid email address.');
      return;
    }
    isSubmitting.value = true;
    try {
      await _authRemoteDataSource.requestPasswordOtp(value);
      await _logoutUser();
      // Do not await the route's result: it completes when Login is closed.
      Get.offAllNamed<void>(AppRoutes.login);
      Get.snackbar(
        'Reset email sent',
        'Check your email for the password reset code. Please log in again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on ServerException catch (error) {
      _showError(error.message);
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showError(String message) => Get.snackbar(
    'Unable to request password reset',
    message,
    snackPosition: SnackPosition.BOTTOM,
  );

  @override
  void onClose() {
    email.dispose();
    super.onClose();
  }
}
