import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/data/models/app_version_policy.dart';
import 'package:mobile_hexy/presentation/view/app_update_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateService extends GetxService with WidgetsBindingObserver {
  AppUpdateService(
    this._api, {
    SecureStorage? storage,
    Future<PackageInfo> Function()? packageInfo,
    TargetPlatform Function()? platform,
    Future<void> Function(AvailableAppUpdate)? showUpdate,
  }) : _storage = storage,
       _packageInfo = packageInfo ?? PackageInfo.fromPlatform,
       _platform = platform ?? (() => defaultTargetPlatform),
       _showUpdate = showUpdate ?? _openUpdate;

  final ApiService _api;
  final SecureStorage? _storage;
  final Future<PackageInfo> Function() _packageInfo;
  final TargetPlatform Function() _platform;
  final Future<void> Function(AvailableAppUpdate) _showUpdate;
  final requiredUpdate = Rxn<AvailableAppUpdate>();
  Completer<void>? _forceGate;
  Future<void>? _refreshing;
  String? _optionalVersionShown;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refreshPolicy());
  }

  Future<void> checkForUpdate() async {
    await refreshPolicy();
    // All callers wait for the same mandatory gate, including concurrent startup.
    await _forceGate?.future;
  }

  Future<void> refreshPolicy() => _refreshing ??= _refresh().whenComplete(() {
    _refreshing = null;
  });

  Future<void> _refresh() async {
    if (kIsWeb) return;
    final platform = _platform();
    if (platform != TargetPlatform.iOS && platform != TargetPlatform.android) {
      return;
    }
    final platformKey = platform == TargetPlatform.iOS ? 'ios' : 'android';
    final cacheKey = 'required_app_update_$platformKey';
    String installed = requiredUpdate.value?.installedVersion ?? '';
    try {
      installed = (await _packageInfo().timeout(
        const Duration(seconds: 8),
      )).version;
    } catch (error) {
      debugPrint('Installed version unavailable: ${error.runtimeType}');
    }
    final known = requiredUpdate.value;
    if (known != null &&
        installed.isNotEmpty &&
        !known.policy.isNewerThan(installed)) {
      _release();
    }
    // Restore a known requirement before querying the network. Offline startup
    // cannot silently bypass a mandatory update learned on an earlier launch.
    try {
      final cached = await _storage?.read(cacheKey);
      if (cached != null) {
        final policy = AppVersionPolicy.fromJson(jsonDecode(cached) as Map);
        if (policy.forceUpdate &&
            (installed.isEmpty || policy.isNewerThan(installed))) {
          final knownVersion = requiredUpdate.value?.policy.version;
          if (knownVersion == null || policy.isNewerThan(knownVersion)) {
            _require(_update(policy, installed, platform));
          }
        } else {
          await _storage?.remove(cacheKey);
        }
      }
    } catch (error) {
      debugPrint('Cached update policy unavailable: ${error.runtimeType}');
    }
    try {
      final response = await _api
          .get<dynamic>(
            ApiEndpoints.appVersion,
            options: Options(
              extra: const {ApiEndpoints.requiresAuthKey: false},
            ),
          )
          .timeout(const Duration(seconds: 8));
      final body = response.data;
      final data = body is Map && body['success'] == true ? body['data'] : null;
      final raw = data is Map ? data[platformKey] : null;
      if (raw is! Map) {
        throw const FormatException('Version policy unavailable.');
      }
      final policy = AppVersionPolicy.fromJson(raw);
      final needsUpdate = installed.isEmpty || policy.isNewerThan(installed);
      if (policy.forceUpdate && needsUpdate) {
        _require(_update(policy, installed, platform));
        try {
          await _storage?.write(
            cacheKey,
            jsonEncode({'version': policy.version, 'force_update': true}),
          );
        } catch (error) {
          debugPrint('Update policy persistence failed: ${error.runtimeType}');
        }
      } else {
        _release();
        try {
          await _storage?.remove(cacheKey);
        } catch (_) {}
        if (needsUpdate &&
            installed.isNotEmpty &&
            _optionalVersionShown != policy.version) {
          _optionalVersionShown = policy.version;
          await _showUpdate(_update(policy, installed, platform));
        }
      }
    } catch (error) {
      // Keep a previously required update enforced when the API is unreachable.
      debugPrint('App version check unavailable: ${error.runtimeType}');
    }
  }

  AvailableAppUpdate _update(
    AppVersionPolicy policy,
    String installed,
    TargetPlatform platform,
  ) => AvailableAppUpdate(
    policy: policy,
    installedVersion: installed,
    storeUrl: Uri.parse(
      platform == TargetPlatform.iOS
          ? 'https://apps.apple.com/co/app/hexcy-store/id6830248474?l=en-GB'
          : 'https://play.google.com/store/apps/details?id=com.joytech.hexcy',
    ),
  );

  void _require(AvailableAppUpdate update) {
    requiredUpdate.value = update;
    _forceGate ??= Completer<void>();
  }

  void _release() {
    requiredUpdate.value = null;
    final gate = _forceGate;
    _forceGate = null;
    if (gate != null && !gate.isCompleted) gate.complete();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _release();
    super.onClose();
  }

  static Future<void> _openUpdate(AvailableAppUpdate update) async {
    await Get.to<void>(
      () => AppUpdatePage(update: update),
      preventDuplicates: true,
      fullscreenDialog: true,
    );
  }
}
