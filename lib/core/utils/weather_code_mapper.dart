import 'package:flutter/material.dart';

class WeatherInfo {
  final String description;
  final IconData icon;

  WeatherInfo(this.description, this.icon);
}

class WeatherCodeMapper {
  static WeatherInfo getWeatherInfo(int code) {
    switch (code) {
      case 0:
        return WeatherInfo('Clear sky', Icons.wb_sunny);
      case 1:
        return WeatherInfo('Mainly clear', Icons.wb_sunny_outlined);
      case 2:
        return WeatherInfo('Partly cloudy', Icons.cloud_queue);
      case 3:
        return WeatherInfo('Overcast', Icons.cloud);
      case 45:
      case 48:
        return WeatherInfo('Fog', Icons.foggy);
      case 51:
      case 53:
      case 55:
        return WeatherInfo('Drizzle', Icons.grain);
      case 56:
      case 57:
        return WeatherInfo('Freezing Drizzle', Icons.ac_unit);
      case 61:
      case 63:
      case 65:
        return WeatherInfo('Rain', Icons.water_drop);
      case 66:
      case 67:
        return WeatherInfo('Freezing Rain', Icons.ac_unit);
      case 71:
      case 73:
      case 75:
        return WeatherInfo('Snow fall', Icons.ac_unit);
      case 77:
        return WeatherInfo('Snow grains', Icons.ac_unit);
      case 80:
      case 81:
      case 82:
        return WeatherInfo('Rain showers', Icons.water_drop_outlined);
      case 85:
      case 86:
        return WeatherInfo('Snow showers', Icons.ac_unit);
      case 95:
        return WeatherInfo('Thunderstorm', Icons.thunderstorm);
      case 96:
      case 99:
        return WeatherInfo('Thunderstorm with hail', Icons.thunderstorm);
      default:
        return WeatherInfo('Unknown', Icons.help_outline);
    }
  }
}
