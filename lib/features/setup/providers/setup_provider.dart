import 'package:flutter/foundation.dart';
import '../../../core/services/key_manager.dart';

class SetupProvider extends ChangeNotifier {
  final KeyManager _keyManager;

  SetupProvider({KeyManager? keyManager})
      : _keyManager = keyManager ?? KeyManager();
  bool _isLoading = false;
  String? _publicKey;
  String? _error;

  bool get isLoading => _isLoading;
  String? get publicKey => _publicKey;
  String? get error => _error;

  static String _friendlyError(Object e) {
    if (e is ArgumentError) {
      final msg = e.message.toString();
      if (msg.contains('32 bytes')) {
        return 'Seed must be exactly 64 hex characters (32 bytes).';
      }
      if (msg.contains('even length')) {
        return 'Seed hex string must have an even number of characters.';
      }
      if (msg.contains('invalid hex')) {
        return 'Seed contains invalid characters. Use only 0-9 and A-F.';
      }
    }
    return e.toString();
  }

  Future<bool> generateKey() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _publicKey = await _keyManager.generateKeyPair();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> importSeed(String seed) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _keyManager.importSeed(seed);
      _publicKey = await _keyManager.getPublicKey();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> hasKeys() async {
    return await _keyManager.hasKeyPair();
  }

  Future<void> resetKeys() async {
    try {
      await _keyManager.deleteKeyPair();
    } catch (e) {
      _error = _friendlyError(e);
      notifyListeners();
      return;
    }
    _publicKey = null;
    _error = null;
    notifyListeners();
  }
}
