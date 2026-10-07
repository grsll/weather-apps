import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/saved_locations_controller.dart';
import '../controllers/weather_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/liquid_glass_card.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../core/utils/temp_converter.dart';
import '../../data/models/location_data.dart';
import 'search_screen.dart';

class LocationsScreen extends ConsumerWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedLocations = ref.watch(savedLocationsProvider);
    final currentLocation = ref.watch(currentLocationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : AppTheme.textLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Locations',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  _glassButton(
                    context,
                    icon: Icons.add_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(showSaveButton: true),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Current Location Card ───────────────────────────────────
            if (currentLocation != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _CurrentLocationCard(location: currentLocation),
              ),

            const SizedBox(height: 12),

            // ─── Saved List ──────────────────────────────────────────────
            Expanded(
              child: savedLocations.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: savedLocations.length,
                      itemBuilder: (context, index) {
                        final loc = savedLocations[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: ValueKey('${loc.latitude}-${loc.longitude}'),
                            direction: DismissDirection.endToStart,
                            background: _deleteBackground(),
                            confirmDismiss: (_) => _confirmDelete(context),
                            onDismissed: (_) {
                              ref
                                  .read(savedLocationsProvider.notifier)
                                  .removeLocation(loc);
                            },
                            child: _SavedLocationCard(
                              location: loc,
                              onTap: () {
                                ref
                                    .read(currentLocationProvider.notifier)
                                    .updateLocation(loc);
                                ref
                                    .read(weatherControllerProvider.notifier)
                                    .refresh();
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassButton(BuildContext context,
      {required IconData icon, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(25)
                  : Colors.white.withAlpha(160),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(50)
                    : Colors.white.withAlpha(220),
                width: 1.2,
              ),
            ),
            child: Icon(icon,
                size: 22,
                color: isDark ? Colors.white : AppTheme.deepPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_location_alt_rounded,
            size: 72,
            color: AppTheme.primary.withAlpha(120),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved locations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a city',
            style: TextStyle(
              color: isDark ? Colors.white38 : AppTheme.mutedTextLight,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(200),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Location'),
        content: const Text('Remove this city from your saved locations?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Current Location Card ─────────────────────────────────────────────────
class _CurrentLocationCard extends ConsumerWidget {
  final LocationData location;
  const _CurrentLocationCard({required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync =
        ref.watch(locationWeatherProvider(location));
    final unit = ref.watch(temperatureUnitProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary.withAlpha(isDark ? 100 : 180),
                AppTheme.deepPrimary.withAlpha(isDark ? 150 : 220),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withAlpha(60),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.my_location_rounded,
                            color: Colors.white70, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Current Location',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              weatherAsync.when(
                data: (w) {
                  final info =
                      WeatherCodeMapper.getWeatherInfo(w.weatherCode);
                  return Row(
                    children: [
                      Icon(info.icon, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        TempConverter.formatShort(w.temperature, unit),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white54,
                    strokeWidth: 2,
                  ),
                ),
                error: (_, stack) =>
                    const Icon(Icons.cloud_off, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Saved Location Card ───────────────────────────────────────────────────
class _SavedLocationCard extends ConsumerWidget {
  final LocationData location;
  final VoidCallback onTap;
  const _SavedLocationCard({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(locationWeatherProvider(location));
    final unit = ref.watch(temperatureUnitProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textLight;
    final mutedColor = isDark ? Colors.white54 : AppTheme.mutedTextLight;

    return GestureDetector(
      onTap: onTap,
      child: LiquidGlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  weatherAsync.when(
                    data: (w) {
                      final info =
                          WeatherCodeMapper.getWeatherInfo(w.weatherCode);
                      return Text(
                        info.description,
                        style: TextStyle(fontSize: 13, color: mutedColor),
                      );
                    },
                    loading: () => Text('Loading...',
                        style: TextStyle(fontSize: 13, color: mutedColor)),
                    error: (_, stack) => Text('Unavailable',
                        style: TextStyle(fontSize: 13, color: mutedColor)),
                  ),
                ],
              ),
            ),
            weatherAsync.when(
              data: (w) {
                final info =
                    WeatherCodeMapper.getWeatherInfo(w.weatherCode);
                return Row(
                  children: [
                    Icon(info.icon, color: AppTheme.primary, size: 26),
                    const SizedBox(width: 10),
                    Text(
                      TempConverter.formatShort(w.temperature, unit),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.primary),
              ),
              error: (_, stack) =>
                  const Icon(Icons.cloud_off, color: Colors.grey),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: mutedColor, size: 20),
          ],
        ),
      ),
    );
  }
}
