import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/car_state.dart';
import 'user_guide_view.dart';
import 'web_broadcast_view.dart';

class PhoneControllerView extends StatelessWidget {
  const PhoneControllerView({super.key});

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarState>();

    return Scaffold(
      backgroundColor: car.bgMain,
      appBar: AppBar(
        backgroundColor: car.bgHeader,
        elevation: car.isLightMode ? 1 : 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: car.accentBlue.withValues(alpha: car.isLightMode ? 0.15 : 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.phone_iphone, color: car.accentBlue, size: 16),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'iPHONE ➔ W212 LINK',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: car.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    car.isHdmiConnected ? '● Écran W212 Connecté' : '○ Mode Autonome Actif',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: car.isHdmiConnected
                          ? (car.isLightMode ? const Color(0xFF059669) : Colors.greenAccent)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Diffuser sur PC / TV / Câble',
            icon: Icon(Icons.cast, color: car.accentBlue, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WebBroadcastView()),
              );
            },
          ),
          IconButton(
            tooltip: 'Guide d\'utilisation',
            icon: Icon(Icons.help_outline, color: car.accentBlue, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserGuideView()),
              );
            },
          ),
          IconButton(
            tooltip: 'Mode Thème Clair / Sombre',
            icon: Icon(
              car.isLightMode ? Icons.light_mode : Icons.dark_mode,
              color: car.isLightMode ? const Color(0xFFD97706) : Colors.cyanAccent,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              car.toggleThemeMode();
            },
          ),
          IconButton(
            tooltip: 'Assistant Vocal iPhone',
            icon: const Icon(Icons.mic, color: Colors.purpleAccent, size: 20),
            onPressed: () {
              HapticFeedback.mediumImpact();
              car.triggerVoiceAssistant('Microphone iPhone en écoute...');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 0. Bannière Diffusion PC / TV & Branchement Câble
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WebBroadcastView()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: car.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: car.isWebServerRunning ? car.accentBlue : car.borderGlow,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: car.accentBlue.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: car.accentBlue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.cast_connected, color: car.accentBlue, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'DIFFUSION PC, TV & CÂBLE',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: car.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12.5,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: car.isWebServerRunning ? car.accentGreen : car.accentRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Ouvrir sur PC: ${car.webServerUrl}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: car.accentBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: car.textSecondary, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 1. Autorisations Matérielles iPhone
            _buildPermissionsCard(context, car),

            const SizedBox(height: 16),

            // 2. Format d'Écran Cible (Multi-Écran: W212, Tablette, TV 16:9, PC)
            Text(
              'COMPATIBILITÉ MULTI-ÉCRAN',
              style: TextStyle(
                color: car.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            _buildScreenTypeSelector(context, car),

            const SizedBox(height: 16),

            // 3. Sélecteur de Mode pour l'écran
            Text(
              'PROJECTION SUR L\'ÉCRAN',
              style: TextStyle(
                color: car.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            _buildModeGrid(context, car),

            const SizedBox(height: 16),

            // 4. Radios Web en Direct & Musique
            Text(
              'RADIOS WEB EN DIRECT & AUDIO',
              style: TextStyle(
                color: car.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            _buildRadioPlayerCard(context, car),

            const SizedBox(height: 16),

            // 5. Vidéos de l'iPhone (Lecteur Vidéo Réel)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'VIDÉOTHÈQUE RÉELLE iPHONE',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: car.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (car.isRealVideoLoaded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: const Text('CHARGÉ', style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRealVideoCard(context, car),

            const SizedBox(height: 16),

            // 6. Capteurs et Télémétrie en Direct (Données Réelles)
            Text(
              'TÉLÉMÉTRIE GPS & CAPTEURS EN DIRECT',
              style: TextStyle(
                color: car.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            _buildLiveSensorsCard(context, car),

            const SizedBox(height: 16),

            // 7. Profils et Personnalisation Véhicule
            _buildAudioAndAmbientCard(context, car),
          ],
        ),
      ),
    );
  }

  // 1. Permissions and Live Hardware Card
  Widget _buildPermissionsCard(BuildContext context, CarState car) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(Icons.verified_user, color: car.accentBlue, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'AUTORISATIONS MATÉRIELLES',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: car.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  car.requestPermissions();
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: car.accentBlue.withValues(alpha: car.isLightMode ? 0.12 : 0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: car.accentBlue.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: car.accentBlue, size: 12),
                      const SizedBox(width: 4),
                      Text('Autoriser', style: TextStyle(color: car.accentBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _permissionBadge(car, 'GPS Vitesse', car.isGpsGranted, Icons.gps_fixed),
                const SizedBox(width: 8),
                _permissionBadge(car, 'Galerie / Vidéos', car.isStorageGranted, Icons.video_library),
                const SizedBox(width: 8),
                _permissionBadge(car, 'Microphone', car.isMicGranted, Icons.mic),
                const SizedBox(width: 8),
                _permissionBadge(car, 'Accéléromètre', true, Icons.screen_rotation),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: car.bgCardSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icon(
                    car.isIphoneCharging ? Icons.battery_charging_full : Icons.battery_std,
                    color: car.iphoneBattery > 20
                        ? (car.isLightMode ? const Color(0xFF059669) : Colors.greenAccent)
                        : Colors.redAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'iPhone: ${car.iphoneBattery}% ${car.isIphoneCharging ? "(En charge)" : ""}',
                    style: TextStyle(color: car.textSecondary, fontSize: 10),
                  ),
                  const SizedBox(width: 14),
                  Icon(Icons.wifi, color: car.accentBlue, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    car.networkType,
                    style: TextStyle(color: car.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionBadge(CarState car, String label, bool isGranted, IconData icon) {
    final greenCol = car.isLightMode ? const Color(0xFF059669) : Colors.greenAccent;
    final redCol = Colors.redAccent;
    final activeCol = isGranted ? greenCol : redCol;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: activeCol.withValues(alpha: car.isLightMode ? 0.10 : 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: activeCol.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: activeCol, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: activeCol,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Multi-Screen Type Selector Widget
  Widget _buildScreenTypeSelector(BuildContext context, CarState car) {
    final screens = [
      {'type': TargetScreenType.mercedesNtg, 'name': 'Mercedes W212', 'icon': Icons.directions_car, 'desc': '800x480 NTG 4.5'},
      {'type': TargetScreenType.tabletHd, 'name': 'Tablette / iPad', 'icon': Icons.tablet_mac, 'desc': 'Format 4:3 / 16:10'},
      {'type': TargetScreenType.tvMonitor169, 'name': 'Écran TV / Moniteur', 'icon': Icons.tv, 'desc': '16:9 Full HD / 4K'},
      {'type': TargetScreenType.ultraWide219, 'name': 'PC Ultra-Wide', 'icon': Icons.desktop_windows, 'desc': 'Format 21:9'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: screens.map((item) {
          final isSelected = car.screenType == item['type'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                car.setScreenType(item['type'] as TargetScreenType);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? car.accentBlue.withValues(alpha: car.isLightMode ? 0.15 : 0.25)
                      : car.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? car.accentBlue : car.borderGlow,
                    width: isSelected ? 1.6 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 16,
                      color: isSelected ? car.accentBlue : car.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] as String,
                          style: TextStyle(
                            color: isSelected ? car.accentBlue : car.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          item['desc'] as String,
                          style: TextStyle(
                            color: car.textSecondary,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 3. Mode Grid Widget
  Widget _buildModeGrid(BuildContext context, CarState car) {
    final modes = [
      {'mode': CarDisplayMode.amgDashboard, 'title': 'AMG Telemetry', 'icon': Icons.speed, 'desc': 'Compteurs Réels'},
      {'mode': CarDisplayMode.carPlaySplit, 'title': 'CarPlay 2.0', 'icon': Icons.splitscreen, 'desc': 'Multi-Widgets'},
      {'mode': CarDisplayMode.radioMusic, 'title': 'Radios Web', 'icon': Icons.radio, 'desc': 'En Direct'},
      {'mode': CarDisplayMode.carPlayHome, 'title': 'App Grid', 'icon': Icons.apps, 'desc': 'Applications'},
      {'mode': CarDisplayMode.videoPlayer, 'title': 'Vidéos HD', 'icon': Icons.movie_creation, 'desc': 'Films Galerie'},
      {'mode': CarDisplayMode.navigation, 'title': 'GPS Navi', 'icon': Icons.navigation, 'desc': 'Satellite'},
      {'mode': CarDisplayMode.diagnostics, 'title': 'Diagnostics', 'icon': Icons.car_repair, 'desc': 'TPMS & Huile'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 340 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            childAspectRatio: 1.7,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: modes.length,
          itemBuilder: (context, index) {
            final item = modes[index];
            final isSelected = car.displayMode == item['mode'];

            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                car.setDisplayMode(item['mode'] as CarDisplayMode);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? car.accentBlue.withValues(alpha: car.isLightMode ? 0.15 : 0.25)
                      : car.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? car.accentBlue : car.borderGlow,
                    width: isSelected ? 1.6 : 1,
                  ),
                  boxShadow: isSelected && car.isLightMode
                      ? [
                          BoxShadow(
                            color: car.accentBlue.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: isSelected ? car.accentBlue : car.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: isSelected ? car.accentBlue : car.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 4. Radio Player Card
  Widget _buildRadioPlayerCard(BuildContext context, CarState car) {
    return Container(
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: car.currentRadio.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(car.currentRadio.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.currentRadio.name,
                      style: TextStyle(color: car.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${car.currentRadio.genre} • Flux Réel',
                      style: TextStyle(color: car.textSecondary, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => car.toggleRadio(),
                icon: Icon(
                  car.isRadioPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: car.currentRadio.color,
                  size: 34,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: car.radioStations.asMap().entries.map((entry) {
                final idx = entry.key;
                final station = entry.value;
                final isCurrent = car.selectedRadioIndex == idx;

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    avatar: Icon(station.icon, size: 14, color: isCurrent ? Colors.white : station.color),
                    label: Text(
                      station.name,
                      style: TextStyle(
                        fontSize: 10,
                        color: isCurrent ? Colors.white : car.textPrimary,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: isCurrent ? station.color : car.bgCardSubtle,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    onPressed: () => car.selectAndPlayRadio(idx),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Real Video Card
  Widget _buildRealVideoCard(BuildContext context, CarState car) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: car.isLightMode ? 0.12 : 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.movie_filter, color: Colors.redAccent, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.isRealVideoLoaded ? car.realVideoTitle : 'Aucune vidéo sélectionnée',
                      style: TextStyle(color: car.textPrimary, fontWeight: FontWeight.bold, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      car.isRealVideoLoaded
                          ? 'Vidéo prête pour diffusion vers l\'écran W212'
                          : 'Touchez le bouton pour choisir un fichier vidéo de l\'iPhone',
                      style: TextStyle(color: car.textSecondary, fontSize: 9),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    car.pickAndPlayRealVideo();
                  },
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('Choisir une vidéo iPhone', style: TextStyle(fontSize: 10)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              if (car.isRealVideoLoaded) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => car.toggleVideoPlayback(),
                  style: IconButton.styleFrom(
                    backgroundColor: car.bgCardSubtle,
                  ),
                  icon: Icon(
                    (car.videoPlayerController?.value.isPlaying ?? false)
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: car.textPrimary,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
          if (car.videoPlayerController != null && car.videoPlayerController!.value.isInitialized) ...[
            const SizedBox(height: 8),
            VideoProgressIndicator(
              car.videoPlayerController!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.redAccent,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 6. Live Sensors and Telemetry Card (100% Real Hardware)
  Widget _buildLiveSensorsCard(BuildContext context, CarState car) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: car.bgCard,
        borderRadius: BorderRadius.circular(12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('Vitesse Réelle GPS', overflow: TextOverflow.ellipsis, style: TextStyle(color: car.textSecondary, fontSize: 11)),
              ),
              Text(
                '${car.speed.toStringAsFixed(1)} KM/H',
                style: TextStyle(
                  color: car.accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: car.bgCardSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _sensorMini(car, 'Altitude', '${car.gpsAltitude.round()}m', Icons.landscape),
                  const SizedBox(width: 14),
                  _sensorMini(car, 'Cap GPS', '${car.gpsHeading.round()}°', Icons.explore),
                  const SizedBox(width: 14),
                  _sensorMini(car, 'G-Force X', '${car.gForceX.toStringAsFixed(2)}G', Icons.swap_horiz),
                  const SizedBox(width: 14),
                  _sensorMini(car, 'G-Force Y', '${car.gForceY.toStringAsFixed(2)}G', Icons.swap_vert),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'GPS: ${car.gpsLatitude.toStringAsFixed(5)}, ${car.gpsLongitude.toStringAsFixed(5)}',
            style: TextStyle(color: car.textSecondary, fontSize: 9, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _sensorMini(CarState car, String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: car.accentBlue, size: 14),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: car.textPrimary, fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'monospace')),
        Text(title, style: TextStyle(color: car.textSecondary, fontSize: 8)),
      ],
    );
  }

  // 7. Audio Profile & Ambient Lighting
  Widget _buildAudioAndAmbientCard(BuildContext context, CarState car) {
    final colors = [
      {'name': 'Cyber Blue', 'color': const Color(0xFF0070F3)},
      {'name': 'AMG Red', 'color': const Color(0xFFE11D48)},
      {'name': 'Solar Orange', 'color': const Color(0xFFEA580C)},
      {'name': 'Emerald Green', 'color': const Color(0xFF059669)},
      {'name': 'Polar White', 'color': const Color(0xFF64748B)},
      {'name': 'Violet Neon', 'color': const Color(0xFF9333EA)},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: car.bgCard,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'PROFIL AUDIO MERCEDES',
            style: TextStyle(color: car.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: SoundProfile.values.map((profile) {
                final isSelected = car.soundProfile == profile;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      profile == SoundProfile.burmester3DSurround
                          ? 'Burmester 3D'
                          : profile == SoundProfile.harmanKardonLogic7
                              ? 'Harman Logic7'
                              : 'AMG Exhaust',
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.white : car.textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: car.accentBlue,
                    backgroundColor: car.bgCardSubtle,
                    onSelected: (_) => car.setSoundProfile(profile),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ÉCLAIRAGE D\'AMBIANCE W212',
            style: TextStyle(color: car.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: colors.map((item) {
              final c = item['color'] as Color;
              final isSelected = car.ambientColor == c;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  car.setAmbientColor(c);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? (car.isLightMode ? Colors.black : Colors.white) : Colors.transparent,
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: c.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
