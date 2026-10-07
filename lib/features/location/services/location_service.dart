import 'package:geolocator/geolocator.dart';

class LocationFailure implements Exception {
  final String message;
  final bool openSettings;
  const LocationFailure(this.message, {this.openSettings = false});
}

class LocationService {
  Future<Position> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure('خدمة الموقع متوقفة. فعّلها ثم أعد المحاولة.', openSettings: true);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure('إذن الموقع محظور. فعّله من إعدادات التطبيق.', openSettings: true);
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure('لم تمنح إذن الموقع. يمكنك اختيار الموقع يدويًا.');
    }
    return Geolocator.getCurrentPosition(locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 20),
    ));
  }
}
