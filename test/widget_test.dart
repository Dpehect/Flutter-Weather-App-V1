import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherapp1/main.dart';

void main() {
  testWidgets('WeatherScreen increments counter', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the counter starts at 0.
    expect(find.text('Counter: 0'), findsOneWidget);
    expect(find.text('Counter: 1'), findsNothing);

    // Tap the button to increment the counter.
    await tester.tap(find.byKey(Key('increment_button')));
    await tester.pump();

    // Verify that the counter has incremented.
    expect(find.text('Counter: 0'), findsNothing);
    expect(find.text('Counter: 1'), findsOneWidget);
  });
}
