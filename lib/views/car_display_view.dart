import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import '../models/car_state.dart';
import '../widgets/amg_cluster_painter.dart';
import '../widgets/siri_wave_painter.dart';
import '../widgets/tpms_car_painter.dart';
import 'user_guide_view.dart';

class CarDisplayView extends StatelessWidget {
  const CarDisplayView({super.key});

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarState>();

    return Scaffold(
      backgroundColor: car.bgMain,
      body: Stack(
        children: [
          // Main Automotive Interface Body
          Container(
            decoration: BoxDecoration(
              color: car.bgMain,
              border: Border.all(color: car.borderGlow, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: car.ambientColor.withValues(
                    alpha: (car.isLightMode ? 0.08 : 0.20) * car.ambientBrightness,
                  ),
                  blurRadius: 35,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: car.isHdmiConnected
                ? Column(
                    children: [
                      // 1. Top Status Bar with Real iPhone & GPS Data
                      _buildTopStatusBar(context, car),

                      // 2. Main Dynamic Screen View
                      Expanded(
                        child: _buildMainContent(context, car),
                      ),

                      // 3. Fast Dock Navigation Bar
                      _buildBottomDock(context, car),
                    ],
                  )
                : _buildDisconnectedStandby(context, car),
          ),

          // 4. Voice Assistant Overlay (Hey Mercedes / Siri)
          if (car.isVoiceAssistantActive && car.isHdmiConnected)
            VoiceAssistantWaveOverlay(
              prompt: car.voicePrompt,
              onClose: () => car.triggerVoiceAssistant(),
            ),
        ],
      ),
    );
  }

  // Standby screen when HDMI cable is disconnected
  Widget _buildDisconnectedStandby(BuildContext context, CarState car) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: car.isLightMode ? const Color(0xFFFEE2E2) : Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 2),
            ),
            child: const Icon(Icons.cable, color: Colors.redAccent, size: 38),
          ),
          const SizedBox(height: 16),
          Text(
            'MERCEDES-BENZ NTG • EN ATTENTE DU SIGNAL',
            style: TextStyle(
              color: car.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Branchez votre iPhone / Câble HDMI pour lancer l\'interface',
            style: TextStyle(color: car.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => car.toggleHdmiConnection(),
            icon: const Icon(Icons.cable, size: 16),
            label: const Text('Simuler Connexion Écran', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: car.isLightMode ? const Color(0xFF0284C7) : const Color(0xFF1E2D4A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatusBar(BuildContext context, CarState car) {
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: car.bgHeader,
        border: Border(bottom: BorderSide(color: car.borderGlow)),
        boxShadow: car.isLightMode
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, color: car.textPrimary, size: 14),
                const SizedBox(width: 4),
                Text(
                  'MERCEDES',
                  style: TextStyle(
                    color: car.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'AMG',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: car.ambientColor.withValues(alpha: car.isLightMode ? 0.12 : 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: car.ambientColor.withValues(alpha: 0.6)),
              ),
              child: Text(
                'MODE ${car.driveMode.name.toUpperCase()}',
                style: TextStyle(
                  color: car.ambientColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Real Hardware Status (Real iPhone Battery & Real Network)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  car.isIphoneCharging ? Icons.battery_charging_full : Icons.battery_std,
                  color: car.iphoneBattery > 20
                      ? (car.isLightMode ? const Color(0xFF059669) : Colors.greenAccent)
                      : Colors.redAccent,
                  size: 13,
                ),
                Text('${car.iphoneBattery}%', style: TextStyle(color: car.textSecondary, fontSize: 10)),
                const SizedBox(width: 8),
                Icon(Icons.signal_cellular_alt, color: car.accentBlue, size: 12),
                const SizedBox(width: 2),
                Text(car.networkType, style: TextStyle(color: car.textSecondary, fontSize: 10)),
                const SizedBox(width: 8),
                const Icon(Icons.gps_fixed, color: Colors.blueAccent, size: 12),
                const SizedBox(width: 2),
                Text(
                  '${car.gpsAltitude.round()}m',
                  style: TextStyle(color: car.textSecondary, fontSize: 10),
                ),
                const SizedBox(width: 8),
                Text(
                  timeStr,
                  style: TextStyle(
                    color: car.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                // Light / Dark Theme toggle
                InkWell(
                  onTap: () => car.toggleThemeMode(),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: car.isLightMode ? const Color(0xFFE2E8F0) : const Color(0xFF1E2638),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      car.isLightMode ? Icons.light_mode : Icons.dark_mode,
                      size: 12,
                      color: car.isLightMode ? const Color(0xFFD97706) : Colors.cyanAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Guide d'utilisation Button
                InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserGuideView())),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: car.accentBlue.withValues(alpha: car.isLightMode ? 0.12 : 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.help_outline,
                      size: 12,
                      color: car.accentBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, CarState car) {
    switch (car.displayMode) {
      case CarDisplayMode.amgDashboard:
        return _buildAmgDashboard(context, car);
      case CarDisplayMode.carPlaySplit:
        return _buildCarPlaySplit(context, car);
      case CarDisplayMode.carPlayHome:
        return _buildCarPlayHome(context, car);
      case CarDisplayMode.videoPlayer:
        return _buildVideoPlayer(context, car);
      case CarDisplayMode.navigation:
        return _buildNavigation(context, car);
      case CarDisplayMode.diagnostics:
        return _buildDiagnostics(context, car);
      case CarDisplayMode.ntgClassic:
        return _buildNtgClassic(context, car);
    }
  }

  // 1. AMG PERFORMANCE INSTRUMENT CLUSTER (100% Real GPS Data)
  Widget _buildAmgDashboard(BuildContext context, CarState car) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 800,
          height: 380,
          child: Row(
            children: [
              // Left: Real GPS Speedometer Gauge
              Expanded(
                flex: 4,
                child: AmgHighPerformanceGauge(
                  value: car.speed,
                  maxValue: 300,
                  title: 'GPS SPEED',
                  unit: 'KM/H',
                  accentColor: car.ambientColor,
                  isLightMode: car.isLightMode,
                  secondaryText: 'Cap: ${car.gpsHeading.round()}° • ${car.gearMode}${car.gear}',
                ),
              ),

              // Center: Telemetry & Real Physical G-Force Hub
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: car.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: car.borderGlow),
                        boxShadow: car.isLightMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'TÉLÉMÉTRIE VÉHICULE & SATELLITE GPS',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: car.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              Icon(Icons.satellite_alt, color: car.ambientColor, size: 18),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _performanceBar(
                                  car,
                                  'PUISSANCE',
                                  '${car.horsepower.round()} CH',
                                  car.horsepower / 585.0,
                                  Colors.redAccent,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _performanceBar(
                                  car,
                                  'COUPLE',
                                  '${car.torque.round()} NM',
                                  car.torque / 800.0,
                                  car.isLightMode ? const Color(0xFFD97706) : Colors.amberAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _telemetryMiniItem(car, 'Altitude', '${car.gpsAltitude.round()} m', Icons.landscape, Colors.orangeAccent),
                              _telemetryMiniItem(car, 'Batterie', '${car.iphoneBattery}%', Icons.battery_charging_full, Colors.greenAccent),
                              _telemetryMiniItem(car, 'Boost', '${car.boostPressure.toStringAsFixed(1)}b', Icons.speed, car.accentBlue),
                              _telemetryMiniItem(car, 'Réseau', car.networkType.split(' ').first, Icons.cell_tower, Colors.blueAccent),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Physical Accelerometer G-Force + Real GPS Coordinates
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 70,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: car.bgCardSubtle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: car.borderGlow),
                          ),
                          child: DynamicGForceMeter(
                            gX: car.gForceX,
                            gY: car.gForceY,
                            accentColor: car.ambientColor,
                            isLightMode: car.isLightMode,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 70,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: car.bgCardSubtle,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: car.borderGlow),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.redAccent, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'COORDONNÉES GPS EN DIRECT',
                                        style: TextStyle(
                                          color: car.textPrimary,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Lat: ${car.gpsLatitude.toStringAsFixed(4)} • Lng: ${car.gpsLongitude.toStringAsFixed(4)}',
                                    style: TextStyle(
                                      color: car.accentBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  Text(
                                    'Vitesse réelle GPS : ${car.speed.toStringAsFixed(1)} KM/H',
                                    style: TextStyle(color: car.textSecondary, fontSize: 9),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right: RPM Gauge
              Expanded(
                flex: 4,
                child: AmgHighPerformanceGauge(
                  value: car.rpm,
                  maxValue: 8000,
                  title: 'ENGINE',
                  unit: 'RPM x1000',
                  accentColor: Colors.redAccent,
                  isRpm: true,
                  isLightMode: car.isLightMode,
                  secondaryText: '${car.boostPressure.toStringAsFixed(1)} BAR',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _performanceBar(CarState car, String title, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: car.textSecondary, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
            Text(value, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ],
        ),
        const SizedBox(height: 3),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: car.isLightMode ? const Color(0xFFE2E8F0) : Colors.white12,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  static Widget _telemetryMiniItem(CarState car, String title, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: car.textPrimary, fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'monospace'),
        ),
        Text(
          title,
          style: TextStyle(color: car.textSecondary, fontSize: 8),
        ),
      ],
    );
  }

  // 2. APPLE CARPLAY MULTI-WIDGET DASHBOARD
  Widget _buildCarPlaySplit(BuildContext context, CarState car) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            flex: 55,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: car.borderGlow),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildNavigation(context, car),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 45,
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: car.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: car.borderGlow),
                      boxShadow: car.isLightMode
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: car.accentBlue.withValues(alpha: car.isLightMode ? 0.15 : 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.video_library, color: car.accentBlue, size: 24),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    car.isRealVideoLoaded ? car.realVideoTitle : 'Vidéothèque iPhone',
                                    style: TextStyle(color: car.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    car.isRealVideoLoaded ? 'Prêt pour diffusion HD' : 'Sélectionnez depuis l\'iPhone',
                                    style: TextStyle(color: car.textSecondary, fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => car.pickAndPlayRealVideo(),
                          icon: const Icon(Icons.add_to_photos, size: 16),
                          label: const Text('Choisir une vidéo de l\'iPhone', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: car.accentBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: car.isLightMode
                            ? [const Color(0xFFFFF1F2), const Color(0xFFFFFFFF)]
                            : [const Color(0xFF2A1515), const Color(0xFF181B22)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.radar, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'VITESSE GPS RÉELLE',
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              Text(
                                '${car.speed.round()} KM/H • ${car.gpsAltitude.round()}m Altitude',
                                style: TextStyle(color: car.textSecondary, fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. APPLE CARPLAY CLASSIC APP GRID
  Widget _buildCarPlayHome(BuildContext context, CarState car) {
    final apps = [
      {'name': 'Tableau Bord', 'icon': Icons.splitscreen, 'color': const Color(0xFF0284C7), 'mode': CarDisplayMode.carPlaySplit},
      {'name': 'GPS Navi', 'icon': Icons.map, 'color': const Color(0xFF2563EB), 'mode': CarDisplayMode.navigation},
      {'name': 'Vidéos iPhone', 'icon': Icons.video_library, 'color': const Color(0xFFE11D48), 'action': () => car.pickAndPlayRealVideo()},
      {'name': 'AMG Telemetry', 'icon': Icons.speed, 'color': const Color(0xFF0891B2), 'mode': CarDisplayMode.amgDashboard},
      {'name': 'Diagnostics', 'icon': Icons.car_repair, 'color': const Color(0xFFD97706), 'mode': CarDisplayMode.diagnostics},
      {'name': 'Siri Vocal', 'icon': Icons.mic, 'color': const Color(0xFF9333EA), 'action': () => car.triggerVoiceAssistant('Microphone iPhone en direct...')},
      {'name': 'NTG Classic', 'icon': Icons.album, 'color': const Color(0xFF4F46E5), 'mode': CarDisplayMode.ntgClassic},
      {'name': 'Guide & Aide', 'icon': Icons.menu_book, 'color': const Color(0xFF059669), 'action': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserGuideView()))},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.25,
          crossAxisSpacing: 10,
          mainAxisSpacing: 8,
        ),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return InkWell(
            onTap: () {
              if (app.containsKey('action')) {
                (app['action'] as VoidCallback)();
              } else if (app.containsKey('mode')) {
                car.setDisplayMode(app['mode'] as CarDisplayMode);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: app['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (app['color'] as Color).withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      app['icon'] as IconData,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app['name'] as String,
                    style: TextStyle(
                      color: car.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. REAL VIDEO PLAYER WIDGET
  Widget _buildVideoPlayer(BuildContext context, CarState car) {
    if (car.videoPlayerController != null && car.videoPlayerController!.value.isInitialized) {
      return Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: car.videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(car.videoPlayerController!),
          ),
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.video_file, color: Colors.cyanAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      car.realVideoTitle,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => car.toggleVideoPlayback(),
                    icon: Icon(
                      car.videoPlayerController!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: VideoProgressIndicator(
                      car.videoPlayerController!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.redAccent,
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.hd, color: Colors.cyanAccent, size: 16),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent.withValues(alpha: 0.15),
              border: Border.all(color: Colors.redAccent, width: 2),
            ),
            child: const Icon(Icons.video_collection, color: Colors.redAccent, size: 36),
          ),
          const SizedBox(height: 14),
          Text(
            'LECTEUR VIDÉO HD SUR ÉCRAN W212',
            style: TextStyle(color: car.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Choisissez n\'importe quel film ou vidéo de la galerie de votre iPhone',
            style: TextStyle(color: car.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => car.pickAndPlayRealVideo(),
            icon: const Icon(Icons.folder_open),
            label: const Text('Ouvrir la Galerie iPhone'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // 5. GPS NAVIGATION MAP
  Widget _buildNavigation(BuildContext context, CarState car) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: car.isLightMode
                  ? [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)]
                  : [const Color(0xFF131B26), const Color(0xFF0A0F17)],
            ),
          ),
          child: CustomPaint(
            painter: _AdvancedMapPainter(isLightMode: car.isLightMode),
          ),
        ),
        Positioned(
          left: 10,
          top: 10,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: car.bgCard.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: car.accentBlue.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: car.accentBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.navigation, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Position GPS : ${car.gpsLatitude.toStringAsFixed(4)}, ${car.gpsLongitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: car.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Altitude : ${car.gpsAltitude.round()}m • Cap : ${car.gpsHeading.round()}°',
                      style: TextStyle(color: car.accentBlue, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.red, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    '${car.speedLimit}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: car.bgCard.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: car.borderGlow),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${car.speed.round()} KM/H GPS',
                      style: TextStyle(
                        color: car.isLightMode ? const Color(0xFF059669) : Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text('Précision Satellite', style: TextStyle(color: car.textSecondary, fontSize: 9)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. VEHICLE DIAGNOSTICS & TPMS
  Widget _buildDiagnostics(BuildContext context, CarState car) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CarTpmsDiagramWidget(
            pressures: car.tirePressures,
            temperatures: car.tireTemps,
            accentColor: car.ambientColor,
            isLightMode: car.isLightMode,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: car.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: car.borderGlow),
              boxShadow: car.isLightMode
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _diagItem(car, 'Batterie iPhone', '${car.iphoneBattery}% (${car.isIphoneCharging ? "Charge" : "Batterie"})', Icons.battery_charging_full, car.isLightMode ? const Color(0xFF059669) : Colors.greenAccent),
                _diagItem(car, 'Réseau', car.networkType, Icons.cell_tower, Colors.blueAccent),
                _diagItem(car, 'Altitude GPS', '${car.gpsAltitude.round()} mètres', Icons.terrain, car.accentBlue),
                _diagItem(car, 'Alternateur W212', '14.4V (Prêt)', Icons.bolt, const Color(0xFFD97706)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _diagItem(CarState car, String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: car.textPrimary, fontWeight: FontWeight.bold, fontSize: 10)),
        Text(value, style: TextStyle(color: car.textSecondary, fontSize: 9)),
      ],
    );
  }

  // 7. MERCEDES NTG CLASSIC CAROUSEL
  Widget _buildNtgClassic(BuildContext context, CarState car) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'MERCEDES-BENZ COMAND NTG',
            style: TextStyle(
              color: car.textPrimary,
              letterSpacing: 2.0,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ntgMenuItem(car, 'Navi', Icons.explore, false),
                _ntgMenuItem(car, 'Audio', Icons.radio, false),
                _ntgMenuItem(car, 'CarPlay', Icons.phone_iphone, true),
                _ntgMenuItem(car, 'Vidéo', Icons.movie, false),
                _ntgMenuItem(car, 'Système', Icons.settings_applications, false),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Utilisez la molette COMAND ou votre iPhone pour naviguer',
            style: TextStyle(color: car.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _ntgMenuItem(CarState car, String title, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? (car.isLightMode ? const Color(0xFFE0F2FE) : const Color(0xFF1E3A5F))
            : car.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? car.accentBlue : car.borderGlow,
          width: isSelected ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: isSelected ? car.accentBlue : car.textSecondary, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? car.accentBlue : car.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // Fast Bottom Dock
  Widget _buildBottomDock(BuildContext context, CarState car) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      decoration: BoxDecoration(
        color: car.bgHeader,
        border: Border(top: BorderSide(color: car.borderGlow)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _dockButton(
              context,
              car,
              icon: Icons.speed,
              label: 'AMG',
              isSelected: car.displayMode == CarDisplayMode.amgDashboard,
              onTap: () => car.setDisplayMode(CarDisplayMode.amgDashboard),
            ),
            _dockButton(
              context,
              car,
              icon: Icons.splitscreen,
              label: 'Dashboard',
              isSelected: car.displayMode == CarDisplayMode.carPlaySplit,
              onTap: () => car.setDisplayMode(CarDisplayMode.carPlaySplit),
            ),
            _dockButton(
              context,
              car,
              icon: Icons.apps,
              label: 'CarPlay',
              isSelected: car.displayMode == CarDisplayMode.carPlayHome,
              onTap: () => car.setDisplayMode(CarDisplayMode.carPlayHome),
            ),
            _dockButton(
              context,
              car,
              icon: Icons.video_library,
              label: 'Vidéos',
              isSelected: car.displayMode == CarDisplayMode.videoPlayer,
              onTap: () => car.setDisplayMode(CarDisplayMode.videoPlayer),
            ),
            _dockButton(
              context,
              car,
              icon: Icons.navigation,
              label: 'GPS',
              isSelected: car.displayMode == CarDisplayMode.navigation,
              onTap: () => car.setDisplayMode(CarDisplayMode.navigation),
            ),
            _dockButton(
              context,
              car,
              icon: Icons.car_repair,
              label: 'Diagnostics',
              isSelected: car.displayMode == CarDisplayMode.diagnostics,
              onTap: () => car.setDisplayMode(CarDisplayMode.diagnostics),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dockButton(
    BuildContext context,
    CarState car, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? car.accentBlue.withValues(alpha: car.isLightMode ? 0.12 : 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? Border.all(color: car.accentBlue.withValues(alpha: 0.6)) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? car.accentBlue : car.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? car.accentBlue : car.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvancedMapPainter extends CustomPainter {
  final bool isLightMode;
  _AdvancedMapPainter({this.isLightMode = true});

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = isLightMode ? const Color(0xFF94A3B8) : const Color(0xFF222C3D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    final routePathPaint = Paint()
      ..color = const Color(0xFF0070F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.7, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.2, size.width * 0.85, size.height * 0.15);

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, routePathPaint);

    final carPoint = Offset(size.width * 0.4, size.height * 0.65);
    final pinGlow = Paint()
      ..color = const Color(0xFF0070F3).withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(carPoint, 16, pinGlow);

    final pinPaint = Paint()..color = Colors.white;
    canvas.drawCircle(carPoint, 7, pinPaint);
  }

  @override
  bool shouldRepaint(covariant _AdvancedMapPainter oldDelegate) => oldDelegate.isLightMode != isLightMode;
}
