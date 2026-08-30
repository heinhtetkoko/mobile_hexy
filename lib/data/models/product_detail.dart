class ProductVariantValue {
  const ProductVariantValue({
    required this.id,
    required this.name,
    required this.available,
    required this.variantId,
    required this.selected,
  });

  final int id;
  final String name;
  final bool available;
  final int? variantId;
  final bool selected;
}

class ProductVariantSection {
  const ProductVariantSection({
    required this.attribute,
    required this.key,
    required this.values,
  });

  final String attribute;
  final String key;
  final List<ProductVariantValue> values;
}

class ProductSpecification {
  const ProductSpecification({required this.label, required this.value});

  final String label;
  final String value;
}

class ProductDetailCard {
  const ProductDetailCard({
    required this.id,
    required this.name,
    required this.price,
    required this.currencySymbol,
    required this.imageUrl,
    required this.rating,
    required this.compareAtPrice,
    required this.discountPercent,
  });

  final int id;
  final String name;
  final double price;
  final String currencySymbol;
  final String imageUrl;
  final double rating;
  final double? compareAtPrice;
  final int discountPercent;

  String get formattedPrice =>
      '${ProductDetail._formatAmount(price)} $currencySymbol'.trim();
  String? get formattedCompareAtPrice => compareAtPrice == null
      ? null
      : '${ProductDetail._formatAmount(compareAtPrice!)} $currencySymbol'
            .trim();
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
    required this.brand,
    required this.categories,
    required this.variantSections,
    required this.specifications,
    required this.quantityMin,
    required this.quantityMax,
    required this.quantityStep,
    required this.defaultQuantity,
    required this.wishlist,
    required this.cartQuantity,
    required this.relatedProducts,
    required this.youMightAlsoLike,
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
  final String brand;
  final List<String> categories;
  final List<ProductVariantSection> variantSections;
  final List<ProductSpecification> specifications;
  final int quantityMin;
  final int quantityMax;
  final int quantityStep;
  final int defaultQuantity;
  final bool wishlist;
  final int cartQuantity;
  final List<ProductDetailCard> relatedProducts;
  final List<ProductDetailCard> youMightAlsoLike;

  String get formattedPrice => '${_formatAmount(price)} $currencySymbol'.trim();
  String? get formattedCompareAtPrice => compareAtPrice == null
      ? null
      : '${_formatAmount(compareAtPrice!)} $currencySymbol'.trim();

  static String _formatAmount(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}
