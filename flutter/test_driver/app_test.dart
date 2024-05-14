import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fyp_fit3161_team8_web_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Verify home page has the correct title string', (tester) async {
      // Load app widget.
      await tester.pumpWidget(const App());

      // Find the title widget by looking for a Text widget with the string "RestoReview"
      final titleFinder = find.text('RestoReview');

      // Verify if the title "RestoReview" is present
      expect(titleFinder, findsOneWidget);
    });
  });
}
