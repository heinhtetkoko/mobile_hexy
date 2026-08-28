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
    final identitySource = data['profile'] is Map
        ? Map<String, dynamic>.from(data['profile'] as Map)
        : data['customer'] is Map
        ? Map<String, dynamic>.from(data['customer'] as Map)
        : data;
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
        'username',
      ]),
      email: _firstString(identitySource, const ['email', 'login']),
      avatarUrl: _firstString(identitySource, const [
        'avatar_url',
        'image_url',
        'avatar',
      ]),
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
}
