import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cashier_admin_keygen/features/auth/providers/auth_provider.dart';
import 'package:cashier_admin_keygen/features/auth/screens/auth_gate_screen.dart';
import 'package:cashier_admin_keygen/features/keys/screens/keygen_screen.dart';

void main() {
  testWidgets('AuthGateScreen shows authentication prompt when not authenticated',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(
          home: AuthGateScreen(child: KeyGenScreen()),
        ),
      ),
    );
    expect(find.text('Authentication Required'), findsOneWidget);
  });

  testWidgets('pause resets auth state back to idle', (tester) async {
    final auth = AuthProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(
          home: AuthGateScreen(child: SizedBox.shrink()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    auth.value = const AuthState(status: AuthStatus.success);
    await tester.pump();
    expect(auth.status, AuthStatus.success);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

    expect(auth.status, AuthStatus.idle);
  });

  testWidgets('pause then resume triggers re-authentication from idle',
      (tester) async {
    final auth = AuthProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(
          home: AuthGateScreen(child: SizedBox.shrink()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    auth.value = const AuthState(status: AuthStatus.success);
    await tester.pump();
    expect(auth.status, AuthStatus.success);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(auth.status, AuthStatus.idle);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(auth.status, AuthStatus.loading);
  });

  testWidgets('loading guard prevents concurrent auth on resume',
      (tester) async {
    final auth = AuthProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: auth,
        child: const MaterialApp(
          home: AuthGateScreen(child: SizedBox.shrink()),
        ),
      ),
    );
    await tester.pump();

    auth.value = const AuthState(status: AuthStatus.loading);
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(auth.status, AuthStatus.loading);
  });
}
