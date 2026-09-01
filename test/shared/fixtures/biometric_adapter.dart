import 'package:bdo_event/core/security/biometric.dart';

class RecordingBiometricAdapter implements BiometricAdapter {
  RecordingBiometricAdapter({
    this.available = true,
    this.authenticated = true,
    this.availabilityError,
    this.authenticationError,
  });

  final bool available;
  final bool authenticated;
  final Object? availabilityError;
  final Object? authenticationError;
  int availabilityCalls = 0;
  int authenticationCalls = 0;
  String? localizedReason;

  @override
  Future<bool> isAvailable() async {
    availabilityCalls++;
    if (availabilityError != null) throw availabilityError!;
    return available;
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    authenticationCalls++;
    this.localizedReason = localizedReason;
    if (authenticationError != null) throw authenticationError!;
    return authenticated;
  }
}
