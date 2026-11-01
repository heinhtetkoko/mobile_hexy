import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/data/models/catalog_brand.dart';
import 'package:mobile_hexy/data/models/product_list_request.dart';
import 'package:mobile_hexy/presentation/viewmodel/brands_view_model.dart';

class BrandsPage extends GetView<BrandsViewModel> {
  const BrandsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          const _Header(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.brands.isEmpty) {
                return const _BrandGridLoading();
              }
              if (controller.error.value != null && controller.brands.isEmpty) {
                return _BrandsMessage(
                  icon: Icons.cloud_off_rounded,
                  message: controller.error.value!,
                  actionLabel: 'Try again',
                  onAction: controller.loadBrands,
                );
              }
              if (controller.brands.isEmpty) {
                return const _BrandsMessage(
                  icon: Icons.sell_outlined,
                  message: 'No brands found.',
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadBrands,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    mainAxisExtent: 196,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: controller.brands.length,
                  itemBuilder: (_, index) => _BrandCard(
                    brand: controller.brands[index],
                    onTap: () => Get.toNamed<void>(
                      AppRoutes.productList,
                      arguments: ProductListRequest.brand(
                        id: controller.brands[index].id,
                        name: controller.brands[index].name,
                      ),
                    ),
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
        SizedBox(
          width: 70,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: const CircleBorder(),
              child: IconButton(
                key: const Key('brands-back-button'),
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Top Brands'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 70),
      ],
    ),
  );
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.brand, required this.onTap});

  final CatalogBrand brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: colors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: .65),
          ),
        ),
        child: InkWell(
          key: Key('brand-${brand.id}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: brand.imageUrl.isEmpty
                        ? Icon(
                            Icons.sell_outlined,
                            size: 36,
                            color: Colors.grey.shade400,
                          )
                        : Image.network(
                            brand.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.sell_outlined,
                              size: 36,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  brand.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${brand.productCount} ${brand.productCount == 1 ? 'product' : 'products'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: .08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandsMessage extends StatelessWidget {
  const _BrandsMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 14),
          Text(message.tr, textAlign: TextAlign.center),
          if (onAction != null) ...[
            const SizedBox(height: 14),
            FilledButton.tonal(
              onPressed: onAction,
              child: Text(actionLabel!.tr),
            ),
          ],
        ],
      ),
    ),
  );
}

class _BrandGridLoading extends StatelessWidget {
  const _BrandGridLoading();

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 180,
      mainAxisExtent: 196,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
    ),
    itemCount: 8,
    itemBuilder: (_, _) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  );
}
