import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:carplay_w212/models/car_state.dart';
import 'package:carplay_w212/views/dual_screen_simulator.dart';

void main() {
  testWidgets('App loads DualScreenSimulator successfully', (WidgetTester tester) async {
    final carState = CarState(initHardware: false);

    await tester.pumpWidget(
      ChangeNotifierProvider<CarState>.value(
        value: carState,
        child: const MaterialApp(
          home: DualScreenSimulator(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(DualScreenSimulator), findsOneWidget);
  });
}
