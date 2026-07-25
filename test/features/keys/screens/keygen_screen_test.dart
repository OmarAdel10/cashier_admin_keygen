import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_admin_keygen/features/keys/screens/keygen_screen.dart';
import '../../../shared/fake_key_manager.dart';

Widget buildTestHarness({bool hasKeys = true, String? signResult}) {
  final keyManager = FakeKeyManager(hasKeys: hasKeys, signResult: signResult);
  return MaterialApp(home: KeyGenScreen(keyManager: keyManager));
}

void main() {
  group('Manual device ID input + Generate button', () {
    Future<void> pumpSigningUi(WidgetTester tester, {String? signResult}) async {
      await tester.pumpWidget(buildTestHarness(signResult: signResult));
      // First pump: initial build with loading spinner
      await tester.pump();
      // Second pump: _checkKeys completes, signing UI renders
      await tester.pump();
    }

    testWidgets('typing valid CS-XXXX-XXXX enables button', (tester) async {
      await pumpSigningUi(tester);

      await tester.enterText(find.byType(TextField), 'CS-ABCD-1234');
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('empty text field disables button', (tester) async {
      await pumpSigningUi(tester);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('invalid text disables button', (tester) async {
      await pumpSigningUi(tester);

      await tester.enterText(find.byType(TextField), 'garbage');
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('valid -> invalid edit disables button', (tester) async {
      await pumpSigningUi(tester);

      await tester.enterText(find.byType(TextField), 'CS-ABCD-1234');
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );

      await tester.enterText(find.byType(TextField), 'CS-ABCD-');
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('signing shows result then reset clears everything',
        (tester) async {
      await pumpSigningUi(tester, signResult: 'mock_signature');

      await tester.enterText(find.byType(TextField), 'CS-ABCD-1234');
      await tester.pump();

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      await tester.pump();

      expect(find.text('mock_signature'), findsOneWidget);

      // Scroll down so "Generate Another" button is visible
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pump();
      await tester.tap(find.text('Generate Another'));
      await tester.pump();

      expect(find.text('mock_signature'), findsNothing);
    });
  });
}
