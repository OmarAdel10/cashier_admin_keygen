import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/constants.dart';
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

  static String _friendlyError(Object e) {
    if (e is StateError) {
      if (e.message.contains('No key pair found')) {
        return 'No master key found. Set up a key pair first.';
      }
      if (e.message.contains('Corrupted key data')) {
        return 'Stored key data is corrupted. Reset keys and generate a new pair.';
      }
    }
    return e.toString();
  }

  void setDeviceId(String? id) {
    if (id != null && !AppConstants.deviceIdRegex.hasMatch(id)) {
      _deviceId = null;
    } else {
      _deviceId = id;
    }
    _activationKey = null;
    _error = null;
    notifyListeners();
  }

  Future<void> sign() async {
    final id = _deviceId;
    if (id == null || id.isEmpty) return;
    _isSigning = true;
    _error = null;
    _activationKey = null;
    notifyListeners();
    try {
      final signature = await _keyManager.signDeviceId(id);
      _activationKey = ActivationKey(deviceId: id, signatureBase64: signature);
    } catch (e) {
      _error = _friendlyError(e);
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
