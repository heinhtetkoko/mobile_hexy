import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';

enum OrderStatus { pending, processing, delivered, refunded, cancelled }

class OrderSummary {
  const OrderSummary({
    required this.number,
    required this.status,
    required this.itemCount,
    required this.date,
    required this.total,
    required this.actions,
    this.reason,
  });
  final String number;
  final OrderStatus status;
  final int itemCount;
  final DateTime date;
  final String total;
  final List<String> actions;
  final String? reason;
}

class MyOrdersViewModel extends BaseViewModel {
  static const tabs = [
    'All',
    'Pending',
    'Processing',
    'Delivered',
    'Refunded',
    'Cancelled',
  ];
  final selectedStatus = 'All'.obs;
  final searchQuery = ''.obs;
  final latestFirst = true.obs;
  final searchVisible = false.obs;
  final visibleCount = 7.obs;
  final searchController = TextEditingController();
  final orders = <OrderSummary>[
    OrderSummary(
      number: 'STA-2025-0874',
      status: OrderStatus.pending,
      itemCount: 4,
      date: DateTime(2025, 7, 2),
      total: '48,540 Ks',
      actions: ['Track Order'],
    ),
    OrderSummary(
      number: 'STA-2025-0821',
      status: OrderStatus.processing,
      itemCount: 2,
      date: DateTime(2025, 6, 28),
      total: '15,200 Ks',
      actions: ['View Details'],
    ),
    OrderSummary(
      number: 'STA-2025-0701',
      status: OrderStatus.delivered,
      itemCount: 5,
      date: DateTime(2025, 6, 15),
      total: '28,750 Ks',
      actions: ['Buy Again'],
    ),
    OrderSummary(
      number: 'STA-2025-0688',
      status: OrderStatus.pending,
      itemCount: 1,
      date: DateTime(2025, 6, 12),
      total: '8,500 Ks',
      actions: ['Track Order'],
    ),
    OrderSummary(
      number: 'STA-2025-0632',
      status: OrderStatus.refunded,
      itemCount: 2,
      date: DateTime(2025, 6, 5),
      total: '12,000 Ks',
      actions: ['View Details', 'Contact Support'],
    ),
    OrderSummary(
      number: 'STA-2025-0598',
      status: OrderStatus.delivered,
      itemCount: 6,
      date: DateTime(2025, 5, 28),
      total: '35,400 Ks',
      actions: ['Buy Again'],
    ),
    OrderSummary(
      number: 'STA-2025-0543',
      status: OrderStatus.cancelled,
      itemCount: 2,
      date: DateTime(2025, 5, 20),
      total: '95,000 Ks',
      actions: ['View Details', 'Reorder'],
      reason: 'Customer request',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    final initial = Get.arguments;
    if (initial is String && tabs.contains(initial)) {
      selectedStatus.value = initial;
    }
  }

  List<OrderSummary> get filteredOrders {
    return _matchingOrders().take(visibleCount.value).toList();
  }

  bool get hasMoreOrders => visibleCount.value < _matchingOrders().length;

  List<OrderSummary> _matchingOrders() {
    final query = searchQuery.value.trim().toLowerCase();
    final result =
        orders
            .where(
              (order) =>
                  (selectedStatus.value == 'All' ||
                      statusLabel(order.status) == selectedStatus.value) &&
                  (query.isEmpty || order.number.toLowerCase().contains(query)),
            )
            .toList()
          ..sort(
            (a, b) => latestFirst.value
                ? b.date.compareTo(a.date)
                : a.date.compareTo(b.date),
          );
    return result;
  }

  void selectStatus(String status) {
    selectedStatus.value = status;
    visibleCount.value = 7;
  }

  void toggleSearch() {
    searchVisible.toggle();
    if (!searchVisible.value) {
      searchController.clear();
      searchQuery.value = '';
    }
  }

  void setSearch(String value) => searchQuery.value = value;
  void setSort(bool latest) => latestFirst.value = latest;
  void loadMore() {
    if (hasMoreOrders) visibleCount.value += 5;
  }

  void performAction(String action, OrderSummary order) => Get.snackbar(
    action,
    'Order #${order.number}',
    snackPosition: SnackPosition.BOTTOM,
  );
  String statusLabel(OrderStatus status) => switch (status) {
    OrderStatus.pending => 'Pending',
    OrderStatus.processing => 'Processing',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.refunded => 'Refunded',
    OrderStatus.cancelled => 'Cancelled',
  };

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
