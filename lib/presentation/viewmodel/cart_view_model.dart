import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/models/cart_item.dart';

class CartViewModel extends BaseViewModel {
  CartViewModel(this._remoteDataSource);
  final CartRemoteDataSource _remoteDataSource;
  final items = <CartItem>[].obs;
  final couponController = TextEditingController();
  final couponApplied = false.obs;
  final shippingAddress = Rxn<CartShippingAddress>();
  final shippingMethods = <CartShippingMethod>[].obs;
  final selectedShippingMethodId = RxnString();
  final orderSummaryRows = <CartSummaryRow>[].obs;
  final isLoading = false.obs;
  final updatingLineIds = <String>{}.obs;
  final isApplyingCoupon = false.obs;
  int _subtotal = 0;
  int _shipping = 0;
  int _discount = 0;
  int _grandTotal = 0;

  int get subtotal => _subtotal;
  int get shipping => _shipping;
  int get discount => _discount;
  int get grandTotal => _grandTotal;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      _apply(await _remoteDataSource.fetchCart());
    } catch (error) {
      errorMessage.value = _message(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> increment(CartItem item) =>
      _setQuantity(item, item.quantity + 1);

  Future<void> decrement(CartItem item) async {
    if (item.quantity > 1) await _setQuantity(item, item.quantity - 1);
  }

  Future<void> _setQuantity(CartItem item, int quantity) async {
    if (quantity < 1 || updatingLineIds.contains(item.id)) return;

    final itemIndex = items.indexWhere((entry) => entry.id == item.id);
    if (itemIndex < 0) return;

    final parsedLineId = int.tryParse(item.id);
    final lineId = parsedLineId != null && parsedLineId > 0
        ? parsedLineId
        : null;
    if (lineId == null && item.productId <= 0) {
      _showError(
        'Could not update quantity',
        const FormatException('Cart item information is incomplete.'),
      );
      return;
    }

    final previousItem = items[itemIndex];
    items[itemIndex] = previousItem.copyWith(quantity: quantity);
    updatingLineIds.add(item.id);
    try {
      _apply(
        await _remoteDataSource.updateQuantity(
          lineId: lineId,
          productId: item.productId,
          quantity: quantity,
        ),
      );
    } catch (error) {
      final rollbackIndex = items.indexWhere((entry) => entry.id == item.id);
      if (rollbackIndex >= 0) {
        items[rollbackIndex] = previousItem;
      }
      _showError('Could not update quantity', error);
    } finally {
      updatingLineIds.remove(item.id);
    }
  }

  Future<void> remove(CartItem item) async {
    final lineId = int.tryParse(item.id);
    if (lineId == null || updatingLineIds.contains(item.id)) return;
    updatingLineIds.add(item.id);
    try {
      _apply(await _remoteDataSource.removeLine(lineId));
    } catch (error) {
      _showError('Could not remove item', error);
    } finally {
      updatingLineIds.remove(item.id);
    }
  }

  Future<void> applyCoupon() async {
    final code = couponController.text.trim();
    if (code.isEmpty || isApplyingCoupon.value) {
      if (code.isEmpty) {
        Get.snackbar(
          'Enter a coupon',
          'Add a code first.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }
    isApplyingCoupon.value = true;
    try {
      _apply(await _remoteDataSource.applyCoupon(code));
      Get.snackbar(
        'Coupon applied',
        'Your discount is active.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError('Could not apply coupon', error);
    } finally {
      isApplyingCoupon.value = false;
    }
  }

  void _apply(Map<String, dynamic> data) {
    final rawItems = data['items'] ?? data['cart_items'] ?? data['lines'];
    items.assignAll(
      rawItems is List
          ? rawItems.whereType<Map>().map(_parseItem)
          : const <CartItem>[],
    );
    final totalsSource =
        data['order_summary'] ?? data['totals'] ?? data['summary'] ?? data;
    final totals = _normalizeSummary(totalsSource);
    _subtotal = _amount(
      totals['subtotal'] ?? totals['amount_untaxed'] ?? data['subtotal'],
    );
    _shipping = _amount(
      totals['shipping'] ??
          totals['shipping_fee'] ??
          totals['delivery_fee'] ??
          data['shipping_fee'],
    );
    _discount = _amount(totals['discount'] ?? totals['discount_amount']).abs();
    _grandTotal = _amount(
      totals['grand_total'] ?? totals['total'] ?? totals['amount_total'],
    );
    if (_grandTotal == 0 && items.isNotEmpty) {
      _grandTotal = _subtotal + _shipping - _discount;
    }
    orderSummaryRows.assignAll(_parseSummaryRows(totalsSource));
    final coupon = data['coupon'] ?? data['coupon_block'];
    couponApplied.value =
        data['coupon_applied'] == true ||
        (coupon is Map &&
            (coupon['applied'] == true || coupon['is_applied'] == true)) ||
        (coupon is String && coupon.isNotEmpty);
    if (coupon is Map && couponApplied.value) {
      final code = (coupon['code'] ?? coupon['coupon_code'])?.toString() ?? '';
      if (code.isNotEmpty) couponController.text = code;
    }
    shippingAddress.value = _parseAddress(
      data['shipping_address'] ?? data['address'],
    );
    final rawMethods =
        data['shipping_methods'] ??
        data['delivery_methods'] ??
        data['carriers'];
    shippingMethods.assignAll(
      rawMethods is List
          ? rawMethods.whereType<Map>().map(_parseShippingMethod)
          : const <CartShippingMethod>[],
    );
    selectedShippingMethodId.value = shippingMethods
        .firstWhereOrNull((method) => method.selected)
        ?.id;
  }

  CartItem _parseItem(Map<dynamic, dynamic> json) {
    final product = json['product'];
    final source = product is Map ? {...json, ...product} : json;
    final lineId =
        _findIntByKeys(json, const [
          'line_id',
          'cart_line_id',
          'cart_item_id',
          'order_line_id',
        ]) ??
        _intValue(json['id']);
    final productId = _intValue(source['product_id'] ?? source['id']) ?? 0;
    final variant = source['variant'] ?? source['product_variant'];
    final attributes =
        source['attributes'] ?? source['variant_values'] ?? source['options'];
    return CartItem(
      id: lineId?.toString() ?? 'product-$productId',
      productId: productId,
      name:
          (source['name'] ?? source['product_name'] ?? json['display_name'])
              ?.toString() ??
          '',
      sku:
          (source['sku'] ?? source['default_code'] ?? source['product_code'])
              ?.toString() ??
          '',
      variant: variant is Map
          ? (variant['name'] ?? variant['display_name'])?.toString() ?? ''
          : (source['variant_name'] ?? variant)?.toString() ??
                _variantLabel(attributes),
      variantColor: _color(source['variant_color'] ?? source['color']),
      unitPrice: _amount(
        json['unit_price'] ??
            json['price_unit'] ??
            source['current_price'] ??
            source['price'],
      ),
      quantity:
          _intValue(
            json['quantity'] ??
                json['qty'] ??
                json['product_uom_qty'] ??
                json['quantity_control'],
          ) ??
          1,
      imageAsset: '',
      imageUrl: _imageUrl(
        source['image_url'] ?? source['image'] ?? source['thumbnail_url'],
      ),
    );
  }

  Future<void> selectShippingMethod(CartShippingMethod method) async {
    if (method.id.isEmpty || method.id == selectedShippingMethodId.value) {
      return;
    }
    try {
      _apply(await _remoteDataSource.setShippingMethod(method.id));
    } catch (error) {
      _showError('Could not update shipping method', error);
    }
  }

  Map<String, dynamic> _normalizeSummary(Object? source) {
    if (source is Map) {
      final rows = source['rows'] ?? source['items'] ?? source['lines'];
      if (rows is List) return _normalizeSummary(rows);
      return Map<String, dynamic>.from(source);
    }
    if (source is! List) return const {};
    final result = <String, dynamic>{};
    for (final row in source.whereType<Map>()) {
      final key = (row['key'] ?? row['name'] ?? row['label'])
          ?.toString()
          .toLowerCase()
          .replaceAll(' ', '_');
      if (key != null) {
        result[key] = row['amount'] ?? row['value'] ?? row['price'];
      }
    }
    return result;
  }

  List<CartSummaryRow> _parseSummaryRows(Object? source) {
    if (source is Map) {
      final nested = source['rows'] ?? source['items'] ?? source['lines'];
      if (nested is List) return _parseSummaryRows(nested);
      return source.entries
          .where((entry) => entry.key.toString() != 'currency')
          .map((entry) {
            final key = entry.key.toString();
            final value = entry.value;
            final valueMap = value is Map ? value : const {};
            return _summaryRow(
              key: key,
              label: valueMap['label']?.toString() ?? _summaryLabel(key),
              value: value,
              formatted: _formattedValue(value),
              explicitTotal:
                  valueMap['is_total'] == true || valueMap['total'] == true,
            );
          })
          .where((row) => row.label.isNotEmpty)
          .toList();
    }
    if (source is! List) return const [];
    return source
        .whereType<Map>()
        .map((row) {
          final key =
              (row['key'] ?? row['name'] ?? row['code'] ?? row['label'])
                  ?.toString() ??
              '';
          return _summaryRow(
            key: key,
            label:
                (row['label'] ?? row['title'] ?? row['name'])?.toString() ??
                _summaryLabel(key),
            value: row['amount'] ?? row['value'] ?? row['price'],
            formatted:
                (row['formatted_value'] ??
                        row['formatted_amount'] ??
                        row['display_value'])
                    ?.toString(),
            explicitTotal: row['is_total'] == true || row['total'] == true,
          );
        })
        .where((row) => row.label.isNotEmpty)
        .toList();
  }

  CartSummaryRow _summaryRow({
    required String key,
    required String label,
    required Object? value,
    required String? formatted,
    required bool explicitTotal,
  }) {
    final normalized = key.toLowerCase().replaceAll(' ', '_');
    return CartSummaryRow(
      key: normalized,
      label: label,
      amount: _amount(value),
      formattedValue: formatted,
      isTotal:
          explicitTotal ||
          normalized == 'total' ||
          normalized.contains('grand_total') ||
          normalized.contains('amount_total'),
      isDiscount: normalized.contains('discount'),
    );
  }

  String _summaryLabel(String key) => key
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  String? _formattedValue(Object? value) {
    if (value is! Map) return null;
    return (value['formatted'] ??
            value['formatted_value'] ??
            value['display'] ??
            value['text'])
        ?.toString();
  }

  int? _intValue(Object? value) {
    if (value is Map) {
      return _intValue(
        value['value'] ?? value['current'] ?? value['quantity'] ?? value['id'],
      );
    }
    if (value is num) return value.toInt();
    final text = value?.toString().trim() ?? '';
    return int.tryParse(text) ?? double.tryParse(text)?.toInt();
  }

  int? _findIntByKeys(Object? value, List<String> keys, [int depth = 0]) {
    if (depth > 4) return null;
    if (value is Map) {
      for (final key in keys) {
        final found = _intValue(value[key]);
        if (found != null) return found;
      }
      for (final nested in value.values) {
        final found = _findIntByKeys(nested, keys, depth + 1);
        if (found != null) return found;
      }
    } else if (value is List) {
      for (final nested in value) {
        final found = _findIntByKeys(nested, keys, depth + 1);
        if (found != null) return found;
      }
    }
    return null;
  }

  CartShippingAddress? _parseAddress(Object? value) {
    if (value is! Map || value.isEmpty) return null;
    return CartShippingAddress(
      id: int.tryParse(value['id']?.toString() ?? '') ?? 0,
      name: (value['name'] ?? value['recipient_name'])?.toString() ?? '',
      phone: (value['phone'] ?? value['mobile'])?.toString() ?? '',
      address:
          (value['full_address'] ?? value['formatted_address'])?.toString() ??
          [
                value['building'],
                value['street_address'] ?? value['street'],
                value['city_township'] ?? value['city'],
                value['state_region'] ?? value['state'],
              ]
              .where((part) => part != null && part.toString().isNotEmpty)
              .join(', '),
    );
  }

  CartShippingMethod _parseShippingMethod(Map<dynamic, dynamic> value) =>
      CartShippingMethod(
        id:
            (value['id'] ?? value['method_id'] ?? value['carrier_id'])
                ?.toString() ??
            '',
        name: (value['name'] ?? value['title'])?.toString() ?? '',
        description: (value['description'] ?? value['subtitle'] ?? value['eta'])
            ?.toString(),
        price: _amount(value['price'] ?? value['amount'] ?? value['fee']),
        selected: value['selected'] == true || value['is_selected'] == true,
      );

  int _amount(Object? value) {
    if (value is Map) {
      return _amount(
        value['amount'] ?? value['value'] ?? value['raw'] ?? value['price'],
      );
    }
    final normalized = value
        ?.toString()
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9.\-]'), '');
    return (double.tryParse(normalized ?? '') ?? 0).round();
  }

  String? _imageUrl(Object? value) {
    if (value is Map) {
      return (value['url'] ?? value['src'] ?? value['image_url'])?.toString();
    }
    return value?.toString();
  }

  String _variantLabel(Object? value) {
    if (value is! List) return '';
    return value
        .map((item) {
          if (item is Map) {
            return (item['value'] ?? item['name'] ?? item['display_name'])
                    ?.toString() ??
                '';
          }
          return item.toString();
        })
        .where((item) => item.isNotEmpty)
        .join(', ');
  }

  int _color(Object? value) {
    final text = value?.toString().replaceFirst('#', '') ?? '';
    return int.tryParse(text.length == 6 ? 'FF$text' : text, radix: 16) ??
        0xFFE5E7EB;
  }

  String _message(Object error) => error
      .toString()
      .replaceFirst('Exception: ', '')
      .replaceFirst('FormatException: ', '');
  void _showError(String title, Object error) =>
      Get.snackbar(title, _message(error), snackPosition: SnackPosition.BOTTOM);
  void checkout() => Get.toNamed<void>(AppRoutes.checkout);

  @override
  void onClose() {
    couponController.dispose();
    super.onClose();
  }
}

class CartShippingAddress {
  const CartShippingAddress({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });
  final int id;
  final String name;
  final String phone;
  final String address;
}

class CartShippingMethod {
  const CartShippingMethod({
    required this.id,
    required this.name,
    required this.price,
    required this.selected,
    this.description,
  });
  final String id;
  final String name;
  final String? description;
  final int price;
  final bool selected;
}

class CartSummaryRow {
  const CartSummaryRow({
    required this.key,
    required this.label,
    required this.amount,
    required this.isTotal,
    required this.isDiscount,
    this.formattedValue,
  });
  final String key;
  final String label;
  final int amount;
  final String? formattedValue;
  final bool isTotal;
  final bool isDiscount;
}
