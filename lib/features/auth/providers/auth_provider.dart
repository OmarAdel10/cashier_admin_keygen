import 'package:flutter/foundation.dart';
import '../../../core/services/gatekeeper_service.dart';

enum AuthStatus { idle, loading, success, failure, unavailable }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final int attemptCount;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.attemptCount = 0,
  });
}

class AuthProvider extends ValueNotifier<AuthState> {
  static const int maxAttempts = 3;
  final GatekeeperService _gatekeeper = GatekeeperService();
  AuthProvider() : super(const AuthState());

  AuthStatus get status => value.status;
  String? get errorMessage => value.errorMessage;
  int get attemptCount => value.attemptCount;

  Future<void> authenticate() async {
    if (value.attemptCount >= maxAttempts) return;
    value = AuthState(status: AuthStatus.loading, attemptCount: value.attemptCount);

    final failure = await _gatekeeper.authenticate();

    if (failure == null) {
      value = const AuthState(status: AuthStatus.success);
    } else if (failure.code == 'unavailable') {
      value = AuthState(status: AuthStatus.unavailable, errorMessage: failure.message, attemptCount: value.attemptCount);
    } else {
      final newAttempts = value.attemptCount + 1;
      final lockedOut = newAttempts >= maxAttempts;
      value = AuthState(
        status: AuthStatus.failure,
        errorMessage: lockedOut ? 'Too many failed attempts. Restart the app to try again.' : failure.message,
        attemptCount: newAttempts,
      );
    }
  }

  void reset() { value = const AuthState(); }
}
