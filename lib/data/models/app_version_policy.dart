class AppVersionPolicy {
  const AppVersionPolicy({required this.version, required this.forceUpdate});
  final String version;
  final bool forceUpdate;

  factory AppVersionPolicy.fromJson(Map<dynamic, dynamic> json) {
    final version = json['version']?.toString().trim() ?? '';
    if (_parts(version) == null) {
      throw const FormatException('Invalid app version.');
    }
    return AppVersionPolicy(
      version: version,
      forceUpdate: json['force_update'] == true,
    );
  }

  bool isNewerThan(String installed) {
    final latest = _parts(version);
    final current = _parts(installed);
    if (latest == null || current == null) return false;
    for (var i = 0; i < latest.length || i < current.length; i++) {
      final difference =
          (i < latest.length ? latest[i] : 0) -
          (i < current.length ? current[i] : 0);
      if (difference != 0) return difference > 0;
    }
    return false;
  }

  static List<int>? _parts(String version) {
    final value = version.trim().split('+').first;
    if (!RegExp(r'^\d+(\.\d+){0,3}$').hasMatch(value)) return null;
    return value.split('.').map(int.parse).toList();
  }
}

class AvailableAppUpdate {
  const AvailableAppUpdate({
    required this.policy,
    required this.installedVersion,
    required this.storeUrl,
  });
  final AppVersionPolicy policy;
  final String installedVersion;
  final Uri storeUrl;
}
