import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/services/app_translations.dart';
import 'package:mobile_hexy/core/services/initial_binding.dart';
import 'package:mobile_hexy/core/theme/app_theme.dart';
import 'package:mobile_hexy/presentation/controllers/address_form_binding.dart';
import 'package:mobile_hexy/presentation/controllers/auth_binding.dart';
import 'package:mobile_hexy/presentation/controllers/brands_binding.dart';
import 'package:mobile_hexy/presentation/controllers/categories_binding.dart';
import 'package:mobile_hexy/presentation/controllers/checkout_binding.dart';
import 'package:mobile_hexy/presentation/controllers/main_binding.dart';
import 'package:mobile_hexy/presentation/controllers/my_orders_binding.dart';
import 'package:mobile_hexy/presentation/controllers/order_detail_binding.dart';
import 'package:mobile_hexy/presentation/controllers/notifications_binding.dart';
import 'package:mobile_hexy/presentation/controllers/onboarding_binding.dart';
import 'package:mobile_hexy/presentation/controllers/product_detail_binding.dart';
import 'package:mobile_hexy/presentation/controllers/product_list_binding.dart';
import 'package:mobile_hexy/presentation/controllers/personal_information_binding.dart';
import 'package:mobile_hexy/presentation/controllers/change_password_binding.dart';
import 'package:mobile_hexy/presentation/controllers/splash_binding.dart';
import 'package:mobile_hexy/presentation/controllers/shipping_addresses_binding.dart';
import 'package:mobile_hexy/presentation/view/address_form_page.dart';
import 'package:mobile_hexy/presentation/view/auth_pages.dart';
import 'package:mobile_hexy/presentation/view/brands_page.dart';
import 'package:mobile_hexy/presentation/view/categories_page.dart';
import 'package:mobile_hexy/presentation/view/change_password_page.dart';
import 'package:mobile_hexy/presentation/view/checkout_page.dart';
import 'package:mobile_hexy/presentation/view/support_content_page.dart';
import 'package:mobile_hexy/presentation/view/main_view.dart';
import 'package:mobile_hexy/presentation/view/my_orders_page.dart';
import 'package:mobile_hexy/presentation/view/order_detail_page.dart';
import 'package:mobile_hexy/presentation/view/notifications_page.dart';
import 'package:mobile_hexy/presentation/view/onboarding_page.dart';
import 'package:mobile_hexy/presentation/view/payment_success_page.dart';
import 'package:mobile_hexy/presentation/view/personal_information_page.dart';
import 'package:mobile_hexy/presentation/view/product_detail_page.dart';
import 'package:mobile_hexy/presentation/view/product_list_page.dart';
import 'package:mobile_hexy/presentation/view/splash_page.dart';
import 'package:mobile_hexy/presentation/view/shipping_addresses_page.dart';

class HexyApp extends StatelessWidget {
  const HexyApp({
    super.key,
    this.initialThemeMode = ThemeMode.system,
    this.initialLocale = const Locale('en', 'US'),
  });

  final ThemeMode initialThemeMode;
  final Locale initialLocale;

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    title: 'Hexy Megastore',
    debugShowCheckedModeBanner: false,
    initialBinding: InitialBinding(),
    initialRoute: AppRoutes.splash,
    getPages: AppPages.pages,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: initialThemeMode,
    translations: AppTranslations(),
    locale: initialLocale,
    fallbackLocale: const Locale('en', 'US'),
  );
}

abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const categories = '/categories';
  static const brands = '/brands';
  static const productDetail = '/product-detail';
  static const checkout = '/checkout';
  static const paymentSuccess = '/payment-success';
  static const addressForm = '/address';
  static const shippingAddresses = '/shipping-addresses';
  static const productList = '/products';
  static const personalInformation = '/personal-information';
  static const changePassword = '/change-password';
  static const contactUs = '/contact-us';
  static const faq = '/faq';
  static const aboutUs = '/about-us';
  static const privacyPolicy = '/privacy-policy';
  static const termsConditions = '/terms-conditions';
  static const myOrders = '/my-orders';
  static const orderDetail = '/order-detail';
  static const notifications = '/notifications';
  static const notificationDetail = '/notification-detail';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const resetPassword = '/reset-password';
  static const passwordUpdated = '/password-updated';
}

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: SplashPage.new,
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: OnboardingPage.new,
      binding: OnboardingBinding(),
    ),
    GetPage(name: AppRoutes.home, page: MainView.new, binding: MainBinding()),
    GetPage(
      name: AppRoutes.categories,
      page: CategoriesPage.new,
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: AppRoutes.brands,
      page: BrandsPage.new,
      binding: BrandsBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: ProductDetailPage.new,
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: CheckoutPage.new,
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentSuccess,
      page: PaymentSuccessPage.new,
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.addressForm,
      page: AddressFormPage.new,
      binding: AddressFormBinding(),
    ),
    GetPage(
      name: AppRoutes.shippingAddresses,
      page: ShippingAddressesPage.new,
      binding: ShippingAddressesBinding(),
    ),
    GetPage(
      name: AppRoutes.productList,
      page: ProductListPage.new,
      binding: ProductListBinding(),
    ),
    GetPage(
      name: AppRoutes.personalInformation,
      page: PersonalInformationPage.new,
      binding: PersonalInformationBinding(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: ChangePasswordPage.new,
      binding: ChangePasswordBinding(),
    ),
    GetPage(name: AppRoutes.contactUs, page: SupportContentPage.contact),
    GetPage(name: AppRoutes.faq, page: SupportContentPage.faq),
    GetPage(name: AppRoutes.aboutUs, page: SupportContentPage.about),
    GetPage(name: AppRoutes.privacyPolicy, page: SupportContentPage.privacy),
    GetPage(name: AppRoutes.termsConditions, page: SupportContentPage.terms),
    GetPage(
      name: AppRoutes.myOrders,
      page: MyOrdersPage.new,
      binding: MyOrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: OrderDetailPage.new,
      binding: OrderDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: NotificationsPage.new,
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: AppRoutes.notificationDetail,
      page: NotificationDetailPage.new,
    ),
    GetPage(name: AppRoutes.login, page: LoginPage.new, binding: AuthBinding()),
    GetPage(
      name: AppRoutes.register,
      page: RegisterPage.new,
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: ForgotPasswordPage.new,
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: OtpVerificationPage.new,
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: ResetPasswordPage.new,
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.passwordUpdated,
      page: PasswordUpdatedPage.new,
      binding: AuthBinding(),
    ),
  ];
}
