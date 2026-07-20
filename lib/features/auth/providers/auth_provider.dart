import 'package:flutter/foundation.dart';
import '../../../core/failure.dart';
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

    final result = await _gatekeeper.authenticate();

    switch (result) {
      case Right():
        value = const AuthState(status: AuthStatus.success);
      case Left(value: final f) when f.code == 'unavailable':
        value = AuthState(status: AuthStatus.unavailable, errorMessage: f.message);
      case Left(value: final f):
        value = AuthState(status: AuthStatus.failure, errorMessage: f.message);
    }
  }

  void reset() {
    value = const AuthState();
  }
}
