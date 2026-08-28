import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_hexy/data/models/profile_summary.dart';

void main() {
  test('reads profile identity and order summary while ignoring API menus', () {
    final profile = ProfileSummary.fromJson({
      'success': true,
      'data': {
        'profile': {
          'name': 'Mobile Customer',
          'email': 'customer@example.com',
          'avatar_url': 'https://example.com/avatar.png',
        },
        'order_summary': {'pending': 2, 'delivered': 7},
        'account_menu': ['ignored'],
        'support_menu': ['ignored'],
        'application_menu': ['ignored'],
      },
    });

    expect(profile.name, 'Mobile Customer');
    expect(profile.email, 'customer@example.com');
    expect(profile.avatarUrl, 'https://example.com/avatar.png');
    expect(profile.orderCount('pending'), 2);
    expect(profile.orderCount('delivered'), 7);
    expect(profile.orderCount('cancelled'), 0);
  });
}
