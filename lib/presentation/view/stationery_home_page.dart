import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/data/models/home_catalog.dart';
import 'package:mobile_hexy/data/models/catalog_brand.dart';
import 'package:mobile_hexy/data/models/catalog_category.dart';
import 'package:mobile_hexy/data/models/product_list_request.dart';
import 'package:mobile_hexy/data/models/product_collection.dart';
import 'package:mobile_hexy/presentation/widgets/shimmer_skeletons.dart';
import 'package:mobile_hexy/presentation/viewmodel/stationery_home_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/main_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class StationeryHomePage extends GetView<StationeryHomeViewModel> {
  const StationeryHomePage({super.key});

  static const _ink = Color(0xFF1E1B4B);
  static const _pink = Color(0xFFDB2777);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              onNotificationTap: () =>
                  Get.toNamed<void>(AppRoutes.notifications),
              onSearchTap: () => Get.toNamed<void>(
                AppRoutes.productList,
                arguments: const ProductListRequest.search(),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshHome,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _HeroSlider(viewModel: controller),
                    ),
                    SliverToBoxAdapter(
                      child: _Section(
                        title: 'Categories',
                        onArrowTap: () =>
                            Get.find<MainViewModel>().openCategories(),
                        child: Obx(
                          () => _HomeCategoriesContent(
                            items: controller.homeCategories,
                            loading: controller.isCategoriesLoading.value,
                            error: controller.categoriesError.value,
                            onRetry: controller.loadCategories,
                            onTap: (category) => Get.find<MainViewModel>()
                                .openCategories(categoryName: category.name),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _Section(
                        title: 'Top Brands',
                        onArrowTap: () => Get.toNamed<void>(AppRoutes.brands),
                        child: Obx(
                          () => _HomeBrandsContent(
                            items: controller.brands,
                            loading: controller.isBrandsLoading.value,
                            error: controller.brandsError.value,
                            onRetry: controller.loadBrands,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _Section(
                        title: 'Best Sellers',
                        badge: 'HOT',
                        onArrowTap: () => Get.toNamed<void>(
                          AppRoutes.productList,
                          arguments: const ProductListRequest.bestSellers(),
                        ),
                        child: Obx(
                          () => _RemoteProductContent(
                            items: controller.bestSellers,
                            useReferenceCard: true,
                            useRecommendedListBackground: true,
                            loading: controller.isBestSellersLoading.value,
                            loadingMore:
                                controller.isBestSellersLoadingMore.value,
                            error: controller.bestSellersError.value,
                            hasMore: controller.hasMoreBestSellers.value,
                            onRetry: controller.loadBestSellers,
                            onLoadMore: controller.loadMoreBestSellers,
                            onAddToCart: controller.addToCart,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _Section(
                        title: 'New Arrivals',
                        badge: 'NEW',
                        onArrowTap: () => Get.toNamed<void>(
                          AppRoutes.productList,
                          arguments: const ProductListRequest.newArrivals(),
                        ),
                        child: Obx(
                          () => _RemoteProductContent(
                            items: controller.newArrivals,
                            useReferenceCard: true,
                            useRecommendedListBackground: true,
                            loading: controller.isNewArrivalsLoading.value,
                            loadingMore:
                                controller.isNewArrivalsLoadingMore.value,
                            error: controller.newArrivalsError.value,
                            hasMore: controller.hasMoreNewArrivals.value,
                            onRetry: controller.loadNewArrivals,
                            onLoadMore: controller.loadMoreNewArrivals,
                            onAddToCart: controller.addToCart,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Obx(() {
                        if (controller.isPromoBannersLoading.value) {
                          return const _OfferCardLoading();
                        }
                        if (controller.promoBanners.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return _OfferCard(
                          banner: controller.promoBanners.first,
                        );
                      }),
                    ),
                    SliverToBoxAdapter(
                      child: Obx(
                        () => _FlashSaleContent(
                          items: controller.flashSaleProducts,
                          loading: controller.isFlashSaleLoading.value,
                          loadingMore: controller.isFlashSaleLoadingMore.value,
                          error: controller.flashSaleError.value,
                          hasMore: controller.hasMoreFlashSale.value,
                          onRetry: controller.loadFlashSale,
                          onLoadMore: controller.loadMoreFlashSale,
                          onViewAll: () => Get.toNamed<void>(
                            AppRoutes.productList,
                            arguments: const ProductListRequest.flashSale(),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _Section(
                        title: 'Recommended For You',
                        badge: '✨',
                        onArrowTap: () => Get.toNamed<void>(
                          AppRoutes.productList,
                          arguments: const ProductListRequest.recommended(),
                        ),
                        child: Obx(
                          () => _RecommendedContent(
                            items: controller.recommendedProducts,
                            loading: controller.isRecommendedLoading.value,
                            loadingMore:
                                controller.isRecommendedLoadingMore.value,
                            error: controller.recommendedError.value,
                            hasMore: controller.hasMoreRecommended.value,
                            onRetry: controller.loadRecommendedProducts,
                            onLoadMore: controller.loadMoreRecommendedProducts,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _CollectionsSection(controller: controller),
                    ),
                    const SliverToBoxAdapter(child: _ChatFooter()),
                    const SliverToBoxAdapter(child: _PaymentMethods()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearchTap, required this.onNotificationTap});
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF1E1B4B), Color(0xFF4338CA), Color(0xFFDB2777)],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(
                'assets/images/Frame_hexy.png',
                fit: BoxFit.cover,
              ),
            ),
            const Spacer(),
            _BadgeIcon(
              icon: Icons.notifications_none_rounded,
              count: '3',
              onTap: onNotificationTap,
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          readOnly: true,
          onTap: onSearchTap,
          decoration: InputDecoration(
            hintText: 'Search products here'.tr,
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
        ),
      ),
    ],
  );
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({
    required this.icon,
    required this.count,
    required this.onTap,
  });
  final IconData icon;
  final String count;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        const SizedBox(width: 28, height: 28),
        Positioned.fill(child: Icon(icon, color: Colors.white, size: 25)),
        Positioned(right: -3, top: -3, child: _CountBadge(value: count)),
      ],
    ),
  );
}

class _HeroSlider extends StatelessWidget {
  const _HeroSlider({required this.viewModel});
  final StationeryHomeViewModel viewModel;

  @override
  Widget build(BuildContext context) => Obx(() {
    if (viewModel.isBannersLoading.value) {
      return const SizedBox(
        height: 173,
        child: Padding(
          padding: EdgeInsets.only(bottom: 13),
          child: AppShimmer(
            child: ShimmerBox(width: double.infinity, height: 160, radius: 0),
          ),
        ),
      );
    }
    if (viewModel.banners.isEmpty) return const SizedBox.shrink();
    final hasRemoteBanners =
        viewModel.banners.isNotEmpty &&
        viewModel.banners.first.imageUrl?.isNotEmpty == true;
    return SizedBox(
      height: hasRemoteBanners ? 173 : 186,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: viewModel.bannerController,
              itemCount: viewModel.banners.length,
              onPageChanged: viewModel.updateBanner,
              itemBuilder: (context, index) =>
                  _HeroCard(banner: viewModel.banners[index]),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              viewModel.banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: viewModel.activeBanner.value == index ? 24 : 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6, top: 7),
                decoration: BoxDecoration(
                  color: viewModel.activeBanner.value == index
                      ? Colors.white
                      : const Color(0xFFB7B8D1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.banner});
  final HomeBanner banner;
  @override
  Widget build(BuildContext context) {
    final imageUrl = banner.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        color: const Color.fromARGB(255, 231, 230, 236),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.white54),
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.fromLTRB(24, 12, 14, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  banner.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .8),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: StationeryHomePage._pink,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 9,
                    ),
                  ),
                  child: Text('Shop Now'.tr),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 116,
            height: 116,
            child: Image.asset(banner.imageAsset, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.badge,
    this.onArrowTap,
  });
  final String title;
  final String? badge;
  final VoidCallback? onArrowTap;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Text(
                title.tr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 7),
                _LabelBadge(value: badge!),
              ],
              const Spacer(),
              IconButton(
                key: switch (title) {
                  'Categories' => const Key('home-categories-arrow'),
                  'Best Sellers' => const Key('home-best-sellers-arrow'),
                  'New Arrivals' => const Key('home-new-arrivals-arrow'),
                  'Recommended For You' => const Key('home-recommended-arrow'),
                  _ => null,
                },
                onPressed: onArrowTap,
                visualDensity: VisualDensity.compact,
                tooltip: onArrowTap == null ? null : 'View $title',
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    ),
  );
}

class _HomeCategoriesContent extends StatelessWidget {
  const _HomeCategoriesContent({
    required this.items,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.onTap,
  });

  final List<CatalogCategory> items;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<CatalogCategory> onTap;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const HorizontalProductShimmer(height: 104, itemWidth: 72);
    }
    if (error != null) {
      return _HomeTaxonomyError(message: error!, onRetry: onRetry);
    }
    if (items.isEmpty) {
      return const _HomeTaxonomyEmpty(message: 'No categories found.');
    }
    return _CategoryList(items: items, onTap: onTap);
  }
}

class _HomeBrandsContent extends StatelessWidget {
  const _HomeBrandsContent({
    required this.items,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final List<CatalogBrand> items;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const HorizontalProductShimmer(height: 86, itemWidth: 64);
    }
    if (error != null) {
      return _HomeTaxonomyError(message: error!, onRetry: onRetry);
    }
    if (items.isEmpty) {
      return const _HomeTaxonomyEmpty(message: 'No brands found.');
    }
    return _BrandList(items: items);
  }
}

class _HomeTaxonomyError extends StatelessWidget {
  const _HomeTaxonomyError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 86,
    child: Center(
      child: TextButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: Text(message.tr),
      ),
    ),
  );
}

class _HomeTaxonomyEmpty extends StatelessWidget {
  const _HomeTaxonomyEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 86, child: Center(child: Text(message.tr)));
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.item});

  final CatalogCategory item;

  @override
  Widget build(BuildContext context) => item.imageUrl.isEmpty
      ? const ColoredBox(
          color: Color(0xFFF3F4F6),
          child: Icon(Icons.category_outlined),
        )
      : Image.network(
          item.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: Color(0xFFF3F4F6),
            child: Icon(Icons.category_outlined),
          ),
        );
}

