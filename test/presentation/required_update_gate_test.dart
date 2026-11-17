import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:mobile_hexy/core/services/app_update_service.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/data/models/app_version_policy.dart';
import 'package:mobile_hexy/presentation/widgets/app_update_gate.dart';
import 'package:mobile_hexy/presentation/view/app_update_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'product_list_sort_filter_test.dart' show RecordingApi;

class _Storage implements SecureStorage {
  final data = <String, String>{};
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async {
    data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    data.remove(key);
  }
}

Future<void> flush() => Future<void>.delayed(Duration.zero);
void respond(RecordingApi api, {bool forced = true, String version = '1.1.0'}) {
  final call = api.calls.last;
  call.completion.complete(
    Response(
      requestOptions: RequestOptions(path: call.path),
      data: {
        'success': true,
        'data': {
          'ios': {'version': version, 'force_update': forced},
        },
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => Get.reset());
  test(
    'known mandatory policy survives offline restart and releases after installation',
    () async {
      final storage = _Storage();
      final api = RecordingApi();
      var installed = '1.0.0';
      Future<PackageInfo> info() async => PackageInfo(
        appName: 'HEXCY',
        packageName: 'com.joytech.hexcy',
        version: installed,
        buildNumber: '6',
      );
      final first = AppUpdateService(
        api,
        storage: storage,
        packageInfo: info,
        platform: () => TargetPlatform.iOS,
      );
      var entered = false;
      final startup = first.checkForUpdate().then((_) => entered = true);
      var concurrentEntered = false;
      final concurrent = first.checkForUpdate().then(
        (_) => concurrentEntered = true,
      );
      await flush();
      respond(api);
      await first.refreshPolicy();
      await flush();
      expect(first.requiredUpdate.value, isNotNull);
      expect(storage.data, isNotEmpty);
      expect(entered, false);
      expect(concurrentEntered, false);
      expect(api.calls.length, 1);
      first.onClose();
      await Future.wait([startup, concurrent]);

      final second = AppUpdateService(
        api,
        storage: storage,
        packageInfo: info,
        platform: () => TargetPlatform.iOS,
      );
      entered = false;
      final restart = second.checkForUpdate().then((_) => entered = true);
      await flush();
      api.calls.last.fail();
      await second.refreshPolicy();
      await flush();
      expect(second.requiredUpdate.value?.policy.version, '1.1.0');
      expect(entered, false);
      // The actual installed version, not a flag set by tapping Update Now, releases it.
      installed = '1.1.0';
      final refreshed = second.refreshPolicy();
      await flush();
      api.calls.last.fail();
      await refreshed;
      await restart;
      expect(entered, true);
      expect(second.requiredUpdate.value, isNull);
      expect(storage.data, isEmpty);
      second.onClose();
    },
  );
  test(
    'resume rechecks and backend can revoke an outdated mandatory policy',
    () async {
      final api = RecordingApi();
      final service = AppUpdateService(
        api,
        storage: _Storage(),
        platform: () => TargetPlatform.iOS,
        packageInfo: () async => PackageInfo(
          appName: 'HEXCY',
          packageName: 'com.joytech.hexcy',
          version: '1.0.0',
          buildNumber: '6',
        ),
        showUpdate: (_) async {},
      );
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await flush();
      respond(api);
      await service.refreshPolicy();
      expect(service.requiredUpdate.value, isNotNull);
      service.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await flush();
      respond(api, forced: false);
      await service.refreshPolicy();
      expect(service.requiredUpdate.value, isNull);
      service.onClose();
    },
  );
  testWidgets(
    'mandatory gate remains above all routes and blocks underlying controls',
    (tester) async {
      final service = Get.put(AppUpdateService(RecordingApi()));
      var taps = 0;
      service.requiredUpdate.value = AvailableAppUpdate(
        policy: const AppVersionPolicy(version: '1.1.0', forceUpdate: true),
        installedVersion: '1.0.0',
        storeUrl: Uri.parse('https://example.com'),
      );
      await tester.pumpWidget(
        GetMaterialApp(
          builder: (context, child) => AppUpdateGate(child: child!),
          home: Scaffold(
            body: TextButton(
              onPressed: () => taps++,
              child: const Text('Protected home'),
            ),
          ),
          getPages: [
            GetPage(
              name: '/other',
              page: () => const Scaffold(body: Text('Other page')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Protected home'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(taps, 0);
      expect(find.byType(AppUpdatePage), findsOneWidget);
      expect(find.byKey(const Key('app-update-later')), findsNothing);
      Get.offAllNamed<void>('/other');
      await tester.pumpAndSettle();
      expect(find.byType(AppUpdatePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
