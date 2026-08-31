class CartItem {
  const CartItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.variant,
    required this.variantColor,
    required this.unitPrice,
    required this.quantity,
    required this.imageAsset,
    this.imageUrl,
    this.productId = 0,
  });

  final String id;
  final String name;
  final String sku;
  final String variant;
  final int variantColor;
  final int unitPrice;
  final int quantity;
  final String imageAsset;
  final String? imageUrl;
  final int productId;

  CartItem copyWith({int? quantity}) => CartItem(
    id: id,
    name: name,
    sku: sku,
    variant: variant,
    variantColor: variantColor,
    unitPrice: unitPrice,
    quantity: quantity ?? this.quantity,
    imageAsset: imageAsset,
    imageUrl: imageUrl,
    productId: productId,
  );
}
