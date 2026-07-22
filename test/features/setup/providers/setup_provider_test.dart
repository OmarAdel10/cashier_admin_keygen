import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_admin_keygen/features/setup/providers/setup_provider.dart';
import '../../../shared/fake_key_manager.dart';

void main() {
  group('SetupProvider', () {
    test('initial state is correct', () {
      final provider = SetupProvider(keyManager: FakeKeyManager());
      expect(provider.isLoading, false);
      expect(provider.publicKey, isNull);
      expect(provider.error, isNull);
    });

    test('hasKeys delegates to KeyManager.hasKeyPair()', () async {
      final keyManager = FakeKeyManager(hasKeys: true);
      final provider = SetupProvider(keyManager: keyManager);
      expect(await provider.hasKeys(), true);
    });

    test('hasKeys returns false when no keys', () async {
      final keyManager = FakeKeyManager(hasKeys: false);
      final provider = SetupProvider(keyManager: keyManager);
      expect(await provider.hasKeys(), false);
    });

    test('generateKey sets publicKey on success', () async {
      final keyManager = FakeKeyManager(publicKey: 'deadbeef');
      final provider = SetupProvider(keyManager: keyManager);
      final result = await provider.generateKey();
      expect(result, true);
      expect(provider.publicKey, 'deadbeef');
      expect(provider.error, isNull);
    });

    test('generateKey sets error on failure', () async {
      final keyManager = FakeKeyManager(shouldThrow: true);
      final provider = SetupProvider(keyManager: keyManager);
      final result = await provider.generateKey();
      expect(result, false);
      expect(provider.error, isNotNull);
      expect(provider.publicKey, isNull);
    });

    test('importSeed sets publicKey on success', () async {
      final keyManager = FakeKeyManager(publicKey: 'cafebabe');
      final provider = SetupProvider(keyManager: keyManager);
      final result = await provider.importSeed('A' * 64);
      expect(result, true);
      expect(provider.publicKey, 'cafebabe');
      expect(provider.error, isNull);
    });

    test('importSeed sets error on failure', () async {
      final keyManager = FakeKeyManager(shouldThrow: true);
      final provider = SetupProvider(keyManager: keyManager);
      final result = await provider.importSeed('bad');
      expect(result, false);
      expect(provider.error, isNotNull);
      expect(provider.publicKey, isNull);
    });
  });
}
