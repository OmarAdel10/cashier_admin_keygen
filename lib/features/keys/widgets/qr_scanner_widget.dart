import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerWidget extends StatelessWidget {
  final void Function(String deviceId) onDetected;

  const QrScannerWidget({super.key, required this.onDetected});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 250,
        child: MobileScanner(
          onDetect: (capture) {
            final barcode = capture.barcodes.firstOrNull;
            if (barcode?.rawValue != null) {
              final raw = barcode!.rawValue!;
              final regex = RegExp(r'^CS-[A-Z0-9]{4}-[A-Z0-9]{4}$');
              if (regex.hasMatch(raw.toUpperCase())) {
                onDetected(raw.toUpperCase());
              }
            }
          },
        ),
      ),
    );
  }
}
