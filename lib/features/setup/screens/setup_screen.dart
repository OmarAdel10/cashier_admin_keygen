import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/setup_provider.dart';

class SetupScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SetupScreen({super.key, required this.onComplete});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _seedController = TextEditingController();
  bool _showImport = false;

  @override
  void dispose() {
    _seedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SetupProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Key Setup')),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.vpn_key, size: 64, color: Colors.indigoAccent),
                const SizedBox(height: 16),
                const Text(
                  'No master key found',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Generate a new Ed25519 keypair or import an existing seed.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (provider.publicKey != null) ...[
                  const Text('Public Key:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      provider.publicKey!,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: provider.publicKey!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Public key copied')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Public Key'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: widget.onComplete,
                    child: const Text('Continue'),
                  ),
                ] else ...[
                  FilledButton.icon(
                    onPressed: provider.isLoading ? null : () => provider.generateKey(),
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.add),
                    label: const Text('Generate New Key'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _showImport = !_showImport),
                    child: Text(_showImport ? 'Cancel Import' : 'Import Existing Seed'),
                  ),
                  if (_showImport) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _seedController,
                      decoration: const InputDecoration(
                        labelText: 'Seed (64 hex chars)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: provider.isLoading
                          ? null
                          : () => provider.importSeed(_seedController.text.trim()),
                      child: const Text('Import'),
                    ),
                  ],
                ],
                if (provider.error != null) ...[
                  const SizedBox(height: 16),
                  Text(provider.error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
