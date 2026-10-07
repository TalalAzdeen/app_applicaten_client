import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled1/data/models/service_model.dart';
import 'package:untitled1/features/location/services/address_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('selected coordinates and reported accuracy survive reloading', () async {
    final store = AddressStore();
    await store.save([const CustomerAddress(id: 'local_test', label: 'Home', fullAddress: 'Building 7',
      latitude: 25.125, longitude: 47.875, accuracyMeters: 8)]);
    final loaded = await AddressStore().load();
    expect(loaded, hasLength(1));
    expect(loaded.single.latitude, 25.125);
    expect(loaded.single.longitude, 47.875);
    expect(loaded.single.accuracyMeters, 8);
  });
  test('malformed address entries do not prevent loading', () async {
    SharedPreferences.setMockInitialValues({'saved_addresses_v1': '[1, null, {}, {"latitude": 100}]'});
    expect(await AddressStore().load(), isEmpty);
  });
  test('corrupt local storage does not prevent app startup', () async {
    SharedPreferences.setMockInitialValues({'saved_addresses_v1': 'invalid JSON'});
    expect(await AddressStore().load(), isEmpty);
  });
}
