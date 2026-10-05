import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/theme/app_theme.dart';
import 'package:mobile_hexy/presentation/view/auth_pages.dart';
import 'package:mobile_hexy/presentation/viewmodel/auth_view_model.dart';
import 'package:mobile_hexy/domain/usecases/login_user.dart';
import 'package:mobile_hexy/domain/usecases/login_with_google.dart';
import 'package:mobile_hexy/domain/usecases/register_user.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/data/datasources/auth_remote_data_source.dart';
import 'package:mobile_hexy/data/repositories/auth_repository_impl.dart';
import 'package:mobile_hexy/domain/usecases/logout_user.dart';
import 'package:mobile_hexy/presentation/view/in_app_forgot_password_page.dart';
import 'package:mobile_hexy/presentation/viewmodel/in_app_forgot_password_view_model.dart';

void main() {
  tearDown(Get.reset);

  for (final hasHistory in [false, true]) {
    testWidgets('Login back opens main view with history=$hasHistory', (
      tester,
    ) async {
      final storage = _Storage();
      final remote = AuthRemoteDataSource(_Api());
      final repository = AuthRepositoryImpl(remote, storage);
      Get.put(
        AuthViewModel(
          LoginUser(repository),
          LoginWithGoogle(repository),
          RegisterUser(repository),
          storage,
          remote,
        ),
      );
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.light,
          // Keep the test runner's wide Ahem glyphs within the auth card.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(0.6)),
            child: child!,
          ),
          initialRoute: hasHistory ? AppRoutes.home : AppRoutes.login,
          getPages: [
            GetPage(name: AppRoutes.login, page: LoginPage.new),
            GetPage(
              name: AppRoutes.home,
              page: () => const Scaffold(body: Text('Main view')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      if (hasHistory) {
        Get.toNamed<void>(AppRoutes.login);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.home);
      expect(find.text('Main view'), findsOneWidget);
      expect(Get.key.currentState!.canPop(), false);
    });
  }

  for (final success in [true, false]) {
    testWidgets('request success=$success controls logout and navigation', (
      tester,
    ) async {
      final api = _Api();
      final storage = _Storage();
      final remote = AuthRemoteDataSource(api);
      final vm = InAppForgotPasswordViewModel(
        remote,
        LogoutUser(AuthRepositoryImpl(remote, storage)),
      );
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/protected',
          getPages: [
            GetPage(
              name: '/protected',
              page: () => const Scaffold(body: Text('Protected')),
            ),
            GetPage(
              name: AppRoutes.inAppForgotPassword,
              page: InAppForgotPasswordPage.new,
              binding: BindingsBuilder(() {
                Get.put(vm);
              }),
            ),
            GetPage(
              name: AppRoutes.login,
              page: () => const Scaffold(body: Text('Login')),
            ),
          ],
        ),
      );
      Get.toNamed<void>(AppRoutes.inAppForgotPassword);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      vm.email.text = 'invalid';
      await vm.submit();
      expect(api.calls, 0);
      Get.closeAllSnackbars();
      await tester.pumpAndSettle();
      vm.email.text = '  user@example.com  ';
      final pending = vm.submit();
      await vm.submit();
      await tester.pump();
      expect(api.calls, 1);
      expect(api.payload, {'email': 'user@example.com'});
      expect(api.path, ApiEndpoints.forgotPasswordRequest);
      expect(api.options?.extra?[ApiEndpoints.requiresAuthKey], false);
      expect(vm.isSubmitting.value, true);
      expect(storage.token, 'jwt');
      api.result.complete(
        Response(
          requestOptions: RequestOptions(path: api.path!),
          data: {'success': success, 'message': 'Request rejected'},
        ),
      );
      await pending;
      await tester.pumpAndSettle();
      expect(storage.token, success ? isNull : 'jwt');
      expect(
        Get.currentRoute,
        success ? AppRoutes.login : AppRoutes.inAppForgotPassword,
      );
      expect(vm.isSubmitting.value, false);
      if (success) expect(Get.key.currentState!.canPop(), false);
      Get.closeAllSnackbars();
      await tester.pumpAndSettle();
    });
  }
}

class _Api extends ApiService {
  _Api() : super(Dio());
  final result = Completer<Response<dynamic>>();
  int calls = 0;
  Object? payload;
  String? path;
  Options? options;
  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    calls++;
    this.path = path;
    payload = data;
    this.options = options;
    return await result.future as Response<T>;
  }
}

class _Storage implements SecureStorage {
  String? token = 'jwt';
  @override
  Future<String?> read(String key) async => token;
  @override
  Future<void> write(String key, String value) async => token = value;
  @override
  Future<void> remove(String key) async {
    expect(key, AppConstants.accessTokenKey);
    token = null;
  }
}
