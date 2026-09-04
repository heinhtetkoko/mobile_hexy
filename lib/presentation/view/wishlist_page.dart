import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';
import 'package:mobile_hexy/data/models/wishlist_item.dart';
import 'package:mobile_hexy/presentation/viewmodel/wishlist_view_model.dart';
import 'package:mobile_hexy/presentation/widgets/shimmer_skeletons.dart';

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
              () => controller.isLoading.value
                  ? const _WishlistShimmer()
                  : controller.errorMessage.value != null
                  ? _WishlistError(
                      message: controller.errorMessage.value!,
                      onRetry: controller.loadWishlist,
                    )
                  : controller.items.isEmpty
                  ? const _EmptyWishlist()
                  : RefreshIndicator(
                      onRefresh: controller.loadWishlist,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
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
          ),
        ],
      ),
    ),
  );
}

class _WishlistShimmer extends StatelessWidget {
  const _WishlistShimmer();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) =>
          const ShimmerBox(width: double.infinity, height: 94, radius: 14),
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
        const SizedBox(width: 70),
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
          width: 70,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$itemCount ${itemCount == 1 ? 'Item'.tr : 'Items'.tr}',
                maxLines: 1,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
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
          child: item.imageUrl?.isNotEmpty == true
              ? Image.network(
                  item.imageUrl!,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    width: 84,
                    height: 84,
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                )
              : item.imageAsset.isNotEmpty
              ? Image.asset(
                  item.imageAsset,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                )
              : const SizedBox(
                  width: 84,
                  height: 84,
                  child: Icon(Icons.image_not_supported_outlined),
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

class _WishlistError extends StatelessWidget {
  const _WishlistError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: Text('Retry'.tr)),
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
