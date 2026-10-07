import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import '../../data/models/weather_data.dart';
import '../../data/models/location_data.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/services/local_storage_service.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../core/utils/temp_converter.dart';
import 'settings_controller.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main');
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(ref.watch(sharedPreferencesProvider));
});

class LocationNotifier extends Notifier<LocationData?> {
  @override
  LocationData? build() {
    return ref.watch(localStorageProvider).getCurrentLocation();
  }
  
  void updateLocation(LocationData data) {
    state = data;
    ref.read(localStorageProvider).saveCurrentLocation(data);
  }
}

final currentLocationProvider = NotifierProvider<LocationNotifier, LocationData?>(() {
  return LocationNotifier();
});
final weatherControllerProvider = AsyncNotifierProvider<WeatherController, WeatherData?>(() {
  return WeatherController();
});

class WeatherController extends AsyncNotifier<WeatherData?> {
  @override
  Future<WeatherData?> build() async {
    final location = ref.watch(currentLocationProvider);
    final lat = location?.latitude ?? -6.2088;
    final lon = location?.longitude ?? 106.8456;
    
    final weather = await _fetchWeather(lat, lon);
    _updateWidget(weather, location);
    return weather;
  }

  Future<WeatherData> _fetchWeather(double lat, double lon) async {
    final repo = ref.read(weatherRepositoryProvider);
    return await repo.getWeather(lat, lon);
  }

  Future<void> _updateWidget(WeatherData weather, LocationData? location) async {
    final unit = ref.read(temperatureUnitProvider);
    final tempStr = TempConverter.formatShort(weather.temperature, unit);
    final info = WeatherCodeMapper.getWeatherInfo(weather.weatherCode);
    final locName = location?.name ?? 'Jakarta';

    await HomeWidget.saveWidgetData<String>('widget_location', locName);
    await HomeWidget.saveWidgetData<String>('widget_temperature', tempStr);
    await HomeWidget.saveWidgetData<String>('widget_description', info.description);
    await HomeWidget.updateWidget(
      name: 'WeatherWidgetProvider',
      androidName: 'WeatherWidgetProvider',
    );
  }

  Future<void> refresh() async {
    final location = ref.read(currentLocationProvider);
    state = const AsyncValue.loading();
    try {
      final lat = location?.latitude ?? -6.2088;
      final lon = location?.longitude ?? 106.8456;
      final weather = await _fetchWeather(lat, lon);
      _updateWidget(weather, location);
      state = AsyncValue.data(weather);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateLocation(LocationData newLocation) {
    ref.read(currentLocationProvider.notifier).updateLocation(newLocation);
  }
}
