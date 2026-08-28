import 'package:bdo_event/core/util/event.resource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String mapAuthError(Object error, {required bool signingUp}) {
  if (error is AuthException) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return AppText.emailOrPasswordIncorrect;
    }
    if (signingUp &&
        (message.contains('already registered') ||
            message.contains('already exists') ||
            message.contains('user already'))) {
      return AppText.emailAlreadyRegistered;
    }
  }

  return signingUp ? AppText.unableToCreateAccount : AppText.unableToSignIn;
}