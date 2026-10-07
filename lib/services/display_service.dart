import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DisplayDetectionService {
  static const MethodChannel _channel = MethodChannel('com.mercedes.custom/external_display');
  static const EventChannel _eventChannel = EventChannel('com.mercedes.custom/display_events');

  static final DisplayDetectionService _instance = DisplayDetectionService._internal();
  factory DisplayDetectionService() => _instance;
  DisplayDetectionService._internal();

  StreamController<bool>? _connectionStreamController;
  Stream<bool> get onDisplayConnectionChanged =>
      _connectionStreamController?.stream ?? const Stream.empty();

  void init(Function(bool isConnected) onStateChanged) {
    _connectionStreamController = StreamController<bool>.broadcast();

    // 1. Listen for native iOS (UIScreenDidConnect) / Android (DisplayManager) events
    _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is bool) {
          onStateChanged(event);
        } else if (event is Map && event.containsKey('connected')) {
          onStateChanged(event['connected'] as bool);
        }
      },
      onError: (error) {
        // Fallback or development mode
      },
    );

    // 2. Poll initial hardware status from platform channel
    _checkInitialDisplayStatus(onStateChanged);
  }

  Future<void> _checkInitialDisplayStatus(Function(bool isConnected) onStateChanged) async {
    try {
      final bool? isConnected = await _channel.invokeMethod<bool>('isExternalDisplayConnected');
      if (isConnected != null) {
        onStateChanged(isConnected);
      }
    } catch (_) {
      // Running in simulator or non-native environment
    }
  }

  void dispose() {
    _connectionStreamController?.close();
  }
}
