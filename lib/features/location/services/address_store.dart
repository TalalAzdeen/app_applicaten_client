import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/service_model.dart';

class AddressStore {
  static const _key = 'saved_addresses_v1';
  Future<List<CustomerAddress>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final result = <CustomerAddress>[];
      for (final item in decoded) {
        if (item is! Map<String, dynamic> || item['id'] is! String ||
            item['label'] is! String || item['fullAddress'] is! String ||
            item['latitude'] is! num || item['longitude'] is! num) continue;
        final latitude = (item['latitude'] as num).toDouble();
        final longitude = (item['longitude'] as num).toDouble();
        if (!latitude.isFinite || !longitude.isFinite || latitude.abs() > 90 || longitude.abs() > 180) continue;
        final accuracy = item['accuracyMeters'];
        result.add(CustomerAddress(
          id: item['id'] as String, label: item['label'] as String,
          fullAddress: item['fullAddress'] as String, latitude: latitude, longitude: longitude,
          accuracyMeters: accuracy is num && accuracy.isFinite && accuracy >= 0 ? accuracy.toDouble() : null,
        ));
      }
      return result;
    } on FormatException { return []; }
  }

  Future<void> save(List<CustomerAddress> addresses) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_key, jsonEncode(addresses.map((address) => {
      'id': address.id, 'label': address.label, 'fullAddress': address.fullAddress,
      'latitude': address.latitude, 'longitude': address.longitude,
      'accuracyMeters': address.accuracyMeters,
    }).toList()));
    if (!saved) throw StateError('Address storage failed');
  }
}
