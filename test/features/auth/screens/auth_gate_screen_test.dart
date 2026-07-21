import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cashoer_system_activation/features/auth/screens/auth_gate_screen.dart';

void main() {
  const channel = MethodChannel('plugins.flutter.io/local_auth');

  Widget buildTestApp({bool initialAuthResult = true}) {
    return MaterialApp(
      home: AuthGateScreen(
        child: const Scaffold(
          body: Text('Protected Content'),
        ),
      ),
    );
  }

  group('AuthGateScreen', () {
    testWidgets('shows authenticate button when not authenticated',
        (WidgetTester tester) async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return false;
      });

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Authenticate'), findsOneWidget);
      expect(find.text('Protected Content'), findsNothing);
    });

    testWidgets('shows protected content after successful authentication',
        (WidgetTester tester) async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return true;
      });

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Protected Content'), findsOneWidget);
      expect(find.text('Authenticate'), findsNothing);
    });

    testWidgets('shows loading indicator during authentication',
        (WidgetTester tester) async {
      late Completer<void> authCompleter;
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        authCompleter = Completer<void>();
        await authCompleter.future;
        return true;
      });

      await tester.pumpWidget(buildTestApp());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      authCompleter?.complete();
    });

    testWidgets('re-locks on app resume after successful auth',
        (WidgetTester tester) async {
      final authResults = <bool>[true, false];
      int authCallCount = 0;
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        final result = authResults[authCallCount];
        authCallCount++;
        return result;
      });

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Protected Content'), findsOneWidget);

      final state = tester.state<State<AuthGateScreen>>(
        find.byType(AuthGateScreen),
      );
      (state as WidgetsBindingObserver).didChangeAppLifecycleState(
        AppLifecycleState.resumed,
      );
      await tester.pumpAndSettle();

      expect(find.text('Authenticate'), findsOneWidget);
      expect(find.text('Protected Content'), findsNothing);
    });
  });
}
