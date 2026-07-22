import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cashier_admin_keygen/features/keys/providers/keygen_provider.dart';
import '../../../shared/fake_key_manager.dart';

Widget buildTestHarness(KeygenProvider provider) {
  final manualController = TextEditingController();
  return MaterialApp(
    home: ChangeNotifierProvider.value(
      value: provider,
      child: Consumer<KeygenProvider>(
        builder: (context, p, _) {
          return Scaffold(
            body: Column(
              children: [
                TextField(
                  controller: manualController,
                  onChanged: (v) {
                    final regex =
                        RegExp(r'^CS-[A-Z0-9]{4}-[A-Z0-9]{4}$');
                    if (regex.hasMatch(v.toUpperCase())) {
                      p.setDeviceId(v.toUpperCase());
                    } else {
                      p.setDeviceId(null);
                    }
                  },
                ),
                FilledButton(
                  onPressed: p.deviceId == null || p.isSigning
                      ? null
                      : () => p.sign(),
                  child: const Text('Generate'),
                ),
                if (p.hasResult)
                  Text('Result: ${p.activationKey}'),
                if (p.error != null)
                  Text(p.error!, style: const TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: () {
                    p.reset();
                    manualController.clear();
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  group('Manual device ID input + Generate button', () {
    testWidgets('typing valid CS-XXXX-XXXX enables button', (tester) async {
      final provider = KeygenProvider(
        keyManager: FakeKeyManager(signResult: 'mock_key'),
      );
      await tester.pumpWidget(buildTestHarness(provider));

      await tester.enterText(find.byType(TextField), 'CS-ABCD-1234');
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('empty text field disables button', (tester) async {
      final provider = KeygenProvider(keyManager: FakeKeyManager());
      await tester.pumpWidget(buildTestHarness(provider));

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('invalid text disables button', (tester) async {
      final provider = KeygenProvider(keyManager: FakeKeyManager());
      await tester.pumpWidget(buildTestHarness(provider));

      await tester.enterText(find.byType(TextField), 'garbage');
      await tester.pump();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('valid -> invalid edit disables button', (tester) async {
      final provider = KeygenProvider(
        keyManager: FakeKeyManager(signResult: 'mock_key'),
      );
      await tester.pumpWidget(buildTestHarness(provider));

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
      final provider = KeygenProvider(
        keyManager: FakeKeyManager(signResult: 'mock_signature'),
      );
      await tester.pumpWidget(buildTestHarness(provider));

      await tester.enterText(find.byType(TextField), 'CS-ABCD-1234');
      await tester.pump();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Result: mock_signature'), findsOneWidget);

      await tester.tap(find.byType(TextButton).last);
      await tester.pump();

      expect(provider.deviceId, isNull);
      expect(provider.activationKey, isNull);
      expect(find.text('Result: mock_signature'), findsNothing);
    });
  });
}
