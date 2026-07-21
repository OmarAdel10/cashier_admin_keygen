import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cashoer_system_activation/features/auth/screens/auth_gate_screen.dart';

void main() {
  testWidgets('shows loading indicator before authentication completes',
      (tester) async {
    final auth = CompletableAuth();

    await tester.pumpWidget(
      MaterialApp(
        home: AuthGateScreen(
          child: const Text('protected content'),
          authenticate: auth.call,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('protected content'), findsNothing);

    auth.complete(true);
    await tester.pumpAndSettle();

    expect(find.text('protected content'), findsOneWidget);
  });

  testWidgets('shows protected child after successful authentication',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGateScreen(
          child: const Text('protected content'),
          authenticate: () async => true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('protected content'), findsOneWidget);
  });

  testWidgets('shows retry button after failed authentication',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGateScreen(
          child: const Text('protected content'),
          authenticate: () async => false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('protected content'), findsNothing);
    expect(find.text('Authentication required'), findsOneWidget);
    expect(find.text('Authenticate'), findsOneWidget);
  });

  testWidgets('retry button triggers authentication again', (tester) async {
    var attemptCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: AuthGateScreen(
          child: const Text('protected content'),
          authenticate: () async {
            attemptCount++;
            return attemptCount >= 2;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(attemptCount, 1);

    await tester.tap(find.text('Authenticate'));
    await tester.pumpAndSettle();
    expect(attemptCount, 2);
    expect(find.text('protected content'), findsOneWidget);
  });

  testWidgets('resets authentication on app resume', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGateScreen(
          child: const Text('protected content'),
          authenticate: () async => true,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('protected content'), findsOneWidget);

    tester.binding.handleLifecycleStateChange(AppLifecycleState.paused);
    await tester.pump();

    tester.binding.handleLifecycleStateChange(AppLifecycleState.resumed);
    await tester.pump();

    expect(find.text('protected content'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('protected content'), findsOneWidget);
  });

  testWidgets('disabled button prevents concurrent authentication',
      (tester) async {
    final auth = CompletableAuth();

    await tester.pumpWidget(
      MaterialApp(
        home: AuthGateScreen(
          child: const Text('protected content'),
          authenticate: auth.call,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Authenticate'), findsNothing);

    auth.complete(true);
    await tester.pumpAndSettle();
    expect(find.text('protected content'), findsOneWidget);
  });

  testWidgets('authenticate guard prevents concurrent calls',
      (tester) async {
    var callCount = 0;
    final auth = CompletableAuth();

    await tester.pumpWidget(
      MaterialApp(
        home: AuthGateScreen(
          child: const Text('protected content'),
          authenticate: () {
            callCount++;
            return auth.call();
          },
        ),
      ),
    );

    expect(callCount, 1);

    auth.complete(false);
    await tester.pumpAndSettle();
    expect(callCount, 1);

    await tester.tap(find.text('Authenticate'));
    await tester.pump();
    expect(callCount, 2);
  });
}

class CompletableAuth {
  void Function(bool)? _resolve;

  Future<bool> call() {
    return Future<bool>((resolve) {
      _resolve = resolve;
    });
  }

  void complete(bool value) {
    _resolve?.call(value);
  }
}