class _BrandImage extends StatelessWidget {
  const _BrandImage({required this.item});

  final CatalogBrand item;

  @override
  Widget build(BuildContext context) => item.imageUrl.isEmpty
      ? const Icon(Icons.sell_outlined)
      : Image.network(
          item.imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(Icons.sell_outlined),
        );
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.items, required this.onTap});
  final List<CatalogCategory> items;
  final ValueChanged<CatalogCategory> onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 104,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, index) => SizedBox(
        width: 72,
        child: InkWell(
          key: Key('home-category-${items[index].name}'),
          onTap: () => onTap(items[index]),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x201F1C4D),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(child: _CategoryImage(item: items[index])),
              ),
              const SizedBox(height: 7),
              Text(
                items[index].name.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _BrandList extends StatelessWidget {
  const _BrandList({required this.items});
  final List<CatalogBrand> items;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 86,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (_, index) => SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _BrandImage(item: items[index]),
            ),
            const SizedBox(height: 5),
            Text(
              items[index].name.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.items,
    this.onLoadMore,
    this.loadingMore = false,
    this.useReferenceCard = false,
    this.useRecommendedListBackground = false,
    required this.onAddToCart,
  });
  final List<HomeProduct> items;
  final VoidCallback? onLoadMore;
  final bool loadingMore;
  final bool useReferenceCard;
  final bool useRecommendedListBackground;
  final ValueChanged<HomeProduct> onAddToCart;
  @override
  Widget build(BuildContext context) => Container(
    color: useRecommendedListBackground
        ? null
        : useReferenceCard
        ? Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : Colors.white
        : null,
    height: useReferenceCard ? 200 : 186,
    child: NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (onLoadMore != null &&
            !loadingMore &&
            notification.metrics.extentAfter < 180) {
          onLoadMore!();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length + (loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) => index == items.length
            ? const _HorizontalLoadingIndicator()
            : _ProductCard(
                product: items[index],
                useReferenceCard: useReferenceCard,
                onAddToCart: () => onAddToCart(items[index]),
              ),
      ),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onAddToCart,
    this.useReferenceCard = false,
  });
  final HomeProduct product;
  final bool useReferenceCard;
  final VoidCallback onAddToCart;
  @override
  Widget build(BuildContext context) => _PressBounce(
    enabled: useReferenceCard,
    child: InkWell(
      onTap: product.id.isEmpty
          ? null
          : () => Get.toNamed(AppRoutes.productDetail, arguments: product.id),
      borderRadius: BorderRadius.circular(useReferenceCard ? 18 : 12),
      child: Container(
        width: 142,
        margin: useReferenceCard
            ? const EdgeInsets.symmetric(vertical: 12)
            : null,
        padding: EdgeInsets.all(useReferenceCard ? 0 : 8),
        decoration: BoxDecoration(
          color: useReferenceCard
              ? Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : Colors.white
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(useReferenceCard ? 18 : 12),
          border: useReferenceCard
              ? Border.all(color: const Color(0xFFF0F0F0))
              : null,
          boxShadow: [
            BoxShadow(
              color: useReferenceCard
                  ? const Color(0x0D000000)
                  : const Color(0x16000000),
              blurRadius: useReferenceCard ? 12 : 9,
              offset: Offset(0, useReferenceCard ? 4 : 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: useReferenceCard
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(17),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: product.imageUrl?.isNotEmpty == true
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                ),
                              )
                            : Image.asset(
                                product.imageAsset,
                                fit: BoxFit.cover,
                              ),
                      ),
                    )
                  : Center(
                      child: product.imageUrl?.isNotEmpty == true
                          ? Image.network(
                              product.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.image_not_supported_outlined,
                                size: 36,
                              ),
                            )
                          : Image.asset(
                              product.imageAsset,
                              fit: BoxFit.contain,
                            ),
                    ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: useReferenceCard ? 16 : 0,
              ),
              child: Text(
                product.name.tr,
                maxLines: useReferenceCard ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 11,
                  fontWeight: useReferenceCard
                      ? FontWeight.w800
                      : FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: useReferenceCard ? 8 : 4),
            Padding(
              padding: EdgeInsets.fromLTRB(
                useReferenceCard ? 16 : 0,
                0,
                useReferenceCard ? 16 : 0,
                useReferenceCard ? 12 : 0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.price,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onAddToCart,
                    child: useReferenceCard
                        ? Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: StationeryHomePage._pink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.add_shopping_cart_outlined,
                              color: StationeryHomePage._pink,
                              size: 19,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PressBounce extends StatefulWidget {
  const _PressBounce({required this.enabled, required this.child});
  final bool enabled;
  final Widget child;

  @override
  State<_PressBounce> createState() => _PressBounceState();
}

class _PressBounceState extends State<_PressBounce> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _setPressed(true),
    onPointerUp: (_) => _setPressed(false),
    onPointerCancel: (_) => _setPressed(false),
    child: AnimatedScale(
      scale: _pressed ? .97 : 1,
      duration: const Duration(milliseconds: 180),
      curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
      child: widget.child,
    ),
  );
}

class _RemoteProductContent extends StatelessWidget {
  const _RemoteProductContent({
    required this.items,
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.hasMore,
    required this.onRetry,
    required this.onLoadMore,
    required this.onAddToCart,
    this.useReferenceCard = false,
    this.useRecommendedListBackground = false,
  });

  final List<HomeProduct> items;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final bool hasMore;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final ValueChanged<HomeProduct> onAddToCart;
  final bool useReferenceCard;
  final bool useRecommendedListBackground;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const HorizontalProductShimmer();
    }
    if (error != null) {
      return SizedBox(
        height: 120,
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(error!),
          ),
        ),
      );
    }
    if (items.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No best sellers found.')),
      );
    }
    return _ProductList(
      items: items,
      useReferenceCard: useReferenceCard,
      useRecommendedListBackground: useRecommendedListBackground,
      onAddToCart: onAddToCart,
      onLoadMore: hasMore ? onLoadMore : null,
      loadingMore: loadingMore,
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.banner});

  final HomePromoBanner banner;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF252269), Color(0xFF5948E4)],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                banner.title.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5),
              Text(
                banner.subtitle.tr,
                style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12),
              ),
              SizedBox(height: 14),
              if (banner.buttonText.isNotEmpty)
                _LabelBadge(
                  value: banner.buttonText,
                  onTap: () => Get.toNamed<void>(
                    AppRoutes.productList,
                    arguments: const ProductListRequest.discountProducts(),
                  ),
                ),
            ],
          ),
        ),
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .2),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: banner.imageUrl?.isNotEmpty == true
              ? Image.network(
                  banner.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white,
                    size: 42,
                  ),
                )
              : const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 42,
                ),
        ),
      ],
    ),
  );
}

