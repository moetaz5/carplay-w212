import 'dart:math';
import 'package:flutter/material.dart';

class VoiceAssistantWaveOverlay extends StatefulWidget {
  final String prompt;
  final VoidCallback onClose;

  const VoiceAssistantWaveOverlay({
    super.key,
    required this.prompt,
    required this.onClose,
  });

  @override
  State<VoiceAssistantWaveOverlay> createState() => _VoiceAssistantWaveOverlayState();
}

class _VoiceAssistantWaveOverlayState extends State<VoiceAssistantWaveOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mercedes / Apple Glowing Siri Wave Sphere
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SizedBox(
                  width: 180,
                  height: 100,
                  child: CustomPaint(
                    painter: _SiriWavePainter(phase: _controller.value * 2 * pi),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'HEY MERCEDES • ASSISTANT INTELLIGENT',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                widget.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close, size: 16, color: Colors.white60),
              label: const Text('Fermer', style: TextStyle(color: Colors.white60, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SiriWavePainter extends CustomPainter {
  final double phase;

  _SiriWavePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final width = size.width;

    final waveColors = [
      const Color(0xFF00F0FF).withValues(alpha: 0.8),
      const Color(0xFFFF0077).withValues(alpha: 0.7),
      const Color(0xFF7B00FF).withValues(alpha: 0.6),
      const Color(0xFF00FF88).withValues(alpha: 0.5),
    ];

    for (int i = 0; i < waveColors.length; i++) {
      final paint = Paint()
        ..color = waveColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 - (i * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final path = Path();
      path.moveTo(0, midY);

      for (double x = 0; x <= width; x += 4) {
        final scaling = sin(pi * (x / width)); // Taper at edges
        final y = midY + sin((x * 0.04) + phase + (i * 0.8)) * 24 * scaling;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SiriWavePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
