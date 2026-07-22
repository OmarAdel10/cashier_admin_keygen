import 'package:cashier_admin_keygen/core/services/key_manager.dart';

class FakeKeyManager extends KeyManager {
  final String? signResult;
  final bool shouldThrow;
  final bool hasKeys;

  FakeKeyManager({
    this.signResult,
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
}
