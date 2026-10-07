import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/temp_converter.dart';
import '../widgets/liquid_glass_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textLight;
    final unit = ref.watch(temperatureUnitProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // ─── Temperature Unit ──────────────────────────────────────
              _sectionLabel('Units', isDark),
              LiquidGlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _SegmentRow(
                      label: 'Temperature',
                      icon: Icons.thermostat_rounded,
                      options: const ['Celsius (°C)', 'Fahrenheit (°F)'],
                      selectedIndex:
                          unit == TemperatureUnit.celsius ? 0 : 1,
                      onChanged: (i) => ref
                          .read(temperatureUnitProvider.notifier)
                          .setUnit(i == 0
                              ? TemperatureUnit.celsius
                              : TemperatureUnit.fahrenheit),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── Appearance ────────────────────────────────────────────
              _sectionLabel('Appearance', isDark),
              LiquidGlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _SegmentRow(
                      label: 'Theme',
                      icon: Icons.dark_mode_rounded,
                      options: const ['System', 'Light', 'Dark'],
                      selectedIndex: themeMode == ThemeMode.system
                          ? 0
                          : themeMode == ThemeMode.light
                              ? 1
                              : 2,
                      onChanged: (i) {
                        final modes = [
                          ThemeMode.system,
                          ThemeMode.light,
                          ThemeMode.dark
                        ];
                        ref
                            .read(themeModeProvider.notifier)
                            .setMode(modes[i]);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── About ─────────────────────────────────────────────────
              _sectionLabel('About', isDark),
              LiquidGlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.cloud_rounded,
                      title: 'Weather Data',
                      value: 'Open-Meteo (open-meteo.com)',
                      isDark: isDark,
                    ),
                    _divider(isDark),
                    _InfoTile(
                      icon: Icons.location_on_rounded,
                      title: 'Geocoding',
                      value: 'Open-Meteo Geocoding API',
                      isDark: isDark,
                    ),
                    _divider(isDark),
                    _InfoTile(
                      icon: Icons.info_rounded,
                      title: 'Version',
                      value: '1.0.0',
                      isDark: isDark,
                    ),
                    _divider(isDark),
                    _InfoTile(
                      icon: Icons.code_rounded,
                      title: 'Built with',
                      value: 'Flutter + Riverpod',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white38 : AppTheme.mutedTextLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _divider(bool isDark) => Divider(
        height: 1,
        color: isDark ? Colors.white12 : Colors.black.withAlpha(12),
      );
}

// ─── Segment Row ──────────────────────────────────────────────────────────────
class _SegmentRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> options;
  final int selectedIndex;
  final void Function(int) onChanged;

  const _SegmentRow({
    required this.label,
    required this.icon,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textLight;
    final mutedColor = isDark ? Colors.white54 : AppTheme.mutedTextLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(15)
                  : Colors.black.withAlpha(10),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: List.generate(
                options.length,
                (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selectedIndex == i
                            ? AppTheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        options[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selectedIndex == i
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selectedIndex == i
                              ? Colors.white
                              : mutedColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Tile ────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDark;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppTheme.textLight;
    final mutedColor = isDark ? Colors.white54 : AppTheme.mutedTextLight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13, color: mutedColor),
          ),
        ],
      ),
    );
  }
}
