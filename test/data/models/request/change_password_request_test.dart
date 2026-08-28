import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/data/models/request/change_password_request.dart';

void main() {
  test('serializes the Postman change-password payload', () {
    const request = ChangePasswordRequest(
      currentPassword: 'Password123',
      newPassword: 'Password1234',
    );

    expect(request.toJson(), {
      'current_password': 'Password123',
      'new_password': 'Password1234',
    });
  });
}
