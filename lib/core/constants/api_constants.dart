abstract final class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://heinhtetkoko-odooecommerce-main-36975121.dev.odoo.com/',
  );
  static const login = 'api/v1/auth/token';
  static const categories = 'api/v1/categories';
  static const bestSellers = 'api/v1/best-sellers';
  static const newArrivals = 'api/v1/new-arrivals';
  static const flashSale = 'api/v1/flash-sale';
  static const recommendedProducts = 'api/v1/recommended-products';
  static String productDetail(Object id) => 'api/v1/product/$id';
  static const requiresAuthKey = 'requiresAuth';
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
  static const sendTimeout = Duration(seconds: 15);
}
