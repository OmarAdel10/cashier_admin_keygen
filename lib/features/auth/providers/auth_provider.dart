import 'package:flutter/foundation.dart';
import '../../../core/services/gatekeeper_service.dart';

enum AuthStatus { idle, loading, success, failure, unavailable }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
  });
}

class AuthProvider extends ValueNotifier<AuthState> {
  final GatekeeperService _gatekeeper = GatekeeperService();
  AuthProvider() : super(const AuthState());

  AuthStatus get status => value.status;
  String? get errorMessage => value.errorMessage;

  Future<void> authenticate() async {
    value = const AuthState(status: AuthStatus.loading);

    final failure = await _gatekeeper.authenticate();

    if (failure == null) {
      value = const AuthState(status: AuthStatus.success);
    } else if (failure.code == 'unavailable') {
      value = AuthState(status: AuthStatus.unavailable, errorMessage: failure.message);
    } else {
      value = AuthState(status: AuthStatus.failure, errorMessage: failure.message);
    }
  }

  void reset() {
    value = const AuthState();
  }
}
