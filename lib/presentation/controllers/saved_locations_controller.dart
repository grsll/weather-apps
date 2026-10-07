import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/weather_controller.dart';
import '../../data/models/location_data.dart';
import '../../data/models/weather_data.dart';

// ─── Saved Locations List ─────────────────────────────────────────────────────
class SavedLocationsNotifier extends Notifier<List<LocationData>> {
  @override
  List<LocationData> build() {
    return ref.watch(localStorageProvider).getSavedLocations();
  }

  Future<void> addLocation(LocationData location) async {
    await ref.read(localStorageProvider).addSavedLocation(location);
    state = ref.read(localStorageProvider).getSavedLocations();
  }

  Future<void> removeLocation(LocationData location) async {
    await ref.read(localStorageProvider).removeSavedLocation(location);
    state = ref.read(localStorageProvider).getSavedLocations();
  }

  bool isSaved(LocationData location) {
    return state.any(
      (l) => l.latitude == location.latitude && l.longitude == location.longitude,
    );
  }
}

final savedLocationsProvider =
    NotifierProvider<SavedLocationsNotifier, List<LocationData>>(
        SavedLocationsNotifier.new);

// ─── Per-Location Weather (family provider) ───────────────────────────────────
final locationWeatherProvider =
    FutureProvider.family<WeatherData, LocationData>((ref, location) async {
  final repo = ref.read(weatherRepositoryProvider);
  return repo.getWeather(location.latitude, location.longitude);
});
