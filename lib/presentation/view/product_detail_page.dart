import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/widgets/shimmer_skeletons.dart';
import 'package:mobile_hexy/presentation/viewmodel/product_detail_view_model.dart';

class ProductDetailPage extends GetView<ProductDetailViewModel> {
  const ProductDetailPage({super.key});

  static const _ink = Color(0xFF1E1B4B);
  static const _pink = Color(0xFFDB2777);

  @override
  Widget build(BuildContext context) => Obx(() {
    final product = controller.product.value;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: product == null
          ? null
          : _BottomActions(controller: controller),
      body: SafeArea(
        bottom: false,
        child: controller.isLoading.value
            ? const ProductDetailShimmer()
            : controller.errorMessage.value != null
            ? _DetailError(
                message: controller.errorMessage.value!,
                onRetry: controller.loadProduct,
              )
            : product == null
            ? const Center(child: Text('Product not found.'))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _Header(controller: controller)),
                  SliverToBoxAdapter(child: _Gallery(controller: controller)),
                  SliverToBoxAdapter(
                    child: _ProductInfo(controller: controller),
                  ),
                  SliverToBoxAdapter(child: _Variants(controller: controller)),
                  SliverToBoxAdapter(
                    child: _Description(controller: controller),
                  ),
                  const SliverToBoxAdapter(child: _SimilarProducts()),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
      ),
    );
  });
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final ProductDetailViewModel controller;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Row(
      children: [
        const SizedBox(width: 12),
        IconButton(
          onPressed: Get.back,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Product Detail'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          icon: const Icon(Icons.share_outlined, size: 19),
        ),
        Obx(
          () => IconButton(
            onPressed: () => controller.isFavorite.toggle(),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            icon: Icon(
              controller.isFavorite.value
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: controller.isFavorite.value
                  ? ProductDetailPage._pink
                  : Theme.of(context).colorScheme.onSurface,
              size: 19,
            ),
          ),
        ),
        const _CartBadge(),
        const SizedBox(width: 8),
      ],
    ),
  );
}

class _CartBadge extends StatelessWidget {
  const _CartBadge();
  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      IconButton(
        onPressed: () {},
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        icon: const Icon(Icons.shopping_cart_outlined, size: 19),
      ),
      Positioned(
        right: 2,
        top: 0,
        child: Container(
          width: 16,
          height: 16,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: ProductDetailPage._pink,
            shape: BoxShape.circle,
          ),
          child: Text(
            '3'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ],
  );
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.controller});
  final ProductDetailViewModel controller;
  @override
  Widget build(BuildContext context) {
    final images = controller.product.value!.imageUrls;
    return Column(
      children: [
        Obx(
          () => SizedBox(
            height: 300,
            width: double.infinity,
            child: images.isEmpty
                ? const Icon(Icons.image_not_supported_outlined, size: 64)
                : Image.network(
                    images[controller.selectedImage.value],
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                    ),
                  ),
          ),
        ),
        if (images.length > 1)
          SizedBox(
            height: 60,
            child: Obx(() {
              final selectedImage = controller.selectedImage.value;
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () => controller.selectedImage.value = index,
                  child: Container(
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedImage == index
                            ? ProductDetailPage._pink
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(images[index], fit: BoxFit.cover),
                    ),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.controller});
  final ProductDetailViewModel controller;
  @override
  Widget build(BuildContext context) {
    final product = controller.product.value!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.categories
                .map((name) => _Tag(label: name, active: true))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            product.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.sku.isEmpty ? 'No SKU' : 'SKU: ${product.sku}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: product.inStock
                        ? const Color(0xFF22C55E)
                        : Colors.red,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    product.inStock ? 'In Stock'.tr : 'Out of Stock'.tr,
                    style: TextStyle(
                      color: product.inStock
                          ? const Color(0xFF22C55E)
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < product.rating.round()
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: const Color(0xFFFBBF24),
                  size: 18,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                product.rating.toStringAsFixed(1),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' / 5.0 (${product.reviewCount})',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  product.formattedPrice,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (product.formattedCompareAtPrice != null) ...[
                  const SizedBox(width: 12),
                  Text(
                    product.formattedCompareAtPrice!,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
                if (product.discountPercent > 0) ...[
                  const SizedBox(width: 12),
                  _DiscountBadge(percent: product.discountPercent),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.active = false});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: active
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label.tr,
      style: TextStyle(
        fontSize: 11,
        color: active
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});
  final int percent;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: ProductDetailPage._pink,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '$percent% OFF'.tr,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _Variants extends StatelessWidget {
  const _Variants({required this.controller});
  final ProductDetailViewModel controller;
  @override
  Widget build(BuildContext context) {
    final variants = controller.product.value!.variants;
    if (variants.length <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variants'.tr,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: variants.map((variant) {
                final selected =
                    controller.selectedVariantId.value == variant.id;
                return ChoiceChip(
                  label: Text(variant.name),
                  selected: selected,
                  onSelected: (_) =>
                      controller.selectedVariantId.value = variant.id,
                  selectedColor: ProductDetailPage._ink,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    color: selected ? Colors.white : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.controller});
  final ProductDetailViewModel controller;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Description'.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          controller.product.value!.description.isEmpty
              ? 'No description available.'.tr
              : controller.product.value!.description,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

class _SimilarProducts extends StatelessWidget {
  const _SimilarProducts();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.controller});
  final ProductDetailViewModel controller;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(
            () => _QuantitySelector(
              quantity: controller.quantity.value,
              onMinus: controller.decrement,
              onPlus: controller.increment,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: ProductDetailPage._ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text('Add to Cart'.tr),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: ProductDetailPage._pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.bolt),
              label: Text('Buy Now'.tr),
            ),
          ),
        ],
      ),
    ),
  );
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });
  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        onPressed: onMinus,
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
        ),
        icon: const Icon(Icons.remove, size: 16),
      ),
      SizedBox(
        width: 20,
        child: Text(
          '$quantity'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      IconButton(
        onPressed: onPlus,
        style: IconButton.styleFrom(backgroundColor: ProductDetailPage._ink),
        color: Colors.white,
        icon: const Icon(Icons.add, size: 16),
      ),
    ],
  );
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 12),
            IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.chevron_left),
            ),
          ],
        ),
      ),
      Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    ],
  );
}
