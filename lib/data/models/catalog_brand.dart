class CatalogBrand {
  const CatalogBrand({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.productCount,
  });

  final int id;
  final String name;
  final String imageUrl;
  final int productCount;

  factory CatalogBrand.fromJson(Map<String, dynamic> json) => CatalogBrand(
    id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
    name: json['name']?.toString() ?? '',
    imageUrl:
        json['image_url']?.toString() ?? json['logo_url']?.toString() ?? '',
    productCount: int.tryParse(json['product_count']?.toString() ?? '') ?? 0,
  );
}
