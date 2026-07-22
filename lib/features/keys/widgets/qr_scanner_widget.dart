import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerWidget extends StatefulWidget {
  final void Function(String deviceId) onDetected;
  const QrScannerWidget({super.key, required this.onDetected});

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  String? _lastDetected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 250,
        child: MobileScanner(
          onDetect: (capture) {
            final barcode = capture.barcodes.firstOrNull;
            if (barcode == null) return;
            final raw = barcode.rawValue;
            if (raw == null) return;
            final normalized = raw.toUpperCase();
            final regex = RegExp(r'^CS-[A-Z0-9]{4}-[A-Z0-9]{4}$');
            if (regex.hasMatch(normalized) && normalized != _lastDetected) {
              _lastDetected = normalized;
              widget.onDetected(normalized);
            }
          },
        ),
      ),
    );
  }
}
