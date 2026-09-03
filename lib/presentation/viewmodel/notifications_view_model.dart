import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/notifications_remote_data_source.dart';
import 'package:mobile_hexy/data/models/app_notification.dart';

class NotificationsViewModel extends BaseViewModel {
  NotificationsViewModel(this._remoteDataSource);
  final NotificationsRemoteDataSource _remoteDataSource;
  final notifications = <AppNotification>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  int _page = 1;
  bool _hasNext = false;

  bool get hasMore => _hasNext && !isLoadingMore.value;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    errorMessage.value = null;
    _page = 1;
    try {
      _apply(await _remoteDataSource.fetchNotifications(page: _page), true);
    } catch (error) {
      errorMessage.value = _message(error);
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore) return;
    isLoadingMore.value = true;
    try {
      final data = await _remoteDataSource.fetchNotifications(page: _page + 1);
      _page++;
      _apply(data, false);
    } catch (error) {
      Get.snackbar('Could not load notifications', _message(error));
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _apply(Map<String, dynamic> payload, bool replace) {
    final source =
        payload['notifications'] ?? payload['items'] ?? payload['data'];
    final raw = source is Map
        ? source['data'] ?? source['items'] ?? source['notifications']
        : source;
    final parsed = raw is List
        ? raw.whereType<Map>().map(AppNotification.fromJson).toList()
        : <AppNotification>[];
    if (replace) {
      notifications.assignAll(parsed);
    } else {
      final ids = notifications.map((item) => item.id).toSet();
      notifications.addAll(parsed.where((item) => !ids.contains(item.id)));
    }
    final metaSource = payload['meta'] ?? (source is Map ? source : null);
    final meta = metaSource is Map ? metaSource : const {};
    final current = _int(meta['page'] ?? meta['current_page'], _page);
    final pages = _int(meta['pages'] ?? meta['total_pages'], 0);
    _hasNext =
        meta['has_next'] == true ||
        meta['has_more'] == true ||
        (pages > 0 && current < pages) ||
        (meta.isEmpty && parsed.length >= 20);
  }

  void openDetail(AppNotification notification) => Get.toNamed<dynamic>(
    AppRoutes.notificationDetail,
    arguments: notification,
  );

  int _int(Object? value, int fallback) => value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '') ?? fallback;
  String _message(Object error) => error
      .toString()
      .replaceFirst('Exception: ', '')
      .replaceFirst('FormatException: ', '');
}
