import 'package:local_auth/local_auth.dart';

abstract interface class BiometricAdapter {
  Future<bool> isAvailable();

  Future<bool> authenticate({required String localizedReason});
}

class LocalAuthBiometricAdapter implements BiometricAdapter {
  LocalAuthBiometricAdapter({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  @override
  Future<bool> isAvailable() async {
    return await _authentication.isDeviceSupported() &&
        await _authentication.canCheckBiometrics;
  }

  @override
  Future<bool> authenticate({required String localizedReason}) =>
      _authentication.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
}
