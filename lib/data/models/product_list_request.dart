enum ProductListMode {
  bestSellers,
  newArrivals,
  flashSale,
  recommended,
  discountProducts,
  search,
}

class ProductListRequest {
  const ProductListRequest.bestSellers()
    : mode = ProductListMode.bestSellers,
      query = '';
  const ProductListRequest.newArrivals()
    : mode = ProductListMode.newArrivals,
      query = '';
  const ProductListRequest.flashSale()
    : mode = ProductListMode.flashSale,
      query = '';
  const ProductListRequest.recommended()
    : mode = ProductListMode.recommended,
      query = '';
  const ProductListRequest.discountProducts()
    : mode = ProductListMode.discountProducts,
      query = '';
  const ProductListRequest.search({this.query = ''})
    : mode = ProductListMode.search;

  final ProductListMode mode;
  final String query;
}
