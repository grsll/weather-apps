import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/weather_controller.dart';
import '../../core/utils/temp_converter.dart';

// ─── Temperature Unit ─────────────────────────────────────────────────────────
class TemperatureUnitNotifier extends Notifier<TemperatureUnit> {
  @override
  TemperatureUnit build() {
    final stored = ref.watch(localStorageProvider).getTemperatureUnit();
    return stored == 'F' ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius;
  }

  void setUnit(TemperatureUnit unit) {
    state = unit;
    ref.read(localStorageProvider).saveTemperatureUnit(
          unit == TemperatureUnit.fahrenheit ? 'F' : 'C',
        );
  }
}

final temperatureUnitProvider =
    NotifierProvider<TemperatureUnitNotifier, TemperatureUnit>(
        TemperatureUnitNotifier.new);

// ─── Theme Mode ───────────────────────────────────────────────────────────────
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final stored = ref.watch(localStorageProvider).getThemeMode();
    switch (stored) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setMode(ThemeMode mode) {
    state = mode;
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
      case ThemeMode.dark:
        value = 'dark';
      default:
        value = 'system';
    }
    ref.read(localStorageProvider).saveThemeModeString(value);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
