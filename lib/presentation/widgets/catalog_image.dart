import 'package:flutter/material.dart';
import 'package:mobile_hexy/core/services/asset_paths.dart';

class CatalogImage extends StatelessWidget {
  const CatalogImage({super.key, required this.url, this.fit = BoxFit.contain});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim() ?? '';
    if (imageUrl.isEmpty || imageUrl.toLowerCase() == 'null') {
      return const _CatalogLogoPlaceholder();
    }
    return Image.network(
      imageUrl,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
          wasSynchronouslyLoaded || frame != null
          ? child
          : const _CatalogLogoPlaceholder(),
      errorBuilder: (_, _, _) => const _CatalogLogoPlaceholder(),
    );
  }
}

class _CatalogLogoPlaceholder extends StatelessWidget {
  const _CatalogLogoPlaceholder();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Image.asset(AssetPaths.appLogo, fit: BoxFit.contain),
    ),
  );
}
