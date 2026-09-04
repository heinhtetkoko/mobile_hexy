import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';
import 'package:mobile_hexy/data/models/catalog_product.dart';
import 'package:mobile_hexy/presentation/widgets/shimmer_skeletons.dart';
import 'package:mobile_hexy/presentation/viewmodel/product_list_view_model.dart';

class ProductListPage extends GetView<ProductListViewModel> {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          _Header(controller: controller),
          _Toolbar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const ProductGridShimmer();
              }
              final error = controller.errorMessage.value;
              if (error != null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: controller.loadProducts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              final products = controller.filteredProducts;
              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (controller.hasNextPage.value &&
                      !controller.isLoadingMore.value &&
                      notification.metrics.extentAfter < 320) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: RefreshIndicator(
                  onRefresh: controller.loadProducts,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (products.isEmpty)
                        SliverFillRemaining(
                          child: Center(child: Text('No products found'.tr)),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid.builder(
                            itemCount: products.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: .82,
                                ),
                            itemBuilder: (_, index) => _ProductCard(
                              product: products[index],
                              favorite: controller.favorites.contains(
                                products[index].id,
                              ),
                              onFavorite: () =>
                                  controller.toggleFavorite(products[index].id),
                              onCart: () =>
                                  controller.addToCart(products[index]),
                              onOpen: () => Get.toNamed<void>(
                                AppRoutes.productDetail,
                                arguments: products[index].id,
                              ),
                            ),
                          ),
                        ),
                      if (controller.isLoadingMore.value)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final ProductListViewModel controller;

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Obx(
      () => controller.searching.value
          ? Row(
              children: [
                SizedBox(
                  width: 48,
                  child: IconButton(
                    onPressed: () {
                      controller.searching.value = false;
                      controller.query.value = '';
                    },
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                ),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    onChanged: (value) => controller.query.value = value,
                    decoration: InputDecoration(
                      hintText: 'Search products'.tr,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    controller.categoryName.value.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => controller.searching.value = true,
                      icon: const Icon(Icons.search_rounded, size: 21),
                    ),
                  ),
                ),
              ],
            ),
    ),
  );
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.controller});
  final ProductListViewModel controller;

  void _showSort() {
    controller.beginSort();
    Get.bottomSheet<void>(
      _SortBySheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showFilter() {
    controller.beginFilter();
    Get.bottomSheet<void>(
      _FilterSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Row(
      children: [
        Obx(
          () => _ToolChip(
            icon: Icons.sort_rounded,
            label: controller.sortLabel.value,
            onTap: _showSort,
            trailing: Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          ),
        ),
        const SizedBox(width: 12),
        Obx(
          () => _ToolChip(
            icon: Icons.tune_rounded,
            label: 'Filter',
            onTap: _showFilter,
            trailing: controller.activeFilters.value == 0
                ? null
                : _Badge('${controller.activeFilters.value}'),
          ),
        ),
      ],
    ),
  );
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({required this.controller});
  final ProductListViewModel controller;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.only(top: 24, bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              child: SizedBox(
                width: 32,
                height: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Text(
                    'Filter'.tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    key: const Key('reset-filters'),
                    onPressed: controller.resetPendingFilters,
                    child: Text(
                      'Reset All'.tr,
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const _FilterTitle('Category'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.filterCategories.map((category) {
                    final selected =
                        controller.pendingCategory.value == category.name;
                    return ChoiceChip(
                      selected: selected,
                      showCheckmark: false,
                      onSelected: (_) => controller.pendingCategory.value =
                          selected ? '' : category.name,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      side: BorderSide(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                      ),
                      label: Text(category.name.tr),
                      labelStyle: TextStyle(
                        color: selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const _FilterTitle('Brand'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Obx(
                () => Wrap(
                  children: controller.filterBrands.map((brand) {
                    final selected = controller.pendingBrands.contains(
                      brand.name,
                    );
                    return SizedBox(
                      width: MediaQuery.sizeOf(context).width / 2 - 16,
                      height: 40,
                      child: InkWell(
                        onTap: () => controller.togglePendingBrand(brand.name),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded,
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              brand.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(
                () => Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Price Range'.tr,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_money(controller.pendingPriceRange.value.start)} — ${_money(controller.pendingPriceRange.value.end)}'
                              .tr,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: controller.pendingPriceRange.value,
                      min: 0,
                      max: 15000,
                      divisions: 15,
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor: Theme.of(context).dividerColor,
                      onChanged: (value) =>
                          controller.pendingPriceRange.value = value,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(
                () => SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'In Stock Only'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  value: controller.pendingInStockOnly.value,
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) =>
                      controller.pendingInStockOnly.value = value,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: Obx(
                  () => FilledButton(
                    key: const Key('apply-filters'),
                    onPressed: controller.applyFilters,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: Text(
                      'Apply Filters (${controller.pendingFilterCount})'.tr,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  static String _money(double value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
      buffer.write(digits[index]);
    }
    return '$buffer Ks';
  }
}

class _FilterTitle extends StatelessWidget {
  const _FilterTitle(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      value,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _SortBySheet extends StatelessWidget {
  const _SortBySheet({required this.controller});
  final ProductListViewModel controller;

  static const options = [
    'Default Sorting',
    'Popular',
    'New Arrivals',
    'Price: Low to High',
    'Price: High to Low',
    'Biggest Discount',
    'A–Z',
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 12,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            child: SizedBox(
              width: 32,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Text(
              'Sort By'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Obx(
            () => Column(
              children: options.map((option) {
                final selected = controller.pendingSort.value == option;
                return InkWell(
                  key: Key('sort-${option.toLowerCase()}'),
                  onTap: () => controller.pendingSort.value = option,
                  child: SizedBox(
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            option,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 15,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                key: const Key('apply-sort'),
                onPressed: controller.applySort,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text('Apply'.tr),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 5),
          Text(
            label.tr,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 4), trailing!],
        ],
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      value.replaceFirst(RegExp(r'^[-−]\s*'), ''),
      style: TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.favorite,
    required this.onFavorite,
    required this.onCart,
    required this.onOpen,
  });
  final CatalogProduct product;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onCart;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Theme.of(context).dividerColor),
    ),
    elevation: 2,
    shadowColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withValues(alpha: .45)
        : const Color(0x18000000),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (product.imageUrl?.isNotEmpty == true)
                  Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                    ),
                  )
                else
                  Image.asset(product.imageAsset, fit: BoxFit.cover),
                if (product.discount != null)
                  Positioned(left: 8, top: 8, child: _Badge(product.discount!)),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Material(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: .92),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onFavorite,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Icon(
                          favorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: favorite
                              ? AppColors.accent
                              : Theme.of(context).colorScheme.onSurface,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 12,
                    ),
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 12,
                    ),
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 12,
                    ),
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 12,
                    ),
                    Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      product.price,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (product.originalPrice != null) ...[
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          product.originalPrice!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    InkWell(
                      onTap: onCart,
                      child: Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
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
