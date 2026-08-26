import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/core/error/exceptions.dart';
import 'package:mobile_hexy/data/models/auth_session_model.dart';

void main() {
  test('reads a nested access token', () {
    final session = AuthSessionModel.fromJson({
      'data': {'access_token': 'nested-token'},
    });

    expect(session.accessToken, 'nested-token');
  });

  test('reads a top-level access token', () {
    final session = AuthSessionModel.fromJson({
      'access_token': 'top-level-token',
    });

    expect(session.accessToken, 'top-level-token');
  });

  test('rejects a response without an access token', () {
    expect(
      () => AuthSessionModel.fromJson({'data': <String, dynamic>{}}),
      throwsA(isA<ServerException>()),
    );
  });
}
