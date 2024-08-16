import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bdd_example_test_lab/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test navigation to second screen', (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle();

    // Find the button by its text and tap it
    final Finder goToSecondScreenButton = find.text('Go to Second Screen');
    await tester.tap(goToSecondScreenButton);

    await tester.pumpAndSettle();

    // Verify that the second screen is displayed
    expect(find.text('This is the second screen'), findsOneWidget);
  });
}