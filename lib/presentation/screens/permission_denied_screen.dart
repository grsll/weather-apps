import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/liquid_glass_card.dart';
import '../widgets/animated_background_orbs.dart';

class PermissionDeniedScreen extends StatelessWidget {
  final VoidCallback onSearchManually;

  const PermissionDeniedScreen({super.key, required this.onSearchManually});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppTheme.darkBgGradient : AppTheme.lightBgGradient;
    final textColor = isDark ? Colors.white : AppTheme.textLight;
    final mutedColor = isDark ? Colors.white54 : AppTheme.mutedTextLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          children: [
            const AnimatedBackgroundOrbs(),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withAlpha(30),
                  ),
                  child: const Icon(
                    Icons.location_off_rounded,
                    size: 56,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Location Access\nNeeded',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'To show your local weather, we need access to your location. You can also search for a city manually.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: mutedColor,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),

                // Grant permission button
                GestureDetector(
                  onTap: () async {
                    await Geolocator.openAppSettings();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.deepPrimary],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(100),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Open Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Search manually button
                GestureDetector(
                  onTap: onSearchManually,
                  child: LiquidGlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Search a City Manually',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
      ],
      ),
      ),
    );
  }
}
