class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.availableQuantity,
  });

  final int id;
  final String name;
  final String sku;
  final double availableQuantity;
}

class ProductDetail {
  const ProductDetail({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.compareAtPrice,
    required this.discountPercent,
    required this.currencySymbol,
    required this.imageUrls,
    required this.rating,
    required this.reviewCount,
    required this.inStock,
    required this.availableQuantity,
    required this.description,
    required this.categories,
    required this.variants,
  });

  final int id;
  final String name;
  final String sku;
  final double price;
  final double? compareAtPrice;
  final int discountPercent;
  final String currencySymbol;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final double availableQuantity;
  final String description;
  final List<String> categories;
  final List<ProductVariant> variants;

  String get formattedPrice => '$currencySymbol${price.toStringAsFixed(2)}';
  String? get formattedCompareAtPrice => compareAtPrice == null
      ? null
      : '$currencySymbol${compareAtPrice!.toStringAsFixed(2)}';
}
