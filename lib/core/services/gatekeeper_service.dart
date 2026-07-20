import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../failure.dart';

class GatekeeperService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<Either<Failure, bool>> authenticate() async {
    try {
      final canAuth = await _auth.canCheckBiometrics ||
          await _auth.isDeviceSupported();
      if (!canAuth) {
        return const Left(Failure(
          code: 'unavailable',
          message: 'This device does not support biometric authentication.',
        ));
      }

      final result = await _auth.authenticate(
        localizedReason: 'Authenticate to access key generator',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (result) return const Right(true);

      return const Left(Failure(
        code: 'cancelled',
        message: 'Authentication cancelled or not recognized. Try again.',
      ));
    } on PlatformException catch (e) {
      return Left(_failureFromPlatformException(e));
    } catch (e) {
      return Left(Failure(
        code: 'unknown',
        message: 'An unexpected error occurred: $e',
        exception: e,
      ));
    }
  }

  Failure _failureFromPlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return const Failure(
          code: 'unavailable',
          message:
              'Biometric authentication is not available on this device.',
        );
      case 'NotEnrolled':
        return const Failure(
          code: 'not_enrolled',
          message:
              'No biometrics enrolled. Go to Settings > Security to set up fingerprint or face unlock.',
        );
      case 'PermissionDenied':
        return const Failure(
          code: 'permission_denied',
          message:
              'Biometric permission not granted. Check app permissions in Settings.',
        );
      default:
        return Failure(
          code: 'platform_error',
          message: e.message ?? 'Unknown platform error.',
          exception: e,
        );
    }
  }
}