class _OfferCardLoading extends StatelessWidget {
  const _OfferCardLoading();

  @override
  Widget build(BuildContext context) => Container(
    height: 132,
    margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
    ),
  );
}

class _FlashSaleSection extends StatelessWidget {
  const _FlashSaleSection({
    required this.items,
    this.onLoadMore,
    this.loadingMore = false,
    required this.onViewAll,
  });
  final List<HomeProduct> items;
  final VoidCallback? onLoadMore;
  final bool loadingMore;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.symmetric(vertical: 14),
    color: Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surfaceContainerLowest
        : const Color(0xFFFFF3F8),
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              InkWell(
                key: const Key('home-flash-sale-title'),
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Flash Sale'.tr,
                    style: TextStyle(
                      color: StationeryHomePage._pink,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              IconButton(
                key: const Key('home-flash-sale-arrow'),
                onPressed: onViewAll,
                tooltip: 'View Flash Sale',
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: StationeryHomePage._pink,
                ),
              ),
              Spacer(),
              _TimerBox(value: '02'),
              SizedBox(width: 5),
              _TimerBox(value: '18'),
              SizedBox(width: 5),
              _TimerBox(value: '45'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 308,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (onLoadMore != null &&
                  !loadingMore &&
                  notification.metrics.extentAfter < 180) {
                onLoadMore!();
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: items.length + (loadingMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, index) => index == items.length
                  ? const _HorizontalLoadingIndicator()
                  : _FlashSaleCard(
                      product: items[index],
                      stockLeft: const [2, 6, 1][index % 3],
                      progress: const [.8, .4, .9][index % 3],
                      onTap: () => Get.toNamed<void>(
                        AppRoutes.productDetail,
                        arguments: items[index].id,
                      ),
                    ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _FlashSaleContent extends StatelessWidget {
  const _FlashSaleContent({
    required this.items,
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.hasMore,
    required this.onRetry,
    required this.onLoadMore,
    required this.onViewAll,
  });

  final List<HomeProduct> items;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final bool hasMore;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const HorizontalProductShimmer(height: 308, itemWidth: 202);
    }
    if (error != null) {
      return SizedBox(
        height: 130,
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(error!),
          ),
        ),
      );
    }
    if (items.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No flash sale products found.')),
      );
    }
    return _FlashSaleSection(
      items: items,
      onLoadMore: hasMore ? onLoadMore : null,
      loadingMore: loadingMore,
      onViewAll: onViewAll,
    );
  }
}

