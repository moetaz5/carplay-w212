import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/car_state.dart';
import 'car_display_view.dart';
import 'phone_controller_view.dart';
import 'user_guide_view.dart';

enum SimulatorViewMode {
  dualSplit,
  phoneOnly,
  carScreenOnly,
}

class DualScreenSimulator extends StatefulWidget {
  const DualScreenSimulator({super.key});

  @override
  State<DualScreenSimulator> createState() => _DualScreenSimulatorState();
}

class _DualScreenSimulatorState extends State<DualScreenSimulator> {
  SimulatorViewMode _viewMode = SimulatorViewMode.dualSplit;

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarState>();
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final isWide = size.width > 680;

    return Scaffold(
      backgroundColor: car.bgMain,
      appBar: AppBar(
        backgroundColor: car.bgHeader,
        elevation: car.isLightMode ? 1 : 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dashboard_customize, color: car.accentBlue, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isWide ? 'MERCEDES MULTI-ÉCRAN CARPLAY' : 'W212 LINK',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: car.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // User Guide Button
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

          // Light / Dark Theme toggle
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

          // View Mode Switcher
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: SegmentedButton<SimulatorViewMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: SimulatorViewMode.dualSplit,
                  icon: const Icon(Icons.splitscreen, size: 16),
                  label: isWide ? const Text('Double Vue', style: TextStyle(fontSize: 11)) : null,
                ),
                ButtonSegment(
                  value: SimulatorViewMode.phoneOnly,
                  icon: const Icon(Icons.phone_iphone, size: 16),
                  label: isWide ? const Text('iPhone', style: TextStyle(fontSize: 11)) : null,
                ),
                ButtonSegment(
                  value: SimulatorViewMode.carScreenOnly,
                  icon: const Icon(Icons.tv, size: 16),
                  label: isWide ? const Text('Écran', style: TextStyle(fontSize: 11)) : null,
                ),
              ],
              selected: {_viewMode},
              onSelectionChanged: (Set<SimulatorViewMode> selected) {
                setState(() {
                  _viewMode = selected.first;
                });
              },
              style: SegmentedButton.styleFrom(
                backgroundColor: car.bgCardSubtle,
                selectedBackgroundColor: car.accentBlue,
                selectedForegroundColor: Colors.white,
                foregroundColor: car.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(context, car, isLandscape),
    );
  }

  Widget _buildBody(BuildContext context, CarState car, bool isLandscape) {
    switch (_viewMode) {
      case SimulatorViewMode.phoneOnly:
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const PhoneControllerView(),
          ),
        );

      case SimulatorViewMode.carScreenOnly:
        return Center(
          child: _buildAdaptiveScreenContainer(car, const CarDisplayView()),
        );

      case SimulatorViewMode.dualSplit:
        return isLandscape ? _buildLandscapeSplit(car) : _buildPortraitSplit(car);
    }
  }

  Widget _buildAdaptiveScreenContainer(CarState car, Widget child) {
    double? aspectRatio;
    switch (car.screenType) {
      case TargetScreenType.mercedesNtg:
        aspectRatio = 800 / 480; // 5:3
        break;
      case TargetScreenType.tabletHd:
        aspectRatio = 4 / 3;
        break;
      case TargetScreenType.tvMonitor169:
        aspectRatio = 16 / 9;
        break;
      case TargetScreenType.ultraWide219:
        aspectRatio = 21 / 9;
        break;
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: car.borderGlow, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: car.isLightMode ? 0.08 : 0.6),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

  Widget _buildLandscapeSplit(CarState car) {
    return Row(
      children: [
        // Left Panel: Car / TV / Tablet Screen
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.all(12),
            child: _buildAdaptiveScreenContainer(car, const CarDisplayView()),
          ),
        ),

        // Right Panel: iPhone Controller
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 12, right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: car.borderGlow, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: const PhoneControllerView(),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitSplit(CarState car) {
    return Column(
      children: [
        // Top: Screen Display
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.all(10),
            child: _buildAdaptiveScreenContainer(car, const CarDisplayView()),
          ),
        ),

        // Bottom: Phone Controller
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: car.borderGlow),
            ),
            clipBehavior: Clip.antiAlias,
            child: const PhoneControllerView(),
          ),
        ),
      ],
    );
  }
}
