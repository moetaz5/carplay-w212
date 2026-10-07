import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/car_state.dart';
import 'views/dual_screen_simulator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF8FAFC),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarState()),
      ],
      child: const W212CarPlayApp(),
    ),
  );
}

class W212CarPlayApp extends StatelessWidget {
  const W212CarPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarState>();

    return MaterialApp(
      title: 'Mercedes W212 CarPlay System',
      debugShowCheckedModeBanner: false,
      themeMode: car.isLightMode ? ThemeMode.light : ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        primaryColor: const Color(0xFF0070F3),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0070F3),
          secondary: Color(0xFFE11D48),
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08090D),
        primaryColor: const Color(0xFF00D2FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D2FF),
          secondary: Color(0xFFFF2A2A),
          surface: Color(0xFF141923),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const DualScreenSimulator(),
    );
  }
}
