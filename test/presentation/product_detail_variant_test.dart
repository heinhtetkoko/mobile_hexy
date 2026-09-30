import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:mobile_hexy/data/datasources/cart_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/product_detail_remote_data_source.dart';
import 'package:mobile_hexy/data/datasources/wishlist_remote_data_source.dart';
import 'package:mobile_hexy/presentation/viewmodel/product_detail_view_model.dart';
import 'product_list_sort_filter_test.dart' show RecordingApi;

Map<String, dynamic> detail(int variant, {int id = 22, bool exact = true}) => {
  'success': true,
  'data': {
    'id': id,
    'name': 'Pen',
    'current_price': variant == 35 ? 2100 : 3500,
    'price': {
      'currency': {'symbol': 'Ks'},
    },
    'stock': {'in_stock': true, 'qty': 18},
    'selected_variant': {
      'id': variant,
      'image_url': '/web/image/$variant',
      'in_stock': true,
      'available_qty': 18,
    },
    'image_url': '/web/image/template',
    'gallery': {
      'items': [
        {'image_url': '/web/image/$variant'},
        {'zoom_url': '/web/image/$variant/extra'},
      ],
    },
    'variant_sections': [
      {
        'key': 'color',
        'label': 'Color',
        'options': [
          {
            'id': 1,
            'name': 'Blue',
            'selected': variant == 35,
            'available': true,
            if (exact) 'product_variant_id': 35,
            'next_ptav_ids': [12, 18],
          },
          {
            'id': 2,
            'name': 'Green',
            'selected': variant == 36,
            'available': true,
            if (exact) 'product_variant_id': 36,
            'next_ptav_ids': [13, 18],
          },
        ],
      },
    ],
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RecordingApi api;
  late ProductDetailViewModel vm;
  void respond(Map<String, dynamic> data) {
    final call = api.calls.last;
    call.completion.complete(
      Response(
        requestOptions: RequestOptions(path: call.path),
        data: data,
      ),
    );
  }

  Future<void> load({bool exact = true}) async {
    final pending = vm.loadProduct(productId: 22);
    respond(detail(35, exact: exact));
    await pending;
  }

  setUp(() {
    Get.testMode = true;
    api = RecordingApi();
    vm = ProductDetailViewModel(
      ProductDetailRemoteDataSource(api),
      CartRemoteDataSource(api),
      WishlistRemoteDataSource(api),
    );
  });
  tearDown(() {
    vm.onClose();
    Get.reset();
  });

  test(
    'selecting a variant refreshes gallery, price, stock and selected IDs',
    () async {
      await load();
      expect(vm.selectedVariantId.value, 35);
      expect(vm.product.value!.imageUrls.first, endsWith('/web/image/35'));
      vm.selectedImage.value = 2;
      final option = vm.product.value!.variantSections.first.values.last;
      final pending = vm.selectVariantValue('color', option);
      expect(api.calls.last.path, 'api/v1/products/22');
      expect(api.calls.last.query, {'product_variant_id': 36});
      expect(vm.isLoadingVariant.value, true);
      await vm.addToCart(); // Must not authenticate or submit while switching.
      expect(api.calls.length, 2);
      respond(detail(36));
      await pending;
      expect(vm.selectedImage.value, 0);
      expect(vm.selectedVariantId.value, 36);
      expect(vm.selectedVariantValues['color'], 2);
      expect(vm.product.value!.imageUrls.first, endsWith('/web/image/36'));
      expect(vm.product.value!.imageUrls.length, 3);
      expect(vm.product.value!.formattedPrice, '3,500 Ks');
      expect(vm.product.value!.inStock, true);
      expect(vm.product.value!.availableQuantity, 18);
      expect(vm.isLoadingVariant.value, false);
    },
  );

  test(
    'documented next PTAV combination is used when exact variant ID is absent',
    () async {
      await load(exact: false);
      final pending = vm.selectVariantValue(
        'color',
        vm.product.value!.variantSections.first.values.last,
      );
      expect(api.calls.last.query, {'ptav_ids': '13,18'});
      respond(detail(36, exact: false));
      await pending;
      expect(vm.selectedVariantId.value, 36);
    },
  );

  test(
    'failed switch retains confirmed image and selection and allows retry',
    () async {
      await load();
      final option = vm.product.value!.variantSections.first.values.last;
      final pending = vm.selectVariantValue('color', option);
      api.calls.last.fail();
      await pending;
      expect(vm.variantError.value, isNotNull);
      expect(vm.selectedVariantId.value, 35);
      expect(vm.selectedVariantValues['color'], 1);
      expect(vm.product.value!.imageUrls.first, endsWith('/web/image/35'));
      final retry = vm.selectVariantValue('color', option);
      respond(detail(36));
      await retry;
      expect(vm.variantError.value, isNull);
      expect(vm.selectedVariantId.value, 36);
    },
  );

  test('old variant response cannot replace a newly opened product', () async {
    await load();
    final switching = vm.selectVariantValue(
      'color',
      vm.product.value!.variantSections.first.values.last,
    );
    final oldCall = api.calls.last;
    final opening = vm.loadProduct(productId: 99);
    respond(detail(50, id: 99));
    await opening;
    oldCall.completion.complete(
      Response(
        requestOptions: RequestOptions(path: oldCall.path),
        data: detail(36),
      ),
    );
    await switching;
    expect(vm.product.value!.id, 99);
    expect(vm.selectedVariantId.value, 50);
  });

  test(
    'empty variant images fall back to gallery and invalid images are omitted',
    () async {
      final pending = vm.loadProduct(productId: 22);
      final body = detail(35);
      final data = body['data'] as Map;
      data['selected_variant'] = {'id': 35, 'image_url': false};
      data['gallery'] = [
        {'image_url': '/valid'},
        false,
        '',
        {'image_url': false},
      ];
      data['image_url'] = false;
      respond(body);
      await pending;
      expect(vm.product.value!.imageUrls, hasLength(1));
      expect(vm.product.value!.imageUrls.single, endsWith('/valid'));
    },
  );
}
