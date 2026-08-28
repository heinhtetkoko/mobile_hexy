import 'package:flutter/widgets.dart';

/// Shared layout component for consistently spaced page sections.
class AppSection extends StatelessWidget {
  const AppSection({required this.child, super.key, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
    child: child,
  );
}
