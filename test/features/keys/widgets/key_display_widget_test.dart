import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_admin_keygen/features/keys/widgets/key_display_widget.dart';

void main() {
  testWidgets('displays device ID and activation key', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: KeyDisplayWidget(deviceId: 'CS-ABCD-1234', activationKey: 'mock_sig'),
    )));
    expect(find.text('CS-ABCD-1234'), findsOneWidget);
    expect(find.text('mock_sig'), findsOneWidget);
    expect(find.text('Copy Activation Key'), findsOneWidget);
  });

  testWidgets('copy button shows snackbar confirmation', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: KeyDisplayWidget(deviceId: 'CS-ABCD-1234', activationKey: 'mock_key'),
    )));
    await tester.tap(find.text('Copy Activation Key'));
    await tester.pump();
    expect(find.text('Activation key copied'), findsOneWidget);
  });
}
