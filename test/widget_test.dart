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
}
