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

  ({IconData icon, String message, Widget? action}) _buildErrorContent(
      MobileScannerException error) {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return (
          icon: Icons.no_photography_outlined,
          message: 'Camera permission denied. Grant access in device settings.',
          action: null,
        );
      case MobileScannerErrorCode.unsupported:
        return (
          icon: Icons.phonelink_off_outlined,
          message: 'Camera not available on this device. Use manual entry below.',
          action: null,
        );
      default:
        final detail = error.errorDetails?.message;
        return (
          icon: Icons.error_outline,
          message: detail ?? 'Camera unavailable. Use manual entry below.',
          action: null,
        );
    }
  }

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
            final content = _buildErrorContent(error);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(content.icon, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      content.message,
                      textAlign: TextAlign.center,
                    ),
                    if (content.action != null) ...[
                      const SizedBox(height: 12),
                      content.action!,
                    ],
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
