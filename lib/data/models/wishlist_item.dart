class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageAsset,
    required this.productId,
    this.variantId,
    this.imageUrl,
    this.inStock = true,
    this.cartQuantity = 0,
  });

  final String id;
  final String name;
  final String price;
  final String imageAsset;
  final int productId;
  final int? variantId;
  final String? imageUrl;
  final bool inStock;
  final int cartQuantity;
}
