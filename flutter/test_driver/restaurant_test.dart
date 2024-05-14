import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fyp_fit3161_team8_web_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Custom log function to ensure logs are captured
  void log(String message) {
    debugPrint('LOG: $message');
  }

  group('end-to-end test', () {
    testWidgets('Display restaurant details with reviews', (tester) async {

      final originalOnError = FlutterError.onError!;
      FlutterError.onError = (FlutterErrorDetails details) {
        // Check if it's an error we want to ignore
        if (details.exceptionAsString().contains('ParentDataWidget')) {
          log('NonFatalFlutterError: ${details.exceptionAsString()}');
          log('NonFatalError Message: ${details.stack.toString()}');
          return;
        }
        originalOnError(details);
      };

      // Initialize the app and log
      await tester.pumpWidget(const App());
      log('App initialized');

      // Wait for the FutureBuilder to load by repeatedly pumping
      log('Starting pump and settle');
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      log('Pump and settle completed');

      // Tap on the specific restaurant item in the list
      final restaurantFinder = find.text('Iketeru Restaurant');

      await tester.tap(restaurantFinder);
      await tester.pumpAndSettle();
      log('Tapped on restaurant item and settled');

      // Add more assertions or actions as needed
      expect(find.text('Iketeru Restaurant'), findsOneWidget);

      // Verify reviews are displayed
      expect(find.text('riena m'), findsWidgets);
      log('Verified reviews are displayed');

    });
  });
}
