import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../models/location_data.dart';

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
  @override
  String toString() => message;
}

class WeatherService {
  final http.Client _client;
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherData> getWeatherData(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature'
      ',is_day,weather_code,wind_speed_10m,wind_direction_10m'
      ',surface_pressure,visibility'
      '&hourly=temperature_2m,weather_code,wind_speed_10m,precipitation_probability'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min'
      ',sunrise,sunset,uv_index_max,precipitation_probability_max'
      '&timezone=auto'
      '&forecast_days=7',
    );

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return WeatherData.fromJson(json.decode(response.body));
      } else {
        throw WeatherException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('Network error. Check your connection.');
    }
  }

  Future<List<LocationData>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(query)}&count=10&language=en&format=json',
    );
    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        return results.map((j) => LocationData.fromJson(j)).toList();
      } else {
        throw WeatherException('Location search failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('Network error while searching locations.');
    }
  }
}
