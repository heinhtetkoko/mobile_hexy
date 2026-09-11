class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.imageAsset,
    this.imageUrl,
    this.originalPrice,
    this.discount,
    this.variantId,
  });

  final String id;
  final String name;
  final String price;
  final String imageAsset;
  final String? imageUrl;
  final String? originalPrice;
  final String? discount;
  final int? variantId;
}
