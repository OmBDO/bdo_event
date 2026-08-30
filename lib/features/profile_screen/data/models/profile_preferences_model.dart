import 'package:bdo_event/features/profile_screen/domain/entities/profile_preferences.dart';

class ProfilePreferencesModel extends ProfilePreferences {
  const ProfilePreferencesModel({
    super.isDarkModeEnabled,
    super.isLargeTextEnabled,
    super.isHighContrastEnabled,
    super.isWatcherVoiceMuted,
    super.isWatcherVibrationEnabled,
    super.watcherSoundVolume,
    super.isWatcherAutoOpenNextEnabled,
    super.isWatcherKeepHistoryVisibleAfterCheckIn,
    super.isEventRemindersEnabled,
    super.eventReminderLeadTimeMinutes,
    super.dateFormat,
    super.isBiometricLockEnabled,
  });

  factory ProfilePreferencesModel.fromPreferences({
    required bool isDarkModeEnabled,
    required bool isLargeTextEnabled,
    required bool isHighContrastEnabled,
    required bool isWatcherVoiceMuted,
    required bool isWatcherVibrationEnabled,
    required double watcherSoundVolume,
    required bool isWatcherAutoOpenNextEnabled,
    required bool isWatcherKeepHistoryVisibleAfterCheckIn,
    required bool isEventRemindersEnabled,
    required int eventReminderLeadTimeMinutes,
    String dateFormat = 'dd/MM/yyyy',
    bool isBiometricLockEnabled = false,
  }) => ProfilePreferencesModel(
    isDarkModeEnabled: isDarkModeEnabled,
    isLargeTextEnabled: isLargeTextEnabled,
    isHighContrastEnabled: isHighContrastEnabled,
    isWatcherVoiceMuted: isWatcherVoiceMuted,
    isWatcherVibrationEnabled: isWatcherVibrationEnabled,
    watcherSoundVolume: watcherSoundVolume,
    isWatcherAutoOpenNextEnabled: isWatcherAutoOpenNextEnabled,
    isWatcherKeepHistoryVisibleAfterCheckIn:
      isWatcherKeepHistoryVisibleAfterCheckIn,
    isEventRemindersEnabled: isEventRemindersEnabled,
    eventReminderLeadTimeMinutes: eventReminderLeadTimeMinutes,
    dateFormat: dateFormat,
    isBiometricLockEnabled: isBiometricLockEnabled,
  );
}
