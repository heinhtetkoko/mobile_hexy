import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/theme/app_colors.dart';
import 'package:mobile_hexy/data/models/order.dart';
import 'package:mobile_hexy/presentation/viewmodel/my_orders_view_model.dart';
import 'package:mobile_hexy/presentation/widgets/clean_app_bar.dart';
import 'package:mobile_hexy/presentation/widgets/shimmer_skeletons.dart';

class MyOrdersPage extends GetView<MyOrdersViewModel> {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CleanAppBar(
        title: 'My Orders',
        action: Obx(
          () => IconButton(
            key: const Key('my-orders-search-button'),
            icon: Icon(
              controller.searchVisible.value
                  ? Icons.close_rounded
                  : Icons.search_rounded,
            ),
            onPressed: controller.toggleSearch,
          ),
        ),
      ),
      body: Obx(() {
        final orders = controller.filteredOrders;
        return Column(
          children: [
            if (controller.searchVisible.value)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: TextField(
                  controller: controller.searchController,
                  autofocus: true,
                  onChanged: controller.setSearch,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search order number'.tr,
                    isDense: true,
                  ),
                ),
              ),
            SizedBox(
              height: 64,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: MyOrdersViewModel.tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final tab = MyOrdersViewModel.tabs[index];
                  final selected = controller.selectedStatus.value == tab;
                  return ChoiceChip(
                    label: Text(tab.tr),
                    selected: selected,
                    onSelected: (_) => controller.selectStatus(tab),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : colors.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: colors.surface,
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary
                          : Theme.of(context).dividerColor,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: const StadiumBorder(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
              child: Row(
                children: [
                  Text(
                    'Showing @count orders'.trParams({
                      'count': '${controller.totalCount.value}',
                    }),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<bool>(
                    onSelected: controller.setSort,
                    itemBuilder: (_) => [
                      PopupMenuItem(value: true, child: Text('Latest'.tr)),
                      PopupMenuItem(value: false, child: Text('Oldest'.tr)),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Text(
                            '${'Sort by:'.tr} ${controller.latestFirst.value ? 'Latest'.tr : 'Oldest'.tr}',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.isLoading.value
                  ? const _OrdersShimmer()
                  : controller.errorMessage.value != null
                  ? _OrdersError(
                      message: controller.errorMessage.value!,
                      onRetry: controller.loadOrders,
                    )
                  : orders.isEmpty
                  ? _EmptyOrders(query: controller.searchQuery.value)
                  : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (controller.hasMoreOrders &&
                            notification.metrics.extentAfter < 240) {
                          controller.loadMore();
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        onRefresh: controller.loadOrders,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          itemCount:
                              orders.length +
                              (controller.isLoadingMore.value ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, index) => index == orders.length
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : _OrderCard(order: orders[index]),
                        ),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _OrdersShimmer extends StatelessWidget {
  const _OrdersShimmer();

  @override
  Widget build(BuildContext context) => AppShimmer(
    child: ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) =>
          const ShimmerBox(width: double.infinity, height: 178, radius: 16),
    ),
  );
}

class _OrderCard extends GetView<MyOrdersViewModel> {
  const _OrderCard({required this.order});
  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = _statusStyle(order.status);
    return InkWell(
      onTap: () => controller.openDetail(order),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.number}'.tr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status.background,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: status.foreground,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.statusLabel(order.status).tr,
                        style: TextStyle(
                          color: status.foreground,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            const SizedBox(height: 10),
            Row(
              children: [
                _Info(
                  label: 'ITEMS',
                  value:
                      '${order.itemCount} ${order.itemCount == 1 ? 'Item' : 'Items'}',
                  bold: true,
                ),
                _Info(label: 'DATE', value: _date(order.date)),
                _Info(
                  label: 'TOTAL',
                  value: order.total,
                  bold: true,
                  alignEnd: true,
                  valueColor: colors.primary,
                ),
              ],
            ),
            if (order.reason != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Reason: ${order.reason}'.tr,
                  style: const TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < order.actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: order.actions[i],
                      primary: _isPrimary(order.actions[i]),
                      onTap: () =>
                          controller.performAction(order.actions[i], order),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isPrimary(String action) =>
      !['Buy Again', 'View Details'].contains(action);
  static String _date(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year}';
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.label,
    required this.value,
    this.bold = false,
    this.alignEnd = false,
    this.valueColor,
  });
  final String label;
  final String value;
  final bool bold;
  final bool alignEnd;
  final Color? valueColor;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });
  final String label;
  final bool primary;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final accent = label == 'Buy Again'
        ? AppColors.accent
        : Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 36,
      child: primary
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                label.tr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(
                  color: label == 'Buy Again'
                      ? accent
                      : Theme.of(context).dividerColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                label.tr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.query});
  final String query;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 52,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          query.isEmpty ? 'No orders in this status' : 'No matching orders',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _OrdersError extends StatelessWidget {
  const _OrdersError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: Text('Try Again'.tr)),
        ],
      ),
    ),
  );
}

({Color background, Color foreground}) _statusStyle(OrderStatus status) =>
    switch (status) {
      OrderStatus.pending => (
        background: const Color(0xFFFEF3C7),
        foreground: const Color(0xFF92400E),
      ),
      OrderStatus.processing => (
        background: const Color(0xFFEEF2FF),
        foreground: const Color(0xFF1E1B4B),
      ),
      OrderStatus.delivered => (
        background: const Color(0xFFF0FDF4),
        foreground: const Color(0xFF166534),
      ),
      OrderStatus.refunded => (
        background: const Color(0xFFFDF4FF),
        foreground: const Color(0xFF7E22CE),
      ),
      OrderStatus.cancelled => (
        background: const Color(0xFFFEF2F2),
        foreground: const Color(0xFF991B1B),
      ),
    };
