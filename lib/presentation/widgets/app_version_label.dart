import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Reads the installed build once per widget lifetime, including build overrides.
class AppVersionLabel extends StatefulWidget {
  const AppVersionLabel({super.key, this.style});

  final TextStyle? style;

  @override
  State<AppVersionLabel> createState() => _AppVersionLabelState();
}

class _AppVersionLabelState extends State<AppVersionLabel> {
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) => FutureBuilder<PackageInfo>(
    future: _info,
    builder: (context, snapshot) {
      final info = snapshot.data;
      if (info == null || info.version.trim().isEmpty) {
        return const SizedBox.shrink();
      }
      return Text(
        'Version ${info.version}',
        style:
            widget.style ??
            TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
      );
    },
  );
}
