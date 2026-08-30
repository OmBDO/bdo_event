import 'package:bdo_event/features/profile_screen/data/datasource/profile_preferences_local_data_source.dart';
import 'package:bdo_event/features/profile_screen/data/models/profile_preferences_model.dart';
import 'package:bdo_event/features/profile_screen/domain/entities/profile_preferences.dart';
import 'package:bdo_event/features/profile_screen/domain/repositories/profile_preferences_repository.dart';

class ProfilePreferencesRepository
    implements ProfilePreferencesRepositoryContract {
  const ProfilePreferencesRepository(this._dataSource);

  final ProfilePreferencesLocalDataSource _dataSource;

  @override
  ProfilePreferences load() => _dataSource.load();

  @override
  Future<void> save(ProfilePreferences preferences) => _dataSource.save(
    ProfilePreferencesModel(
      isDarkModeEnabled: preferences.isDarkModeEnabled,
      isLargeTextEnabled: preferences.isLargeTextEnabled,
      isHighContrastEnabled: preferences.isHighContrastEnabled,
      isWatcherVoiceMuted: preferences.isWatcherVoiceMuted,
      isWatcherVibrationEnabled: preferences.isWatcherVibrationEnabled,
      watcherSoundVolume: preferences.watcherSoundVolume,
        isWatcherAutoOpenNextEnabled: preferences.isWatcherAutoOpenNextEnabled,
        isWatcherKeepHistoryVisibleAfterCheckIn:
          preferences.isWatcherKeepHistoryVisibleAfterCheckIn,
      isEventRemindersEnabled: preferences.isEventRemindersEnabled,
      eventReminderLeadTimeMinutes: preferences.eventReminderLeadTimeMinutes,
    ),
  );
}
