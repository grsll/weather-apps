import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/weather_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/liquid_glass_card.dart';
import '../widgets/temperature_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/weather_code_mapper.dart';
import '../../core/utils/temp_converter.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherControllerProvider);
    final location = ref.watch(currentLocationProvider);
    final locationName = location?.name ?? 'Jakarta';
    final unit = ref.watch(temperatureUnitProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: Colors.white.withAlpha(200),
          onRefresh: () => ref.read(weatherControllerProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, locationName),
                  const SizedBox(height: 24),
                  weatherState.when(
                    data: (weather) {
                      if (weather == null) {
                        return const Center(child: Text('No data'));
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWeatherHero(context, weather, unit),
                          const SizedBox(height: 20),
                          _buildHourlyForecast(context, weather, unit),
                          const SizedBox(height: 24),
                          TemperatureChart(hourlyData: weather.hourlyForecast, unit: unit),
                          const SizedBox(height: 24),
                          _buildDailyForecast(context, weather, unit),
                          const SizedBox(height: 20),
                          _buildWeatherDetails(context, weather),
                          const SizedBox(height: 100), // padding for bottom nav
                        ],
                      );
                    },
                    loading: () => _buildLoadingSkeleton(context),
                    error: (e, st) => _buildError(context, ref, e),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Background Orbs ─────────────────────────────────────────────────────
  // ─── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, String locationName) {
    final now = DateTime.now();
    final dateString = DateFormat('EEEE, d MMMM').format(now);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textLight;
    final mutedColor = isDark ? AppTheme.mutedTextDark : AppTheme.mutedTextLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 18, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  locationName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                dateString,
                style: TextStyle(
                  fontSize: 13,
                  color: mutedColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        _glassIconButton(
          context,
          icon: Icons.search_rounded,
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, b) => const SearchScreen(),
              transitionsBuilder: (_, anim, b, child) => FadeTransition(
                opacity: anim,
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassIconButton(BuildContext context, {required IconData icon, required VoidCallback onTap}) {
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
              color: isDark ? Colors.white.withAlpha(25) : Colors.white.withAlpha(160),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withAlpha(50) : Colors.white.withAlpha(220),
                width: 1.2,
              ),
            ),
            child: Icon(icon, size: 20, color: isDark ? Colors.white : AppTheme.deepPrimary),
          ),
        ),
      ),
    );
  }

  // ─── Weather Hero ─────────────────────────────────────────────────────────
  Widget _buildWeatherHero(BuildContext context, weather, TemperatureUnit unit) {
    final info = WeatherCodeMapper.getWeatherInfo(weather.weatherCode);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textLight;
    final mutedColor = isDark ? Colors.white60 : AppTheme.mutedTextLight;

    return LiquidGlassCard(
      borderRadius: 32,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        children: [
          // Big weather icon with subtle glow
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(80),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              Icon(info.icon, size: 80, color: isDark ? Colors.white : AppTheme.deepPrimary),
            ],
          ),
          const SizedBox(height: 20),

          // Temperature — the star of the show
          Text(
            TempConverter.format(weather.temperature, unit),
            style: TextStyle(
              fontSize: 96,
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 1.0,
              letterSpacing: -4,
            ),
          ),
          const SizedBox(height: 8),

          // Condition
          Text(
            info.description,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: textColor.withAlpha(200),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),

          // Feels like
          Text(
            'Feels like ${TempConverter.formatShort(weather.feelsLike, unit)}',
            style: TextStyle(
              fontSize: 14,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Divider(color: isDark ? Colors.white24 : Colors.black12),
          const SizedBox(height: 12),

          // High / Low
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tempBadge(context, 'H', TempConverter.formatShort(weather.highTemp, unit), Colors.orange),
              const SizedBox(width: 24),
              _tempBadge(context, 'L', TempConverter.formatShort(weather.lowTemp, unit), Colors.lightBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tempBadge(BuildContext context, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  // ─── Hourly Forecast ──────────────────────────────────────────────────────
  Widget _buildHourlyForecast(BuildContext context, weather, TemperatureUnit unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Hourly Forecast',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weather.hourlyForecast.length,
            itemBuilder: (context, index) {
              final forecast = weather.hourlyForecast[index];
              final info = WeatherCodeMapper.getWeatherInfo(forecast.weatherCode);
              final timeString = DateFormat('HH:mm').format(forecast.time);
              final isNow = index == 0;
              final tempStr = TempConverter.formatShort(forecast.temperature, unit);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 72,
                margin: const EdgeInsets.only(right: 10),
                child: isNow
                    ? _activeHourlyCard(context, timeString, info.icon, tempStr)
                    : _inactiveHourlyCard(context, timeString, info.icon, tempStr),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _activeHourlyCard(BuildContext context, String time, IconData icon, String tempStr) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primary, AppTheme.deepPrimary],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(120),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 8),
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 8),
          Text(
            tempStr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inactiveHourlyCard(BuildContext context, String time, IconData icon, String tempStr) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textLight;
    final mutedColor = isDark ? Colors.white54 : AppTheme.mutedTextLight;
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(18) : Colors.white.withAlpha(110),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(35) : Colors.white.withAlpha(200),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(time, style: TextStyle(fontSize: 11, color: mutedColor)),
              const SizedBox(height: 8),
              Icon(icon, color: AppTheme.primary, size: 22),
              const SizedBox(height: 8),
              Text(
                tempStr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Daily Forecast ───────────────────────────────────────────────────────
  Widget _buildDailyForecast(BuildContext context, weather, TemperatureUnit unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textLight;
    final mutedColor = isDark ? Colors.white54 : AppTheme.mutedTextLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '7-Day Forecast',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
        ),
        LiquidGlassCard(
          borderRadius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: List.generate(
              weather.dailyForecast.length,
              (index) {
                final forecast = weather.dailyForecast[index];
                final info = WeatherCodeMapper.getWeatherInfo(forecast.weatherCode);
                final dateString =
                    index == 0 ? 'Today' : DateFormat('EEE').format(forecast.date);
                final isLast = index == weather.dailyForecast.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 56,
                            child: Text(
                              dateString,
                              style: TextStyle(
                                fontWeight: index == 0 ? FontWeight.w700 : FontWeight.w500,
                                color: index == 0 ? AppTheme.primary : textColor,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Icon(info.icon, color: AppTheme.primary, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              info.description,
                              style: TextStyle(fontSize: 13, color: mutedColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            TempConverter.formatShort(forecast.minTemp, unit),
                            style: TextStyle(
                              color: Colors.lightBlue.shade300,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            TempConverter.formatShort(forecast.maxTemp, unit),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: isDark ? Colors.white12 : Colors.black.withAlpha(15),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─── Weather Details ──────────────────────────────────────────────────────
  Widget _buildWeatherDetails(BuildContext context, weather) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _buildDetailCard(context, Icons.water_drop_rounded, 'Humidity',
                '${weather.humidity.round()}%', Colors.blue),
            _buildDetailCard(context, Icons.air_rounded, 'Wind',
                '${weather.windSpeed.toStringAsFixed(1)} km/h', Colors.cyan),
            _buildDetailCard(context, Icons.wb_sunny_rounded, 'UV Index',
                _uvLabel(weather.uvIndex), Colors.orange),
            _buildDetailCard(context, Icons.visibility_rounded, 'Visibility',
                '${(weather.visibility / 1000).toStringAsFixed(1)} km', Colors.teal),
          ],
        ),
      ],
    );
  }

  String _uvLabel(double uv) {
    if (uv <= 2) return '${uv.toStringAsFixed(0)} Low';
    if (uv <= 5) return '${uv.toStringAsFixed(0)} Moderate';
    if (uv <= 7) return '${uv.toStringAsFixed(0)} High';
    return '${uv.toStringAsFixed(0)} Very High';
  }

  Widget _buildDetailCard(
      BuildContext context, IconData icon, String title, String value, Color accentColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textLight;
    final mutedColor = isDark ? Colors.white54 : AppTheme.mutedTextLight;

    return LiquidGlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: accentColor),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Loading Skeleton ─────────────────────────────────────────────────────
  Widget _buildLoadingSkeleton(BuildContext context) {
    return Column(
      children: [
        LiquidGlassCard(
          borderRadius: 32,
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              _shimmerBox(80, 80, circle: true),
              const SizedBox(height: 16),
              _shimmerBox(100, 24),
              const SizedBox(height: 8),
              _shimmerBox(160, 16),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LiquidGlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: List.generate(
              5,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _shimmerBox(double.infinity, 90, radius: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmerBox(double width, double height, {bool circle = false, double radius = 12}) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(60),
        borderRadius: circle ? null : BorderRadius.circular(radius),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }

  // ─── Error State ──────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, WidgetRef ref, Object e) {
    return LiquidGlassCard(
      borderRadius: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            'Unable to load weather',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            e.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => ref.read(weatherControllerProvider.notifier).refresh(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.deepPrimary],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
