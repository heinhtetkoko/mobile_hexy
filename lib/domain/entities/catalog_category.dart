class CatalogCategory {
  const CatalogCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.productCount,
    required this.hasChildren,
    required this.next,
  });

  final int id;
  final String name;
  final String imageUrl;
  final int productCount;
  final bool hasChildren;
  final String next;

  factory CatalogCategory.fromJson(Map<String, dynamic> json) {
    return CatalogCategory(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      productCount: int.tryParse(json['product_count']?.toString() ?? '') ?? 0,
      hasChildren: json['has_children'] == true,
      next: json['next']?.toString() ?? '',
    );
  }
}
