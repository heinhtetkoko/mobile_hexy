import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/data/models/product_detail.dart';
import 'package:mobile_hexy/data/models/product_list_request.dart';
import 'package:mobile_hexy/presentation/widgets/shimmer_skeletons.dart';
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
        child: Column(
          children: [
            _Header(controller: controller),
            Expanded(
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
                      controller: controller.scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: _Gallery(controller: controller),
                        ),
                        SliverToBoxAdapter(
                          child: _ProductInfo(controller: controller),
                        ),
                        SliverToBoxAdapter(
                          child: _Variants(controller: controller),
                        ),
                        SliverToBoxAdapter(
                          child: _Description(controller: controller),
                        ),
                        SliverToBoxAdapter(
                          child: _Specifications(controller: controller),
                        ),
                        SliverToBoxAdapter(
                          child: _ProductRecommendations(
                            title: 'Related Products',
                            products: product.relatedProducts,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _ProductRecommendations(
                            title: 'You Might Also Like',
                            products: product.youMightAlsoLike,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      ],
                    ),
            ),
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
            onPressed: controller.isUpdatingWishlist.value
                ? null
                : controller.toggleWishlist,
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
        _CartBadge(quantity: controller.product.value?.cartQuantity ?? 0),
        const SizedBox(width: 8),
      ],
    ),
  );
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.quantity});
  final int quantity;
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
      if (quantity > 0)
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
              '$quantity',
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
        Obx(() {
          final selectedImage = controller.selectedImage.value;
          return Stack(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: images.isEmpty
                    ? const Icon(Icons.image_not_supported_outlined, size: 64)
                    : Image.network(
                        images[selectedImage],
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 64,
                        ),
                      ),
              ),
              if (images.isNotEmpty)
                Positioned(
                  right: 16,
                  top: 8,
                  child: _GalleryBadge(
                    label: '${selectedImage + 1} / ${images.length}',
                  ),
                ),
              Positioned(
                right: 16,
                bottom: 14,
                child: Material(
                  color: ProductDetailPage._pink,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: images.isEmpty
                        ? null
                        : () => showDialog<void>(
                            context: context,
                            barrierColor: Colors.black,
                            builder: (_) => _FullScreenGallery(
                              images: images,
                              initialIndex: selectedImage,
                            ),
                          ),
                    color: Colors.white,
                    icon: const Icon(Icons.open_in_full_rounded, size: 18),
                  ),
                ),
              ),
            ],
          );
        }),
        if (images.length > 1)
          SizedBox(
            height: 68,
            child: Obx(() {
              final selectedImage = controller.selectedImage.value;
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, index) => GestureDetector(
                  onTap: () => controller.selectedImage.value = index,
                  child: Container(
                    width: 54,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      border: Border.all(
                        color: selectedImage == index
                            ? ProductDetailPage._ink
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Image.network(
                      images[index],
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image_not_supported_outlined),
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

class _GalleryBadge extends StatelessWidget {
  const _GalleryBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xB81F2024),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _FullScreenGallery extends StatefulWidget {
  const _FullScreenGallery({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _pageController;
  final TransformationController _transformationController =
      TransformationController();
  late int _currentIndex;
  double _zoom = 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _setZoom(double value) {
    final next = value.clamp(1.0, 4.0);
    setState(() => _zoom = next);
    _transformationController.value = Matrix4.diagonal3Values(next, next, 1);
  }

  void _resetZoom() => _setZoom(1);

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black,
    child: SafeArea(
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: _zoom > 1
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            itemCount: widget.images.length,
            onPageChanged: (index) {
              _resetZoom();
              setState(() => _currentIndex = index);
            },
            itemBuilder: (_, index) => InteractiveViewer(
              transformationController: index == _currentIndex
                  ? _transformationController
                  : null,
              minScale: 1,
              maxScale: 4,
              onInteractionEnd: (_) {
                if (index != _currentIndex) return;
                final scale = _transformationController.value
                    .getMaxScaleOnAxis()
                    .clamp(1.0, 4.0);
                setState(() => _zoom = scale);
              },
              child: Center(
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white54,
                    size: 72,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 8,
            child: Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
                const Spacer(),
                _GalleryBadge(
                  label: '${_currentIndex + 1} / ${widget.images.length}',
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xCC1F2024),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Zoom out',
                      onPressed: _zoom <= 1 ? null : () => _setZoom(_zoom - .5),
                      color: Colors.white,
                      disabledColor: Colors.white38,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    TextButton(
                      onPressed: _resetZoom,
                      child: Text(
                        '${(_zoom * 100).round()}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Zoom in',
                      onPressed: _zoom >= 4 ? null : () => _setZoom(_zoom + .5),
                      color: Colors.white,
                      disabledColor: Colors.white38,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
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
            children: [
              if (product.brand.isNotEmpty)
                _Tag(label: product.brand, active: true),
              ...product.categories.map((name) => _Tag(label: name)),
            ],
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
    final sections = controller.product.value!.variantSections
        .map(
          (section) => (
            section: section,
            values: section.values
                .where((value) => value.available)
                .toList(growable: false),
          ),
        )
        .where((item) => item.values.isNotEmpty)
        .toList(growable: false);
    if (sections.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections.map((item) {
          final section = item.section;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${section.attribute}:',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final selectedValueId =
                      controller.selectedVariantValues[section.key];
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.values.map((value) {
                      final selected = selectedValueId == value.id;
                      return ChoiceChip(
                        label: Text(value.name),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) =>
                            controller.selectVariantValue(section.key, value),
                        selectedColor: ProductDetailPage._ink,
                        backgroundColor: const Color(0xFFF5F6F8),
                        disabledColor: const Color(0xFFF0F1F3),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          );
        }).toList(),
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

class _ProductRecommendations extends StatelessWidget {
  const _ProductRecommendations({required this.title, required this.products});

  final String title;
  final List<ProductDetailCard> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  key: Key(
                    'view-all-${title.toLowerCase().replaceAll(' ', '-')}',
                  ),
                  tooltip: 'View all $title',
                  onPressed: () => Get.toNamed<void>(
                    AppRoutes.productList,
                    arguments: const ProductListRequest.search(),
                  ),
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 234,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, index) =>
                  _RecommendationCard(product: products[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.product});
  final ProductDetailCard product;

  @override
  Widget build(BuildContext context) => InkWell(
    key: Key('recommendation-product-${product.id}'),
    onTap: () => Get.find<ProductDetailViewModel>().openProduct(product.id),
    borderRadius: BorderRadius.circular(18),
    child: Container(
      width: 132,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 112,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: product.imageUrl.isEmpty
                    ? const Icon(Icons.image_not_supported_outlined)
                    : Image.network(product.imageUrl, fit: BoxFit.contain),
              ),
              if (product.discountPercent > 0)
                Positioned(
                  left: 0,
                  top: 8,
                  child: _DiscountBadge(percent: product.discountPercent),
                ),
              const Positioned(
                right: 7,
                top: 7,
                child: Icon(
                  Icons.favorite_border_rounded,
                  color: ProductDetailPage._pink,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < product.rating.round()
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: const Color(0xFFFBBF24),
                size: 12,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            product.formattedPrice,
            style: const TextStyle(
              color: ProductDetailPage._pink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Specifications extends StatelessWidget {
  const _Specifications({required this.controller});

  final ProductDetailViewModel controller;

  @override
  Widget build(BuildContext context) {
    final specifications = controller.product.value!.specifications;
    if (specifications.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specifications'.tr,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: specifications.indexed.map((entry) {
                final (index, specification) = entry;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              specification.label,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              specification.value,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < specifications.length - 1)
                      const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
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
            child: Obx(
              () => FilledButton.icon(
                onPressed: controller.isAddingToCart.value
                    ? null
                    : controller.addToCart,
                style: FilledButton.styleFrom(
                  backgroundColor: ProductDetailPage._ink,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: controller.isAddingToCart.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shopping_cart_outlined, size: 18),
                label: Text(
                  'Add to Cart'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: ProductDetailPage._pink,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: Text(
                'Buy Now'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
