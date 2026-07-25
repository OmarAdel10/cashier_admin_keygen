import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_admin_keygen/core/models/failure.dart';
import 'package:cashier_admin_keygen/core/services/gatekeeper_service.dart';
import 'package:cashier_admin_keygen/features/auth/providers/auth_provider.dart';

class FakeGatekeeperService extends GatekeeperService {
  final Failure? _failureResult;
  FakeGatekeeperService({this._failureResult});

  @override
  Future<Failure?> authenticate() async => _failureResult;
}

void main() {
  group('AuthProvider', () {
    test('initial state has attemptCount=0 and AuthStatus.idle', () {
      final provider = AuthProvider(gatekeeper: FakeGatekeeperService());

      expect(provider.attemptCount, 0);
      expect(provider.status, AuthStatus.idle);
    });

    test('authenticate() failure increments attemptCount', () async {
      final provider = AuthProvider(
        gatekeeper: FakeGatekeeperService(
          failureResult: const Failure(code: 'cancelled', message: 'failed'),
        ),
      );

      await provider.authenticate();

      expect(provider.attemptCount, 1);
      expect(provider.status, AuthStatus.failure);
    });

    test('3rd failure shows lockout message, attemptCount=3', () async {
      final provider = AuthProvider(
        gatekeeper: FakeGatekeeperService(
          failureResult: const Failure(code: 'cancelled', message: 'failed'),
        ),
      );

      for (int i = 0; i < 3; i++) {
        await provider.authenticate();
      }

      expect(provider.attemptCount, 3);
      expect(provider.status, AuthStatus.failure);
      expect(provider.errorMessage, contains('Too many failed attempts'));
    });

    test('authenticate() returns early when attemptCount >= 3', () async {
      final provider = AuthProvider(
        gatekeeper: FakeGatekeeperService(
          failureResult: const Failure(code: 'cancelled', message: 'failed'),
        ),
      );

      // Lock out by failing 3 times
      for (int i = 0; i < 3; i++) {
        await provider.authenticate();
      }
      expect(provider.attemptCount, 3);

      // Attempt again while locked out
      await provider.authenticate();

      expect(provider.attemptCount, 3);
      expect(provider.status, AuthStatus.failure);
    });

    test('authenticate() success resets attemptCount to 0', () async {
      final provider = AuthProvider(gatekeeper: FakeGatekeeperService());

      // Simulate prior failures
      provider.value = AuthState(
        status: AuthStatus.failure,
        errorMessage: 'prior failures',
        attemptCount: 2,
      );

      await provider.authenticate();

      expect(provider.attemptCount, 0);
      expect(provider.status, AuthStatus.success);
    });

    test('reset() clears status and errorMessage', () {
      final provider = AuthProvider(gatekeeper: FakeGatekeeperService());
      provider.value = AuthState(
        status: AuthStatus.failure,
        errorMessage: 'something went wrong',
        attemptCount: 1,
      );

      provider.reset();

      expect(provider.status, AuthStatus.idle);
      expect(provider.errorMessage, isNull);
      expect(provider.attemptCount, 0);
    });
  });
}
