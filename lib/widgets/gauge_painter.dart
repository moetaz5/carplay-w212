import 'dart:math';
import 'package:flutter/material.dart';

class AmgSpeedometerGauge extends StatelessWidget {
  final double speed;
  final double maxSpeed;
  final String unit;
  final Color accentColor;
  final int gear;
  final String gearMode;

  const AmgSpeedometerGauge({
    super.key,
    required this.speed,
    this.maxSpeed = 260.0,
    this.unit = 'KM/H',
    this.accentColor = const Color(0xFF00D2FF),
    required this.gear,
    required this.gearMode,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: CustomPaint(
        painter: _AmgGaugePainter(
          value: speed,
          maxValue: maxSpeed,
          accentColor: accentColor,
          isRpm: false,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${speed.round()}',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.5,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.6), width: 1.2),
                ),
                child: Text(
                  '$gearMode$gear',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AmgRpmGauge extends StatelessWidget {
  final double rpm;
  final double maxRpm;
  final double boostPressure;
  final Color accentColor;

  const AmgRpmGauge({
    super.key,
    required this.rpm,
    this.maxRpm = 8000.0,
    required this.boostPressure,
    this.accentColor = const Color(0xFFFF3366),
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: CustomPaint(
        painter: _AmgGaugePainter(
          value: rpm,
          maxValue: maxRpm,
          accentColor: accentColor,
          isRpm: true,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (rpm / 1000).toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
              const Text(
                'RPM x1000',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.speed, size: 14, color: Colors.amberAccent),
                  const SizedBox(width: 4),
                  Text(
                    '${boostPressure.toStringAsFixed(1)} BAR',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmgGaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color accentColor;
  final bool isRpm;

  _AmgGaugePainter({
    required this.value,
    required this.maxValue,
    required this.accentColor,
    required this.isRpm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 14;

    const startAngle = 135 * (pi / 180);
    const sweepAngle = 270 * (pi / 180);

    // 1. Dark Gauge Outer Ring
    final ringPaint = Paint()
      ..color = const Color(0xFF1E222D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      ringPaint,
    );

    // 2. Active Glow Arc
    final progress = (value / maxValue).clamp(0.0, 1.0);
    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          accentColor.withValues(alpha: 0.4),
          accentColor,
          isRpm ? Colors.red : accentColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      activePaint,
    );

    // 3. Ticks
    final tickCount = isRpm ? 8 : 13;
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 2;

    final redlineTickPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 3;

    for (int i = 0; i <= tickCount; i++) {
      final tickProgress = i / tickCount;
      final angle = startAngle + (sweepAngle * tickProgress);
      final isRedzone = isRpm && i >= 6;

      final innerOffset = Offset(
        center.dx + (radius - 12) * cos(angle),
        center.dy + (radius - 12) * sin(angle),
      );
      final outerOffset = Offset(
        center.dx + (radius + 2) * cos(angle),
        center.dy + (radius + 2) * sin(angle),
      );

      canvas.drawLine(
        innerOffset,
        outerOffset,
        isRedzone ? redlineTickPaint : tickPaint,
      );
    }

    // 4. Glowing Needle Point
    final needleAngle = startAngle + (sweepAngle * progress);
    final needleDotOffset = Offset(
      center.dx + radius * cos(needleAngle),
      center.dy + radius * sin(needleAngle),
    );

    final glowPaint = Paint()
      ..color = (isRpm && progress > 0.75 ? Colors.redAccent : accentColor)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(needleDotOffset, 7, glowPaint);

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(needleDotOffset, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _AmgGaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.accentColor != accentColor;
  }
}
