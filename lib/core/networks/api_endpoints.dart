abstract final class ApiEndpoints {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://heinhtetkoko-odooecommerce-main-37444175.dev.odoo.com/',
  );
  static const login = 'api/v1/auth/token';
  static const googleLogin = 'api/v1/auth/google';
  static const signup = 'api/v1/auth/signup';
  static const forgotPasswordRequest = 'api/v1/auth/forgot-password/request';
  static const forgotPasswordVerify = 'api/v1/auth/forgot-password/verify';
  static const forgotPasswordReset = 'api/v1/auth/forgot-password/reset';
  static const banners = 'api/v1/banners';
  static const promoBanners = 'api/v1/promo-banners';
  static const profile = 'api/v1/profile';
  static const personalInfo = 'api/v1/profile/personal-info';
  static const avatar = 'api/v1/profile/avatar';
  static const changePassword = 'api/v1/profile/change-password';
  static const categories = 'api/v1/categories';
  static const brands = 'api/v1/brands';
  static const bestSellers = 'api/v1/best-sellers';
  static const newArrivals = 'api/v1/new-arrivals';
  static const flashSale = 'api/v1/flash-sale';
  static const recommendedProducts = 'api/v1/recommended-products';
  static const discountProducts = 'api/v1/discount-products';
  static const productSearch = 'api/v1/product/search';
  static const allProducts = 'api/v1/products';
  static const cart = 'api/v1/cart';
  static const checkout = 'api/v1/checkout';
  static const checkoutPlaceOrder = 'api/v1/checkout/place-order';
  static const deliveryMethods = 'api/v1/delivery-methods';
  static const orders = 'api/v1/orders';
  static String orderDetail(Object id) => 'api/v1/orders/$id';
  static const notifications = 'api/notification';
  static const wishlist = 'api/v1/wishlist';
  static const contactUs = 'api/v1/contact-us';
  static const faqs = 'api/v1/faqs';
  static const aboutUs = 'api/v1/pages/about-us';
  static const privacyPolicy = 'api/v1/pages/privacy-policy';
  static const termsConditions = 'api/v1/pages/terms-conditions';
  static const addressOptions = 'api/v1/profile/address-options';
  static const locationStates = 'api/v1/locations/states';
  static const locationCities = 'api/v1/locations/cities';
  static const shippingAddresses = 'api/v1/profile/addresses';
  static String shippingAddress(Object id) => 'api/v1/profile/addresses/$id';
  static String productDetail(Object id) => 'api/v1/products/$id';
  static const requiresAuthKey = 'requiresAuth';
  static const redirectOnUnauthorizedKey = 'redirectOnUnauthorized';
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
  static const sendTimeout = Duration(seconds: 15);
}
