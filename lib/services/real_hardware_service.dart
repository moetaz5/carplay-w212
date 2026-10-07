import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class RealHardwareService {
  static final RealHardwareService _instance = RealHardwareService._internal();
  factory RealHardwareService() => _instance;
  RealHardwareService._internal();

  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  final ImagePicker _picker = ImagePicker();

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;
  StreamSubscription<BatteryState>? _batterySubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Real Permission States
  bool _isGpsGranted = false;
  bool _isMicGranted = false;
  bool _isStorageGranted = false;

  bool get isGpsGranted => _isGpsGranted;
  bool get isMicGranted => _isMicGranted;
  bool get isStorageGranted => _isStorageGranted;

  // Real Hardware State Callbacks
  Function(double speedKmH, double heading, double altitude, double lat, double lng)? onLocationUpdate;
  Function(double gX, double gY)? onGForceUpdate;
  Function(int batteryLevel, bool isCharging)? onBatteryUpdate;
  Function(String networkType)? onNetworkUpdate;
  VoidCallback? onPermissionsChanged;

  Future<void> initialize({
    required Function(double speedKmH, double heading, double altitude, double lat, double lng) onLocation,
    required Function(double gX, double gY) onGForce,
    required Function(int batteryLevel, bool isCharging) onBattery,
    required Function(String networkType) onNetwork,
    VoidCallback? onPermissions,
  }) async {
    onLocationUpdate = onLocation;
    onGForceUpdate = onGForce;
    onBatteryUpdate = onBattery;
    onNetworkUpdate = onNetwork;
    onPermissionsChanged = onPermissions;

    // 1. Check and request permissions
    await checkAndRequestPermissions();

    // 2. Start Real GPS Tracking
    _startRealGps();

    // 3. Start Real Device Accelerometer (G-Force)
    _startRealSensors();

    // 4. Start Real Battery Level Monitoring
    _startRealBattery();

    // 5. Start Real Network Status Monitoring
    _startRealConnectivity();
  }

  Future<void> checkAndRequestPermissions() async {
    try {
      final locStatus = await Permission.locationWhenInUse.status;
      final micStatus = await Permission.microphone.status;
      final photosStatus = await Permission.photos.status;

      if (!locStatus.isGranted || !micStatus.isGranted || !photosStatus.isGranted) {
        final statuses = await [
          Permission.locationWhenInUse,
          Permission.microphone,
          Permission.photos,
          Permission.mediaLibrary,
        ].request();

        _isGpsGranted = statuses[Permission.locationWhenInUse]?.isGranted ?? false;
        _isMicGranted = statuses[Permission.microphone]?.isGranted ?? false;
        _isStorageGranted = (statuses[Permission.photos]?.isGranted ?? false) ||
            (statuses[Permission.mediaLibrary]?.isGranted ?? false);
      } else {
        _isGpsGranted = true;
        _isMicGranted = true;
        _isStorageGranted = true;
      }
      onPermissionsChanged?.call();
    } catch (e) {
      debugPrint('Permission request error: $e');
    }
  }

  void _startRealGps() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      _isGpsGranted = true;
      onPermissionsChanged?.call();

      // Real high-precision GPS stream from iPhone / Android GPS chip
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );

      _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position pos) {
          // Convert real m/s speed from GPS hardware to KM/H
          final double speedKmH = (pos.speed.clamp(0.0, 120.0) * 3.6);
          onLocationUpdate?.call(
            speedKmH,
            pos.heading,
            pos.altitude,
            pos.latitude,
            pos.longitude,
          );
        },
        onError: (err) {
          debugPrint('GPS stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('GPS init error: $e');
    }
  }

  void _startRealSensors() {
    try {
      _sensorSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
        // Real G-Force calculated from physical accelerometer hardware (9.81 m/s² = 1G)
        final double gX = (event.x / 9.81).clamp(-1.5, 1.5);
        final double gY = (event.y / 9.81).clamp(-1.5, 1.5);
        onGForceUpdate?.call(gX, gY);
      });
    } catch (e) {
      debugPrint('Sensors init error: $e');
    }
  }

  void _startRealBattery() async {
    try {
      final int level = await _battery.batteryLevel;
      final BatteryState state = await _battery.batteryState;
      onBatteryUpdate?.call(level, state == BatteryState.charging || state == BatteryState.full);

      _batterySubscription = _battery.onBatteryStateChanged.listen((BatteryState state) async {
        final int currentLevel = await _battery.batteryLevel;
        onBatteryUpdate?.call(currentLevel, state == BatteryState.charging || state == BatteryState.full);
      });
    } catch (e) {
      debugPrint('Battery init error: $e');
    }
  }

  void _startRealConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      _handleConnectivityResults(results);

      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
        _handleConnectivityResults(results);
      });
    } catch (e) {
      debugPrint('Connectivity init error: $e');
    }
  }

  void _handleConnectivityResults(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      onNetworkUpdate?.call('Wi-Fi Connecté');
    } else if (results.contains(ConnectivityResult.mobile)) {
      onNetworkUpdate?.call('5G / 4G LTE');
    } else if (results.contains(ConnectivityResult.none)) {
      onNetworkUpdate?.call('Hors ligne');
    } else {
      onNetworkUpdate?.call('Cellulaire');
    }
  }

  // Real Video File Picker from iPhone Camera Roll / Files
  Future<File?> pickRealVideoFromPhone() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(hours: 4),
      );
      if (video != null) {
        _isStorageGranted = true;
        onPermissionsChanged?.call();
        return File(video.path);
      }
    } catch (e) {
      debugPrint('Video pick error: $e');
    }
    return null;
  }

  void dispose() {
    _positionSubscription?.cancel();
    _sensorSubscription?.cancel();
    _batterySubscription?.cancel();
    _connectivitySubscription?.cancel();
  }
}
