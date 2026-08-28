enum ProductListMode { bestSellers, newArrivals, flashSale, recommended }

class ProductListRequest {
  const ProductListRequest.bestSellers() : mode = ProductListMode.bestSellers;
  const ProductListRequest.newArrivals() : mode = ProductListMode.newArrivals;
  const ProductListRequest.flashSale() : mode = ProductListMode.flashSale;
  const ProductListRequest.recommended() : mode = ProductListMode.recommended;

  final ProductListMode mode;
}
