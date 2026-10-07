import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/theme/app_theme.dart';
import 'package:weather_app/presentation/screens/main_shell.dart';

import 'package:weather_app/core/utils/location_helper.dart';
import 'package:weather_app/data/models/location_data.dart';
import 'package:weather_app/presentation/controllers/weather_controller.dart';
import 'package:weather_app/presentation/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final position = await LocationHelper.getCurrentPosition();
    if (position != null) {
      final loc = LocationData(
        name: 'Current Location',
        latitude: position.latitude,
        longitude: position.longitude,
      );
      ref.read(currentLocationProvider.notifier).updateLocation(loc);
      // Wait for build to finish then refresh weather
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(weatherControllerProvider.notifier).refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Weather App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}
