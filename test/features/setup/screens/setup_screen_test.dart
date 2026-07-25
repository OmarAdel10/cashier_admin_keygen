import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cashier_admin_keygen/features/setup/providers/setup_provider.dart';
import 'package:cashier_admin_keygen/features/setup/screens/setup_screen.dart';
import '../../../shared/fake_key_manager.dart';

Widget buildTestHarness({FakeKeyManager? keyManager}) {
  final km = keyManager ?? FakeKeyManager(hasKeys: false);
  return MaterialApp(
    home: ChangeNotifierProvider(
      create: (_) => SetupProvider(keyManager: km),
      child: const SetupScreen(onComplete: _noop),
    ),
  );
}

void _noop() {}

void main() {
  testWidgets('shows generate button and import toggle initially',
      (tester) async {
    await tester.pumpWidget(buildTestHarness());
    await tester.pump();

    expect(find.text('Generate New Key'), findsOneWidget);
    expect(find.text('Import Existing Seed'), findsOneWidget);
    expect(find.text('Seed (64 hex chars)'), findsNothing);
  });

  testWidgets('tapping import toggle shows seed field', (tester) async {
    await tester.pumpWidget(buildTestHarness());
    await tester.pump();

    await tester.tap(find.text('Import Existing Seed'));
    await tester.pump();

    expect(find.text('Seed (64 hex chars)'), findsOneWidget);
    expect(find.text('Cancel Import'), findsOneWidget);
    expect(find.text('Import'), findsOneWidget);
  });

  testWidgets('shows public key and continue after generation', (tester) async {
    final keyManager = FakeKeyManager(hasKeys: false, publicKey: 'cafebabe');
    await tester.pumpWidget(buildTestHarness(keyManager: keyManager));
    await tester.pump();

    await tester.tap(find.text('Generate New Key'));
    await tester.pump();
    await tester.pump();

    expect(find.text('cafebabe'), findsOneWidget);
    expect(find.text('Copy Public Key'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Generate New Key'), findsNothing);
  });

  testWidgets('displays error message from provider', (tester) async {
    final keyManager = FakeKeyManager(hasKeys: false, shouldThrow: true);
    await tester.pumpWidget(buildTestHarness(keyManager: keyManager));
    await tester.pump();

    await tester.tap(find.text('Generate New Key'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Exception: generate failed'), findsOneWidget);
  });

  testWidgets('calls onComplete when Continue is tapped', (tester) async {
    bool completed = false;
    final keyManager = FakeKeyManager(hasKeys: false, publicKey: 'deadbeef');
    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => SetupProvider(keyManager: keyManager),
        child: SetupScreen(onComplete: () => completed = true),
      ),
    ));
    await tester.pump();

    await tester.tap(find.text('Generate New Key'));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(completed, true);
  });
}