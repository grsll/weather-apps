import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/weather_controller.dart';
import '../controllers/saved_locations_controller.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/animated_background_orbs.dart';
import '../../data/models/location_data.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final bool showSaveButton;

  const SearchScreen({super.key, this.showSaveButton = false});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  List<LocationData> _results = [];
  bool _isLoading = false;

  void _search(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(weatherRepositoryProvider);
      final results = await repo.searchLocations(query);
      if (mounted) setState(() => _results = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppTheme.darkBgGradient : AppTheme.lightBgGradient;
    final textColor = isDark ? Colors.white : AppTheme.textLight;
    final mutedColor = isDark ? Colors.white60 : AppTheme.mutedTextLight;

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
                  child: Column(
                    children: [
                      // ─── Glass Search Bar ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(20)
                            : Colors.white.withAlpha(160),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withAlpha(40)
                              : Colors.white.withAlpha(220),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded,
                              color: isDark ? Colors.white60 : AppTheme.mutedTextLight),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: TextStyle(color: textColor, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Search city...',
                                hintStyle: TextStyle(color: mutedColor),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: _search,
                              textInputAction: TextInputAction.search,
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _search('');
                              },
                              child: Icon(Icons.close_rounded,
                                  size: 20,
                                  color: isDark ? Colors.white54 : AppTheme.mutedTextLight),
                            ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Results ───────────────────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.primary),
                      )
                    : _results.isEmpty
                        ? _buildEmptyState(isDark, mutedColor)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final location = _results[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (widget.showSaveButton) {
                                          ref
                                              .read(savedLocationsProvider.notifier)
                                              .addLocation(location);
                                          Navigator.pop(context);
                                        } else {
                                          ref
                                              .read(currentLocationProvider.notifier)
                                              .updateLocation(location);
                                          ref
                                              .read(weatherControllerProvider.notifier)
                                              .refresh();
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withAlpha(18)
                                              : Colors.white.withAlpha(140),
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white.withAlpha(30)
                                                : Colors.white.withAlpha(220),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primary.withAlpha(30),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.location_city_rounded,
                                                color: AppTheme.primary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    location.name,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      color: textColor,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    [location.admin1, location.country]
                                                        .where((s) =>
                                                            s != null && s.isNotEmpty)
                                                        .join(', '),
                                                    style: TextStyle(
                                                      color: mutedColor,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              widget.showSaveButton
                                                  ? Icons.add_circle_outline_rounded
                                                  : Icons.chevron_right_rounded,
                                              color: widget.showSaveButton
                                                  ? AppTheme.primary
                                                  : mutedColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ), // Expanded
            ],
          ), // Column
        ), // SafeArea
      ), // ConstrainedBox
      ), // Center
      ], // Stack children
      ), // Stack
      ), // Container
    ); // Scaffold
  }

  Widget _buildEmptyState(bool isDark, Color mutedColor) {
    final hasTyped = _searchController.text.isNotEmpty;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasTyped ? Icons.search_off_rounded : Icons.travel_explore_rounded,
            size: 64,
            color: AppTheme.primary.withAlpha(120),
          ),
          const SizedBox(height: 16),
          Text(
            hasTyped ? 'No cities found' : 'Search for a city',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasTyped
                ? 'Try a different name'
                : 'Enter a city name above to\nget the weather forecast',
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedColor, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
