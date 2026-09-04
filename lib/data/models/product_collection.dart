class ProductCollection {
  const ProductCollection({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.itemCount,
    this.imageUrl,
  });
  final int id;
  final String name;
  final String subtitle;
  final int itemCount;
  final String? imageUrl;

  factory ProductCollection.fromJson(
    Map<dynamic, dynamic> json,
  ) => ProductCollection(
    id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
    name:
        (json['name'] ?? json['title'] ?? json['display_name'])?.toString() ??
        '',
    subtitle:
        (json['subtitle'] ?? json['description'] ?? json['tagline'])
            ?.toString() ??
        '',
    itemCount:
        int.tryParse(
          (json['product_count'] ?? json['item_count'] ?? json['count'])
                  ?.toString() ??
              '',
        ) ??
        0,
    imageUrl:
        (json['image_url'] ?? json['mobile_image_url'] ?? json['thumbnail_url'])
            ?.toString(),
  );
}
