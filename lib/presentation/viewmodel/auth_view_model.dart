import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/base/exceptions.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/domain/usecases/login_user.dart';
import 'package:mobile_hexy/domain/usecases/register_user.dart';

class AuthViewModel extends BaseViewModel {
  AuthViewModel(this._loginUser, this._registerUser, this._secureStorage);

  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final SecureStorage _secureStorage;

  final email = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final passwordHidden = true.obs;
  final confirmPasswordHidden = true.obs;
  final isLoggingIn = false.obs;
  final isRegistering = false.obs;
  final rememberLogin = false.obs;
  final otp = List.generate(6, (_) => TextEditingController());
  final otpFocus = List.generate(6, (_) => FocusNode());

  void togglePassword() => passwordHidden.toggle();
  void toggleConfirmPassword() => confirmPasswordHidden.toggle();

  @override
  void onInit() {
    super.onInit();
    _restoreRememberedLogin();
  }

  Future<void> _restoreRememberedLogin() async {
    final remembered = await _secureStorage.read(
      AppConstants.rememberedLoginKey,
    );
    if (remembered == null || remembered.isEmpty) return;
    email.text = remembered;
    password.text =
        await _secureStorage.read(AppConstants.rememberedPasswordKey) ?? '';
    rememberLogin.value = true;
  }

  Future<void> setRememberLogin(bool? value) async {
    rememberLogin.value = value ?? false;
    if (!rememberLogin.value) {
      await _secureStorage.remove(AppConstants.rememberedLoginKey);
      await _secureStorage.remove(AppConstants.rememberedPasswordKey);
    }
  }

  Future<void> login() async {
    final login = email.text.trim();
    if (login.isEmpty) return _message('Please enter your email or username.');
    if (password.text.isEmpty) return _message('Please enter your password.');
    if (isLoggingIn.value) return;

    isLoggingIn.value = true;
    try {
      await _loginUser(login: login, password: password.text);
      if (rememberLogin.value) {
        await _secureStorage.write(AppConstants.rememberedLoginKey, login);
        await _secureStorage.write(
          AppConstants.rememberedPasswordKey,
          password.text,
        );
      } else {
        await _secureStorage.remove(AppConstants.rememberedLoginKey);
        await _secureStorage.remove(AppConstants.rememberedPasswordKey);
      }
      final loginArguments = Get.arguments;
      final returnProductId = loginArguments is Map
          ? int.tryParse(loginArguments['returnProductId']?.toString() ?? '')
          : null;
      if (returnProductId != null && returnProductId > 0) {
        final productArguments = <String, Object?>{
          'productId': returnProductId,
          'pendingAction': loginArguments['pendingAction'],
          'quantity': loginArguments['quantity'],
        };
        Get.offAllNamed<dynamic>(AppRoutes.home);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed<dynamic>(
            AppRoutes.productDetail,
            arguments: productArguments,
          );
        });
        return;
      }
      final tabIndex = loginArguments is Map
          ? loginArguments['tabIndex']
          : null;
      await Get.offAllNamed<dynamic>(
        AppRoutes.home,
        arguments: tabIndex is int ? {'tabIndex': tabIndex} : null,
      );
    } on ServerException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('Unable to login. Please try again.');
    } finally {
      isLoggingIn.value = false;
    }
  }

  Future<void> register() async {
    if (username.text.trim().isEmpty) {
      return _message('Please enter your username.');
    }
    if (!_validEmail()) return;
    if (password.text.length < 8) {
      return _message('Password must contain at least 8 characters.');
    }
    if (password.text != confirmPassword.text) {
      return _message('Passwords do not match.');
    }
    if (isRegistering.value) return;

    isRegistering.value = true;
    try {
      await _registerUser(
        username: username.text.trim(),
        email: email.text.trim(),
        password: password.text,
      );
      await Get.offAllNamed<dynamic>(AppRoutes.home);
    } on ServerException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('Unable to create your account. Please try again.');
    } finally {
      isRegistering.value = false;
    }
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
