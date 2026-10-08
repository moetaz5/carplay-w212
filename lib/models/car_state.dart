import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/display_service.dart';
import '../services/real_hardware_service.dart';

enum CarDisplayMode {
  amgDashboard,
  carPlayHome,
  carPlaySplit,
  videoPlayer,
  navigation,
  radioMusic,
  diagnostics,
  ntgClassic,
}

enum DriveMode {
  eco,
  comfort,
  sport,
  sportPlus,
  race,
}

enum SoundProfile {
  harmanKardonLogic7,
  burmester3DSurround,
  amgPerformanceExhaust,
  studioPure,
}

enum ClusterTheme {
  amgTwinDial,
  supersportDigital,
  nightVisionStealth,
}

enum TargetScreenType {
  mercedesNtg, // 800x480 NTG 4.5/4.7
  tabletHd,    // 4:3 iPad / Tablette
  tvMonitor169,// 16:9 TV / Moniteur PC 1080p/4K
  ultraWide219,// 21:9 PC Ultra-Wide
}

class RadioStation {
  final String name;
  final String genre;
  final String streamUrl;
  final IconData icon;
  final Color color;

  const RadioStation({
    required this.name,
    required this.genre,
    required this.streamUrl,
    required this.icon,
    required this.color,
  });
}

class CarState extends ChangeNotifier {
  // 1. Connection & Screen States
  bool _isHdmiConnected = true;
  bool get isHdmiConnected => _isHdmiConnected;

  String _connectionStatusMessage = 'Écran Connecté';
  String get connectionStatusMessage => _connectionStatusMessage;

  CarDisplayMode _displayMode = CarDisplayMode.amgDashboard;
  CarDisplayMode get displayMode => _displayMode;

  ClusterTheme _clusterTheme = ClusterTheme.amgTwinDial;
  ClusterTheme get clusterTheme => _clusterTheme;

  TargetScreenType _screenType = TargetScreenType.mercedesNtg;
  TargetScreenType get screenType => _screenType;

  // 2. MODERN LIGHT & DYNAMIC THEME SYSTEM
  bool _isLightMode = true; // Style clair et dynamique par défaut
  bool get isLightMode => _isLightMode;

  Color get bgMain => _isLightMode ? const Color(0xFFF0F4F8) : const Color(0xFF08090D);
  Color get bgCard => _isLightMode ? Colors.white : const Color(0xFF141923);
  Color get bgCardSubtle => _isLightMode ? const Color(0xFFE8EEF5) : const Color(0xFF10141D);
  Color get bgHeader => _isLightMode ? const Color(0xFFFFFFFF) : const Color(0xFF0E121B);
  Color get textPrimary => _isLightMode ? const Color(0xFF0F172A) : Colors.white;
  Color get textSecondary => _isLightMode ? const Color(0xFF64748B) : Colors.white60;
  Color get borderGlow => _isLightMode ? const Color(0xFFCBD5E1) : Colors.white12;
  Color get accentBlue => _isLightMode ? const Color(0xFF0070F3) : const Color(0xFF00D2FF);
  Color get accentRed => _isLightMode ? const Color(0xFFE11D48) : const Color(0xFFFF2A2A);
  Color get accentGreen => _isLightMode ? const Color(0xFF10B981) : const Color(0xFF00FF88);

  // 3. REAL PERMISSIONS STATUS
  bool get isGpsGranted => RealHardwareService().isGpsGranted;
  bool get isMicGranted => RealHardwareService().isMicGranted;
  bool get isStorageGranted => RealHardwareService().isStorageGranted;

  // 4. REAL GPS & HARDWARE TELEMETRY (From iPhone Hardware Sensors)
  double _speed = 0.0; // Real GPS speed in KM/H
  double get speed => _speed;

  double _rpm = 0.0; // Calculated from real vehicle velocity
  double get rpm => _rpm;

  int _gear = 1;
  int get gear => _gear;

