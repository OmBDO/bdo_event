import 'package:bdo_event/core/util/resource/app_other.dart';

class ProfilePreferences {
  static const reminderLeadTimeOptions = <int>[60, 1440, 10080];

  const ProfilePreferences({
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
    this.dateFormat = AppDateFormats.dayMonthYear,
    this.isBiometricLockEnabled = false,
  });

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

  ProfilePreferences copyWith({
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
  }) => ProfilePreferences(
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
  );
}
