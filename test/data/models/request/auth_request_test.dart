import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/data/models/request/login_request.dart';
import 'package:mobile_hexy/data/models/request/signup_request.dart';

void main() {
  test('serializes the Postman login payload', () {
    const request = LoginRequest(login: 'admin', password: 'admin');

    expect(request.toJson(), {'login': 'admin', 'password': 'admin'});
  });

  test('serializes the Postman signup payload', () {
    const request = SignupRequest(
      username: 'Mobile Customer',
      email: 'mobile.customer@example.com',
      password: 'Password123',
    );

    expect(request.toJson(), {
      'username': 'Mobile Customer',
      'email': 'mobile.customer@example.com',
      'password': 'Password123',
    });
  });
}
