
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Konum servisinin açık ve iznin verilmiş
  // olup olmadığını kontrol eder.
  Future<bool> checkLocationPermission() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    final permission = await Geolocator.checkPermission();

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Kullanıcı hareket etmese bile mevcut GPS konumunu alır.
  Future<Position> getCurrentLocation() async {
    final hasPermission = await checkLocationPermission();

    if (!hasPermission) {
      throw StateError(
        'Konum servisi kapalı veya konum izni verilmemiş.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  // Kullanıcı yürüdükçe canlı GPS konumlarını sağlar.
  Stream<Position> getLocationStream() async* {
    final hasPermission = await checkLocationPermission();

    if (!hasPermission) {
      throw StateError(
        'GPS takibi için konum izni gerekiyor.',
      );
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    yield* Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  // İki koordinat arasındaki mesafeyi metre cinsinden hesaplar.
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
