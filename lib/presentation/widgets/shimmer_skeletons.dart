import 'package:flutter/material.dart';

class AppShimmer extends StatefulWidget {
  const AppShimmer({required this.child, super.key});

  final Widget child;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = dark ? const Color(0xFF27273A) : const Color(0xFFE5E7EB);
    final highlightColor = dark
        ? const Color(0xFF3D3D55)
        : const Color(0xFFF8FAFC);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.25, 0.5, 0.75],
          transform: _SlidingGradientTransform(_controller.value),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.value);
  final double value;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (value * 2 - 1), 0, 0);
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 10,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF27273A)
        : const Color(0xFFE5E7EB);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class HorizontalProductShimmer extends StatelessWidget {
  const HorizontalProductShimmer({
    this.height = 186,
    this.itemWidth = 142,
    super.key,
  });

  final double height;
  final double itemWidth;

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: SizedBox(
      height: height,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) =>
            ShimmerBox(width: itemWidth, height: height, radius: 14),
      ),
    ),
  );
}

class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .82,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const ShimmerBox(
        width: double.infinity,
        height: double.infinity,
        radius: 16,
      ),
    ),
  );
}

class CategoriesShimmer extends StatelessWidget {
  const CategoriesShimmer({this.sidebar = true, super.key});

  final bool sidebar;

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: Row(
      children: [
        if (sidebar)
          SizedBox(
            width: 88,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: 8,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, _) =>
                  const ShimmerBox(width: 88, height: 64, radius: 8),
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: 7,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, _) => const ShimmerBox(
              width: double.infinity,
              height: 72,
              radius: 12,
            ),
          ),
        ),
      ],
    ),
  );
}

class ProductDetailShimmer extends StatelessWidget {
  const ProductDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerBox(width: double.infinity, height: 300, radius: 16),
          SizedBox(height: 20),
          ShimmerBox(width: 220, height: 28),
          SizedBox(height: 12),
          ShimmerBox(width: 150, height: 16),
          SizedBox(height: 18),
          ShimmerBox(width: double.infinity, height: 72, radius: 16),
          SizedBox(height: 24),
          ShimmerBox(width: 110, height: 18),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 90),
        ],
      ),
    ),
  );
}
