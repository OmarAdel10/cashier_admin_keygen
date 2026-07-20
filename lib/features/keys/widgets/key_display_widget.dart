import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyDisplayWidget extends StatelessWidget {
  final String deviceId;
  final String activationKey;

  const KeyDisplayWidget({
    super.key,
    required this.deviceId,
    required this.activationKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigoAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Device ID:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(deviceId, style: const TextStyle(fontFamily: 'monospace', fontSize: 16)),
          const SizedBox(height: 16),
          const Text('Activation Key:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SelectableText(
            activationKey,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: activationKey));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activation key copied')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Activation Key'),
          ),
        ],
      ),
    );
  }
}
