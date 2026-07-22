import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:cashier_admin_keygen/core/services/key_manager.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final _store = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _store[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _store[key] = value;
    } else {
      _store.remove(key);
    }
  }
}

void main() {
  late FakeSecureStorage fakeStorage;
  late KeyManager keyManager;

  setUp(() {
    fakeStorage = FakeSecureStorage();
    keyManager = KeyManager(storage: fakeStorage);
  });

  group('KeyManager', () {
    group('getPublicKey', () {
      test('returns hex-encoded public key for a stored seed', () async {
        final keyPair = ed.generateKey();
        final seedBytes = ed.seed(keyPair.privateKey);
        await fakeStorage.write(key: 'ed25519_seed', value: base64.encode(seedBytes));

        final publicKeyHex = await keyManager.getPublicKey();
        final expectedHex = keyPair.publicKey.bytes
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join();
        expect(publicKeyHex, equals(expectedHex));
      });

      test('throws StateError when no key pair exists', () async {
        expect(
          () => keyManager.getPublicKey(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('signDeviceId', () {
      test('returns a valid base64 signature for a stored seed', () async {
        final keyPair = ed.generateKey();
        final seedBytes = ed.seed(keyPair.privateKey);
        await fakeStorage.write(key: 'ed25519_seed', value: base64.encode(seedBytes));

        final deviceId = 'CS-ABCD-1234';
        final signatureB64 = await keyManager.signDeviceId(deviceId);
        final signature = base64.decode(signatureB64);
        final payload = utf8.encode(deviceId);

        expect(ed.verify(keyPair.publicKey, Uint8List.fromList(payload), Uint8List.fromList(signature)), isTrue);
      });

      test('throws StateError when no key pair exists', () async {
        expect(
          () => keyManager.signDeviceId('CS-ABCD-1234'),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
