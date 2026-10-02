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
    this.isFreeProduct = false,
    this.freeProductValue,
    this.discountPercentage,
    this.currency = '',
    this.programName = '',
    this.programType = '',
    this.freeQuantity,
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
  final bool isFreeProduct;
  final int? freeProductValue;
  final num? discountPercentage;
  final String currency;
  final String programName;
  final String programType;
  final num? freeQuantity;

  num get displayQuantity => freeQuantity ?? quantity;

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
    isFreeProduct: isFreeProduct,
    freeProductValue: freeProductValue,
    discountPercentage: discountPercentage,
    currency: currency,
    programName: programName,
    programType: programType,
    freeQuantity: freeQuantity,
  );
}
