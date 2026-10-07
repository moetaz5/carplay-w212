import 'package:flutter/material.dart';

class CarTpmsDiagramWidget extends StatelessWidget {
  final List<double> pressures;
  final List<double> temperatures;
  final Color accentColor;
  final bool isLightMode;

  const CarTpmsDiagramWidget({
    super.key,
    required this.pressures,
    required this.temperatures,
    this.accentColor = const Color(0xFF0070F3),
    this.isLightMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLightMode ? Colors.white : const Color(0xFF10141D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLightMode ? const Color(0xFFE2E8F0) : Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: isLightMode
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Left Tires (Front-Left & Rear-Left)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tireBadge('AVG (Avant Gauche)', pressures[0], temperatures[0]),
              const SizedBox(height: 24),
              _tireBadge('ARG (Arrière Gauche)', pressures[2], temperatures[2]),
            ],
          ),

          // Center Car Wireframe
          Column(
            children: [
              Container(
                width: 90,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 2),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accentColor.withValues(alpha: isLightMode ? 0.12 : 0.15),
                      Colors.transparent,
                      accentColor.withValues(alpha: isLightMode ? 0.08 : 0.1),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Windshield
                    Positioned(
                      top: 35,
                      child: Container(
                        width: 60,
                        height: 25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isLightMode ? const Color(0xFF94A3B8) : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                    // Mercedes Star
                    Icon(
                      Icons.shield_outlined,
                      color: isLightMode ? const Color(0xFF334155) : Colors.white70,
                      size: 28,
                    ),
                    // Rear Glass
                    Positioned(
                      bottom: 35,
                      child: Container(
                        width: 55,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isLightMode ? const Color(0xFF94A3B8) : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'W212 TPMS ACTIF',
                style: TextStyle(
                  color: isLightMode ? const Color(0xFF64748B) : Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          // Right Tires (Front-Right & Rear-Right)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tireBadge('AVD (Avant Droit)', pressures[1], temperatures[1]),
              const SizedBox(height: 24),
              _tireBadge('ARD (Arrière Droit)', pressures[3], temperatures[3]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tireBadge(String position, double pressure, double temp) {
    final isOk = pressure >= 2.2 && pressure <= 2.8;
    final greenCol = isLightMode ? const Color(0xFF059669) : Colors.greenAccent;
    final warnCol = isLightMode ? const Color(0xFFD97706) : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isLightMode ? const Color(0xFFF8FAFC) : const Color(0xFF18202E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOk ? greenCol.withValues(alpha: 0.5) : warnCol,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tire_repair, size: 14, color: isOk ? greenCol : warnCol),
              const SizedBox(width: 4),
              Text(
                '${pressure.toStringAsFixed(1)} BAR',
                style: TextStyle(
                  color: isLightMode ? const Color(0xFF0F172A) : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${temp.round()}°C • ${(pressure * 14.5038).round()} PSI',
            style: TextStyle(
              color: isLightMode ? const Color(0xFF64748B) : Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
