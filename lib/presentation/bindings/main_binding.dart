import 'package:get/get.dart';
import 'package:mobile_hexy/data/datasources/categories_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/home_catalog_local_data_source.dart';
import 'package:mobile_hexy/data/repositories/home_catalog_repository_impl.dart';
import 'package:mobile_hexy/domain/repositories/home_catalog_repository.dart';
import 'package:mobile_hexy/domain/usecases/get_home_catalog.dart';
import 'package:mobile_hexy/presentation/viewmodel/categories_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/main_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/stationery_home_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/wishlist_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/profile_view_model.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => const HomeCatalogLocalDataSource());
    Get.lazyPut<HomeCatalogRepository>(
      () => HomeCatalogRepositoryImpl(Get.find()),
    );
    Get.lazyPut(() => GetHomeCatalog(Get.find()));
    Get.lazyPut(() => StationeryHomeViewModel(Get.find()));
    Get.lazyPut(() => CategoriesRemoteDataSource(Get.find()));
    Get.lazyPut(() => CategoriesViewModel(Get.find()));
    Get.lazyPut(CartViewModel.new);
    Get.lazyPut(WishlistViewModel.new);
    Get.lazyPut(ProfileViewModel.new);
    Get.lazyPut(MainViewModel.new);
  }
}
