import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_data.dart';

class LocalStorageService {
  static const _savedLocationsKey = 'saved_locations';
  static const _currentLocationKey = 'current_location';
  static const _themeModeKey = 'theme_mode';
  static const _temperatureUnitKey = 'temperature_unit';

  final SharedPreferences _prefs;
  LocalStorageService(this._prefs);

  // ─── Current Location ─────────────────────────────────────────────────────
  Future<void> saveCurrentLocation(LocationData location) async {
    await _prefs.setString(_currentLocationKey, json.encode(location.toJson()));
  }

  LocationData? getCurrentLocation() {
    final str = _prefs.getString(_currentLocationKey);
    if (str != null) return LocationData.fromJson(json.decode(str));
    return null;
  }

  // ─── Saved Locations ──────────────────────────────────────────────────────
  Future<void> addSavedLocation(LocationData location) async {
    final locations = getSavedLocations();
    final alreadyExists = locations.any(
      (l) => l.latitude == location.latitude && l.longitude == location.longitude,
    );
    if (!alreadyExists) {
      locations.add(location);
      await _saveSavedLocations(locations);
    }
  }

  Future<void> removeSavedLocation(LocationData location) async {
    final locations = getSavedLocations();
    locations.removeWhere(
      (l) => l.latitude == location.latitude && l.longitude == location.longitude,
    );
    await _saveSavedLocations(locations);
  }

  List<LocationData> getSavedLocations() {
    final strList = _prefs.getStringList(_savedLocationsKey) ?? [];
    return strList
        .map((s) => LocationData.fromJson(json.decode(s)))
        .toList();
  }

  Future<void> _saveSavedLocations(List<LocationData> locations) async {
    await _prefs.setStringList(
      _savedLocationsKey,
      locations.map((l) => json.encode(l.toJson())).toList(),
    );
  }

  // ─── Theme Mode ───────────────────────────────────────────────────────────
  Future<void> saveThemeModeString(String value) async {
    await _prefs.setString(_themeModeKey, value);
  }

  String? getThemeMode() => _prefs.getString(_themeModeKey);

  // ─── Temperature Unit ─────────────────────────────────────────────────────
  Future<void> saveTemperatureUnit(String unit) async {
    await _prefs.setString(_temperatureUnitKey, unit);
  }

  String? getTemperatureUnit() => _prefs.getString(_temperatureUnitKey);
}
