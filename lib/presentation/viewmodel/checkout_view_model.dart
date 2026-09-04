import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_hexy/app.dart';
import 'package:mobile_hexy/core/base/base_view_model.dart';
import 'package:mobile_hexy/data/datasources/checkout_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/shipping_address_remote_data_source.dart';
import 'package:mobile_hexy/data/models/shipping_address.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';

class CheckoutViewModel extends BaseViewModel {
  CheckoutViewModel(
    this.cart,
    this._checkoutRemoteDataSource,
    this._addressRemoteDataSource,
  );

  final CartViewModel cart;
  final CheckoutRemoteDataSource _checkoutRemoteDataSource;
  final ShippingAddressRemoteDataSource _addressRemoteDataSource;
  final selectedPayment = 'Cash on Delivery'.obs;
  final termsAccepted = false.obs;
  final itemsExpanded = false.obs;
  final notesController = TextEditingController();
  final addresses = <ShippingAddress>[].obs;
  final deliveryMethods = <CheckoutDeliveryMethod>[].obs;
  final selectedAddress = Rxn<ShippingAddress>();
  final selectedDeliveryMethod = Rxn<CheckoutDeliveryMethod>();
  final isLoading = true.obs;
  final isUpdatingAddress = false.obs;
  final isUpdatingDeliveryMethod = false.obs;
  final isUpdatingNotes = false.obs;
  final isPlacingOrder = false.obs;
  final hasCheckoutData = false.obs;
  String _savedNotes = '';

  @override
  void onInit() {
    super.onInit();
    loadCheckout();
  }