  String _gearMode = 'P';
  String get gearMode => _gearMode;

  double _boostPressure = 0.0;
  double get boostPressure => _boostPressure;

  double _horsepower = 0.0;
  double get horsepower => _horsepower;

  double _torque = 0.0;
  double get torque => _torque;

  // Real physical G-Force from iPhone accelerometer
  double _gForceX = 0.0;
  double get gForceX => _gForceX;

  double _gForceY = 0.0;
  double get gForceY => _gForceY;

  // Real GPS Altitude, Heading & Coordinates
  double _gpsHeading = 0.0;
  double get gpsHeading => _gpsHeading;

  double _gpsAltitude = 0.0;
  double get gpsAltitude => _gpsAltitude;

  double _gpsLatitude = 48.8566;
  double get gpsLatitude => _gpsLatitude;

  double _gpsLongitude = 2.3522;
  double get gpsLongitude => _gpsLongitude;

  // 5. REAL iPhone Battery & Network Hardware Info
  int _iphoneBattery = 100;
  int get iphoneBattery => _iphoneBattery;

  bool _isIphoneCharging = false;
  bool get isIphoneCharging => _isIphoneCharging;

  String _networkType = '5G / 4G LTE';
  String get networkType => _networkType;

  // 6. Vehicle Status
  final double _engineTemp = 90.0;
  double get engineTemp => _engineTemp;

  final double _oilTemp = 96.0;
  double get oilTemp => _oilTemp;

  final double _transmissionTemp = 84.0;
  double get transmissionTemp => _transmissionTemp;

  final double _batteryVoltage = 14.4;
  double get batteryVoltage => _batteryVoltage;

  final List<double> _tirePressures = [2.4, 2.4, 2.5, 2.5];
  List<double> get tirePressures => _tirePressures;

  final List<double> _tireTemps = [32.0, 33.0, 35.0, 36.0];
  List<double> get tireTemps => _tireTemps;

  // 7. Customization & Dynamic Lighting
  DriveMode _driveMode = DriveMode.sportPlus;
  DriveMode get driveMode => _driveMode;

  Color _ambientColor = const Color(0xFF0070F3); // Vibrant Clear Electric Blue
  Color get ambientColor => _ambientColor;

  double _ambientBrightness = 0.90;
  double get ambientBrightness => _ambientBrightness;

  SoundProfile _soundProfile = SoundProfile.burmester3DSurround;
  SoundProfile get soundProfile => _soundProfile;

  // 8. Real Video Player from iPhone Storage
  VideoPlayerController? _videoPlayerController;
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  String _realVideoTitle = 'Aucune vidéo sélectionnée';
  String get realVideoTitle => _realVideoTitle;

  bool _isRealVideoLoaded = false;
  bool get isRealVideoLoaded => _isRealVideoLoaded;

  // 9. Real Live Radio Streaming Service
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRadioPlaying = false;
  bool get isRadioPlaying => _isRadioPlaying;

  int _selectedRadioIndex = 0;
  int get selectedRadioIndex => _selectedRadioIndex;

  final List<RadioStation> radioStations = const [
    RadioStation(
      name: 'NRJ Hits',
      genre: 'Pop / Top 40',
      streamUrl: 'https://scdn.nrjaudio.fm/audio1/fr/30001/mp3_128.mp3',
      icon: Icons.radio,
      color: Color(0xFFE11D48),
    ),
    RadioStation(
      name: 'Skyrock',
      genre: 'Rap & Urban',
      streamUrl: 'https://icecast.skyrock.net/s/natio_mp3_128k',
      icon: Icons.headphones,
      color: Color(0xFF0070F3),
    ),
    RadioStation(
      name: 'RMC Info Talk Sport',
      genre: 'News & Sports',
      streamUrl: 'https://audio.bfmtv.com/rmcradio_128.mp3',
      icon: Icons.sports_soccer,
      color: Color(0xFFD97706),
    ),
    RadioStation(
      name: 'Radio FG Deep',
      genre: 'Electro & House',
      streamUrl: 'https://radiofg.immanens.com/fgd.mp3',
      icon: Icons.graphic_eq,
      color: Color(0xFF9333EA),
    ),
    RadioStation(
      name: 'Smooth Chill Jazz',
      genre: 'Lounge & Chill',
      streamUrl: 'https://media-the.musicradio.com/SmoothChillMP3',
      icon: Icons.nightlife,
      color: Color(0xFF059669),
    ),
  ];

