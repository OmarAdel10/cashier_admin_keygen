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

  testWidgets('AuthGateScreen re-locks on app resume after successful auth',
      (tester) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authProvider,
        child: const MaterialApp(
          home: AuthGateScreen(child: KeyGenScreen()),
        ),
      ),
    );

    // Let the post-frame callback fire
    await tester.pump();

    // Simulate successful biometric authentication
    authProvider.value = const AuthState(status: AuthStatus.success);
    await tester.pump();

    // After success, the child UI is visible and auth prompt is hidden
    expect(find.byType(KeyGenScreen), findsOneWidget);
    expect(find.text('Authentication Required'), findsNothing);

    // Simulate app resuming from background
    final binding = tester.binding;
    binding.setAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();

    // The child should now be hidden again — auth gate re-locks
    expect(find.byType(KeyGenScreen), findsNothing);
  });
}
