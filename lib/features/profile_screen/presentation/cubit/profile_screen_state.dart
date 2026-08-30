import 'package:bdo_event/core/model/user_model/user_model.dart';

enum ProfileScreenStatus { ready, savingNotificationPreference, notificationPreferenceError }

class ProfileScreenState {
  final User? user;
  final ProfileScreenStatus status;
  final bool isNotificationEnabled;
  final bool isDarkModeEnabled;
  final bool isLargeTextEnabled;
  final bool isHighContrastEnabled;
  final bool isWatcherVoiceMuted;
  final bool isWatcherVibrationEnabled;
  final double watcherSoundVolume;
  final bool isWatcherAutoOpenNextEnabled;
  final bool isWatcherKeepHistoryVisibleAfterCheckIn;
  final bool isEventRemindersEnabled;
  final int eventReminderLeadTimeMinutes;
  final String dateFormat;
  final bool isBiometricLockEnabled;
  final String? errorMessage;

  const ProfileScreenState({
    required this.user,
    required this.isNotificationEnabled,
    this.isDarkModeEnabled = false,
    this.isLargeTextEnabled = false,
    this.isHighContrastEnabled = false,
    this.isWatcherVoiceMuted = false,
    this.isWatcherVibrationEnabled = true,
    this.watcherSoundVolume = 1.0,
    this.isWatcherAutoOpenNextEnabled = true,
    this.isWatcherKeepHistoryVisibleAfterCheckIn = false,
    this.isEventRemindersEnabled = true,
    this.eventReminderLeadTimeMinutes = 1440,
    this.dateFormat = 'dd/MM/yyyy',
    this.isBiometricLockEnabled = false,
    this.status = ProfileScreenStatus.ready,
    this.errorMessage,
  });

  ProfileScreenState copyWith({
    User? user,
    ProfileScreenStatus? status,
    bool? isNotificationEnabled,
    bool? isDarkModeEnabled,
    bool? isLargeTextEnabled,
    bool? isHighContrastEnabled,
    bool? isWatcherVoiceMuted,
    bool? isWatcherVibrationEnabled,
    double? watcherSoundVolume,
    bool? isWatcherAutoOpenNextEnabled,
    bool? isWatcherKeepHistoryVisibleAfterCheckIn,
    bool? isEventRemindersEnabled,
    int? eventReminderLeadTimeMinutes,
    String? dateFormat,
    bool? isBiometricLockEnabled,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) => ProfileScreenState(
    user: user ?? this.user,
    status: status ?? this.status,
    isNotificationEnabled:
        isNotificationEnabled ?? this.isNotificationEnabled,
    isDarkModeEnabled: isDarkModeEnabled ?? this.isDarkModeEnabled,
    isLargeTextEnabled: isLargeTextEnabled ?? this.isLargeTextEnabled,
    isHighContrastEnabled: isHighContrastEnabled ?? this.isHighContrastEnabled,
    isWatcherVoiceMuted: isWatcherVoiceMuted ?? this.isWatcherVoiceMuted,
    isWatcherVibrationEnabled:
      isWatcherVibrationEnabled ?? this.isWatcherVibrationEnabled,
    watcherSoundVolume: watcherSoundVolume ?? this.watcherSoundVolume,
    isWatcherAutoOpenNextEnabled:
      isWatcherAutoOpenNextEnabled ?? this.isWatcherAutoOpenNextEnabled,
    isWatcherKeepHistoryVisibleAfterCheckIn:
      isWatcherKeepHistoryVisibleAfterCheckIn ??
      this.isWatcherKeepHistoryVisibleAfterCheckIn,
    isEventRemindersEnabled:
      isEventRemindersEnabled ?? this.isEventRemindersEnabled,
    eventReminderLeadTimeMinutes:
      eventReminderLeadTimeMinutes ?? this.eventReminderLeadTimeMinutes,
    dateFormat: dateFormat ?? this.dateFormat,
    isBiometricLockEnabled:
      isBiometricLockEnabled ?? this.isBiometricLockEnabled,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}
