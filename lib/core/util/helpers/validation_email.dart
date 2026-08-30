import 'package:bdo_event/core/util/event_resource.dart';

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return AppText.enterEmail;
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return AppText.validEmail;
  }
  return null;
}
