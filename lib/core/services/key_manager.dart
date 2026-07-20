import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;

class KeyManager {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _seedKey = 'ed25519_seed';

  Future<bool> hasKeyPair() async {
    final seed = await _storage.read(key: _seedKey);
    return seed != null && seed.isNotEmpty;
  }

  Future<String> generateKeyPair() async {
    final keyPair = ed.generateKey();
    final seedBytes = Uint8List.fromList(
      keyPair.privateKey.bytes.sublist(0, 32),
    );
    final seed = base64.encode(seedBytes);
    await _storage.write(key: _seedKey, value: seed);
    return getPublicKey();
  }

  Future<void> importSeed(String seedHex) async {
    final seedBytes = _hexToBytes(seedHex);
    if (seedBytes.length != 32) {
      throw ArgumentError('Seed must be exactly 32 bytes (64 hex chars)');
    }
    final seedB64 = base64.encode(seedBytes);
    await _storage.write(key: _seedKey, value: seedB64);
  }

  Future<String> getPublicKey() async {
    final seedB64 = await _storage.read(key: _seedKey);
    if (seedB64 == null) throw StateError('No key pair found');
    final seedBytes = Uint8List.fromList(base64.decode(seedB64));
    final privateKey = ed.newKeyFromSeed(seedBytes);
    return _bytesToHex(Uint8List.fromList(privateKey.bytes.sublist(32)));
  }

  Future<String> signDeviceId(String deviceId) async {
    final seedB64 = await _storage.read(key: _seedKey);
    if (seedB64 == null) throw StateError('No key pair found');
    final seedBytes = Uint8List.fromList(base64.decode(seedB64));
    final privateKey = ed.newKeyFromSeed(seedBytes);
    final payload = Uint8List.fromList(utf8.encode(deviceId));
    final signature = ed.sign(privateKey, payload);
    return base64.encode(signature);
  }

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Uint8List _hexToBytes(String hex) {
    final cleaned = hex.replaceAll(' ', '');
    if (cleaned.length % 2 != 0) {
      throw ArgumentError('Hex string must have even length');
    }
    final bytes = Uint8List(cleaned.length ~/ 2);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(cleaned.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return bytes;
  }
}
