import 'package:bdo_event/features/profile_screen/data/models/profile_preferences_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ProfilePreferencesLocalDataSource {
  ProfilePreferencesModel load();

  Future<void> save(ProfilePreferencesModel preferences);
}

class ProfilePreferencesLocalDataSourceImpl
    implements ProfilePreferencesLocalDataSource {
  ProfilePreferencesLocalDataSourceImpl(this._preferences);

  final SharedPreferences? _preferences;

  static const _watcherVoiceMutedKey = 'watcher_voice_muted';
  static const _darkModeKey = 'dark_mode_enabled';
  static const _largeTextKey = 'large_text_enabled';
  static const _highContrastKey = 'high_contrast_enabled';
  static const _watcherVibrationKey = 'watcher_vibration_enabled';
  static const _watcherSoundVolumeKey = 'watcher_sound_volume';
  static const _watcherAutoOpenNextKey = 'watcher_auto_open_next_enabled';
  static const _watcherKeepHistoryKey =
      'watcher_keep_history_visible_after_check_in';
  static const _eventRemindersEnabledKey = 'event_reminders_enabled';
  static const _eventReminderLeadTimeKey = 'event_reminder_lead_time';
  static const _dateFormatKey = 'date_format';
  static const _biometricLockKey = 'biometric_lock_enabled';

  @override
  ProfilePreferencesModel load() => ProfilePreferencesModel.fromPreferences(
    isDarkModeEnabled: _preferences?.getBool(_darkModeKey) ?? false,
    isLargeTextEnabled: _preferences?.getBool(_largeTextKey) ?? false,
    isHighContrastEnabled: _preferences?.getBool(_highContrastKey) ?? false,
    isWatcherVoiceMuted: _preferences?.getBool(_watcherVoiceMutedKey) ?? false,
    isWatcherVibrationEnabled:
        _preferences?.getBool(_watcherVibrationKey) ?? true,
    watcherSoundVolume: _preferences?.getDouble(_watcherSoundVolumeKey) ?? 1.0,
    isWatcherAutoOpenNextEnabled:
      _preferences?.getBool(_watcherAutoOpenNextKey) ?? true,
    isWatcherKeepHistoryVisibleAfterCheckIn:
      _preferences?.getBool(_watcherKeepHistoryKey) ?? false,
    isEventRemindersEnabled:
        _preferences?.getBool(_eventRemindersEnabledKey) ?? true,
    eventReminderLeadTimeMinutes:
        _preferences?.getInt(_eventReminderLeadTimeKey) ?? 1440,
    dateFormat: _preferences?.getString(_dateFormatKey) ?? 'dd/MM/yyyy',
    isBiometricLockEnabled: _preferences?.getBool(_biometricLockKey) ?? false,
  );

  @override
  Future<void> save(ProfilePreferencesModel preferences) async {
    if (_preferences == null) return;
    await _preferences!.setBool(
      _darkModeKey,
      preferences.isDarkModeEnabled,
    );
    await _preferences!.setBool(
      _largeTextKey,
      preferences.isLargeTextEnabled,
    );
    await _preferences!.setBool(
      _highContrastKey,
      preferences.isHighContrastEnabled,
    );
    await _preferences!.setBool(
      _watcherVoiceMutedKey,
      preferences.isWatcherVoiceMuted,
    );
    await _preferences!.setBool(
      _watcherVibrationKey,
      preferences.isWatcherVibrationEnabled,
    );
    await _preferences!.setDouble(
      _watcherSoundVolumeKey,
      preferences.watcherSoundVolume,
    );
    await _preferences!.setBool(
      _watcherAutoOpenNextKey,
      preferences.isWatcherAutoOpenNextEnabled,
    );
    await _preferences!.setBool(
      _watcherKeepHistoryKey,
      preferences.isWatcherKeepHistoryVisibleAfterCheckIn,
    );
    await _preferences!.setBool(
      _eventRemindersEnabledKey,
      preferences.isEventRemindersEnabled,
    );
    await _preferences!.setInt(
      _eventReminderLeadTimeKey,
      preferences.eventReminderLeadTimeMinutes,
    );
    await _preferences!.setString(_dateFormatKey, preferences.dateFormat);
    await _preferences!.setBool(
      _biometricLockKey,
      preferences.isBiometricLockEnabled,
    );
  }
}
