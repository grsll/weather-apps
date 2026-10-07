import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../core/theme/app_theme.dart';
import '../../data/models/weather_data.dart';
import '../../core/utils/temp_converter.dart';
import 'liquid_glass_card.dart';

class TemperatureChart extends StatelessWidget {
  final List<HourlyForecast> hourlyData;
  final TemperatureUnit unit;

  const TemperatureChart({
    super.key,
    required this.hourlyData,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    // Only take the next 24 hours to avoid a cramped chart
    final data = hourlyData.take(24).toList();
    if (data.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Temperature Trend',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.textLight,
              letterSpacing: -0.3,
            ),
          ),
        ),
        LiquidGlassCard(
          borderRadius: 32,
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _ChartPainter(
                data: data,
                unit: unit,
                isDark: isDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<HourlyForecast> data;
  final TemperatureUnit unit;
  final bool isDark;

  _ChartPainter({
    required this.data,
    required this.unit,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double width = size.width;
    final double height = size.height;

    // Find min and max temps
    double minTemp = data.map((e) => e.temperature).reduce((a, b) => a < b ? a : b);
    double maxTemp = data.map((e) => e.temperature).reduce((a, b) => a > b ? a : b);

    // Add some vertical padding to min/max to ensure lines don't hit the absolute top/bottom
    final range = maxTemp - minTemp;
    final adjustedRange = range == 0 ? 1.0 : range;
    minTemp -= adjustedRange * 0.3;
    maxTemp += adjustedRange * 0.3;
    final actualRange = maxTemp - minTemp;

    final path = Path();
    final points = <Offset>[];

    final dx = width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final normalizedY = (data[i].temperature - minTemp) / actualRange;
      final y = height - (normalizedY * height);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Curve to the next point
        final prev = points[i - 1];
        final controlPoint1 = Offset(prev.dx + dx / 2, prev.dy);
        final controlPoint2 = Offset(x - dx / 2, y);
        path.cubicTo(
            controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, x, y);
      }
    }

    // Draw the gradient fill below the line
    final fillPath = Path.from(path)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(0, height),
      [
        AppTheme.primary.withAlpha(isDark ? 100 : 150),
        AppTheme.primary.withAlpha(0),
      ],
    );

    canvas.drawPath(
      fillPath,
      Paint()..shader = gradient,
    );

    // Draw outer glow for the line
    final glowPaint = Paint()
      ..color = AppTheme.primary.withAlpha(120)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glowPaint);

    // Draw the main line
    final linePaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Draw points and text (every 4th point: e.g., 0, 4, 8, 12, 16, 20)
    for (int i = 0; i < points.length; i += 4) {
      final p = points[i];

      // Point circle
      canvas.drawCircle(p, 4, Paint()..color = AppTheme.primary);
      canvas.drawCircle(p, 2, Paint()..color = Colors.white);

      // Text (Temperature)
      final tempStr = TempConverter.formatShort(data[i].temperature, unit);
      final textPainter = TextPainter(
        text: TextSpan(
          text: tempStr,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textLight,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(p.dx - textPainter.width / 2, p.dy - textPainter.height - 12),
      );
      
      // Text (Time)
      final hour = data[i].time.hour;
      final timeStr = '${hour.toString().padLeft(2, '0')}:00';
      final timePainter = TextPainter(
        text: TextSpan(
          text: timeStr,
          style: TextStyle(
            color: isDark ? Colors.white54 : AppTheme.mutedTextLight,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      timePainter.layout();
      timePainter.paint(
        canvas,
        Offset(p.dx - timePainter.width / 2, height + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.unit != unit ||
        oldDelegate.isDark != isDark;
  }
}
