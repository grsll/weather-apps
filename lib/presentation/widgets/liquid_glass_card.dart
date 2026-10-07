import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable Liquid Glass card widget.
/// Uses [BackdropFilter] + [ImageFilter.blur] to create the frosted glass effect,
/// with a subtle luminous border and inner highlight.
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? tintColor;
  final double blurSigma;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.tintColor,
    this.blurSigma = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTint = isDark
        ? Colors.white.withAlpha(20)
        : Colors.white.withAlpha(100);
    final borderColor = isDark
        ? Colors.white.withAlpha(38)
        : Colors.white.withAlpha(200);
    final shadowColor = isDark
        ? Colors.black.withAlpha(100)
        : Colors.black.withAlpha(25);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: tintColor ?? defaultTint,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 32,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
