import 'dart:math';
import 'package:flutter/material.dart';

class AmgHighPerformanceGauge extends StatelessWidget {
  final double value;
  final double maxValue;
  final String title;
  final String unit;
  final Color accentColor;
  final bool isRpm;
  final bool isLightMode;
  final String? secondaryText;
  final Widget? centerWidget;

  const AmgHighPerformanceGauge({
    super.key,
    required this.value,
    required this.maxValue,
    required this.title,
    required this.unit,
    this.accentColor = const Color(0xFF0070F3),
    this.isRpm = false,
    this.isLightMode = true,
    this.secondaryText,
    this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: CustomPaint(
        painter: _AmgMasterDialPainter(
          value: value,
          maxValue: maxValue,
          accentColor: accentColor,
          isRpm: isRpm,
          isLightMode: isLightMode,
        ),
        child: Center(
          child: centerWidget ??
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRpm
                        ? (value / 1000).toStringAsFixed(1)
                        : value.round().toString(),
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      color: isLightMode ? const Color(0xFF0F172A) : Colors.white,
                      letterSpacing: -1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                  if (secondaryText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      secondaryText!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? const Color(0xFFD97706) : Colors.amberAccent,
                      ),
                    ),
                  ],
                ],
              ),
        ),
      ),
    );
  }
}

class _AmgMasterDialPainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color accentColor;
  final bool isRpm;
  final bool isLightMode;

  _AmgMasterDialPainter({
    required this.value,
    required this.maxValue,
    required this.accentColor,
    required this.isRpm,
    required this.isLightMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = min(size.width, size.height) / 2 - 8;
    final trackRadius = outerRadius - 14;

    const startAngle = 135 * (pi / 180);
    const sweepAngle = 270 * (pi / 180);

    // 1. Outer Ring with Specular Shading
    final bezelPaint = Paint()
      ..shader = SweepGradient(
        colors: isLightMode
            ? [
                const Color(0xFFCBD5E1),
                const Color(0xFFFFFFFF),
                const Color(0xFF94A3B8),
                const Color(0xFFFFFFFF),
                const Color(0xFFCBD5E1),
              ]
            : [
                const Color(0xFF2C3240),
                const Color(0xFF151922),
                const Color(0xFF4A5568),
                const Color(0xFF151922),
                const Color(0xFF2C3240),
              ],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawCircle(center, outerRadius, bezelPaint);

    // 2. Track Background
    final trackPaint = Paint()
      ..color = isLightMode ? const Color(0xFFE2E8F0) : const Color(0xFF121620)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: trackRadius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // 3. Illuminated Active Arc with Multi-Color Glow
    final progress = (value / maxValue).clamp(0.0, 1.0);
    final isRedline = isRpm && progress > 0.78;

    final activeShader = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: [
        accentColor.withValues(alpha: 0.3),
        accentColor,
        isRpm ? Colors.redAccent : accentColor,
      ],
    ).createShader(Rect.fromCircle(center: center, radius: trackRadius));

    final activeArcPaint = Paint()
      ..shader = activeShader
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: trackRadius),
      startAngle,
      sweepAngle * progress,
      false,
      activeArcPaint,
    );

    // 4. Precision Engraved Ticks
    final tickCount = isRpm ? 8 : 13;
    final tickPaint = Paint()
      ..color = isLightMode ? const Color(0xFF64748B) : Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.8;

    final redTickPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2.8;

    for (int i = 0; i <= tickCount; i++) {
      final tProgress = i / tickCount;
      final angle = startAngle + (sweepAngle * tProgress);
      final isZoneRed = isRpm && i >= 6;

      final inner = Offset(
        center.dx + (trackRadius - 10) * cos(angle),
        center.dy + (trackRadius - 10) * sin(angle),
      );
      final outer = Offset(
        center.dx + (trackRadius + 4) * cos(angle),
        center.dy + (trackRadius + 4) * sin(angle),
      );

      canvas.drawLine(inner, outer, isZoneRed ? redTickPaint : tickPaint);
    }

    // 5. Dynamic Needle with High-Precision Tip
    final needleAngle = startAngle + (sweepAngle * progress);
    final needleTip = Offset(
      center.dx + trackRadius * cos(needleAngle),
      center.dy + trackRadius * sin(needleAngle),
    );

    // Halo Glow
    final glowColor = isRedline ? Colors.redAccent : accentColor;
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(needleTip, 9, glowPaint);

    // Diamond Point
    final diamondPaint = Paint()..color = isLightMode ? const Color(0xFF0F172A) : Colors.white;
    canvas.drawCircle(needleTip, 4.5, diamondPaint);
  }

  @override
  bool shouldRepaint(covariant _AmgMasterDialPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isLightMode != isLightMode ||
        oldDelegate.isRpm != isRpm;
  }
}

class DynamicGForceMeter extends StatelessWidget {
  final double gX;
  final double gY;
  final Color accentColor;
  final bool isLightMode;

  const DynamicGForceMeter({
    super.key,
    required this.gX,
    required this.gY,
    this.accentColor = const Color(0xFF0070F3),
    this.isLightMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: CustomPaint(
        painter: _GForcePainter(gX: gX, gY: gY, accentColor: accentColor, isLightMode: isLightMode),
        child: Center(
          child: Text(
            'G-METER',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isLightMode ? const Color(0xFF64748B) : Colors.white54,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _GForcePainter extends CustomPainter {
  final double gX;
  final double gY;
  final Color accentColor;
  final bool isLightMode;

  _GForcePainter({
    required this.gX,
    required this.gY,
    required this.accentColor,
    required this.isLightMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;

    // Crosshairs
    final gridPaint = Paint()
      ..color = isLightMode ? const Color(0xFFCBD5E1) : Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, gridPaint);
    canvas.drawCircle(center, radius * 0.5, gridPaint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), gridPaint);
    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), gridPaint);

    // Current G-Force Ball
    final dotX = center.dx + (gX.clamp(-1.2, 1.2) * (radius * 0.7));
    final dotY = center.dy - (gY.clamp(-1.2, 1.2) * (radius * 0.7));
    final dotPos = Offset(dotX, dotY);

    final dotGlow = Paint()
      ..color = accentColor.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(dotPos, 7, dotGlow);

    final dotPaint = Paint()..color = isLightMode ? accentColor : Colors.white;
    canvas.drawCircle(dotPos, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _GForcePainter oldDelegate) {
    return oldDelegate.gX != gX ||
        oldDelegate.gY != gY ||
        oldDelegate.isLightMode != isLightMode ||
        oldDelegate.accentColor != accentColor;
  }
}