class _TimerBox extends StatelessWidget {
  const _TimerBox({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 30,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: StationeryHomePage._pink,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      value,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _FlashSaleCard extends StatelessWidget {
  const _FlashSaleCard({
    required this.product,
    required this.stockLeft,
    required this.progress,
    required this.onTap,
  });
  final HomeProduct product;
  final int stockLeft;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      width: 202,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -3,
            top: -3,
            child: Container(
              width: 66,
              height: 22,
              decoration: const BoxDecoration(
                color: StationeryHomePage._pink,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(14),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  height: 136,
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: _RemoteOrAssetImage(product: product),
                ),
              ),
              const SizedBox(height: 11),
              Text(
                product.name.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                product.price,
                style: const TextStyle(
                  color: StationeryHomePage._pink,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: StationeryHomePage._pink,
                  backgroundColor: Theme.of(context).dividerColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$stockLeft left!'.tr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: StationeryHomePage._pink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text('Add to Cart'.tr),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _RecommendedList extends StatelessWidget {
  const _RecommendedList({
    required this.items,
    this.onLoadMore,
    this.loadingMore = false,
  });
  final List<HomeProduct> items;
  final VoidCallback? onLoadMore;
  final bool loadingMore;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 218,
    child: NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (onLoadMore != null &&
            !loadingMore &&
            notification.metrics.extentAfter < 180) {
          onLoadMore!();
        }
        return false;
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length + (loadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, index) => index == items.length
            ? const _HorizontalLoadingIndicator()
            : _RecommendedCard(product: items[index]),
      ),
    ),
  );
}

class _RecommendedContent extends StatelessWidget {
  const _RecommendedContent({
    required this.items,
    required this.loading,
    required this.loadingMore,
    required this.error,
    required this.hasMore,
    required this.onRetry,
    required this.onLoadMore,
  });

  final List<HomeProduct> items;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final bool hasMore;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const HorizontalProductShimmer(height: 218, itemWidth: 158);
    }
    if (error != null) {
      return SizedBox(
        height: 120,
        child: Center(
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(error!),
          ),
        ),
      );
    }
    if (items.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No recommended products found.')),
      );
    }
    return _RecommendedList(
      items: items,
      onLoadMore: hasMore ? onLoadMore : null,
      loadingMore: loadingMore,
    );
  }
}

