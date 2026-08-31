class ShippingAddress {
  const ShippingAddress({
    required this.id,
    required this.name,
    required this.phone,
    required this.addressType,
    required this.stateRegion,
    required this.cityTownship,
    required this.streetAddress,
    required this.building,
    required this.isDefault,
    this.countryId,
    this.stateId,
  });
  final int id;
  final String name;
  final String phone;
  final String addressType;
  final String stateRegion;
  final String cityTownship;
  final String streetAddress;
  final String building;
  final bool isDefault;
  final int? countryId;
  final int? stateId;

  factory ShippingAddress.fromJson(Map<dynamic, dynamic> json) =>
      ShippingAddress(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        addressType: json['address_type']?.toString() ?? 'home',
        stateRegion: json['state_region']?.toString() ?? '',
        cityTownship: json['city_township']?.toString() ?? '',
        streetAddress: json['street_address']?.toString() ?? '',
        building: json['building']?.toString() ?? '',
        isDefault: json['is_default'] == true,
        countryId: int.tryParse(json['country_id']?.toString() ?? ''),
        stateId: int.tryParse(json['state_id']?.toString() ?? ''),
      );
}

class AddressOption {
  const AddressOption({required this.id, required this.name});
  final int? id;
  final String name;
}
