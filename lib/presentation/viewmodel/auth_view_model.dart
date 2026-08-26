import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/routes/app_routes.dart';
import 'package:mobile_hexy/core/error/exceptions.dart';
import 'package:mobile_hexy/domain/usecases/login_user.dart';

class AuthViewModel extends GetxController {
  AuthViewModel(this._loginUser);

  final LoginUser _loginUser;

  final email = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final passwordHidden = true.obs;
  final confirmPasswordHidden = true.obs;
  final isLoggingIn = false.obs;
  final otp = List.generate(6, (_) => TextEditingController());
  final otpFocus = List.generate(6, (_) => FocusNode());

  void togglePassword() => passwordHidden.toggle();
  void toggleConfirmPassword() => confirmPasswordHidden.toggle();

  Future<void> login() async {
    final login = email.text.trim();
    if (login.isEmpty) return _message('Please enter your email or username.');
    if (password.text.isEmpty) return _message('Please enter your password.');
    if (isLoggingIn.value) return;

    isLoggingIn.value = true;
    try {
      await _loginUser(login: login, password: password.text);
      Get.offAllNamed<void>(AppRoutes.home);
    } on ServerException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('Unable to login. Please try again.');
    } finally {
      isLoggingIn.value = false;
    }
  }

  void register() {
    if (username.text.trim().isEmpty) {
      return _message('Please enter your username.');
    }
    if (!_validEmail()) return;
    if (password.text.length < 8) {
      return _message('Password must contain at least 8 characters.');
    }
    Get.offAllNamed<void>(AppRoutes.home);
  }

  void sendCode() {
    if (_validEmail()) {
      Get.toNamed<void>(
        AppRoutes.otpVerification,
        arguments: email.text.trim(),
      );
    }
  }

  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) otpFocus[index + 1].requestFocus();
    if (value.isEmpty && index > 0) otpFocus[index - 1].requestFocus();
  }

  void verifyCode() {
    if (otp.map((field) => field.text).join().length != 6) {
      return _message('Please enter the 6-digit verification code.');
    }
    Get.toNamed<void>(AppRoutes.resetPassword);
  }

  void resetPassword() {
    if (password.text.length < 8) {
      return _message('Password must contain at least 8 characters.');
    }
    if (password.text != confirmPassword.text) {
      return _message('Passwords do not match.');
    }
    Get.offNamed<void>(AppRoutes.passwordUpdated);
  }

  bool _validEmail() {
    if (!GetUtils.isEmail(email.text.trim())) {
      _message('Please enter a valid email address.');
      return false;
    }
    return true;
  }

  void _message(String message) => Get.snackbar(
    'Check your details',
    message,
    snackPosition: SnackPosition.BOTTOM,
  );

  @override
  void onClose() {
    email.dispose();
    username.dispose();
    password.dispose();
    confirmPassword.dispose();
    for (final field in otp) {
      field.dispose();
    }
    for (final focus in otpFocus) {
      focus.dispose();
    }
    super.onClose();
  }
}
