import 'package:dio/dio.dart';
import 'package:mobile_hexy/core/networks/api_endpoints.dart';
import 'package:mobile_hexy/core/networks/api_service.dart';
import 'package:mobile_hexy/data/models/shipping_address.dart';

class AddressFormOptions {
  const AddressFormOptions({required this.states, required this.cities});
  final List<AddressOption> states;
  final List<AddressOption> cities;
}

class ShippingAddressRemoteDataSource {
  ShippingAddressRemoteDataSource(this._apiService);
  final ApiService _apiService;

  Future<List<ShippingAddress>> fetchAddresses() async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.shippingAddresses,
    );
    final data = _data(response.data);
    final raw = data is List
        ? data
        : data is Map
        ? data['addresses']
        : null;
    return raw is List
        ? raw.whereType<Map>().map(ShippingAddress.fromJson).toList()
        : const [];
  }

  Future<List<AddressOption>> fetchStates() async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.locationStates,
      queryParameters: const {'country_code': 'MM'},
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final data = _data(response.data);
    return _options(data is Map ? data['states'] ?? data['regions'] : data);
  }

  Future<List<AddressOption>> fetchCities(int stateId) async {
    final response = await _apiService.get<dynamic>(
      ApiEndpoints.locationCities,
      queryParameters: {'state_id': stateId},
      options: Options(extra: const {ApiEndpoints.requiresAuthKey: false}),
    );
    final data = _data(response.data);
    return _options(data is Map ? data['cities'] ?? data['townships'] : data);
  }

  Future<void> create(Map<String, dynamic> body) async =>
      _apiService.post<dynamic>(ApiEndpoints.shippingAddresses, data: body);
  Future<void> update(int id, Map<String, dynamic> body) async =>
      _apiService.put<dynamic>(ApiEndpoints.shippingAddress(id), data: body);
  Future<void> delete(int id) async =>
      _apiService.delete<dynamic>(ApiEndpoints.shippingAddress(id));

  Object? _data(Object? body) {
    if (body is Map && body['success'] == false) {
      throw FormatException(
        body['message']?.toString() ?? 'Address request failed.',
      );
    }
    return body is Map && body.containsKey('data') ? body['data'] : body;
  }

  List<AddressOption> _options(Object? raw) => raw is List
      ? raw
            .whereType<Map>()
            .map(
              (item) => AddressOption(
                id: int.tryParse(item['id']?.toString() ?? ''),
                name: (item['name'] ?? item['display_name'])?.toString() ?? '',
              ),
            )
            .where((item) => item.name.isNotEmpty)
            .toList()
      : const [];
}
