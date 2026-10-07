import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/animated_background_orbs.dart';
import 'home_screen.dart';
import 'locations_screen.dart';
import 'settings_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LocationsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppTheme.darkBgGradient : AppTheme.lightBgGradient;

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          const AnimatedBackgroundOrbs(),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                extendBody: true,
                body: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
                bottomNavigationBar: Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  height: 72,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withAlpha(20) : Colors.white.withAlpha(180),
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(
                            color: isDark ? Colors.white.withAlpha(40) : Colors.white.withAlpha(200),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 100 : 20),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _NavItem(
                              icon: Icons.grid_view_rounded,
                              label: 'Home',
                              isSelected: _currentIndex == 0,
                              onTap: () => setState(() => _currentIndex = 0),
                            ),
                            _NavItem(
                              icon: Icons.location_on_rounded,
                              label: 'Locations',
                              isSelected: _currentIndex == 1,
                              onTap: () => setState(() => _currentIndex = 1),
                            ),
                            _NavItem(
                              icon: Icons.settings_rounded,
                              label: 'Settings',
                              isSelected: _currentIndex == 2,
                              onTap: () => setState(() => _currentIndex = 2),
                            ),
                          ],
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? AppTheme.primary
        : (isDark ? Colors.white54 : AppTheme.mutedTextLight);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        height: double.infinity,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(isSelected ? 10 : 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withAlpha(30)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: isSelected ? 26 : 24),
        ),
      ),
    );
  }
}
