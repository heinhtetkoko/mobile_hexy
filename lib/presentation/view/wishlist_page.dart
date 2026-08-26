import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app/theme/app_colors.dart';
import 'package:mobile_hexy/domain/entities/wishlist_item.dart';
import 'package:mobile_hexy/presentation/viewmodel/wishlist_view_model.dart';

class WishlistPage extends GetView<WishlistViewModel> {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Obx(() => _WishlistHeader(itemCount: controller.items.length)),
          Expanded(
            child: Obx(
              () => controller.items.isEmpty
                  ? const _EmptyWishlist()
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: controller.items.length,
                      itemExtent: 110,
                      itemBuilder: (context, index) {
                        final item = controller.items[index];
                        return _WishlistCard(
                          key: ValueKey(item.id),
                          item: item,
                          onAddToCart: () => controller.addToCart(item),
                          onRemove: () => controller.removeItem(item),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _WishlistHeader extends StatelessWidget {
  const _WishlistHeader({required this.itemCount});

  final int itemCount;

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
        const SizedBox(width: 64),
        Expanded(
          child: Text(
            'Wishlist'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          width: 64,
          child: Text(
            '$itemCount ${itemCount == 1 ? 'item'.tr : 'items'.tr}',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({
    super.key,
    required this.item,
    required this.onAddToCart,
    required this.onRemove,
  });

  final WishlistItem item;
  final VoidCallback onAddToCart;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            item.imageAsset,
            width: 84,
            height: 84,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.price,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 27,
                child: FilledButton(
                  key: Key('add-to-cart-${item.id}'),
                  onPressed: onAddToCart,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text('Add to Cart'.tr),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: IconButton(
            key: Key('remove-wishlist-${item.id}'),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 23,
            ),
          ),
        ),
      ],
    ),
  );
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.favorite_border_rounded,
          size: 56,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(height: 12),
        Text(
          'Your wishlist is empty'.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
