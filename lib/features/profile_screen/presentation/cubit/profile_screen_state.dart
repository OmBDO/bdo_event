import 'package:bdo_event/core/model/user_model/user_model.dart';

enum ProfileScreenStatus { ready, savingNotificationPreference, notificationPreferenceError }

class ProfileScreenState {
  final User? user;
  final ProfileScreenStatus status;
  final bool isNotificationEnabled;
  final bool isDarkModeEnabled;
  final String? errorMessage;

  const ProfileScreenState({
    required this.user,
    required this.isNotificationEnabled,
    this.isDarkModeEnabled = false,
    this.status = ProfileScreenStatus.ready,
    this.errorMessage,
  });

  ProfileScreenState copyWith({
    User? user,
    ProfileScreenStatus? status,
    bool? isNotificationEnabled,
    bool? isDarkModeEnabled,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) => ProfileScreenState(
    user: user ?? this.user,
    status: status ?? this.status,
    isNotificationEnabled:
        isNotificationEnabled ?? this.isNotificationEnabled,
    isDarkModeEnabled: isDarkModeEnabled ?? this.isDarkModeEnabled,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}
