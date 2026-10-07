import '../models/weather_data.dart';
import '../models/location_data.dart';
import '../services/weather_service.dart';

class WeatherRepository {
  final WeatherService _weatherService;

  WeatherRepository({WeatherService? weatherService}) 
      : _weatherService = weatherService ?? WeatherService();

  Future<WeatherData> getWeather(double lat, double lon) {
    return _weatherService.getWeatherData(lat, lon);
  }

  Future<List<LocationData>> searchLocations(String query) {
    return _weatherService.searchLocations(query);
  }
}
