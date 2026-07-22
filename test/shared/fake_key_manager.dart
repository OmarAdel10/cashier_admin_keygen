import 'package:cashier_admin_keygen/core/services/key_manager.dart';

class FakeKeyManager extends KeyManager {
  final String? signResult;
  final String? publicKey;
  final bool shouldThrow;
  final bool hasKeys;

  FakeKeyManager({
    this.signResult,
    this.publicKey,
    this.shouldThrow = false,
    this.hasKeys = true,
  });

  @override
  Future<String> signDeviceId(String deviceId) async {
    if (shouldThrow) throw Exception('sign failed');
    return signResult ?? 'mock_signature';
  }

  @override
  Future<bool> hasKeyPair() async => hasKeys;

  @override
  Future<String> generateKeyPair() async {
    if (shouldThrow) throw Exception('generate failed');
    return publicKey ?? 'mock_pubkey';
  }

  @override
  Future<void> importSeed(String seedHex) async {
    if (shouldThrow) throw Exception('import failed');
  }

  @override
  Future<String> getPublicKey() async {
    if (shouldThrow) throw Exception('getPublicKey failed');
    return publicKey ?? 'mock_pubkey';
  }
}
