import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/models/activation_key.dart';
import '../../../core/services/key_manager.dart';

class KeygenProvider extends ChangeNotifier {
  final KeyManager _keyManager;
  String? _deviceId;
  ActivationKey? _activationKey;
  bool _isSigning = false;
  String? _error;

  KeygenProvider({KeyManager? keyManager})
      : _keyManager = keyManager ?? KeyManager();

  String? get deviceId => _deviceId;
  ActivationKey? get activationKey => _activationKey;
  bool get isSigning => _isSigning;
  String? get error => _error;
  bool get hasResult => _activationKey != null;

  void setDeviceId(String? id) {
    _deviceId = id;
    _activationKey = null;
    _error = null;
    notifyListeners();
  }

  Future<void> sign() async {
    if (_deviceId == null || _deviceId!.isEmpty) return;
    _isSigning = true;
    _error = null;
    _activationKey = null;
    notifyListeners();
    try {
      final signature = await _keyManager.signDeviceId(_deviceId!);
      _activationKey = ActivationKey(deviceId: _deviceId!, signatureBase64: signature);
    } catch (e) {
      _error = e.toString();
    }
    _isSigning = false;
    notifyListeners();
  }

  void reset() {
    _deviceId = null;
    _activationKey = null;
    _error = null;
    _isSigning = false;
    notifyListeners();
  }
}
