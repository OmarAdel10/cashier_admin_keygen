import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_admin_keygen/core/services/key_manager.dart';
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

    test('resetKeys clears publicKey and error', () async {
      final keyManager = FakeKeyManager(publicKey: 'deadbeef');
      final provider = SetupProvider(keyManager: keyManager);
      await provider.generateKey();
      expect(provider.publicKey, 'deadbeef');

      await provider.resetKeys();
      expect(provider.publicKey, isNull);
      expect(provider.error, isNull);
    });
  });

  group('SetupProvider friendly errors', () {
    late KeyManager realKeyManager;

    setUp(() {
      realKeyManager = KeyManager();
    });

    test('importSeed with odd-length hex shows friendly even-length error',
        () async {
      final provider = SetupProvider(keyManager: realKeyManager);
      final result = await provider.importSeed('A' * 63);
      expect(result, false);
      expect(provider.error, contains('even number of characters'));
    });

    test('importSeed with invalid hex chars shows friendly error', () async {
      final provider = SetupProvider(keyManager: realKeyManager);
      final result = await provider.importSeed('Z' * 64);
      expect(result, false);
      expect(provider.error, contains('invalid'));
    });

    test('importSeed with wrong byte length shows friendly error', () async {
      final provider = SetupProvider(keyManager: realKeyManager);
      final result = await provider.importSeed('A' * 128);
      expect(result, false);
      expect(provider.error, contains('64 hex characters'));
    });
  });
}
