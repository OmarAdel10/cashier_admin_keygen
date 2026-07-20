import 'package:flutter/foundation.dart';
import '../../../core/failure.dart';
import '../../../core/services/gatekeeper_service.dart';

enum AuthStatus { idle, loading, success, failure, unavailable }

class AuthProvider extends ChangeNotifier {
  final GatekeeperService _gatekeeper = GatekeeperService();
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> authenticate() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _gatekeeper.authenticate();

    switch (result) {
      case Right():
        _status = AuthStatus.success;
      case Left(value: final f) when f.code == 'unavailable':
        _status = AuthStatus.unavailable;
        _errorMessage = f.message;
      case Left(value: final f):
        _status = AuthStatus.failure;
        _errorMessage = f.message;
    }

    notifyListeners();
  }

  void reset() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