  Future<void> loadCheckout() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait<Object>([
        _checkoutRemoteDataSource.fetchCheckout(),
        _addressRemoteDataSource.fetchAddresses(),
        _checkoutRemoteDataSource.fetchDeliveryMethods(),
      ]);
      addresses.assignAll(results[1] as List<ShippingAddress>);
      deliveryMethods.assignAll(
        (results[2] as List<Map<String, dynamic>>).map(
          CheckoutDeliveryMethod.fromJson,
        ),
      );
      _applyCheckout(results[0] as Map<String, dynamic>);
      hasCheckoutData.value = true;
    } catch (error) {
      errorMessage.value = _message(error);
    } finally {
      isLoading.value = false;
    }
  }

  void selectPayment(String payment) => selectedPayment.value = payment;

  Future<bool> selectAddress(ShippingAddress address) async {
    if (isUpdatingAddress.value) return false;
    if (address.id == selectedAddress.value?.id) return true;
    isUpdatingAddress.value = true;
    try {
      final data = await _checkoutRemoteDataSource.updateCheckout(
        shippingAddressId: address.id,
      );
      selectedAddress.value = address;
      _applyCheckout(data, fallbackAddressId: address.id);
      await _refreshDeliveryMethods();
      return true;
    } catch (error) {
      _showError('Could not update delivery information', error);
      return false;
    } finally {
      isUpdatingAddress.value = false;
    }
  }

  Future<bool> selectDeliveryMethod(CheckoutDeliveryMethod method) async {
    if (isUpdatingDeliveryMethod.value) return false;
    if (method.id == selectedDeliveryMethod.value?.id) return true;
    isUpdatingDeliveryMethod.value = true;
    try {
      final data = await _checkoutRemoteDataSource.updateCheckout(
        deliveryMethodId: method.id,
      );
      selectedDeliveryMethod.value = method;
      _applyCheckout(data, fallbackDeliveryMethodId: method.id);
      return true;
    } catch (error) {
      _showError('Could not update delivery method', error);
      return false;
    } finally {
      isUpdatingDeliveryMethod.value = false;
    }
  }

  Future<void> updateDeliveryNotes() async {
    final notes = notesController.text.trim();
    if (isUpdatingNotes.value || notes == _savedNotes) return;
    isUpdatingNotes.value = true;
    try {
      await _checkoutRemoteDataSource.updateCheckout(deliveryNotes: notes);
      _savedNotes = notes;
    } catch (error) {
      _showError('Could not update delivery notes', error);
    } finally {
      isUpdatingNotes.value = false;
    }
  }

  Future<void> _refreshDeliveryMethods() async {
    final raw = await _checkoutRemoteDataSource.fetchDeliveryMethods();
    final previousId = selectedDeliveryMethod.value?.id;
    deliveryMethods.assignAll(raw.map(CheckoutDeliveryMethod.fromJson));
    selectedDeliveryMethod.value = deliveryMethods.firstWhereOrNull(
      (method) => method.selected || method.id == previousId,
    );
  }

  void _applyCheckout(
    Map<String, dynamic> data, {
    int? fallbackAddressId,
    String? fallbackDeliveryMethodId,
  }) {
    cart.applyCheckoutPayload(data);
    final addressSource =
        data['selected_shipping_address'] ??
        data['shipping_address'] ??
        data['delivery_information'] ??
        _selectedMap(data['shipping_addresses']);
    final addressId =
        _id(addressSource) ??
        _int(data['shipping_address_id']) ??
        fallbackAddressId;
    selectedAddress.value = addresses.firstWhereOrNull(
      (address) => address.id == addressId,
    );
    if (selectedAddress.value == null && addressSource is Map) {
      selectedAddress.value = ShippingAddress.fromJson(addressSource);
    }
    selectedAddress.value ??= addresses.firstWhereOrNull(
      (address) => address.isDefault,
    );

    final methodSource =
        data['selected_delivery_method'] ??
        data['delivery_method'] ??
        data['shipping_method'];
    final methodId =
        _id(methodSource)?.toString() ??
        data['delivery_method_id']?.toString() ??
        data['delivery_method_is']?.toString() ??
        data['shipping_method_id']?.toString() ??
        fallbackDeliveryMethodId;
    selectedDeliveryMethod.value = deliveryMethods.firstWhereOrNull(
      (method) => method.id == methodId,
    );
    if (selectedDeliveryMethod.value == null && methodSource is Map) {
      selectedDeliveryMethod.value = CheckoutDeliveryMethod.fromJson(
        Map<String, dynamic>.from(methodSource),
      );
    }
    selectedDeliveryMethod.value ??= deliveryMethods.firstWhereOrNull(
      (method) => method.selected,
    );

    final payment = data['payment_method'] ?? data['selected_payment_method'];
    _setPayment(payment is Map ? payment['code'] ?? payment['name'] : payment);
  }

  void _setPayment(Object? value) {
    final normalized = value?.toString().toLowerCase() ?? '';
    if (normalized == 'cod' || normalized.contains('cash')) {
      selectedPayment.value = 'Cash on Delivery';
    }
  }

  int? _id(Object? value) => value is Map
      ? _int(value['id'] ?? value['address_id'] ?? value['method_id'])
      : _int(value);

  Map<dynamic, dynamic>? _selectedMap(Object? value) {
    if (value is! List) return null;
    for (final item in value.whereType<Map>()) {
      if (item['selected'] == true ||
          item['is_selected'] == true ||
          item['is_default'] == true) {
        return item;
      }
    }
    return null;
  }

  int? _int(Object? value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
  String _message(Object error) => error
      .toString()
      .replaceFirst('Exception: ', '')
      .replaceFirst('FormatException: ', '');
  void _showError(String title, Object error) =>
      Get.snackbar(title, _message(error), snackPosition: SnackPosition.BOTTOM);

  Future<void> placeOrder() async {
    if (isPlacingOrder.value) return;
    if (selectedAddress.value == null) {
      Get.snackbar(
        'Delivery address required',
        'Please select a shipping address.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedDeliveryMethod.value == null) {
      Get.snackbar(
        'Delivery method required',
        'Please select a delivery method.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!termsAccepted.value) {
      Get.snackbar(
        'Agreement required',
        'Please accept the Terms & Conditions and Privacy Policy.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isPlacingOrder.value = true;
    try {
      final result = await _checkoutRemoteDataSource.placeOrder(
        shippingAddressId: selectedAddress.value!.id,
        deliveryMethodId: selectedDeliveryMethod.value!.id,
        paymentMethod: _paymentCode(selectedPayment.value),
        termsAccepted: termsAccepted.value,
        deliveryNotes: notesController.text.trim(),
      );
      Get.offNamed<dynamic>(AppRoutes.paymentSuccess, arguments: result);
    } catch (error) {
      _showError('Could not place order', error);
    } finally {
      isPlacingOrder.value = false;
    }
  }

  String _paymentCode(String payment) => switch (payment) {
    'Cash on Delivery' => 'cod',
    'KBZPay' => 'kbzpay',
    'WavePay' => 'wavepay',
    'Visa/Master' => 'card',
    'MPU' => 'mpu',
    _ => payment.toLowerCase().replaceAll(' ', '_'),
  };

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}

class CheckoutDeliveryMethod {
  const CheckoutDeliveryMethod({
    required this.id,
    required this.name,
    required this.price,
    required this.selected,
    this.description,
    this.formattedPrice,
  });
  final String id;
  final String name;
  final String? description;
  final int price;
  final String? formattedPrice;
  final bool selected;

  factory CheckoutDeliveryMethod.fromJson(Map<String, dynamic> json) {
    final priceValue =
        json['price'] ??
        json['delivery_price'] ??
        json['amount'] ??
        json['fee'];
    return CheckoutDeliveryMethod(
      id:
          (json['id'] ?? json['delivery_method_id'] ?? json['carrier_id'])
              ?.toString() ??
          '',
      name:
          (json['name'] ??
                  json['label'] ??
                  json['title'] ??
                  json['display_name'])
              ?.toString() ??
          '',
      description:
          (json['description'] ?? json['subtitle'] ?? json['eta'])
              ?.toString() ??
          json['estimated_delivery']?.toString(),
      price: _amount(priceValue),
      formattedPrice:
          _formattedPrice(priceValue, json['currency']) ??
          (json['formatted_price'] ?? json['price_display'])?.toString(),
      selected: json['selected'] == true || json['is_selected'] == true,
    );
  }

  static int _amount(Object? value) {
    if (value is Map) {
      return _amount(value['amount'] ?? value['value'] ?? value['price']);
    }
    final normalized = value
        ?.toString()
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9.\-]'), '');
    return (double.tryParse(normalized ?? '') ?? 0).round();
  }

  static String? _formattedPrice(Object? price, Object? currency) {
    if (currency is! Map) return null;
    final symbol = currency['symbol']?.toString() ?? '';
    if (symbol.isEmpty) return null;
    final amount = price is num
        ? price
        : double.tryParse(price?.toString() ?? '');
    if (amount == null) return null;
    final value = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '$value $symbol';
  }
}
