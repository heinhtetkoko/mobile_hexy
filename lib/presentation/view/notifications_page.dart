import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/data/models/app_notification.dart';
import 'package:mobile_hexy/presentation/viewmodel/notifications_view_model.dart';

class NotificationsPage extends GetView<NotificationsViewModel> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Obx(
            () => _NotificationsHeader(
              itemCount: controller.notifications.length,
            ),
          ),
          Expanded(child: Obx(() => _content())),
        ],
      ),
    ),
  );

  Widget _content() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = controller.errorMessage.value;
    if (error != null) {
      return _MessageState(
        icon: Icons.cloud_off_outlined,
        message: error,
        action: controller.loadNotifications,
      );
    }
    if (controller.notifications.isEmpty) {
      return const _MessageState(
        icon: Icons.notifications_none_rounded,
        message: 'No notifications found.',
      );
    }
    return RefreshIndicator(
      onRefresh: controller.loadNotifications,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (controller.hasMore && notification.metrics.extentAfter < 250) {
            controller.loadMore();
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          itemCount:
              controller.notifications.length +
              (controller.isLoadingMore.value ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, index) => index == controller.notifications.length
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _NotificationCard(
                  notification: controller.notifications[index],
                  onTap: () =>
                      controller.openDetail(controller.notifications[index]),
                ),
        ),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.itemCount});

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
        SizedBox(
          width: 70,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: const CircleBorder(),
              child: IconButton(
                key: const Key('notifications-back-button'),
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Notifications'.tr,
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
                '$itemCount',
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

class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notification = Get.arguments;
    if (notification is! AppNotification) {
      return Scaffold(
        appBar: _appBar(context, 'Notification Detail'),
        body: const _MessageState(
          icon: Icons.error_outline_rounded,
          message: 'Notification information is unavailable.',
        ),
      );
    }
    return Scaffold(
      appBar: _appBar(context, 'Notification Detail'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _notificationIcon(notification.type),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                if (notification.date.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    notification.date,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 14),
                Text(
                  notification.message,
                  style: const TextStyle(fontSize: 15, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

PreferredSizeWidget _appBar(BuildContext context, String title) => AppBar(
  leadingWidth: 68,
  leading: Padding(
    padding: const EdgeInsets.only(left: 16),
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: Get.back,
        icon: const Icon(Icons.arrow_back_rounded, size: 20),
      ),
    ),
  ),
  title: Text(
    title.tr,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
  ),
  centerTitle: true,
);

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});
  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _notificationIcon(notification.type),
                    color: Theme.of(context).colorScheme.primary,
                    size: 21,
                  ),
                ),
                if (!notification.isRead)
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notification.isRead
                          ? FontWeight.w600
                          : FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  if (notification.date.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      notification.date,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    ),
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.icon, required this.message, this.action});
  final IconData icon;
  final String message;
  final VoidCallback? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 52,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(message.tr, textAlign: TextAlign.center),
        ),
        if (action != null) ...[
          const SizedBox(height: 12),
          FilledButton(onPressed: action, child: Text('Try Again'.tr)),
        ],
      ],
    ),
  );
}

IconData _notificationIcon(String? type) {
  final value = type?.toLowerCase() ?? '';
  if (value.contains('order')) return Icons.inventory_2_outlined;
  if (value.contains('promo') || value.contains('sale')) {
    return Icons.local_offer_outlined;
  }
  if (value.contains('payment')) return Icons.payments_outlined;
  return Icons.notifications_none_rounded;
}
