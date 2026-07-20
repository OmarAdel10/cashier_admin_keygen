import 'package:flutter/foundation.dart';
import '../../../core/services/key_manager.dart';

class SetupProvider extends ChangeNotifier {
  final KeyManager _keyManager = KeyManager();
  bool _isLoading = false;
  String? _publicKey;
  String? _error;

  bool get isLoading => _isLoading;
  String? get publicKey => _publicKey;
  String? get error => _error;

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
      _error = e.toString();
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
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> hasKeys() async {
    return await _keyManager.hasKeyPair();
  }
}
