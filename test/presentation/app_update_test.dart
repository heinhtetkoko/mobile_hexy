import 'dart:async';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/services/app_navigator.dart';
import 'package:mobile_hexy/presentation/viewmodel/splash_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/services/app_update_service.dart';
import 'package:mobile_hexy/data/models/app_version_policy.dart';
import 'package:mobile_hexy/presentation/view/app_update_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'product_list_sort_filter_test.dart' show RecordingApi, MemoryStorage;

class _RecordingNavigator implements AppNavigator {
  final routes = <String>[];
  @override
  void replaceWith(String route) => routes.add(route);
  @override
  void clearAndNavigate(String route) => routes.add(route);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => Get.reset());
  test(
    'numeric version comparison handles differing digit lengths and build suffixes',
    () {
      expect(
        const AppVersionPolicy(
          version: '1.10.0',
          forceUpdate: false,
        ).isNewerThan('1.9.9'),
        true,
      );
      expect(
        const AppVersionPolicy(
          version: '1.0',
          forceUpdate: true,
        ).isNewerThan('1.0.0'),
        false,
      );
      expect(
        const AppVersionPolicy(
          version: '1.0.0+7',
          forceUpdate: false,
        ).isNewerThan('1.0.0+6'),
        false,
      );
      expect(
        const AppVersionPolicy(
          version: '1.0.0',
          forceUpdate: true,
        ).isNewerThan('2.0.0'),
        false,
      );
      expect(
        () => AppVersionPolicy.fromJson({'version': 'invalid'}),
        throwsFormatException,
      );
    },
  );
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    test(
      '$platform uses its own policy and public request without JWT',
      () async {
        final api = RecordingApi();
        AvailableAppUpdate? shown;
        final service = AppUpdateService(
          api,
          platform: () => platform,
          packageInfo: () async => PackageInfo(
            appName: 'HEXCY',
            packageName: 'com.joytech.hexcy',
            version: '1.0.0',
            buildNumber: '6',
          ),
          showUpdate: (update) async {
            shown = update;
          },
        );
        final checking = service.refreshPolicy();
        await Future<void>.delayed(Duration.zero);
        final call = api.calls.single;
        expect(call.path, ApiEndpoints.appVersion);
        expect(call.query, isEmpty);
        expect(call.options?.extra?[ApiEndpoints.requiresAuthKey], false);
        call.completion.complete(
          Response(
            requestOptions: RequestOptions(path: call.path),
            data: {
              'success': true,
              'data': {
                'ios': {'version': '1.2.0', 'force_update': true},
                'android': {'version': '1.3.0', 'force_update': false},
              },
            },
          ),
        );
        await checking;
        shown ??= service.requiredUpdate.value;
        expect(
          shown?.policy.version,
          platform == TargetPlatform.iOS ? '1.2.0' : '1.3.0',
        );
        expect(shown?.policy.forceUpdate, platform == TargetPlatform.iOS);
        expect(
          shown?.storeUrl.host,
          platform == TargetPlatform.iOS ? 'apps.apple.com' : 'play.google.com',
        );
      },
    );
  }
  for (final scenario in ['same', 'older', 'offline', 'invalid']) {
    test('$scenario version check does not block startup', () async {
      final api = RecordingApi();
      var prompts = 0;
      final service = AppUpdateService(
        api,
        platform: () => TargetPlatform.iOS,
        packageInfo: () async => PackageInfo(
          appName: 'HEXCY',
          packageName: 'com.joytech.hexcy',
          version: '1.0.0',
          buildNumber: '6',
        ),
        showUpdate: (_) async {
          prompts++;
        },
      );
      final checking = service.checkForUpdate();
      await Future<void>.delayed(Duration.zero);
      final call = api.calls.single;
      if (scenario == 'offline') {
        call.fail();
      } else {
        call.completion.complete(
          Response(
            requestOptions: RequestOptions(path: call.path),
            data: {
              'success': true,
              'data': {
                'ios': {
                  'version': scenario == 'same'
                      ? '1.0.0'
                      : scenario == 'older'
                      ? '0.9.0'
                      : 'invalid',
                  'force_update': true,
                },
              },
            },
          ),
        );
      }
      await checking;
      expect(prompts, 0);
    });
  }
  for (final forced in [true, false]) {
    testWidgets(
      'update screen mandatory=$forced respects back and store failures',
      (tester) async {
        final update = AvailableAppUpdate(
          policy: AppVersionPolicy(version: '1.1.0', forceUpdate: forced),
          installedVersion: '1.0.0',
          storeUrl: Uri.parse('https://apps.apple.com/app/id6830248474'),
        );
        var opened = false;
        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              body: TextButton(
                onPressed: () => Get.to<void>(
                  () => AppUpdatePage(
                    update: update,
                    openStore: (uri) async {
                      opened = uri == update.storeUrl;
                      return false;
                    },
                  ),
                ),
                child: const Text('Start'),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Start'));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('app-update-later')),
          forced ? findsNothing : findsOneWidget,
        );
        await tester.ensureVisible(find.byKey(const Key('app-update-now')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('app-update-now')));
        await tester.pumpAndSettle();
        expect(opened, true);
        expect(
          find.text('Could not open the store. Please try again.'),
          findsOneWidget,
        );
        if (forced) {
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.byType(AppUpdatePage), findsOneWidget);
        } else {
          await tester.ensureVisible(find.byKey(const Key('app-update-later')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('app-update-later')));
          await tester.pumpAndSettle();
          expect(find.byType(AppUpdatePage), findsNothing);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('splash waits for the update gate before opening onboarding', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    final api = RecordingApi();
    final navigator = _RecordingNavigator();
    final gate = Completer<void>();
    var shown = false;
    final updates = AppUpdateService(
      api,
      platform: () => TargetPlatform.iOS,
      packageInfo: () async => PackageInfo(
        appName: 'HEXCY',
        packageName: 'com.joytech.hexcy',
        version: '1.0.0',
        buildNumber: '6',
      ),
      showUpdate: (_) {
        shown = true;
        return gate.future;
      },
    );
    final splash = SplashViewModel(
      navigator,
      MemoryStorage(),
      appUpdateService: updates,
    );
    splash.onInit();
    await tester.pump(const Duration(seconds: 3));
    final call = api.calls.single;
    call.completion.complete(
      Response(
        requestOptions: RequestOptions(path: call.path),
        data: {
          'success': true,
          'data': {
            'ios': {'version': '1.1.0', 'force_update': false},
          },
        },
      ),
    );
    await tester.pump();
    expect(shown, true);
    expect(navigator.routes, isEmpty);
    gate.complete();
    await tester.pump();
    expect(navigator.routes, [AppRoutes.onboarding]);
    splash.onClose();
  });
}
