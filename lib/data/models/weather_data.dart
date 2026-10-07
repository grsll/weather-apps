class WeatherData {
  final double temperature;
  final double feelsLike;
  final int weatherCode;
  final double humidity;
  final double windSpeed;
  final double windDirection;
  final double uvIndex;
  final double visibility;
  final double pressure;
  final bool isDay;
  final String? sunrise;
  final String? sunset;
  final double highTemp;
  final double lowTemp;
  final int precipitationProbability;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeed,
    this.windDirection = 0,
    this.uvIndex = 0.0,
    required this.visibility,
    this.pressure = 0.0,
    this.isDay = true,
    this.sunrise,
    this.sunset,
    required this.highTemp,
    required this.lowTemp,
    this.precipitationProbability = 0,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final hourly = json['hourly'] as Map<String, dynamic>? ?? {};
    final daily = json['daily'] as Map<String, dynamic>? ?? {};

    // ── Hourly ──────────────────────────────────────────────────────────────
    List<HourlyForecast> parsedHourly = [];
    final hTimes = hourly['time'] as List?;
    final hTemps = hourly['temperature_2m'] as List?;
    final hCodes = hourly['weather_code'] as List?;
    final hWind = hourly['wind_speed_10m'] as List?;
    final hPrecip = hourly['precipitation_probability'] as List?;

    if (hTimes != null && hTemps != null && hCodes != null) {
      final now = DateTime.now();
      int startIndex = 0;
      for (int i = 0; i < hTimes.length; i++) {
        final t = DateTime.tryParse(hTimes[i].toString());
        if (t != null && t.isAfter(now.subtract(const Duration(minutes: 30)))) {
          startIndex = i;
          break;
        }
      }
      for (int i = startIndex; i < startIndex + 24 && i < hTimes.length; i++) {
        parsedHourly.add(HourlyForecast(
          time: DateTime.tryParse(hTimes[i].toString()) ?? DateTime.now(),
          temperature: (hTemps[i] as num).toDouble(),
          weatherCode: (hCodes[i] as num).toInt(),
          windSpeed: hWind != null ? (hWind[i] as num).toDouble() : 0,
          precipitationProbability:
              hPrecip != null ? (hPrecip[i] as num).toInt() : 0,
        ));
      }
    }

    // ── Daily ───────────────────────────────────────────────────────────────
    List<DailyForecast> parsedDaily = [];
    final dTimes = daily['time'] as List?;
    final dMax = daily['temperature_2m_max'] as List?;
    final dMin = daily['temperature_2m_min'] as List?;
    final dCodes = daily['weather_code'] as List?;
    final dSunrise = daily['sunrise'] as List? ?? [];
    final dSunset = daily['sunset'] as List? ?? [];
    final dUV = daily['uv_index_max'] as List?;
    final dPrecip = daily['precipitation_probability_max'] as List?;

    if (dTimes != null && dMax != null && dMin != null && dCodes != null) {
      for (int i = 0; i < dTimes.length; i++) {
        parsedDaily.add(DailyForecast(
          date: DateTime.tryParse(dTimes[i].toString()) ?? DateTime.now(),
          maxTemp: (dMax[i] as num).toDouble(),
          minTemp: (dMin[i] as num).toDouble(),
          weatherCode: (dCodes[i] as num).toInt(),
          sunrise: dSunrise.length > i ? dSunrise[i].toString() : null,
          sunset: dSunset.length > i ? dSunset[i].toString() : null,
          uvIndex: dUV != null ? (dUV[i] as num).toDouble() : 0,
          precipitationProbability:
              dPrecip != null ? (dPrecip[i] as num).toInt() : 0,
        ));
      }
    }

    final uvToday = (dUV?.isNotEmpty == true) ? (dUV![0] as num).toDouble() : 0.0;

    return WeatherData(
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      feelsLike: (current['apparent_temperature'] as num?)?.toDouble() ?? 0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      humidity: (current['relative_humidity_2m'] as num?)?.toDouble() ?? 0,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      windDirection: (current['wind_direction_10m'] as num?)?.toDouble() ?? 0,
      visibility: (current['visibility'] as num?)?.toDouble() ?? 0,
      pressure: (current['surface_pressure'] as num?)?.toDouble() ?? 0,
      isDay: (current['is_day'] as num?)?.toInt() == 1,
      highTemp: parsedDaily.isNotEmpty ? parsedDaily.first.maxTemp : 0,
      lowTemp: parsedDaily.isNotEmpty ? parsedDaily.first.minTemp : 0,
      uvIndex: uvToday,
      sunrise: parsedDaily.isNotEmpty ? parsedDaily.first.sunrise : null,
      sunset: parsedDaily.isNotEmpty ? parsedDaily.first.sunset : null,
      precipitationProbability:
          parsedDaily.isNotEmpty ? parsedDaily.first.precipitationProbability : 0,
      hourlyForecast: parsedHourly,
      dailyForecast: parsedDaily,
    );
  }

  /// Cardinal direction from degrees
  String get windDirectionLabel {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((windDirection + 22.5) / 45).floor() % 8;
    return dirs[idx];
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final double windSpeed;
  final int precipitationProbability;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    this.windSpeed = 0,
    this.precipitationProbability = 0,
  });
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final String? sunrise;
  final String? sunset;
  final double uvIndex;
  final int precipitationProbability;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    this.sunrise,
    this.sunset,
    this.uvIndex = 0,
    this.precipitationProbability = 0,
  });
}
