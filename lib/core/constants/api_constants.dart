abstract final class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://heinhtetkoko-odooecommerce-main-36975121.dev.odoo.com/',
  );
  static const login = 'api/v1/auth/token';
  static const categories = 'api/v1/categories';
  static const requiresAuthKey = 'requiresAuth';
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
  static const sendTimeout = Duration(seconds: 15);
}
