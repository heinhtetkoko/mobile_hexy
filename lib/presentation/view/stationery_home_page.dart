import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/routes/app_routes.dart';
import 'package:mobile_hexy/domain/entities/home_catalog.dart';
import 'package:mobile_hexy/presentation/viewmodel/stationery_home_view_model.dart';

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
            _Header(onSearch: controller.updateSearch),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _HeroSlider(viewModel: controller)),
                  SliverToBoxAdapter(
                    child: _Section(
                      title: 'Categories',
                      child: _CategoryList(
                        items: controller.catalog.categories,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _Section(
                      title: 'Top Brands',
                      child: _BrandList(items: controller.catalog.brands),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _Section(
                      title: 'Best Sellers',
                      badge: 'HOT',
                      child: _ProductList(
                        items: controller.catalog.bestSellers,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _Section(
                      title: 'New Arrivals',
                      badge: 'NEW',
                      child: _ProductList(
                        items: controller.catalog.newArrivals,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: _OfferCard()),
                  SliverToBoxAdapter(
                    child: _FlashSaleSection(
                      items: controller.catalog.bestSellers,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _Section(
                      title: 'Recommended For You',
                      badge: '✨',
                      child: _RecommendedList(
                        items: controller.catalog.newArrivals,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: _CollectionsSection()),
                  const SliverToBoxAdapter(child: _ChatFooter()),
                  const SliverToBoxAdapter(child: _PaymentMethods()),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearch});
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: StationeryHomePage._ink,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'H'.tr,
                style: TextStyle(
                  color: StationeryHomePage._ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Spacer(),
            _BadgeIcon(icon: Icons.notifications_none_rounded, count: '3'),
            const SizedBox(width: 14),
            _BadgeIcon(icon: Icons.shopping_cart_outlined, count: '2'),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          onChanged: onSearch,
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
  const _BadgeIcon({required this.icon, required this.count});
  final IconData icon;
  final String count;
  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      const SizedBox(width: 28, height: 28),
      Positioned.fill(child: Icon(icon, color: Colors.white, size: 25)),
      Positioned(right: -3, top: -3, child: _CountBadge(value: count)),
    ],
  );
}

class _HeroSlider extends StatelessWidget {
  const _HeroSlider({required this.viewModel});
  final StationeryHomeViewModel viewModel;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 186,
    child: Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: viewModel.bannerController,
            itemCount: viewModel.catalog.banners.length,
            onPageChanged: viewModel.updateBanner,
            itemBuilder: (context, index) =>
                _HeroCard(banner: viewModel.catalog.banners[index]),
          ),
        ),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              viewModel.catalog.banners.length,
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
        ),
      ],
    ),
  );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.banner});
  final HomeBanner banner;
  @override
  Widget build(BuildContext context) => Container(
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.badge});
  final String title;
  final String? badge;
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
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),
        ),
        child,
      ],
    ),
  );
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.items});
  final List<HomeCategory> items;
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
              child: ClipOval(
                child: Image.asset(items[index].imageAsset, fit: BoxFit.cover),
              ),
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
  );
}

class _BrandList extends StatelessWidget {
  const _BrandList({required this.items});
  final List<HomeCategory> items;
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
              child: Image.asset(items[index].imageAsset, fit: BoxFit.contain),
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
  const _ProductList({required this.items});
  final List<HomeProduct> items;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 186,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, index) => _ProductCard(product: items[index]),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final HomeProduct product;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Get.toNamed(AppRoutes.productDetail),
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 142,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 9,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(product.imageAsset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            product.name.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
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
              const Icon(
                Icons.add_shopping_cart_outlined,
                color: StationeryHomePage._pink,
                size: 19,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _OfferCard extends StatelessWidget {
  const _OfferCard();
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
                'Buy 2 Get 1 FREE'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'On all notebooks & stationery sets'.tr,
                style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12),
              ),
              SizedBox(height: 14),
              _LabelBadge(value: 'Grab Deal'),
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
          child: const Icon(
            Icons.inventory_2_outlined,
            color: Colors.white,
            size: 42,
          ),
        ),
      ],
    ),
  );
}

class _FlashSaleSection extends StatelessWidget {
  const _FlashSaleSection({required this.items});
  final List<HomeProduct> items;

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
              Text(
                'Flash Sale'.tr,
                style: TextStyle(
                  color: StationeryHomePage._pink,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
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
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) => _FlashSaleCard(
              product: items[index],
              stockLeft: const [2, 6, 1][index % 3],
              progress: const [.8, .4, .9][index % 3],
            ),
          ),
        ),
      ],
    ),
  );
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
  });
  final HomeProduct product;
  final int stockLeft;
  final double progress;

  @override
  Widget build(BuildContext context) => Container(
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
                child: Image.asset(product.imageAsset, fit: BoxFit.contain),
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
  );
}

class _RecommendedList extends StatelessWidget {
  const _RecommendedList({required this.items});
  final List<HomeProduct> items;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 218,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, index) => _RecommendedCard(product: items[index]),
    ),
  );
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.product});
  final HomeProduct product;

  @override
  Widget build(BuildContext context) => Container(
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                width: double.infinity,
                height: 112,
                padding: const EdgeInsets.all(8),
                child: Image.asset(product.imageAsset, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: StationeryHomePage._pink,
                  size: 18,
                ),
              ),
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
  );
}

class _CollectionsSection extends StatelessWidget {
  const _CollectionsSection();

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
        SizedBox(
          height: 170,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: const [
              _CollectionCard(
                title: 'Office\nSupplies',
                subtitle: 'Shop essentials',
                count: '50+ ITEMS',
                image: 'assets/images/figma_home/product_1.png',
                colors: [Color(0xFF4338CA), Color(0xFF1E1B4B)],
              ),
              SizedBox(width: 12),
              _CollectionCard(
                title: 'School\nSupplies',
                subtitle: 'Back to school',
                count: '80+ ITEMS',
                image: 'assets/images/cart/notebook.png',
                colors: [Color(0xFFDB2777), Color(0xFF9D174D)],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.image,
    required this.colors,
  });
  final String title;
  final String subtitle;
  final String count;
  final String image;
  final List<Color> colors;

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
            child: Image.asset(image, fit: BoxFit.contain),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CollectionBadge(value: count),
            const SizedBox(height: 12),
            Text(
              title.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle.tr,
              style: const TextStyle(color: Color(0xFFD8D5FF), fontSize: 11),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: colors.last.withValues(alpha: .85),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Explore →'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
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
            ),
            _SupportChannel(
              icon: Icons.message_rounded,
              label: 'Messenger',
              color: Color(0xFF7C3AED),
            ),
            _SupportChannel(
              icon: Icons.send_rounded,
              label: 'Telegram',
              color: Color(0xFF38BDF8),
            ),
            _SupportChannel(
              icon: Icons.phone_in_talk_rounded,
              label: 'Viber',
              color: Color(0xFF8B5CF6),
            ),
            _SupportChannel(
              icon: Icons.camera_alt_rounded,
              label: 'Instagram',
              color: Color(0xFFEC4899),
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
}

class _SupportChannel extends StatelessWidget {
  const _SupportChannel({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
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
  const _LabelBadge({required this.value});
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: StationeryHomePage._pink,
      borderRadius: BorderRadius.circular(10),
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
