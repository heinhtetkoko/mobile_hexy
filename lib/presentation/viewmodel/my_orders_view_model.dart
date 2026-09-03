import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/orders_remote_data_source.dart';
import 'package:mobile_hexy/data/models/order.dart';

class MyOrdersViewModel extends BaseViewModel {
  MyOrdersViewModel(this._remoteDataSource);
  final OrdersRemoteDataSource _remoteDataSource;

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
  final searchController = TextEditingController();
  final orders = <OrderSummary>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final totalCount = 0.obs;
  int _page = 1;
  bool _hasNextPage = false;

  @override
  void onInit() {
    super.onInit();
    final initial = Get.arguments;
    if (initial is String && tabs.contains(initial)) {
      selectedStatus.value = initial;
    }
    loadOrders();
  }

  List<OrderSummary> get filteredOrders {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return orders;
    return orders
        .where((order) => order.number.toLowerCase().contains(query))
        .toList();
  }

  bool get hasMoreOrders => _hasNextPage && !isLoadingMore.value;

  Future<void> loadOrders() async {
    isLoading.value = true;
    errorMessage.value = null;
    _page = 1;
    try {
      final data = await _remoteDataSource.fetchOrders(
        status: selectedStatus.value.toLowerCase(),
        sort: latestFirst.value ? 'latest' : 'oldest',
        page: _page,
      );
      _apply(data, replace: true);
    } catch (error) {
      errorMessage.value = _message(error);
      orders.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMoreOrders) return;
    isLoadingMore.value = true;
    try {
      final data = await _remoteDataSource.fetchOrders(
        status: selectedStatus.value.toLowerCase(),
        sort: latestFirst.value ? 'latest' : 'oldest',
        page: _page + 1,
      );
      _page++;
      _apply(data, replace: false);
    } catch (error) {
      Get.snackbar(
        'Could not load more orders',
        _message(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _apply(Map<String, dynamic> data, {required bool replace}) {
    final source = data['orders'] ?? data['items'] ?? data['data'];
    final raw = source is Map
        ? source['data'] ?? source['items'] ?? source['orders']
        : source;
    final parsed = raw is List
        ? raw.whereType<Map>().map(OrderSummary.fromJson).toList()
        : <OrderSummary>[];
    if (replace) {
      orders.assignAll(parsed);
    } else {
      final known = orders.map((order) => order.id).toSet();
      orders.addAll(parsed.where((order) => !known.contains(order.id)));
    }
    final paginationSource =
        data['pagination'] ?? data['meta'] ?? (source is Map ? source : null);
    final pagination = paginationSource is Map ? paginationSource : const {};
    totalCount.value = _int(
      pagination['total'] ?? pagination['total_count'] ?? data['count'],
      fallback: orders.length,
    );
    final current = _int(
      pagination['page'] ?? pagination['current_page'],
      fallback: _page,
    );
    final pages = _int(pagination['pages'] ?? pagination['total_pages']);
    _hasNextPage =
        pagination['has_next'] == true ||
        pagination['has_more'] == true ||
        (pages > 0 && current < pages) ||
        (parsed.length >= 10 && orders.length < totalCount.value);
  }

  void selectStatus(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    loadOrders();
  }

  void toggleSearch() {
    searchVisible.toggle();
    if (!searchVisible.value) {
      searchController.clear();
      searchQuery.value = '';
    }
  }

  void setSearch(String value) => searchQuery.value = value;
  void setSort(bool latest) {
    if (latestFirst.value == latest) return;
    latestFirst.value = latest;
    loadOrders();
  }

  void performAction(String action, OrderSummary order) {
    if (action.toLowerCase().contains('detail') ||
        action.toLowerCase().contains('track')) {
      openDetail(order);
      return;
    }
    Get.snackbar(
      action,
      'Order #${order.number}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openDetail(OrderSummary order) => Get.toNamed<dynamic>(
    AppRoutes.orderDetail,
    arguments: {'id': order.id, 'number': order.number},
  );

  String statusLabel(OrderStatus status) => switch (status) {
    OrderStatus.pending => 'Pending',
    OrderStatus.processing => 'Processing',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.refunded => 'Refunded',
    OrderStatus.cancelled => 'Cancelled',
  };

  int _int(Object? value, {int fallback = 0}) => value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '') ?? fallback;
  String _message(Object error) => error
      .toString()
      .replaceFirst('Exception: ', '')
      .replaceFirst('FormatException: ', '');

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
