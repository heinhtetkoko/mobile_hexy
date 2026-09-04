import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/view/categories_page.dart';
import 'package:mobile_hexy/presentation/view/cart_page.dart';
import 'package:mobile_hexy/presentation/view/stationery_home_page.dart';
import 'package:mobile_hexy/presentation/view/wishlist_page.dart';
import 'package:mobile_hexy/presentation/view/profile_page.dart';
import 'package:mobile_hexy/presentation/viewmodel/main_view_model.dart';
import 'package:mobile_hexy/data/datasources/wishlist_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/banners_remote_data_source.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  static bool _promotionShownThisLaunch = false;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  MainViewModel get controller => Get.find<MainViewModel>();

  static const _pages = <Widget>[
    StationeryHomePage(),
    CategoriesPage(),
    WishlistPage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    if (!MainView._promotionShownThisLaunch) {
      MainView._promotionShownThisLaunch = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadPromotion();
      });
    }
  }

  Future<void> _loadPromotion() async {
    try {
      final imageUrl = await Get.find<BannersRemoteDataSource>()
          .fetchPopupAdImage();
      if (mounted && imageUrl != null && imageUrl.isNotEmpty) {
        final image = NetworkImage(imageUrl);
        await precacheImage(image, context);
        if (mounted) await _showPromotion(image);
      }
    } catch (_) {
      // Popup ads are optional and must never block the main application.
    }
  }

  Future<void> _showPromotion(ImageProvider image) => showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: .72),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(dialogContext).height * .78,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image(image: image, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              child: IconButton(
                key: const Key('close-main-promotion'),
                tooltip: 'Close'.tr,
                onPressed: () => Navigator.of(dialogContext).pop(),
                color: Colors.black87,
                iconSize: 28,
                padding: const EdgeInsets.all(12),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Obx(
    () => Scaffold(
      body: IndexedStack(
        index: controller.selectedIndex.value,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changePage,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, key: Key('bottom-nav-home')),
              activeIcon: Icon(Icons.home, key: Key('active-tab-home')),
              label: 'Home'.tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.grid_view_outlined,
                key: Key('bottom-nav-categories'),
              ),
              activeIcon: Icon(
                Icons.grid_view_rounded,
                key: Key('active-tab-categories'),
              ),
              label: 'Categories'.tr,
            ),
            BottomNavigationBarItem(
              icon: Obx(
                () => Badge(
                  isLabelVisible:
                      Get.find<WishlistRemoteDataSource>().badgeCount.value > 0,
                  label: Text(
                    '${Get.find<WishlistRemoteDataSource>().badgeCount.value}'
                        .tr,
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    key: Key('bottom-nav-wishlist'),
                  ),
                ),
              ),
              activeIcon: Obx(
                () => Badge(
                  isLabelVisible:
                      Get.find<WishlistRemoteDataSource>().badgeCount.value > 0,
                  label: Text(
                    '${Get.find<WishlistRemoteDataSource>().badgeCount.value}'
                        .tr,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    key: Key('active-tab-wishlist'),
                  ),
                ),
              ),
              label: 'Wishlist'.tr,
            ),
            BottomNavigationBarItem(
              icon: Obx(
                () => Badge(
                  isLabelVisible:
                      Get.find<CartRemoteDataSource>().badgeCount.value > 0,
                  label: Text(
                    '${Get.find<CartRemoteDataSource>().badgeCount.value}'.tr,
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    key: Key('bottom-nav-cart'),
                  ),
                ),
              ),
              activeIcon: Obx(
                () => Badge(
                  isLabelVisible:
                      Get.find<CartRemoteDataSource>().badgeCount.value > 0,
                  label: Text(
                    '${Get.find<CartRemoteDataSource>().badgeCount.value}'.tr,
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    key: Key('active-tab-cart'),
                  ),
                ),
              ),
              label: 'Cart'.tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline_rounded,
                key: Key('bottom-nav-profile'),
              ),
              activeIcon: Icon(
                Icons.person_rounded,
                key: Key('active-tab-profile'),
              ),
              label: 'Profile'.tr,
            ),
          ],
        ),
      ),
    ),
  );
}