  RadioStation get currentRadio => radioStations[_selectedRadioIndex];

  // 10. Siri / Voice Assistant State
  bool _isVoiceAssistantActive = false;
  bool get isVoiceAssistantActive => _isVoiceAssistantActive;

  String _voicePrompt = 'Prêt pour commande vocale...';
  String get voicePrompt => _voicePrompt;

  // 11. Navigation
  String _navDestination = 'Position GPS Satellite en Direct';
  String get navDestination => _navDestination;

  String _navNextTurn = 'Guidage satellite actif';
  String get navNextTurn => _navNextTurn;

  int _speedLimit = 110;
  int get speedLimit => _speedLimit;

  final bool _hasRadarAlert = true;
  final String _radarAlertText = 'Capteur GPS Actif';
  bool get hasRadarAlert => _hasRadarAlert;
  String get radarAlertText => _radarAlertText;

  CarState({bool initHardware = true}) {
    if (initHardware) {
      _initRealHardware();
    }
  }

  void _initRealHardware() {
    // 1. External Display connection detection
    DisplayDetectionService().init((isConnected) {
      setHdmiConnection(isConnected);
    });

    // 2. Real GPS, Accelerometer G-Force, Battery, and Network
    RealHardwareService().initialize(
      onLocation: (speedKmH, heading, altitude, lat, lng) {
        _speed = speedKmH;
        _gpsHeading = heading;
        _gpsAltitude = altitude;
        _gpsLatitude = lat;
        _gpsLongitude = lng;

        // Realistic RPM and Gear calculation based on real GPS speed
        if (_speed < 1.0) {
          _rpm = 800.0;
          _gear = 1;
          _gearMode = 'P';
          _boostPressure = 0.05;
          _horsepower = 15.0;
          _torque = 45.0;
        } else {
          _gearMode = 'D';
          _rpm = 1200 + (_speed * 35) % 4500;
          _gear = ((_speed / 28).floor() + 1).clamp(1, 7);
          _boostPressure = (_rpm / 6500 * 2.1).clamp(0.1, 2.3);
          _horsepower = (_rpm / 6500 * 557).clamp(40, 585);
          _torque = (_boostPressure / 2.0 * 800).clamp(120, 800);
        }
        notifyListeners();
      },
      onGForce: (gX, gY) {
        _gForceX = gX;
        _gForceY = gY;
        notifyListeners();
      },
      onBattery: (batteryLevel, isCharging) {
        _iphoneBattery = batteryLevel;
        _isIphoneCharging = isCharging;
        notifyListeners();
      },
      onNetwork: (networkType) {
        _networkType = networkType;
        notifyListeners();
      },
      onPermissions: () {
        notifyListeners();
      },
    );
  }

