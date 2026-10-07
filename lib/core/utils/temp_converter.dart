enum TemperatureUnit { celsius, fahrenheit }

class TempConverter {
  static double convert(double celsius, TemperatureUnit unit) {
    if (unit == TemperatureUnit.fahrenheit) {
      return celsius * 9 / 5 + 32;
    }
    return celsius;
  }

  static String format(double celsius, TemperatureUnit unit) {
    final value = convert(celsius, unit).round();
    final symbol = unit == TemperatureUnit.fahrenheit ? '°F' : '°';
    return '$value$symbol';
  }

  static String formatShort(double celsius, TemperatureUnit unit) {
    return '${convert(celsius, unit).round()}°';
  }
}
