import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/data/datasources/notifications_remote_data_source.dart';
import '../../presentation/product_list_sort_filter_test.dart'
    show RecordingApi;

void main() {
  test('loads unread count from dedicated notification endpoint', () async {
    final api = RecordingApi();
    final pending = NotificationsRemoteDataSource(api).fetchUnreadCount();
    final call = api.calls.single;
    expect(call.path, 'api/notification/unread-count');
    call.completion.complete(
      Response(
        requestOptions: RequestOptions(path: call.path),
        data: {
          'success': true,
          'data': {'unread_count': 7},
        },
      ),
    );
    expect(await pending, 7);
  });
  test('invalid response never becomes a fabricated badge count', () async {
    final api = RecordingApi();
    final pending = NotificationsRemoteDataSource(api).fetchUnreadCount();
    final expectation = expectLater(pending, throwsFormatException);
    final call = api.calls.single;
    call.completion.complete(
      Response(
        requestOptions: RequestOptions(path: call.path),
        data: {'success': false, 'message': 'Unauthorized'},
      ),
    );
    await expectation;
  });
}
