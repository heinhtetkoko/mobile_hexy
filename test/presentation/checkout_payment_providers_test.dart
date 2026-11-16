import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/checkout_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/shipping_address_remote_data_source.dart';
import 'package:mobile_hexy/presentation/viewmodel/cart_view_model.dart';
import 'package:mobile_hexy/presentation/viewmodel/checkout_view_model.dart';
import 'product_list_sort_filter_test.dart' show RecordingApi;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RecordingApi api;
  late CheckoutViewModel vm;
  late CartViewModel cart;
  setUp(() {
    api = RecordingApi();
    cart = CartViewModel(CartRemoteDataSource(api));
    vm = CheckoutViewModel(
      cart,
      CheckoutRemoteDataSource(api),
      ShippingAddressRemoteDataSource(api),
    );
  });
  tearDown(() {
    vm.onClose();
    cart.onClose();
    Get.reset();
  });
  void respond({bool disabledMpu = false}) {
    final call = api.calls.last;
    call.completion.complete(
      Response(
        requestOptions: RequestOptions(path: call.path),
        data: {
          'success': true,
          'data': {
            'selected': {'key': 'cod'},
            'data': [
              {
                'id': null,
                'key': 'cod',
                'code': 'cod',
                'label': 'Cash on Delivery',
                'enabled': true,
                'selected': true,
              },
              {
                'id': 23,
                'provider_id': 23,
                'key': 'mpu',
                'code': 'mpu',
                'label': 'MPU',
                'enabled': !disabledMpu,
                'selected': true,
              },
            ],
          },
        },
      ),
    );
  }

  test(
    'API selection wins over conflicting row flags and uses provider IDs',
    () async {
      final loading = vm.loadPaymentProviders();
      expect(api.calls.single.path, ApiEndpoints.paymentProviders);
      expect(api.calls.single.query, isEmpty);
      respond();
      await loading;
      expect(vm.paymentProviders.length, 2);
      expect(vm.selectedPayment.value, 'cod');
      expect(vm.selectedPaymentProvider?.id, isNull);
      vm.selectPayment('mpu');
      expect(vm.selectedPaymentProvider?.id, 23);
      expect(vm.selectedPaymentProvider?.code, 'mpu');
      final refreshing = vm.loadPaymentProviders();
      respond();
      await refreshing;
      expect(vm.selectedPayment.value, 'mpu');
    },
  );
  test(
    'disabled providers cannot be selected and refresh replaces stale choice',
    () async {
      final first = vm.loadPaymentProviders();
      respond();
      await first;
      vm.selectPayment('mpu');
      final reload = vm.loadPaymentProviders();
      respond(disabledMpu: true);
      await reload;
      expect(vm.selectedPayment.value, 'cod');
      vm.selectPayment('mpu');
      expect(vm.selectedPayment.value, 'cod');
    },
  );
  test('failure clears stale methods and retry recovers', () async {
    final first = vm.loadPaymentProviders();
    respond();
    await first;
    final failing = vm.loadPaymentProviders();
    api.calls.last.fail();
    await failing;
    expect(vm.paymentProviders, isEmpty);
    expect(vm.selectedPaymentProvider, isNull);
    expect(vm.paymentProvidersError.value, isNotNull);
    final retry = vm.loadPaymentProviders();
    respond();
    await retry;
    expect(vm.paymentProvidersError.value, isNull);
    expect(vm.selectedPayment.value, 'cod');
  });
  test('empty API methods do not invent a cash on delivery fallback', () async {
    final loading = vm.loadPaymentProviders();
    final call = api.calls.single;
    call.completion.complete(
      Response(
        requestOptions: RequestOptions(path: call.path),
        data: {
          'success': true,
          'data': {'data': []},
        },
      ),
    );
    await loading;
    expect(vm.paymentProviders, isEmpty);
    expect(vm.selectedPaymentProvider, isNull);
  });
  test('place order sends the selected provider ID and API code', () async {
    RequestOptions? sent;
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          sent = request;
          handler.resolve(
            Response(
              requestOptions: request,
              statusCode: 200,
              data: {
                'success': true,
                'data': {'order_id': 10272},
              },
            ),
          );
        },
      ),
    );
    await CheckoutRemoteDataSource(ApiService(dio)).placeOrder(
      orderId: '10272',
      shippingAddressId: 8576,
      deliveryMethodId: 6,
      paymentMethod: 'mpu',
      paymentMethodId: 23,
      termsAccepted: true,
      deliveryNotes: 'Testing',
    );
    expect(sent?.path, ApiEndpoints.checkoutPlaceOrder);
    expect(sent?.data['payment_method'], 'mpu');
    expect(sent?.data['payment_method_id'], 23);
    expect(sent?.data['delivery_notes'], 'Testing');
  });
}
