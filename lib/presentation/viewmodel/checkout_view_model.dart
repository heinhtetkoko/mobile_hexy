import 'package:mobile_hexy/data/models/payment_checkout_session.dart';
import 'package:mobile_hexy/data/models/checkout_payment_provider.dart';
import 'package:mobile_hexy/core/utils/money_formatter.dart';
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
    this._addressRemoteDataSource, {
    this.orderId,
  });

  final String? orderId;
  final CartViewModel cart;
  final CheckoutRemoteDataSource _checkoutRemoteDataSource;
  final ShippingAddressRemoteDataSource _addressRemoteDataSource;
  final selectedPayment = ''.obs;
  final paymentProviders = <CheckoutPaymentProvider>[].obs;
  final isLoadingPaymentProviders = false.obs;
  final paymentProvidersError = RxnString();
  CheckoutPaymentProvider? get selectedPaymentProvider =>
      paymentProviders.firstWhereOrNull(
        (item) => item.key == selectedPayment.value && item.enabled,
      );
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
  final isPlacingOrder = false.obs;
  final hasCheckoutData = false.obs;
  int get shippingTotal => selectedDeliveryMethod.value?.price ?? cart.shipping;
  int get grandTotal => cart.grandTotal - cart.shipping + shippingTotal;

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
        _checkoutRemoteDataSource.fetchCheckout(orderId: orderId),
        _addressRemoteDataSource.fetchAddresses(),
        _checkoutRemoteDataSource.fetchDeliveryMethods(orderId: orderId),
        loadPaymentProviders().then((_) => true),
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

  void selectPayment(String key) {
    if (isPlacingOrder.value) return;
    if (paymentProviders.any((item) => item.key == key && item.enabled)) {
      selectedPayment.value = key;
    }
  }

  Future<void> loadPaymentProviders() async {
    if (isLoadingPaymentProviders.value) return;
    isLoadingPaymentProviders.value = true;
    paymentProvidersError.value = null;
    try {
      final result = await _checkoutRemoteDataSource.fetchPaymentProviders();
      final previous = selectedPayment.value;
      paymentProviders.assignAll(result.items);
      final enabled = result.items.where((item) => item.enabled).toList();
      selectedPayment.value =
          enabled.firstWhereOrNull((item) => item.key == previous)?.key ??
          enabled
              .firstWhereOrNull((item) => item.key == result.selectedKey)
              ?.key ??
          enabled.firstWhereOrNull((item) => item.selected)?.key ??
          enabled.firstOrNull?.key ??
          '';
    } catch (error) {
      paymentProviders.clear();
      selectedPayment.value = '';
      paymentProvidersError.value = _message(error);
    } finally {
      isLoadingPaymentProviders.value = false;
    }
  }

  Future<bool> selectAddress(ShippingAddress address) async {
    if (isPlacingOrder.value) return false;
    selectedAddress.value = address;
    return true;
  }

  Future<bool> selectDeliveryMethod(CheckoutDeliveryMethod method) async {
    if (isPlacingOrder.value) return false;
    selectedDeliveryMethod.value = method;
    return true;
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
    final provider = selectedPaymentProvider;
    if (isLoadingPaymentProviders.value || provider == null) {
      Get.snackbar(
        'Payment method required',
        'Please select an available payment method.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    isPlacingOrder.value = true;
    try {
      final purchasedItems = cart.items
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'product_id': item.productId,
              'name': item.name,
              'quantity': item.quantity,
              'image_url': item.imageUrl,
              'image_asset': item.imageAsset,
            },
          )
          .toList(growable: false);
      final purchasedItemCount = cart.items.fold<int>(
        0,
        (total, item) => total + item.quantity,
      );
      final deliveryAddress = selectedAddress.value!;
      final result = await _checkoutRemoteDataSource.placeOrder(
        orderId: orderId,
        shippingAddressId: selectedAddress.value!.id,
        deliveryMethodId: selectedDeliveryMethod.value!.id,
        paymentMethod: provider.code,
        paymentMethodId: provider.id,
        termsAccepted: termsAccepted.value,
        deliveryNotes: notesController.text.trim(),
      );
      final successArguments = <String, dynamic>{
        ...result,
        'payment_method':
            result['payment_method'] ??
            (PaymentCheckoutSession.isKbzPay(result['type'])
                ? result['type']
                : provider.code),
        '_checkout_items': purchasedItems,
        '_checkout_item_count': purchasedItemCount,
        '_checkout_grand_total': grandTotal,
        '_checkout_currency_symbol': cart.currencySymbol.value,
        '_checkout_payment_method': provider.label,
        '_checkout_delivery_method': selectedDeliveryMethod.value!.name,
        '_checkout_delivery_notes': notesController.text.trim(),
        '_checkout_address': <String, dynamic>{
          'id': deliveryAddress.id,
          'name': deliveryAddress.name,
          'phone': deliveryAddress.phone,
          'address_type': deliveryAddress.addressType,
          'building': deliveryAddress.building,
          'street_address': deliveryAddress.streetAddress,
          'city_township': deliveryAddress.cityTownship,
          'state_region': deliveryAddress.stateRegion,
        },
      };
      final checkoutUrl = result['checkout_url']?.toString().trim() ?? '';
      if (provider.code.toLowerCase() == 'mpu' ||
          PaymentCheckoutSession.isKbzPay(provider.code) ||
          PaymentCheckoutSession.isKbzPay(successArguments['payment_method']) ||
          checkoutUrl.isNotEmpty) {
        final session = PaymentCheckoutSession.fromJson(successArguments);
        Get.offNamed<dynamic>(AppRoutes.paymentCheckout, arguments: session);
        return;
      }
      Get.offNamed<dynamic>(
        AppRoutes.paymentSuccess,
        arguments: successArguments,
      );
    } catch (error) {
      _showError('Could not place order', error);
    } finally {
      isPlacingOrder.value = false;
    }
  }

  @override
  void onClose() {
    if (orderId != null) cart.onClose();
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
    final value = MoneyFormatter.format(amount);
    return '$value $symbol';
  }
}
