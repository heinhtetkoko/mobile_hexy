import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/base/exceptions.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/domain/usecases/login_user.dart';
import 'package:mobile_hexy/domain/usecases/login_with_google.dart';
import 'package:mobile_hexy/domain/usecases/register_user.dart';
import 'package:mobile_hexy/data/datasources/auth_remote_data_source.dart';

class AuthViewModel extends BaseViewModel {
  AuthViewModel(
    this._loginUser,
    this._loginWithGoogle,
    this._registerUser,
    this._secureStorage,
    this._authRemoteDataSource,
  );

  final LoginUser _loginUser;
  final LoginWithGoogle _loginWithGoogle;
  final RegisterUser _registerUser;
  final SecureStorage _secureStorage;
  final AuthRemoteDataSource _authRemoteDataSource;

  final email = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final passwordHidden = true.obs;
  final confirmPasswordHidden = true.obs;
  final isLoggingIn = false.obs;
  final isGoogleLoggingIn = false.obs;
  final isRegistering = false.obs;
  final isRequestingOtp = false.obs;
  final isVerifyingOtp = false.obs;
  final isResettingPassword = false.obs;
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
    if (Get.currentRoute != AppRoutes.login) return;
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
      await _finishLogin();
    } on ServerException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('Unable to login. Please try again.');
    } finally {
      isLoggingIn.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    if (isGoogleLoggingIn.value || isLoggingIn.value) return;
    isGoogleLoggingIn.value = true;
    try {
      const serverClientId = String.fromEnvironment(
        'GOOGLE_SERVER_CLIENT_ID',
        defaultValue:
            '976257170411-ilje208fkdmfdsou1ko0ccqr10vkru96.apps.googleusercontent.com',
      );
      if (serverClientId.isEmpty) {
        _message(
          'Google Sign-In is not configured. Add GOOGLE_SERVER_CLIENT_ID and rebuild the app.',
        );
        return;
      }
      final googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
        serverClientId: serverClientId,
      );
      final account = await googleSignIn.signIn();
      if (account == null) return;
      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        _message(
          'Google did not return an ID token. Configure GOOGLE_SERVER_CLIENT_ID.',
        );
        return;
      } else {
        print('Google ID Token: $idToken');
      }
      await _loginWithGoogle(idToken);
      await _finishLogin();
    } on ServerException catch (error) {
      _message(error.message);
    } catch (error) {
      _message(
        error
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('PlatformException', 'Google Sign-In error'),
      );
    } finally {
      isGoogleLoggingIn.value = false;
    }
  }

  Future<void> _finishLogin() async {
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
    final tabIndex = loginArguments is Map ? loginArguments['tabIndex'] : null;
    await Get.offAllNamed<dynamic>(
      AppRoutes.home,
      arguments: tabIndex is int ? {'tabIndex': tabIndex} : null,
    );
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

  Future<void> sendCode() async {
    if (!_validEmail() || isRequestingOtp.value) return;
    final value = email.text.trim();
    isRequestingOtp.value = true;
    try {
      await _authRemoteDataSource.requestPasswordOtp(value);
      Get.toNamed<void>(AppRoutes.otpVerification, arguments: {'email': value});
    } on ServerException catch (error) {
      _message(error.message);
    } catch (error) {
      _message(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      isRequestingOtp.value = false;
    }
  }

  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) otpFocus[index + 1].requestFocus();
    if (value.isEmpty && index > 0) otpFocus[index - 1].requestFocus();
  }

  Future<void> verifyCode() async {
    final code = otp.map((field) => field.text).join();
    if (code.length != 6) {
      return _message('Please enter the 6-digit verification code.');
    }
    if (isVerifyingOtp.value) return;
    final arguments = Get.arguments;
    final resetEmail = arguments is Map
        ? arguments['email']?.toString() ?? ''
        : arguments?.toString() ?? '';
    if (!GetUtils.isEmail(resetEmail)) {
      return _message('The reset email address is unavailable.');
    }
    isVerifyingOtp.value = true;
    try {
      final resetToken = await _authRemoteDataSource.verifyPasswordOtp(
        email: resetEmail,
        otp: code,
      );
      Get.toNamed<void>(
        AppRoutes.resetPassword,
        arguments: {'email': resetEmail, 'resetToken': resetToken},
      );
    } on ServerException catch (error) {
      _message(error.message);
    } catch (error) {
      _message(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (password.text.length < 8) {
      return _message('Password must contain at least 8 characters.');
    }
    if (password.text != confirmPassword.text) {
      return _message('Passwords do not match.');
    }
    if (isResettingPassword.value) return;
    final arguments = Get.arguments;
    final resetToken = arguments is Map
        ? arguments['resetToken']?.toString() ?? ''
        : '';
    if (resetToken.isEmpty) {
      return _message(
        'The password reset session is invalid. Request a new code.',
      );
    }
    isResettingPassword.value = true;
    try {
      await _authRemoteDataSource.resetForgottenPassword(
        resetToken: resetToken,
        newPassword: password.text,
      );
      await Future.wait([
        _secureStorage.remove(AppConstants.accessTokenKey),
        _secureStorage.remove(AppConstants.rememberedLoginKey),
        _secureStorage.remove(AppConstants.rememberedPasswordKey),
      ]);
      rememberLogin.value = false;
      Get.offAllNamed<void>(AppRoutes.passwordUpdated);
    } on ServerException catch (error) {
      _message(error.message);
    } catch (error) {
      _message(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      isResettingPassword.value = false;
    }
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
