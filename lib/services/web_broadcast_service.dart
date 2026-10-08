import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/car_state.dart';

class WebBroadcastService {
  static final WebBroadcastService _instance = WebBroadcastService._internal();
  factory WebBroadcastService() => _instance;
  WebBroadcastService._internal();

  HttpServer? _server;
  final List<WebSocket> _connectedSockets = [];
  String _serverIp = 'Recherche IP...';
  int _serverPort = 8080;
  bool _isRunning = false;

  bool get isRunning => _isRunning;
  String get serverIp => _serverIp;
  int get serverPort => _serverPort;
  int get connectedClientsCount => _connectedSockets.length;
  String get serverUrl => 'http://$_serverIp:$_serverPort';

  Timer? _telemetryTimer;
  CarState? _carState;

  Future<void> startServer(CarState carState) async {
    if (_isRunning) return;
    _carState = carState;

    try {
      // Find local IP address
      await _updateLocalIp();

      // Bind HTTP server to all network interfaces on port 8080
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
      _serverPort = _server!.port;
      _isRunning = true;
      debugPrint('CarPlay Web Server running on http://$_serverIp:$_serverPort');

      _server!.listen((HttpRequest request) {
        if (request.uri.path == '/ws') {
          _handleWebSocket(request);
        } else {
          _handleHttpRequest(request);
        }
      });

      // Start 30fps / 10Hz telemetry sync loop over WebSockets
      _telemetryTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        _broadcastTelemetry();
      });
    } catch (e) {
      debugPrint('Error starting CarPlay Web Server: $e');
      _isRunning = false;
    }
  }

  Future<void> _updateLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) {
            _serverIp = addr.address;
            return;
          }
        }
      }
      _serverIp = '127.0.0.1';
    } catch (e) {
      _serverIp = '127.0.0.1';
    }
  }

  void _handleWebSocket(HttpRequest request) async {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      _connectedSockets.add(socket);
      debugPrint('New Web Screen Connected! Total: ${_connectedSockets.length}');

      // Send initial full state immediately
      _sendStateToSocket(socket);

      socket.listen(
        (data) {
          try {
            final msg = jsonDecode(data.toString());
            _handleIncomingCommand(msg);
          } catch (e) {
            debugPrint('WS message parse error: $e');
          }
        },
        onDone: () {
          _connectedSockets.remove(socket);
        },
        onError: (e) {
          _connectedSockets.remove(socket);
        },
      );
    }
  }

  void _handleIncomingCommand(Map<String, dynamic> msg) {
    if (_carState == null) return;
    final action = msg['action'] as String?;

    if (action == 'toggleTheme') {
      _carState!.toggleThemeMode();
    } else if (action == 'setMode') {
      final modeIndex = msg['modeIndex'] as int?;
      if (modeIndex != null && modeIndex >= 0 && modeIndex < CarDisplayMode.values.length) {
        _carState!.setDisplayMode(CarDisplayMode.values[modeIndex]);
      }
    } else if (action == 'playRadio') {
      final index = msg['radioIndex'] as int?;
      if (index != null) {
        _carState!.selectAndPlayRadio(index);
      }
    } else if (action == 'toggleRadio') {
      _carState!.toggleRadio();
    }
  }

  void _broadcastTelemetry() {
    if (_connectedSockets.isEmpty || _carState == null) return;
    final payload = _buildStatePayload();
    final jsonString = jsonEncode(payload);

    for (var socket in List<WebSocket>.from(_connectedSockets)) {
      if (socket.readyState == WebSocket.open) {
        socket.add(jsonString);
      }
    }
  }

  void _sendStateToSocket(WebSocket socket) {
    if (_carState == null) return;
    final payload = _buildStatePayload();
    socket.add(jsonEncode(payload));
  }

  Map<String, dynamic> _buildStatePayload() {
    final s = _carState!;
    return {
      'speed': s.speed.toStringAsFixed(0),
      'rpm': s.rpm.toStringAsFixed(0),
      'gear': s.gear,
      'gearMode': s.gearMode,
      'boost': s.boostPressure.toStringAsFixed(2),
      'hp': s.horsepower.toStringAsFixed(0),
      'torque': s.torque.toStringAsFixed(0),
      'gX': s.gForceX.toStringAsFixed(2),
      'gY': s.gForceY.toStringAsFixed(2),
      'lat': s.gpsLatitude,
      'lng': s.gpsLongitude,
      'heading': s.gpsHeading.toStringAsFixed(0),
      'altitude': s.gpsAltitude.toStringAsFixed(0),
      'battery': s.iphoneBattery,
      'isCharging': s.isIphoneCharging,
      'network': s.networkType,
      'isLightMode': s.isLightMode,
      'displayMode': s.displayMode.index,
      'displayModeName': s.displayMode.name,
      'radioName': s.currentRadio.name,
      'radioGenre': s.currentRadio.genre,
      'radioPlaying': s.isRadioPlaying,
      'radioIndex': s.selectedRadioIndex,
      'engineTemp': s.engineTemp,
      'oilTemp': s.oilTemp,
    };
  }

  void _handleHttpRequest(HttpRequest request) {
    final response = request.response;
    response.headers.contentType = ContentType.html;

    final html = _generateDashboardHtml();
    response.write(html);
    response.close();
  }

  String _generateDashboardHtml() {
    return '''<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <title>Mercedes-Benz W212 AMG • Écran Déporté CarPlay</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;900&family=Share+Tech+Mono&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background-color: #08090D;
      color: #FFFFFF;
      font-family: 'Outfit', sans-serif;
      overflow: hidden;
      display: flex;
      flex-direction: column;
      height: 100vh;
      width: 100vw;
    }
    .top-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 10px 24px;
      background: rgba(14, 18, 27, 0.95);
      border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    }
    .brand-logo {
      font-size: 20px;
      font-weight: 900;
      letter-spacing: 2px;
      color: #00D2FF;
    }
    .brand-logo span { color: #FF2A2A; }
    .status-badges {
      display: flex;
      gap: 16px;
      align-items: center;
    }
    .badge {
      background: rgba(255, 255, 255, 0.06);
      padding: 6px 14px;
      border-radius: 20px;
      font-size: 13px;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .badge-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      background: #00FF88;
      box-shadow: 0 0 8px #00FF88;
    }
    .main-screen {
      flex: 1;
      display: grid;
      grid-template-columns: 340px 1fr 340px;
      gap: 16px;
      padding: 16px;
      background: radial-gradient(circle at center, #10141D 0%, #08090D 100%);
    }
    .panel {
      background: rgba(20, 25, 35, 0.85);
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: 20px;
      padding: 20px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      backdrop-filter: blur(12px);
    }
    .dial-title {
      font-size: 14px;
      font-weight: 700;
      color: rgba(255, 255, 255, 0.5);
      text-transform: uppercase;
      letter-spacing: 1.5px;
    }
    .speed-display {
      text-align: center;
      margin: auto 0;
    }
    .speed-val {
      font-size: 88px;
      font-weight: 900;
      font-family: 'Share Tech Mono', monospace;
      color: #FFFFFF;
      line-height: 1;
      text-shadow: 0 0 30px rgba(0, 210, 255, 0.4);
    }
    .speed-unit {
      font-size: 16px;
      font-weight: 700;
      color: #00D2FF;
      letter-spacing: 2px;
      margin-top: 4px;
    }
    .gear-box {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 12px;
      margin-top: 14px;
    }
    .gear-item {
      font-size: 18px;
      font-weight: 700;
      color: rgba(255, 255, 255, 0.3);
      padding: 4px 10px;
      border-radius: 8px;
    }
    .gear-active {
      color: #FF2A2A;
      background: rgba(255, 42, 42, 0.15);
      border: 1px solid rgba(255, 42, 42, 0.4);
      font-size: 22px;
    }
    .center-content {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }
    .center-card {
      background: rgba(20, 25, 35, 0.85);
      border: 1px solid rgba(255, 255, 255, 0.08);
      border-radius: 20px;
      padding: 24px;
      flex: 1;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center;
    }
    .radio-station-title {
      font-size: 32px;
      font-weight: 900;
      color: #FFFFFF;
      margin-bottom: 6px;
    }
    .radio-genre {
      font-size: 15px;
      color: #00D2FF;
      font-weight: 600;
      margin-bottom: 20px;
    }
    .audio-waves {
      display: flex;
      gap: 6px;
      align-items: center;
      height: 40px;
    }
    .wave-bar {
      width: 6px;
      background: #00D2FF;
      border-radius: 4px;
      animation: bounce 1.2s infinite ease-in-out alternate;
    }
    .wave-bar:nth-child(2) { animation-delay: 0.2s; height: 35px; }
    .wave-bar:nth-child(3) { animation-delay: 0.4s; height: 20px; }
    .wave-bar:nth-child(4) { animation-delay: 0.1s; height: 30px; }
    .wave-bar:nth-child(5) { animation-delay: 0.5s; height: 15px; }
    @keyframes bounce {
      0% { height: 8px; }
      100% { height: 38px; }
    }
    .telemetry-row {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 12px;
      width: 100%;
    }
    .tele-stat {
      background: rgba(255, 255, 255, 0.04);
      padding: 12px;
      border-radius: 12px;
      text-align: center;
    }
    .tele-stat .label { font-size: 11px; color: rgba(255, 255, 255, 0.5); text-transform: uppercase; }
    .tele-stat .val { font-size: 20px; font-weight: 800; font-family: 'Share Tech Mono', monospace; color: #FFFFFF; margin-top: 4px; }
    .nav-bar {
      display: flex;
      justify-content: center;
      gap: 14px;
      padding: 12px;
      background: rgba(14, 18, 27, 0.95);
      border-top: 1px solid rgba(255, 255, 255, 0.1);
    }
    .nav-btn {
      background: rgba(255, 255, 255, 0.08);
      border: 1px solid rgba(255, 255, 255, 0.15);
      color: #FFFFFF;
      padding: 10px 22px;
      border-radius: 14px;
      font-size: 14px;
      font-weight: 700;
      cursor: pointer;
      transition: all 0.2s ease;
    }
    .nav-btn:hover {
      background: #00D2FF;
      color: #000000;
      box-shadow: 0 0 15px rgba(0, 210, 255, 0.5);
    }
  </style>
</head>
<body>
  <div class="top-bar">
    <div class="brand-logo">MERCEDES-BENZ <span>AMG W212</span></div>
    <div class="status-badges">
      <div class="badge"><div class="badge-dot"></div> <span id="wsStatus">IPHONE SYNCHRONISÉ</span></div>
      <div class="badge">🔋 <span id="battery">--%</span></div>
      <div class="badge">📡 <span id="network">5G</span></div>
      <div class="badge">📍 <span id="gpsAlt">-- m</span></div>
    </div>
  </div>

  <div class="main-screen">
    <!-- GAUGE SPEED PANEL -->
    <div class="panel">
      <div class="dial-title">VITESSE GPS SATELLITE</div>
      <div class="speed-display">
        <div class="speed-val" id="speed">0</div>
        <div class="speed-unit">KM / H</div>
      </div>
      <div class="gear-box">
        <div class="gear-item" id="gearP">P</div>
        <div class="gear-item" id="gearR">R</div>
        <div class="gear-item" id="gearN">N</div>
        <div class="gear-item gear-active" id="gearD">D</div>
        <div class="gear-item" id="gearNum">D1</div>
      </div>
    </div>

    <!-- CENTER MEDIA / NAV PANEL -->
    <div class="center-content">
      <div class="center-card">
        <div class="dial-title" style="margin-bottom: 12px;">WEBRADIO LIVE FLUTTER</div>
        <div class="radio-station-title" id="radioName">NRJ Hits</div>
        <div class="radio-genre" id="radioGenre">Pop & Hits 40</div>
        <div class="audio-waves">
          <div class="wave-bar"></div>
          <div class="wave-bar"></div>
          <div class="wave-bar"></div>
          <div class="wave-bar"></div>
          <div class="wave-bar"></div>
        </div>
      </div>

      <div class="telemetry-row">
        <div class="tele-stat">
          <div class="label">BOOST TURBO</div>
          <div class="val" id="boost">0.05 BAR</div>
        </div>
        <div class="tele-stat">
          <div class="label">PUISSANCE</div>
          <div class="val" id="hp">15 CH</div>
        </div>
        <div class="tele-stat">
          <div class="label">COUPLE</div>
          <div class="val" id="torque">45 NM</div>
        </div>
        <div class="tele-stat">
          <div class="label">FORCE G (X/Y)</div>
          <div class="val" id="gforce">0.0 / 0.0</div>
        </div>
      </div>
    </div>

    <!-- RIGHT ENGINE / CLUSTER PANEL -->
    <div class="panel">
      <div class="dial-title">RÉGIME MOTEUR</div>
      <div class="speed-display">
        <div class="speed-val" style="color: #FF2A2A;" id="rpm">800</div>
        <div class="speed-unit" style="color: #FF2A2A;">TR / MIN</div>
      </div>
      <div class="telemetry-row" style="grid-template-columns: 1fr 1fr;">
        <div class="tele-stat">
          <div class="label">HUILE</div>
          <div class="val" id="oilTemp">96°C</div>
        </div>
        <div class="tele-stat">
          <div class="label">EAU</div>
          <div class="val" id="waterTemp">90°C</div>
        </div>
      </div>
    </div>
  </div>

  <div class="nav-bar">
    <button class="nav-btn" onclick="sendCommand('setMode', {modeIndex: 0})">AMG Dashboard</button>
    <button class="nav-btn" onclick="sendCommand('setMode', {modeIndex: 1})">CarPlay Home</button>
    <button class="nav-btn" onclick="sendCommand('toggleRadio')">Play/Pause Radio</button>
    <button class="nav-btn" onclick="sendCommand('toggleTheme')">Inverser Thème</button>
  </div>

  <script>
    let ws;
    function connectWS() {
      const loc = window.location;
      const wsUri = (loc.protocol === 'https:' ? 'wss://' : 'ws://') + loc.host + '/ws';
      ws = new WebSocket(wsUri);

      ws.onopen = () => {
        document.getElementById('wsStatus').innerText = 'IPHONE SYNCHRONISÉ';
      };

      ws.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          document.getElementById('speed').innerText = data.speed;
          document.getElementById('rpm').innerText = data.rpm;
          document.getElementById('boost').innerText = data.boost + ' BAR';
          document.getElementById('hp').innerText = data.hp + ' CH';
          document.getElementById('torque').innerText = data.torque + ' NM';
          document.getElementById('gforce').innerText = data.gX + ' / ' + data.gY;
          document.getElementById('battery').innerText = data.battery + '% ' + (data.isCharging ? '⚡' : '');
          document.getElementById('network').innerText = data.network;
          document.getElementById('gpsAlt').innerText = data.altitude + ' m';
          document.getElementById('radioName').innerText = data.radioName;
          document.getElementById('radioGenre').innerText = data.radioGenre;
          document.getElementById('oilTemp').innerText = data.oilTemp + '°C';
          document.getElementById('waterTemp').innerText = data.engineTemp + '°C';
          document.getElementById('gearNum').innerText = data.gearMode + data.gear;
        } catch(e) {}
      };

      ws.onclose = () => {
        document.getElementById('wsStatus').innerText = 'DÉCONNECTÉ (RECONNEXION...)';
        setTimeout(connectWS, 2000);
      };
    }

    function sendCommand(action, params = {}) {
      if (ws && ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify({ action: action, ...params }));
      }
    }

    connectWS();
  </script>
</body>
</html>
''';
  }

  void dispose() {
    _telemetryTimer?.cancel();
    _server?.close(force: true);
    _isRunning = false;
  }
}
