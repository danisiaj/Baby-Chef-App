import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_chef/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BabyChef App Widget Tests', () {
    testWidgets('App launches and shows loading screen',
        (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const BabyChef());

      // First frame
      await tester.pump();

      // Expect a loading indicator or loading text
      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
        reason: 'App should show loading indicator on startup',
      );
    });

    testWidgets('App navigates to main navigation after loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(const BabyChef());

      // Allow async loading to complete
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify at least one main screen widget exists
      expect(
        find.byType(Scaffold),
        findsWidgets,
        reason: 'Main app scaffold should be visible after loading',
      );
    });

    testWidgets('Bottom navigation is present',
        (WidgetTester tester) async {
      await tester.pumpWidget(const BabyChef());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(
        find.byType(BottomNavigationBar),
        findsOneWidget,
        reason: 'Bottom navigation should be rendered',
      );
    });
  });
}
