// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nutriplan/main.dart';

void main() {
  testWidgets('Auth screen renders', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that we have login form elements
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('New user? Create an account'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);

    // Test navigation to register screen
    await tester.tap(find.text('New user? Create an account'));
    await tester.pumpAndSettle();

    // Verify we're now on the registration screen
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('REGISTER'), findsOneWidget);
  });
}
