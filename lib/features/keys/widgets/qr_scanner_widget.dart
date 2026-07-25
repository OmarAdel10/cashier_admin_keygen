import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants.dart';

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
            if (AppConstants.deviceIdRegex.hasMatch(normalized) && normalized != _lastDetected) {
              _lastDetected = normalized;
              widget.onDetected(normalized);
            }
          },
          errorBuilder: (context, error, child) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Camera unavailable. Use manual entry below.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
