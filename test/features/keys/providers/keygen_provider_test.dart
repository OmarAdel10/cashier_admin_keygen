import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_admin_keygen/features/keys/providers/keygen_provider.dart';
import '../../../shared/fake_key_manager.dart';

void main() {
  group('KeygenProvider', () {
    test('setDeviceId with valid ID stores it', () {
      final provider = KeygenProvider(keyManager: FakeKeyManager());
      provider.setDeviceId('CS-ABCD-1234');

      expect(provider.deviceId, 'CS-ABCD-1234');
      expect(provider.hasResult, false);
      expect(provider.error, isNull);
    });

    test('setDeviceId with null clears device ID', () {
      final provider = KeygenProvider(keyManager: FakeKeyManager());
      provider.setDeviceId('CS-ABCD-1234');
      provider.setDeviceId(null);

      expect(provider.deviceId, isNull);
      expect(provider.hasResult, false);
      expect(provider.error, isNull);
    });

    test('setDeviceId clears previous result and error', () async {
      final provider = KeygenProvider(keyManager: FakeKeyManager());
      provider.setDeviceId('CS-ABCD-1234');
      await provider.sign();
      expect(provider.hasResult, true);

      provider.setDeviceId('CS-EFGH-5678');

      expect(provider.deviceId, 'CS-EFGH-5678');
      expect(provider.hasResult, false);
      expect(provider.error, isNull);
    });

    test('sign with null deviceId is no-op', () async {
      final keyManager = FakeKeyManager(signResult: 'should_not_be_called');
      final provider = KeygenProvider(keyManager: keyManager);

      await provider.sign();

      expect(provider.deviceId, isNull);
      expect(provider.activationKey, isNull);
      expect(provider.isSigning, false);
    });

    test('sign with valid deviceId sets activation key', () async {
      final provider = KeygenProvider(
        keyManager: FakeKeyManager(signResult: 'dGhpcyBpcyBhIHRlc3QK'),
      );
      provider.setDeviceId('CS-ABCD-1234');

      await provider.sign();

      expect(provider.activationKey, 'dGhpcyBpcyBhIHRlc3QK');
      expect(provider.isSigning, false);
      expect(provider.error, isNull);
    });

    test('sign stores error on failure', () async {
      final provider = KeygenProvider(
        keyManager: FakeKeyManager(shouldThrow: true),
      );
      provider.setDeviceId('CS-ABCD-1234');

      await provider.sign();

      expect(provider.error, isNotNull);
      expect(provider.activationKey, isNull);
      expect(provider.isSigning, false);
    });

    test('reset clears all state', () async {
      final provider = KeygenProvider(
        keyManager: FakeKeyManager(signResult: 'mock'),
      );
      provider.setDeviceId('CS-ABCD-1234');
      await provider.sign();
      expect(provider.hasResult, true);

      provider.reset();

      expect(provider.deviceId, isNull);
      expect(provider.activationKey, isNull);
      expect(provider.error, isNull);
      expect(provider.isSigning, false);
    });

    test('setDeviceId from valid to invalid clears device ID', () {
      final provider = KeygenProvider(keyManager: FakeKeyManager());
      provider.setDeviceId('CS-ABCD-1234');
      expect(provider.deviceId, 'CS-ABCD-1234');

      provider.setDeviceId(null);

      expect(provider.deviceId, isNull);
      expect(provider.hasResult, false);
    });
  });
}
