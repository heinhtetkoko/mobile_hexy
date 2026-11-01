import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource(this._apiService);
  final ApiService _apiService;

  Future<int> fetchUnreadCount() async {
    final response = await _apiService.get<dynamic>(
      '${ApiEndpoints.notifications}/unread-count',
    );
    final body = response.data;
    if (body is! Map || body['success'] == false) {
      throw const FormatException('Unread count is unavailable.');
    }
    final data = body['data'];
    final raw = data is Map
        ? data['unread_count'] ?? data['count']
        : body['unread_count'] ?? body['count'] ?? data;
    final count = int.tryParse(raw?.toString() ?? '');
    if (count == null || count < 0) {
      throw const FormatException('Unread count is unavailable.');
    }
    return count;
  }

  Future<Map<String, dynamic>> fetchNotifications({
    required int page,
    int limit = 20,
  }) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'limit': limit},
    );
    final body = response.data;
    if (body is Map && body['success'] == false) {
      throw FormatException(
        body['message']?.toString() ?? 'Notifications are unavailable.',
      );
    }
    if (body is List) return {'data': body};
    if (body is Map) {
      final data = body['data'];
      if (data is List) {
        return {'data': data, if (body['meta'] is Map) 'meta': body['meta']};
      }
      if (data is Map) {
        final result = Map<String, dynamic>.from(data);
        if (body['meta'] is Map && !result.containsKey('meta')) {
          result['meta'] = body['meta'];
        }
        return result;
      }
    }
    throw const FormatException('Notifications are unavailable.');
  }
}
