import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AnimatedBackgroundOrbs extends StatefulWidget {
  const AnimatedBackgroundOrbs({super.key});

  @override
  State<AnimatedBackgroundOrbs> createState() => _AnimatedBackgroundOrbsState();
}

class _AnimatedBackgroundOrbsState extends State<AnimatedBackgroundOrbs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orb1 = isDark ? AppTheme.darkOrb1 : AppTheme.lightOrb1;
    final orb2 = isDark ? AppTheme.darkOrb2 : AppTheme.lightOrb2;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final val = _controller.value;
          return SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Top left orb moves slightly down and right
                Positioned(
                  top: -80 + (val * 40),
                  left: -60 + (val * 30),
                  child: _glowOrb(280 + (val * 20), orb1),
                ),
                // Middle right orb moves slightly left and down
                Positioned(
                  top: 200 + (val * 50),
                  right: -100 + (val * 60),
                  child: _glowOrb(320 - (val * 10), orb2),
                ),
                // Bottom left orb moves up
                Positioned(
                  bottom: 100 + (val * 40),
                  left: -40 - (val * 20),
                  child: _glowOrb(240 + (val * 30), orb1.withAlpha(80)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _glowOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: const SizedBox.expand(),
      ),
    );
  }
}
