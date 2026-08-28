import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/services/app_constants.dart';
import 'package:mobile_hexy/core/services/app_navigator.dart';
import 'package:mobile_hexy/core/services/getx_app_navigator.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/core/networks/dio_client.dart';
import 'package:mobile_hexy/core/services/ui_service.dart';
import 'package:mobile_hexy/core/services/ui_service_impl.dart';
import 'package:mobile_hexy/core/services/secure_storage.dart';
import 'package:mobile_hexy/core/services/secure_storage_impl.dart';
import 'package:mobile_hexy/data/datasources/auth_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/best_sellers_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/brands_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/categories_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/category_products_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/home_catalog_local_data_source.dart';
import 'package:mobile_hexy/data/datasources/home_products_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/new_arrivals_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/onboarding_local_data_source.dart';
import 'package:mobile_hexy/data/datasources/product_detail_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/profile_remote_data_source.dart';
import 'package:mobile_hexy/data/repositories/auth_repository_impl.dart';
import 'package:mobile_hexy/data/repositories/home_catalog_repository_impl.dart';
import 'package:mobile_hexy/data/repositories/onboarding_repository_impl.dart';
import 'package:mobile_hexy/data/repositories/profile_repository_impl.dart';
import 'package:mobile_hexy/domain/repositories/auth_repository.dart';
import 'package:mobile_hexy/domain/repositories/home_catalog_repository.dart';
import 'package:mobile_hexy/domain/repositories/onboarding_repository.dart';
import 'package:mobile_hexy/domain/repositories/profile_repository.dart';
import 'package:mobile_hexy/domain/usecases/get_home_catalog.dart';
import 'package:mobile_hexy/domain/usecases/get_onboarding_slides.dart';
import 'package:mobile_hexy/domain/usecases/login_user.dart';
import 'package:mobile_hexy/domain/usecases/logout_user.dart';
import 'package:mobile_hexy/domain/usecases/register_user.dart';
import 'package:mobile_hexy/domain/usecases/get_profile.dart';
import 'package:mobile_hexy/domain/usecases/get_personal_information.dart';
import 'package:mobile_hexy/domain/usecases/update_personal_information.dart';
import 'package:mobile_hexy/domain/usecases/change_password.dart';

/// Registers dependencies shared by every feature.
///
/// Feature-specific dependencies stay in each feature's route binding so they
/// are created only when that feature is opened.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AppNavigator>(GetXAppNavigator(), permanent: true);
    Get.put<SecureStorage>(
      const SecureStorageImpl(FlutterSecureStorage()),
      permanent: true,
    );
    final dio = DioClient.create(
      accessTokenProvider: () =>
          Get.find<SecureStorage>().read(AppConstants.accessTokenKey),
    );
    Get.put<Dio>(dio, permanent: true);
    Get.put<ApiService>(ApiService(dio), permanent: true);
    Get.put<UiService>(UiServiceImpl(), permanent: true);

    Get.lazyPut(() => AuthRemoteDataSource(Get.find()), fenix: true);
    Get.lazyPut(() => BestSellersRemoteDataSource(Get.find()), fenix: true);
    Get.lazyPut(() => BrandsRemoteDataSource(Get.find()), fenix: true);
    Get.lazyPut(() => CategoriesRemoteDataSource(Get.find()), fenix: true);
    Get.lazyPut(
      () => CategoryProductsRemoteDataSource(Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => HomeProductsRemoteDataSource(Get.find()), fenix: true);
    Get.lazyPut(() => NewArrivalsRemoteDataSource(Get.find()), fenix: true);
    Get.lazyPut(() => ProductDetailRemoteDataSource(Get.find()), fenix: true);
    Get.lazyPut(() => ProfileRemoteDataSource(Get.find()), fenix: true);
    Get.lazyPut(() => const HomeCatalogLocalDataSource(), fenix: true);
    Get.lazyPut(() => const OnboardingLocalDataSource(), fenix: true);

    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find(), Get.find()),
      fenix: true,
    );
    Get.lazyPut<HomeCatalogRepository>(
      () => HomeCatalogRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<OnboardingRepository>(
      () => OnboardingRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepositoryImpl(Get.find()),
      fenix: true,
    );

    Get.lazyPut(() => LoginUser(Get.find()), fenix: true);
    Get.lazyPut(() => LogoutUser(Get.find()), fenix: true);
    Get.lazyPut(() => RegisterUser(Get.find()), fenix: true);
    Get.lazyPut(() => GetProfile(Get.find()), fenix: true);
    Get.lazyPut(() => GetPersonalInformation(Get.find()), fenix: true);
    Get.lazyPut(() => UpdatePersonalInformation(Get.find()), fenix: true);
    Get.lazyPut(() => ChangePassword(Get.find()), fenix: true);
    Get.lazyPut(() => GetHomeCatalog(Get.find()), fenix: true);
    Get.lazyPut(() => GetOnboardingSlides(Get.find()), fenix: true);
  }
}

@Deprecated('Use InitialBinding; retained for compatibility.')
class DependencyInjection extends InitialBinding {}
