import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;

class KeyManager {
  final FlutterSecureStorage _storage;

  KeyManager({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();
  static const _seedKey = 'ed25519_seed';

  Future<ed.PrivateKey> _getPrivateKey() async {
    final seedB64 = await _storage.read(key: _seedKey);
    if (seedB64 == null) throw StateError('No key pair found');
    final seedBytes = Uint8List.fromList(base64.decode(seedB64));
    return ed.newKeyFromSeed(seedBytes);
  }

  Future<bool> hasKeyPair() async {
    final seed = await _storage.read(key: _seedKey);
    return seed != null && seed.isNotEmpty;
  }

  Future<String> generateKeyPair() async {
    final keyPair = ed.generateKey();
    final seedBytes = ed.seed(keyPair.privateKey);
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
    final privateKey = await _getPrivateKey();
    return _bytesToHex(Uint8List.fromList(ed.public(privateKey).bytes));
  }

  Future<String> signDeviceId(String deviceId) async {
    final privateKey = await _getPrivateKey();
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
      throw ArgumentError('Seed hex string must have even length');
    }
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleaned)) {
      throw ArgumentError('Seed contains invalid hex characters. Use only 0-9, A-F.');
    }
    final bytes = Uint8List(cleaned.length ~/ 2);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(cleaned.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return bytes;
  }
}
