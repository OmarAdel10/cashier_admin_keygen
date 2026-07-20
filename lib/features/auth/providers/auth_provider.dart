import 'package:flutter/foundation.dart';
import '../../../core/services/gatekeeper_service.dart';

class AuthProvider extends ChangeNotifier {
  final GatekeeperService _gatekeeper = GatekeeperService();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> authenticate() async {
    final result = await _gatekeeper.authenticate();
    _isAuthenticated = result;
    notifyListeners();
    return result;
  }

  void lock() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
