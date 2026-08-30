import 'package:local_auth/local_auth.dart';

class BiometricLockService {
  BiometricLockService([LocalAuthentication? authentication])
      : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  Future<bool> isAvailable() async {
    try {
      return await _authentication.isDeviceSupported() &&
          await _authentication.canCheckBiometrics;
    } on Object {
      return false;
    }
  }

  Future<bool> unlock() async {
    if (!await isAvailable()) return false;
    try {
      return _authentication.authenticate(
        localizedReason: 'Authenticate to open your event account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on Object {
      return false;
    }
  }
}