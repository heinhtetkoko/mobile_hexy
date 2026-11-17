import 'package:mobile_hexy/core/services/asset_paths.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/data/models/app_version_policy.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdatePage extends StatefulWidget {
  const AppUpdatePage({super.key, required this.update, this.openStore});
  final AvailableAppUpdate update;
  @visibleForTesting
  final Future<bool> Function(Uri)? openStore;

  @override
  State<AppUpdatePage> createState() => _AppUpdatePageState();
}

class _AppUpdatePageState extends State<AppUpdatePage> {
  bool _opening = false;
  bool _failed = false;

  Future<void> _openStore() async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _failed = false;
    });
    var opened = false;
    try {
      opened =
          await (widget.openStore?.call(widget.update.storeUrl) ??
              launchUrl(
                widget.update.storeUrl,
                mode: LaunchMode.externalApplication,
              ));
    } catch (_) {}
    if (mounted) {
      setState(() {
        _opening = false;
        _failed = !opened;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final update = widget.update;
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? const Color(0xFFF3F0FF) : const Color(0xFF241D46);
    final muted = dark ? const Color(0xFFB5AFC8) : const Color(0xFF797387);
    return PopScope(
      canPop: !update.policy.forceUpdate,
      child: Scaffold(
        backgroundColor: dark
            ? const Color(0xFF100E1B)
            : const Color(0xFFF8F7FC),
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? const [
                      Color(0xFF211632),
                      Color(0xFF100E1B),
                      Color(0xFF171329),
                    ]
                  : const [
                      Color(0xFFF0EAFF),
                      Color(0xFFFAF9FD),
                      Color(0xFFFFF1F7),
                    ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 56).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'HEXCY',
                                style: TextStyle(
                                  color: ink,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 1,
                                height: 16,
                                color: muted.withValues(alpha: .3),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'App Update'.tr,
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0xFF211C30)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: dark
                                    ? const Color(0xFF383044)
                                    : Colors.white,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF3E235E,
                                  ).withValues(alpha: dark ? .18 : .07),
                                  blurRadius: 40,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _UpdateArtwork(dark: dark),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: dark
                                        ? const Color(0xFF3C2B55)
                                        : const Color(0xFFF0E9FC),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'A new version is ready'.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: dark
                                          ? const Color(0xFFD9BDFF)
                                          : const Color(0xFF7944AD),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  (update.policy.forceUpdate
                                          ? 'Update Required'
                                          : 'Update Available')
                                      .tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: ink,
                                    fontSize: 30,
                                    height: 1.15,
                                    letterSpacing: -.9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  update.policy.forceUpdate
                                      ? 'Please update HEXCY to continue using the app.'
                                            .tr
                                      : 'A newer version of HEXCY is available.'
                                            .tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: dark
                                        ? const Color(0xFF181522)
                                        : const Color(0xFFF8F6FC),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _VersionLabel(
                                          label: 'Current version'.tr,
                                          version: update.installedVersion,
                                          color: muted,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                          color: muted,
                                        ),
                                      ),
                                      Expanded(
                                        child: _VersionLabel(
                                          label: 'New version'.tr,
                                          version: update.policy.version,
                                          color: dark
                                              ? const Color(0xFFD8B8FF)
                                              : const Color(0xFF7944AD),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF7139AF),
                                        Color(0xFFBD397F),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF9C3C9D,
                                        ).withValues(alpha: .22),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      key: const Key('app-update-now'),
                                      onPressed: _opening ? null : _openStore,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        disabledBackgroundColor:
                                            Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        disabledForegroundColor: Colors.white70,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 17,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (_opening)
                                            const SizedBox.square(
                                              dimension: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          else
                                            const Icon(
                                              Icons.system_update_alt_rounded,
                                              size: 20,
                                            ),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: Text(
                                              'Update Now'.tr,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (_failed)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Text(
                                      'Could not open the store. Please try again.'
                                          .tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: colors.error,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                if (!update.policy.forceUpdate)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: TextButton(
                                      key: const Key('app-update-later'),
                                      onPressed: () => Get.back<void>(),
                                      child: Text(
                                        'Later'.tr,
                                        style: TextStyle(color: muted),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.storefront_outlined,
                                size: 14,
                                color: muted,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Available on your app store'.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: muted, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionLabel extends StatelessWidget {
  const _VersionLabel({
    required this.label,
    required this.version,
    required this.color,
  });
  final String label, version;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: 10),
      ),
      const SizedBox(height: 6),
      Text(
        version,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _UpdateArtwork extends StatelessWidget {
  const _UpdateArtwork({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
    height: 164,
    width: double.infinity,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const [Color(0xFF3A2853), Color(0xFF352439)]
            : const [Color(0xFFF0E6FF), Color(0xFFFCE5F0)],
      ),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: -50,
          right: -20,
          child: _ArtworkRing(size: 170, dark: dark),
        ),
        Positioned(
          bottom: -70,
          left: -36,
          child: _ArtworkRing(size: 180, dark: dark),
        ),
        Transform.rotate(
          angle: -.08,
          child: Container(
            width: 98,
            height: 98,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF623882).withValues(alpha: .15),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(AssetPaths.appLogo, fit: BoxFit.contain),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 13,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(left: 92),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8645B5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        Positioned(
          left: 30,
          top: 32,
          child: Icon(
            Icons.add_rounded,
            size: 16,
            color: dark ? const Color(0xFFC798E7) : const Color(0xFFAA7FC8),
          ),
        ),
      ],
    ),
  );
}

class _ArtworkRing extends StatelessWidget {
  const _ArtworkRing({required this.size, required this.dark});
  final double size;
  final bool dark;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withValues(alpha: dark ? .06 : .45),
        width: 1,
      ),
    ),
  );
}
