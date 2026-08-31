import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/data/models/catalog_category.dart';
import 'package:mobile_hexy/presentation/widgets/shimmer_skeletons.dart';
import 'package:mobile_hexy/presentation/viewmodel/categories_view_model.dart';

class CategoriesPage extends GetView<CategoriesViewModel> {
  const CategoriesPage({super.key});

  static const _ink = Color(0xFF1E1B4B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CategoriesShimmer();
                }
                final error = controller.errorMessage.value;
                if (error != null) {
                  return _CategoriesError(
                    message: error,
                    onRetry: controller.loadCategories,
                  );
                }
                if (controller.categories.isEmpty) {
                  return const Center(child: Text('No categories found.'));
                }
                return Row(
                  children: [
                    SizedBox(
                      width: 88,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: ListView.builder(
                          itemCount: controller.categories.length,
                          itemBuilder: (context, index) {
                            final item = controller.categories[index];
                            return _SidebarItem(
                              item: item,
                              selected: controller.selectedIndex.value == index,
                              onTap: () => controller.selectCategory(index),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: controller.isSubcategoriesLoading.value
                          ? const CategoriesShimmer(sidebar: false)
                          : _SubcategoryList(
                              selectedName: controller
                                  .categories[controller.selectedIndex.value]
                                  .name,
                              items: controller.subcategories,
                            ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Row(
      children: [
        const SizedBox(width: 70),
        Expanded(
          child: Center(
            child: Text(
              'Categories'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 70),
      ],
    ),
  );
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });
  final CatalogCategory item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 72,
      decoration: BoxDecoration(
        color: selected ? CategoriesPage._ink : Colors.transparent,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Stack(
        children: [
          if (selected)
            const Positioned(
              left: 0,
              top: 20,
              bottom: 20,
              child: SizedBox(
                width: 3,
                child: ColoredBox(color: Color(0xFFDB2777)),
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: item.imageUrl.isEmpty
                        ? const Icon(Icons.category_outlined, size: 22)
                        : Image.network(
                            item.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.category_outlined, size: 22),
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SubcategoryList extends StatelessWidget {
  const _SubcategoryList({required this.selectedName, required this.items});
  final String selectedName;
  final List<CatalogCategory> items;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      Text(
        'Subcategories'.tr,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 14),
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          '${selectedName.tr} ${'Collections'.tr}',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      if (items.isEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 24),
          child: Center(child: Text('No subcategories found.')),
        ),
      ...items.map((item) => _SubcategoryCard(item: item)),
    ],
  );
}

class _SubcategoryCard extends StatelessWidget {
  const _SubcategoryCard({required this.item});
  final CatalogCategory item;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Get.toNamed<void>(AppRoutes.productList, arguments: item),
    borderRadius: BorderRadius.circular(12),
    child: Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.name.tr,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${item.productCount} products'.tr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _CategoriesError extends StatelessWidget {
  const _CategoriesError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
