import 'package:mobile_hexy/core/networks/api_endpoints.dart';

class ProfileSummary {
  const ProfileSummary({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.orderCounts,
  });

  final String name;
  final String email;
  final String avatarUrl;
  final Map<String, int> orderCounts;

  int orderCount(String status) => orderCounts[status.toLowerCase()] ?? 0;

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final identitySource = _identitySource(data);
    final countsSource = data['order_summary'] is Map
        ? data['order_summary'] as Map
        : data['order_counts'] is Map
        ? data['order_counts'] as Map
        : data['orders'] is Map
        ? data['orders'] as Map
        : const <String, dynamic>{};

    const statuses = [
      'pending',
      'processing',
      'refunded',
      'delivered',
      'cancelled',
    ];
    return ProfileSummary(
      name: _firstString(identitySource, const [
        'name',
        'display_name',
        'full_name',
        'partner_name',
        'username',
      ]),
      email: _firstString(identitySource, const ['email', 'login']),
      avatarUrl: _imageUrl(identitySource),
      orderCounts: {
        for (final status in statuses)
          status: int.tryParse(countsSource[status]?.toString() ?? '') ?? 0,
      },
    );
  }

  static String _firstString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  static Map<String, dynamic> _identitySource(Map<String, dynamic> data) {
    for (final key in const [
      'profile',
      'profile_header',
      'personal_info',
      'customer',
      'user',
      'partner',
    ]) {
      final value = data[key];
      if (value is Map) {
        return {...data, ...Map<String, dynamic>.from(value)};
      }
    }
    return data;
  }

  static String _imageUrl(Map<String, dynamic> source) {
    for (final key in const [
      'avatar_url',
      'image_url',
      'profile_image_url',
      'image_1920_url',
      'image_512_url',
      'avatar',
      'image',
      'photo',
    ]) {
      final raw = source[key];
      final value = raw is Map
          ? (raw['url'] ?? raw['src'] ?? raw['image_url'])?.toString()
          : raw?.toString();
      final normalized = _absoluteUrl(value);
      if (normalized.isNotEmpty) return normalized;
    }
    return '';
  }

  static String _absoluteUrl(String? value) {
    final url = value?.trim() ?? '';
    if (url.isEmpty || url == 'false' || url == 'null') return '';
    final uri = Uri.tryParse(url);
    if (uri?.hasScheme == true) return url;
    return Uri.parse(ApiEndpoints.baseUrl).resolve(url).toString();
  }
}
