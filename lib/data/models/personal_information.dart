import 'package:mobile_hexy/core/networks/api_endpoints.dart';

class PersonalInformation {
  const PersonalInformation({
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.phone,
    required this.email,
    required this.avatarUrl,
  });

  final String firstName;
  final String lastName;
  final String displayName;
  final String phone;
  final String email;
  final String avatarUrl;

  factory PersonalInformation.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final source = data['personal_info'] is Map
        ? Map<String, dynamic>.from(data['personal_info'] as Map)
        : data['profile'] is Map
        ? Map<String, dynamic>.from(data['profile'] as Map)
        : data;
    return PersonalInformation(
      firstName: source['first_name']?.toString() ?? '',
      lastName: source['last_name']?.toString() ?? '',
      displayName:
          source['display_name']?.toString() ??
          source['name']?.toString() ??
          '',
      phone: source['phone']?.toString() ?? '',
      email: source['email']?.toString() ?? '',
      avatarUrl: _imageUrl(source),
    );
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
      final url = value?.trim() ?? '';
      if (url.isEmpty || url == 'false' || url == 'null') continue;
      final uri = Uri.tryParse(url);
      return uri?.hasScheme == true
          ? url
          : Uri.parse(ApiEndpoints.baseUrl).resolve(url).toString();
    }
    return '';
  }
}
