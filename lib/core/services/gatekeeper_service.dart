import 'package:local_auth/local_auth.dart';

class GatekeeperService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final bool canAuth = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canAuth) return false;

      return await _auth.authenticate(
        localizedReason: 'Authenticate to access key generator',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> canAuthenticate() async {
    return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  }
}
