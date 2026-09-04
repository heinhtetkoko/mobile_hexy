enum ProductListMode {
  bestSellers,
  newArrivals,
  flashSale,
  recommended,
  discountProducts,
  collection,
  brand,
  search,
}

class ProductListRequest {
  const ProductListRequest.bestSellers()
    : mode = ProductListMode.bestSellers,
      query = '',
      collectionId = null,
      collectionName = null,
      brandId = null,
      brandName = null;
  const ProductListRequest.newArrivals()
    : mode = ProductListMode.newArrivals,
      query = '',
      collectionId = null,
      collectionName = null,
      brandId = null,
      brandName = null;
  const ProductListRequest.flashSale()
    : mode = ProductListMode.flashSale,
      query = '',
      collectionId = null,
      collectionName = null,
      brandId = null,
      brandName = null;
  const ProductListRequest.recommended()
    : mode = ProductListMode.recommended,
      query = '',
      collectionId = null,
      collectionName = null,
      brandId = null,
      brandName = null;
  const ProductListRequest.discountProducts()
    : mode = ProductListMode.discountProducts,
      query = '',
      collectionId = null,
      collectionName = null,
      brandId = null,
      brandName = null;
  const ProductListRequest.collection({required int id, required String name})
    : mode = ProductListMode.collection,
      query = '',
      collectionId = id,
      collectionName = name,
      brandId = null,
      brandName = null;
  const ProductListRequest.brand({required int id, required String name})
    : mode = ProductListMode.brand,
      query = '',
      collectionId = null,
      collectionName = null,
      brandId = id,
      brandName = name;
  const ProductListRequest.search({this.query = ''})
    : mode = ProductListMode.search,
      collectionId = null,
      collectionName = null,
      brandId = null,
      brandName = null;

  final ProductListMode mode;
  final String query;
  final int? collectionId;
  final String? collectionName;
  final int? brandId;
  final String? brandName;
}
