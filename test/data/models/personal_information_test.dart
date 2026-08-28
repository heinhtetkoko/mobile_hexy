import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/data/models/personal_information.dart';
import 'package:mobile_hexy/data/models/request/update_personal_info_request.dart';

void main() {
  test('reads nested personal information response', () {
    final info = PersonalInformation.fromJson({
      'success': true,
      'data': {
        'first_name': 'Zar',
        'last_name': 'Zar',
        'display_name': 'Zar Zar',
        'phone': '09-123-456-789',
        'email': 'zar@example.com',
      },
    });

    expect(info.firstName, 'Zar');
    expect(info.lastName, 'Zar');
    expect(info.displayName, 'Zar Zar');
    expect(info.phone, '09-123-456-789');
    expect(info.email, 'zar@example.com');
  });

  test('serializes the Postman personal information payload', () {
    const request = UpdatePersonalInfoRequest(
      firstName: 'Zar',
      lastName: 'Zar',
      displayName: 'Zar Zar',
      phone: '09-123-456-789',
      email: 'zar@example.com',
    );

    expect(request.toJson(), {
      'first_name': 'Zar',
      'last_name': 'Zar',
      'display_name': 'Zar Zar',
      'phone': '09-123-456-789',
      'email': 'zar@example.com',
    });
  });
}
