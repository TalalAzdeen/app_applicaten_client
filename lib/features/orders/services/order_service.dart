import '../../../core/network/api_client.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/app_repository.dart';

class OrderService {
  final _api = ApiClient();
  OrderModel _decode(Map<String, dynamic> value) {
    final service = AppRepository.services.firstWhere((item) => item.id == value['serviceId']);
    final address = value['address'] as Map<String, dynamic>;
    return OrderModel(
      id: value['id'] as String, referenceNumber: 'SAL-${(value['id'] as String).substring(0, 8).toUpperCase()}',
      service: service, description: value['description'] as String,
      address: CustomerAddress(id: 'order_${value['id']}', label: address['label'] as String,
        fullAddress: address['fullAddress'] as String, latitude: (address['latitude'] as num).toDouble(),
        longitude: (address['longitude'] as num).toDouble()),
      status: OrderStatus.submitted, createdAt: DateTime.parse(value['createdAt'] as String),
      finalPrice: value['amount'] == null ? null : (value['amount'] as num).toDouble() / 100,
      isPaid: value['paid'] == true,
    );
  }

  Future<List<OrderModel>> load() async {
    final result = await _api.request('GET', '/orders');
    return (result['orders'] as List).map((value) => _decode(value as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> create(ServiceItem service, CustomerAddress address, String description) async {
    final value = await _api.request('POST', '/orders', {
      'serviceId': service.id, 'description': description,
      'address': {'label': address.label, 'fullAddress': address.fullAddress,
        'latitude': address.latitude, 'longitude': address.longitude},
    });
    return _decode(value);
  }
}
