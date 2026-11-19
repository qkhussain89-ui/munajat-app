import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _latKey = 'user_latitude';
  static const String _lngKey = 'user_longitude';
  static const String _cityKey = 'user_city';
  static const String _sourceKey = 'location_source';
  static const String _permissionAskedKey = 'location_permission_asked';

  // Didcot, UK fallback
  static const double fallbackLat = 51.6095;
  static const double fallbackLng = -1.2401;

  /// Request GPS permission and get location. Call this ONCE after user is
  /// authenticated and on the home screen. Shows the iOS/Android permission dialog.
  /// Returns true if location was obtained, false if denied/failed.
  static Future<bool> requestAndSaveLocation() async {
    final prefs = await SharedPreferences.getInstance();

    // Mark that we've asked (so we don't ask again)
    await prefs.setBool(_permissionAskedKey, true);

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      await saveLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        source: 'gps',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Save location to SharedPreferences.
  static Future<void> saveLocation({
    required double latitude,
    required double longitude,
    String city = '',
    String source = 'gps',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, latitude);
    await prefs.setDouble(_lngKey, longitude);
    await prefs.setString(_cityKey, city);
    await prefs.setString(_sourceKey, source);
  }

  /// Get saved location, or fallback to Didcot.
  /// This NEVER triggers a permission request.
  static Future<({double lat, double lng})> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey) ?? fallbackLat;
    final lng = prefs.getDouble(_lngKey) ?? fallbackLng;
    return (lat: lat, lng: lng);
  }

  /// Check if we've already asked for location permission.
  static Future<bool> hasAskedPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionAskedKey) ?? false;
  }

  /// Check if user has a saved GPS location (not fallback).
  static Future<bool> hasStoredLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_latKey);
  }
}
