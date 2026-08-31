import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/categories_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/main_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/stationery_home_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/wishlist_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/profile_view_model.dart';
import 'package:mobile_hexy/domain/usecases/logout_user.dart';
import 'package:mobile_hexy/domain/usecases/get_profile.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => StationeryHomeViewModel(
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
      ),
    );
    Get.lazyPut(() => CategoriesViewModel(Get.find()));
    if (!Get.isRegistered<CartViewModel>()) {
      Get.put(CartViewModel(Get.find()), permanent: true);
    }
    Get.lazyPut(() => WishlistViewModel(Get.find(), Get.find()));
    Get.lazyPut(
      () => ProfileViewModel(Get.find<LogoutUser>(), Get.find<GetProfile>()),
    );
    Get.lazyPut(MainViewModel.new);
  }
}
