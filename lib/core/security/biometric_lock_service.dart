import 'biometric_adapter.dart';

class BiometricLockService {
  factory BiometricLockService({BiometricAdapter? adapter}) {
    return BiometricLockService._(
      adapter ?? LocalAuthBiometricAdapter(),
    );
  }

  BiometricLockService._(this._adapter);

  final BiometricAdapter _adapter;

  Future<bool> isAvailable() async {
    try {
      return await _adapter.isAvailable();
    } on Object {
      return false;
    }
  }

  Future<bool> unlock() async {
    if (!await isAvailable()) return false;
    try {
      return await _adapter.authenticate(
        localizedReason: 'Authenticate to open your event account',
      );
    } on Object {
      return false;
    }
  }
}