  // --- ACTIONS RADIO & AUDIO ---
  Future<void> selectAndPlayRadio(int index) async {
    _selectedRadioIndex = index.clamp(0, radioStations.length - 1);
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(currentRadio.streamUrl));
      _isRadioPlaying = true;
    } catch (e) {
      debugPrint('Radio play error: $e');
      _isRadioPlaying = false;
    }
    notifyListeners();
  }

  Future<void> toggleRadio() async {
    if (_isRadioPlaying) {
      await _audioPlayer.pause();
      _isRadioPlaying = false;
    } else {
      await selectAndPlayRadio(_selectedRadioIndex);
    }
    notifyListeners();
  }

  Future<void> stopRadio() async {
    await _audioPlayer.stop();
    _isRadioPlaying = false;
    notifyListeners();
  }

  // Launch Turn-by-Turn Navigation in Apple Maps or Google Maps
  Future<void> launchMapsNavigation(String query) async {
    final Uri url = Platform.isIOS
        ? Uri.parse('maps://maps.apple.com/?q=$query')
        : Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Maps launch error: $e');
    }
  }

  // --- ACTIONS THEMES & MODES ---
  void toggleThemeMode() {
    _isLightMode = !_isLightMode;
    notifyListeners();
  }

  void setThemeMode(bool isLight) {
    _isLightMode = isLight;
    notifyListeners();
  }

  void setScreenType(TargetScreenType type) {
    _screenType = type;
    notifyListeners();
  }

  Future<void> requestPermissions() async {
    await RealHardwareService().checkAndRequestPermissions();
    notifyListeners();
  }

  // Pick and Load REAL Video from iPhone Gallery
  Future<void> pickAndPlayRealVideo() async {
    final File? file = await RealHardwareService().pickRealVideoFromPhone();
    if (file != null) {
      await _videoPlayerController?.dispose();

      _realVideoTitle = file.path.split(Platform.pathSeparator).last;
      _videoPlayerController = VideoPlayerController.file(file);

      await _videoPlayerController!.initialize();
      await _videoPlayerController!.setLooping(true);
      await _videoPlayerController!.play();

      _isRealVideoLoaded = true;
      _displayMode = CarDisplayMode.videoPlayer;
      notifyListeners();
    }
  }

  void toggleVideoPlayback() {
    if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.pause();
      } else {
        _videoPlayerController!.play();
      }
      notifyListeners();
    }
  }

  void seekVideo(Duration position) {
    _videoPlayerController?.seekTo(position);
    notifyListeners();
  }

  void setHdmiConnection(bool isConnected) {
    if (_isHdmiConnected != isConnected) {
      _isHdmiConnected = isConnected;
      _connectionStatusMessage = isConnected
          ? 'Écran Externe Détecté et Actif'
          : 'Câble déconnecté • En attente';
      notifyListeners();
    }
  }

  void toggleHdmiConnection() {
    setHdmiConnection(!_isHdmiConnected);
  }

  void setDisplayMode(CarDisplayMode mode) {
    _displayMode = mode;
    notifyListeners();
  }

  void setClusterTheme(ClusterTheme theme) {
    _clusterTheme = theme;
    notifyListeners();
  }

  void setDriveMode(DriveMode mode) {
    _driveMode = mode;
    if (mode == DriveMode.sportPlus || mode == DriveMode.race) {
      _ambientColor = const Color(0xFFE11D48);
    } else if (mode == DriveMode.eco) {
      _ambientColor = const Color(0xFF10B981);
    } else if (mode == DriveMode.comfort) {
      _ambientColor = const Color(0xFF0284C7);
    }
    notifyListeners();
  }

  void setAmbientColor(Color color) {
    _ambientColor = color;
    notifyListeners();
  }

  void setAmbientBrightness(double value) {
    _ambientBrightness = value.clamp(0.1, 1.0);
    notifyListeners();
  }

  void setSoundProfile(SoundProfile profile) {
    _soundProfile = profile;
    notifyListeners();
  }

  void triggerVoiceAssistant([String? command]) {
    _isVoiceAssistantActive = true;
    _voicePrompt = command ?? 'Microphone iPhone en écoute...';
    notifyListeners();

    Timer(const Duration(milliseconds: 3500), () {
      _isVoiceAssistantActive = false;
      notifyListeners();
    });
  }

  void setDestination(String dest) {
    _navDestination = dest;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _videoPlayerController?.dispose();
    DisplayDetectionService().dispose();
    RealHardwareService().dispose();
    super.dispose();
  }
}
