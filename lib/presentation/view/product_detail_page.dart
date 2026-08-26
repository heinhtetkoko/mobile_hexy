import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/presentation/viewmodel/product_detail_view_model.dart';

class ProductDetailPage extends GetView<ProductDetailViewModel> {
  const ProductDetailPage({super.key});

  static const _ink = Color(0xFF1E1B4B);
  static const _pink = Color(0xFFDB2777);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    bottomNavigationBar: _BottomActions(controller: controller),
    body: SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(controller: controller)),
          SliverToBoxAdapter(child: _Gallery(controller: controller)),
          SliverToBoxAdapter(child: _ProductInfo(controller: controller)),
          SliverToBoxAdapter(child: _Variants(controller: controller)),
          const SliverToBoxAdapter(child: _Description()),
          const SliverToBoxAdapter(child: _SimilarProducts()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    ),
  );
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
  Widget build(BuildContext context) => Column(
    children: [
      Obx(
        () => SizedBox(
          height: 300,
          width: double.infinity,
          child: Image.asset(
            controller.gallery[controller.selectedImage.value],
            fit: BoxFit.cover,
          ),
        ),
      ),
      SizedBox(
        height: 60,
        child: Obx(() {
          final selectedImage = controller.selectedImage.value;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            scrollDirection: Axis.horizontal,
            itemCount: controller.gallery.length,
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
                  child: Image.asset(
                    controller.gallery[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ],
  );
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.controller});
  final ProductDetailViewModel controller;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _Tag(label: 'PILOT', active: true),
            _Tag(label: 'Gel Pens'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Pilot G-2 Gel Pen 0.7mm Blue'.tr,
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
              'SKU: PIL-G2-07-BLU'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            Row(
              children: [
                Icon(Icons.circle, size: 8, color: Color(0xFF22C55E)),
                SizedBox(width: 5),
                Text(
                  'In Stock'.tr,
                  style: TextStyle(
                    color: Color(0xFF22C55E),
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
            Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 18),
            Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 18),
            Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 18),
            Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 18),
            Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 18),
            SizedBox(width: 7),
            Text(
              '4.8'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' / 5.0'.tr,
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
                '2,100 Ks'.tr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '2,800 Ks'.tr,
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 12),
              _DiscountBadge(),
            ],
          ),
        ),
      ],
    ),
  );
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
  const _DiscountBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: ProductDetailPage._pink,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '25% OFF'.tr,
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color:'.tr,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Obx(
          () => _ChoiceRow(
            values: const ['Blue', 'Black', 'Red', 'Green'],
            selected: controller.selectedColor.value,
            onSelected: (value) => controller.selectedColor.value = value,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Ink Type:'.tr,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Obx(
          () => _ChoiceRow(
            values: const ['Gel Ink', 'Ballpoint'],
            selected: controller.selectedInkType.value,
            onSelected: (value) => controller.selectedInkType.value = value,
          ),
        ),
      ],
    ),
  );
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.values,
    required this.selected,
    required this.onSelected,
  });
  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: values.map((value) {
      final active = value == selected;
      return ChoiceChip(
        label: Text(value.tr),
        selected: active,
        onSelected: (_) => onSelected(value),
        selectedColor: ProductDetailPage._ink,
        backgroundColor: Theme.of(context).colorScheme.surface,
        labelStyle: TextStyle(
          fontSize: 11,
          color: active
              ? Colors.white
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(
          color: active ? ProductDetailPage._ink : Colors.transparent,
        ),
      );
    }).toList(),
  );
}

class _Description extends StatelessWidget {
  const _Description();
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
          'Smooth-writing Pilot G-2 gel pen with a comfortable grip and vibrant blue ink. Perfect for school, office, and everyday notes.'
              .tr,
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