class _HorizontalLoadingIndicator extends StatelessWidget {
  const _HorizontalLoadingIndicator();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 52,
    child: Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );
}

class _RemoteOrAssetImage extends StatelessWidget {
  const _RemoteOrAssetImage({required this.product, this.fit = BoxFit.contain});

  final HomeProduct product;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => product.imageUrl?.isNotEmpty == true
      ? Image.network(
          product.imageUrl!,
          fit: fit,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.image_not_supported_outlined, size: 36),
        )
      : Image.asset(product.imageAsset, fit: fit);
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.product});
  final HomeProduct product;

  @override
  Widget build(BuildContext context) => InkWell(
    key: Key('recommended-product-${product.id}'),
    onTap: product.id.isEmpty
        ? null
        : () =>
              Get.toNamed<void>(AppRoutes.productDetail, arguments: product.id),
    borderRadius: BorderRadius.circular(14),
    child: Container(
      width: 158,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Container(
                  width: double.infinity,
                  height: 112,
                  color: Theme.of(context).colorScheme.surface,
                  child: _RemoteOrAssetImage(
                    product: product,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Obx(() {
                  final controller = Get.find<StationeryHomeViewModel>();
                  final isUpdating = controller.updatingRecommendedWishlistIds
                      .contains(product.id);
                  final isFavorite = controller.recommendedFavoriteIds.contains(
                    product.id,
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: isUpdating
                        ? null
                        : () => controller.toggleRecommendedWishlist(product),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: isUpdating
                          ? const Padding(
                              padding: EdgeInsets.all(7),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: StationeryHomePage._pink,
                              size: 18,
                            ),
                    ),
                  );
                }),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '★★★★★'.tr,
                  style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.price,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: StationeryHomePage._pink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _CollectionsSection extends StatelessWidget {
  const _CollectionsSection({required this.controller});
  final StationeryHomeViewModel controller;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Collections'.tr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (controller.isCollectionsLoading.value) {
            return const SizedBox(
              height: 170,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (controller.collections.isEmpty) return const SizedBox.shrink();
          return SizedBox(
            height: 170,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: controller.collections.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, index) => _CollectionCard(
                collection: controller.collections[index],
                colors: index.isEven
                    ? const [Color(0xFF4338CA), Color(0xFF1E1B4B)]
                    : const [Color(0xFFDB2777), Color(0xFF9D174D)],
                onExplore: () => Get.toNamed<void>(
                  AppRoutes.productList,
                  arguments: ProductListRequest.collection(
                    id: controller.collections[index].id,
                    name: controller.collections[index].name,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    ),
  );
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.collection,
    required this.colors,
    required this.onExplore,
  });
  final ProductCollection collection;
  final List<Color> colors;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) => Container(
    width: 195,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -10,
          bottom: -10,
          child: SizedBox(
            width: 105,
            height: 120,
            child: collection.imageUrl?.isNotEmpty == true
                ? Image.network(
                    collection.imageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.white,
                      size: 54,
                    ),
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white,
                    size: 54,
                  ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CollectionBadge(value: '${collection.itemCount} ITEMS'),
            const SizedBox(height: 12),
            Text(
              collection.name.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              collection.subtitle.tr,
              style: const TextStyle(color: Color(0xFFD8D5FF), fontSize: 11),
            ),
            const Spacer(),
            Material(
              color: colors.last.withValues(alpha: .85),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: onExplore,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Text(
                    'Explore →'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _CollectionBadge extends StatelessWidget {
  const _CollectionBadge({required this.value});
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: .25)),
    ),
    child: Text(
      value,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _ChatFooter extends StatelessWidget {
  const _ChatFooter();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
    color: StationeryHomePage._ink,
    child: Column(
      children: [
        Text(
          '💬  Chat with Our Team'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'We reply within minutes · 24/7 support'.tr,
          style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 11),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SupportChannel(
              icon: Icons.smart_display_rounded,
              label: 'YouTube',
              color: Color(0xFFFF0000),
              onTap: () => _openExternalUrl(
                url: 'https://www.youtube.com/@hexcystationery',
                channelName: 'YouTube',
              ),
            ),
            _SupportChannel(
              icon: Icons.message_rounded,
              label: 'Messenger',
              color: Color(0xFF7C3AED),
              onTap: () => _openExternalUrl(
                url: 'https://m.me/hexcystationery',
                channelName: 'Messenger',
              ),
            ),
            _SupportChannel(
              icon: Icons.send_rounded,
              label: 'Telegram',
              color: Color(0xFF38BDF8),
              onTap: () => _openExternalUrl(
                url: 'https://www.hexcymegastore.com/',
                channelName: 'browser',
              ),
            ),
            _SupportChannel(
              icon: Icons.phone_in_talk_rounded,
              label: 'Viber',
              color: Color(0xFF8B5CF6),
              onTap: _openViberChat,
            ),
            _SupportChannel(
              icon: Icons.camera_alt_rounded,
              label: 'Instagram',
              color: Color(0xFFEC4899),
              onTap: () => _openExternalUrl(
                url: 'https://www.instagram.com/hexcystationery/',
                channelName: 'Instagram',
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Divider(color: Color(0x334F46E5), height: 1),
        SizedBox(height: 12),
        Text(
          'Secure & private communication'.tr,
          style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 11),
        ),
      ],
    ),
  );

  static Future<void> _openViberChat() async {
    const phoneNumber = '+959752473565';
    final uri = Uri(
      scheme: 'viber',
      host: 'chat',
      queryParameters: const {'number': phoneNumber},
    );

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (opened) return;
    } catch (_) {
      // The error message below handles devices without Viber.
    }

    Get.snackbar(
      'Unable to open Viber',
      'Please install Viber and try again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static Future<void> _openExternalUrl({
    required String url,
    required String channelName,
  }) async {
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (opened) return;
    } catch (_) {
      // The error message below handles unavailable external applications.
    }

    Get.snackbar(
      'Unable to open $channelName',
      'Please try again later.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _SupportChannel extends StatelessWidget {
  const _SupportChannel({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(28),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: .2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 5),
          Text(
            label.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PaymentMethods extends StatelessWidget {
  const _PaymentMethods();
  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surface,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
    child: const Row(
      children: [
        Expanded(
          child: _PaymentCard(
            label: 'MMQR',
            color: Color(0xFF2563EB),
            icon: Icons.qr_code_rounded,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _PaymentCard(
            label: 'Kpay',
            color: Color(0xFF10B981),
            icon: Icons.account_balance_wallet_rounded,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _PaymentCard(
            label: 'MPU',
            color: Color(0xFFF97316),
            icon: Icons.credit_card_rounded,
          ),
        ),
      ],
    ),
  );
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.label,
    required this.color,
    required this.icon,
  });
  final String label;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    height: 92,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: .25),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        const SizedBox(height: 8),
        Text(
          label.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.value});
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: StationeryHomePage._pink,
      shape: BoxShape.circle,
    ),
    child: Text(
      value,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _LabelBadge extends StatelessWidget {
  const _LabelBadge({required this.value, this.onTap});
  final String value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: StationeryHomePage._pink,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ),
  );
}
