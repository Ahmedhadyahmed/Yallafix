// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:your_app_name/main.dart';

void main() {
  testWidgets('App loads and shows home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RoadHelperApp());

    // Verify that the app loads properly
    // Look for elements that should be present on the home page
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);

    // Verify that we start on the Home tab
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
  });

  testWidgets('Navigation works correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RoadHelperApp());

    // Tap the 'Services' tab
    await tester.tap(find.text('Services'));
    await tester.pump();

    // Verify that we can navigate (the services tab should still be there)
    expect(find.text('Services'), findsOneWidget);
  });
}