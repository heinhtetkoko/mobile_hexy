import 'package:get/get.dart';
import 'package:mobile_hexy/app/routes/app_routes.dart';
import 'package:mobile_hexy/presentation/bindings/categories_binding.dart';
import 'package:mobile_hexy/presentation/bindings/address_form_binding.dart';
import 'package:mobile_hexy/presentation/bindings/checkout_binding.dart';
import 'package:mobile_hexy/presentation/view/categories_page.dart';
import 'package:mobile_hexy/presentation/view/address_form_page.dart';
import 'package:mobile_hexy/presentation/view/checkout_page.dart';
import 'package:mobile_hexy/presentation/view/payment_success_page.dart';
import 'package:mobile_hexy/presentation/bindings/main_binding.dart';
import 'package:mobile_hexy/presentation/view/main_view.dart';
import 'package:mobile_hexy/presentation/bindings/onboarding_binding.dart';
import 'package:mobile_hexy/presentation/view/onboarding_page.dart';
import 'package:mobile_hexy/presentation/bindings/product_detail_binding.dart';
import 'package:mobile_hexy/presentation/bindings/product_list_binding.dart';
import 'package:mobile_hexy/presentation/view/product_detail_page.dart';
import 'package:mobile_hexy/presentation/view/product_list_page.dart';
import 'package:mobile_hexy/presentation/view/personal_information_page.dart';
import 'package:mobile_hexy/presentation/view/change_password_page.dart';
import 'package:mobile_hexy/presentation/view/contact_us_page.dart';
import 'package:mobile_hexy/presentation/bindings/my_orders_binding.dart';
import 'package:mobile_hexy/presentation/view/my_orders_page.dart';
import 'package:mobile_hexy/presentation/bindings/splash_binding.dart';
import 'package:mobile_hexy/presentation/view/splash_page.dart';
import 'package:mobile_hexy/presentation/bindings/auth_binding.dart';
import 'package:mobile_hexy/presentation/view/auth_pages.dart';

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
      name: AppRoutes.productList,
      page: ProductListPage.new,
      binding: ProductListBinding(),
    ),
    GetPage(
      name: AppRoutes.personalInformation,
      page: PersonalInformationPage.new,
    ),
    GetPage(name: AppRoutes.changePassword, page: ChangePasswordPage.new),
    GetPage(name: AppRoutes.contactUs, page: ContactUsPage.new),
    GetPage(
      name: AppRoutes.myOrders,
      page: MyOrdersPage.new,
      binding: MyOrdersBinding(),
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
