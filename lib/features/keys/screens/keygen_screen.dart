import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../setup/providers/setup_provider.dart';
import '../../setup/screens/setup_screen.dart';
import '../providers/keygen_provider.dart';
import '../widgets/qr_scanner_widget.dart';
import '../widgets/key_display_widget.dart';

class KeyGenScreen extends StatefulWidget {
  const KeyGenScreen({super.key});

  @override
  State<KeyGenScreen> createState() => _KeyGenScreenState();
}

class _KeyGenScreenState extends State<KeyGenScreen> {
  final SetupProvider _setupProvider = SetupProvider();
  bool? _hasKeys;
  final _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkKeys();
  }

  @override
  void dispose() {
    _setupProvider.dispose();
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _checkKeys() async {
    final hasKeys = await _setupProvider.hasKeys();
    if (mounted) setState(() => _hasKeys = hasKeys);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasKeys == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasKeys!) {
      return ChangeNotifierProvider.value(
        value: _setupProvider,
        child: SetupScreen(
          onComplete: () {
            setState(() => _hasKeys = true);
          },
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => KeygenProvider(),
      child: _SigningView(manualController: _manualController),
    );
  }
}

class _ScannerSection extends StatefulWidget {
  final TextEditingController manualController;
  const _ScannerSection({required this.manualController});

  @override
  State<_ScannerSection> createState() => _ScannerSectionState();
}

class _ScannerSectionState extends State<_ScannerSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Scan Device ID QR Code:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        QrScannerWidget(
          onDetected: (id) {
            context.read<KeygenProvider>().setDeviceId(id);
            widget.manualController.text = id;
          },
        ),
        const SizedBox(height: 16),
        const Divider(),
        const Text('Or enter manually:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SigningView extends StatelessWidget {
  final TextEditingController manualController;
  const _SigningView({required this.manualController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cashier Admin Keygen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ScannerSection(manualController: manualController),
            Consumer<KeygenProvider>(
              builder: (context, provider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: manualController,
                      decoration: const InputDecoration(
                        hintText: 'CS-XXXX-XXXX',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (v) {
                        final regex = RegExp(r'^CS-[A-Z0-9]{4}-[A-Z0-9]{4}$');
                        if (regex.hasMatch(v.toUpperCase())) {
                          provider.setDeviceId(v.toUpperCase());
                        } else {
                          provider.setDeviceId(null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: provider.deviceId == null || provider.isSigning
                          ? null
                          : () => provider.sign(),
                      icon: provider.isSigning
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.token),
                      label: const Text('Generate Activation Key'),
                    ),
                    if (provider.error != null) ...[
                      const SizedBox(height: 16),
                      Text(provider.error!, style: const TextStyle(color: Colors.red)),
                    ],
                    if (provider.hasResult) ...[
                      const SizedBox(height: 24),
                      KeyDisplayWidget(
                        deviceId: provider.deviceId!,
                        activationKey: provider.activationKey!,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          provider.reset();
                          manualController.clear();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Generate Another'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
