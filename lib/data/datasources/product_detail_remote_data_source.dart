import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/product_detail.dart';

class ProductDetailRemoteDataSource {
  const ProductDetailRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<ProductDetail> fetch(int id) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.productDetail(id),
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final body = response.data;
    if (body is! Map || body['success'] != true || body['data'] is! Map) {
      throw const FormatException('Could not load product details.');
    }
    final data = Map<String, dynamic>.from(body['data'] as Map);
    final currency = data['currency'];
    final category = data['category'];
    final variantSections = data['variant_sections'];
    final specifications = data['specifications'];
    final images = data['images'];
    final gallery = data['gallery'];
    final quantitySelector = data['quantity_selector'];
    final relatedProducts = data['related_products'];
    final youMightAlsoLike = data['you_might_also_like'];
    final imageUrls = <String>[
      if (data['image_url']?.toString().isNotEmpty == true)
        data['image_url'].toString(),
      if (images is List)
        ...images.whereType<Map>().map(
          (value) => value['image_url']?.toString() ?? '',
        ),
      if (gallery is Map && gallery['items'] is List)
        ...(gallery['items'] as List).whereType<Map>().map(
          (value) =>
              value['image_url']?.toString() ??
              value['zoom_url']?.toString() ??
              '',
        ),
      if (gallery is List) ...gallery.map((value) => value.toString()),
    ];
    final uniqueImageUrls = imageUrls
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final categoryName = category is Map
        ? category['name']?.toString() ?? ''
        : data['category_name']?.toString() ?? '';
    return ProductDetail(
      id: int.tryParse(data['id']?.toString() ?? '') ?? id,
      name: data['name']?.toString() ?? '',
      sku: data['sku'] == false ? '' : data['sku']?.toString() ?? '',
      price:
          double.tryParse(
            (data['current_price'] ?? data['sale_price'] ?? data['price'])
                    ?.toString() ??
                '',
          ) ??
          0,
      compareAtPrice: double.tryParse(
        (data['original_price'] ??
                    data['list_price'] ??
                    data['compare_at_price'])
                ?.toString() ??
            '',
      ),
      discountPercent:
          int.tryParse(
            (data['discount_percentage'] ?? data['discount_percent'])
                    ?.toString() ??
                '',
          ) ??
          0,
      currencySymbol: currency is Map
          ? currency['symbol']?.toString() ?? ''
          : '',
      imageUrls: uniqueImageUrls,
      rating: double.tryParse(data['rating']?.toString() ?? '') ?? 0,
      reviewCount: int.tryParse(data['review_count']?.toString() ?? '') ?? 0,
      inStock: data['in_stock'] == true,
      availableQuantity:
          double.tryParse(data['available_qty']?.toString() ?? '') ?? 0,
      description:
          data['description_plain']?.toString() ??
          data['description']?.toString() ??
          '',
      brand: data['brand']?.toString() ?? '',
      categories: categoryName.isEmpty ? const [] : [categoryName],
      variantSections: _parseVariantSections(variantSections, data['variants']),
      specifications: specifications is List
          ? specifications
                .whereType<Map>()
                .map((value) {
                  return ProductSpecification(
                    label: value['label']?.toString() ?? '',
                    value: value['value']?.toString() ?? '',
                  );
                })
                .toList(growable: false)
          : const [],
      quantityMin: quantitySelector is Map
          ? int.tryParse(quantitySelector['min']?.toString() ?? '') ?? 1
          : 1,
      quantityMax: quantitySelector is Map
          ? int.tryParse(quantitySelector['max']?.toString() ?? '') ?? 1
          : 1,
      quantityStep: quantitySelector is Map
          ? int.tryParse(quantitySelector['step']?.toString() ?? '') ?? 1
          : 1,
      defaultQuantity: quantitySelector is Map
          ? int.tryParse(quantitySelector['default']?.toString() ?? '') ?? 1
          : 1,
      wishlist: data['wishlist'] == true,
      cartQuantity: int.tryParse(data['cart_qty']?.toString() ?? '') ?? 0,
      relatedProducts: _parseProductCards(relatedProducts, currency),
      youMightAlsoLike: _parseProductCards(youMightAlsoLike, currency),
    );
  }

  List<ProductVariantSection> _parseVariantSections(
    Object? sectionsSource,
    Object? variantsSource,
  ) {
    final sections = <ProductVariantSection>[];
    if (sectionsSource is List) {
      for (final section in sectionsSource.whereType<Map>()) {
        final values = _parseVariantValues(
          section['values'] ?? section['options'],
        );
        if (values.isEmpty) continue;
        sections.add(
          ProductVariantSection(
            attribute:
                (section['attribute'] ?? section['label'])?.toString() ?? '',
            key: section['key']?.toString() ?? '',
            values: values,
          ),
        );
      }
    }
    if (variantsSource is Map) {
      for (final entry in variantsSource.entries) {
        final key = entry.key.toString();
        if (sections.any((section) => section.key == key)) continue;
        final values = _parseVariantValues(entry.value);
        if (values.isEmpty) continue;
        sections.add(
          ProductVariantSection(
            attribute: _variantLabel(key),
            key: key,
            values: values,
          ),
        );
      }
    }
    return List.unmodifiable(sections);
  }

  List<ProductVariantValue> _parseVariantValues(Object? source) {
    if (source is! List) return const [];
    return source.indexed
        .map((entry) {
          final (index, raw) = entry;
          if (raw is Map) {
            return ProductVariantValue(
              id:
                  int.tryParse(
                    (raw['id'] ?? raw['value_id'])?.toString() ?? '',
                  ) ??
                  index + 1,
              name:
                  (raw['name'] ?? raw['value'] ?? raw['label'])?.toString() ??
                  '',
              available: raw['available'] != false,
              variantId: int.tryParse(raw['variant_id']?.toString() ?? ''),
              selected: raw['selected'] == true,
            );
          }
          return ProductVariantValue(
            id: index + 1,
            name: raw.toString(),
            available: true,
            variantId: null,
            selected: index == 0,
          );
        })
        .where((value) => value.name.isNotEmpty)
        .toList(growable: false);
  }

  String _variantLabel(String key) => key
      .split('_')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');

  List<ProductDetailCard> _parseProductCards(Object? source, Object? currency) {
    if (source is! List) return const [];
    final fallbackSymbol = currency is Map
        ? currency['symbol']?.toString() ?? ''
        : '';
    return source
        .whereType<Map>()
        .map((value) {
          final itemCurrency = value['currency'];
          final images = value['images'];
          var imageUrl = value['image_url']?.toString() ?? '';
          if (imageUrl.isEmpty && images is List && images.isNotEmpty) {
            final first = images.first;
            imageUrl = first is Map
                ? first['image_url']?.toString() ?? ''
                : first.toString();
          }
          return ProductDetailCard(
            id: int.tryParse(value['id']?.toString() ?? '') ?? 0,
            name: value['name']?.toString() ?? '',
            price:
                double.tryParse(
                  (value['current_price'] ??
                              value['sale_price'] ??
                              value['price'])
                          ?.toString() ??
                      '',
                ) ??
                0,
            currencySymbol: itemCurrency is Map
                ? itemCurrency['symbol']?.toString() ?? fallbackSymbol
                : fallbackSymbol,
            imageUrl: imageUrl,
            rating: double.tryParse(value['rating']?.toString() ?? '') ?? 0,
            compareAtPrice: double.tryParse(
              (value['original_price'] ??
                          value['list_price'] ??
                          value['compare_at_price'])
                      ?.toString() ??
                  '',
            ),
            discountPercent:
                int.tryParse(
                  (value['discount_percentage'] ?? value['discount_percent'])
                          ?.toString() ??
                      '',
                ) ??
                0,
          );
        })
        .where((value) => value.id > 0)
        .toList(growable: false);
  }
}
