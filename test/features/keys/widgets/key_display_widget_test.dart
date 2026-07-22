import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('copy button copies activation key to clipboard', (tester) async {
    String? clipboardText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          clipboardText = (methodCall.arguments as Map)['text'] as String?;
          return null;
        }
        if (methodCall.method == 'Clipboard.getData') {
          return {'text': clipboardText};
        }
        return null;
      },
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: KeyDisplayWidget(deviceId: 'CS-ABCD-1234', activationKey: 'mock_key'),
    )));
    await tester.tap(find.text('Copy Activation Key'));
    await tester.pump();
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    expect(clipboardData?.text, 'mock_key');
  });
}
