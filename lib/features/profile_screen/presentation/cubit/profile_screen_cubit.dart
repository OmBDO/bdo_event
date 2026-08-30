import 'dart:async';

import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/profile_screen/domain/entities/profile_preferences.dart';
import 'package:bdo_event/features/profile_screen/domain/usecases/load_profile_preferences.dart';
import 'package:bdo_event/features/profile_screen/domain/usecases/save_profile_preferences.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_state.dart';
import 'package:bdo_event/core/notifications/event_reminder_notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/security/biometric_lock_service.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/features/profile_screen/domain/entities/profile_visibility.dart';

class ProfileScreenCubit extends Cubit<ProfileScreenState> {
  ProfileScreenCubit({
    required AuthRepositoryContract authRepository,
    required LoadProfilePreferences loadProfilePreferences,
    required SaveProfilePreferences saveProfilePreferences,
    EventReminderNotificationService? reminderNotifications,
    BiometricLockService? biometricLockService,
    EventStore? eventStore,
  })
      : _authRepository = authRepository,
        _saveProfilePreferences = saveProfilePreferences,
        _reminderNotifications = reminderNotifications,
        _biometricLockService = biometricLockService,
        _eventStore = eventStore,
      super(_initialState(authRepository, loadProfilePreferences.call()));

  static ProfileScreenState _initialState(
    AuthRepositoryContract authRepository,
    ProfilePreferences preferences,
  ) => ProfileScreenState(
    user: authRepository.currentUser,
    isNotificationEnabled: authRepository.currentUser?.notificationsEnabled ?? true,
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
    dateFormat: preferences.dateFormat,
    isBiometricLockEnabled: preferences.isBiometricLockEnabled,
  );

  final AuthRepositoryContract _authRepository;
  final SaveProfilePreferences _saveProfilePreferences;
  final EventReminderNotificationService? _reminderNotifications;
  final BiometricLockService? _biometricLockService;
  final EventStore? _eventStore;

  void refresh() {
    final user = _authRepository.currentUser;
    emit(
      state.copyWith(
        user: user,
        isNotificationEnabled: user?.notificationsEnabled ?? true,
        status: ProfileScreenStatus.ready,
        clearErrorMessage: true,
      ),
    );
    unawaited(loadVisibility());
  }

  Future<void> loadVisibility() async {
    final userId = state.user?.id ?? _authRepository.currentUser?.id;
    if (userId == null || _eventStore == null) return;
    try {
      final values = await _eventStore.loadProfileVisibility(userId);
      if (!isClosed) {
        emit(state.copyWith(
          profileVisibility: ProfileVisibility.fromStorage(values['profile_visibility']),
          registrationVisibility:
              RegistrationVisibility.fromStorage(values['registration_visibility']),
        ));
      }
    } on Object {
      return;
    }
  }

  Future<void> updateVisibility({
    ProfileVisibility? profileVisibility,
    RegistrationVisibility? registrationVisibility,
  }) async {
    final nextProfile = profileVisibility ?? state.profileVisibility;
    final nextRegistration =
        registrationVisibility ?? state.registrationVisibility;
    emit(state.copyWith(
      profileVisibility: nextProfile,
      registrationVisibility: nextRegistration,
    ));
    final userId = state.user?.id ?? _authRepository.currentUser?.id;
    if (userId == null || _eventStore == null) return;
    try {
      await _eventStore.saveProfileVisibility(
        userId: userId,
        profileVisibility: nextProfile.storageValue,
        registrationVisibility: nextRegistration.storageValue,
      );
    } on Object {
      return;
    }
  }

  void toggleDarkMode(bool enabled) {
    emit(state.copyWith(isDarkModeEnabled: enabled));
    unawaited(_persistPreferences(_preferencesFromState().copyWith(
      isDarkModeEnabled: enabled,
    )));
  }

  void updateDateFormat(String format) {
    emit(state.copyWith(dateFormat: format));
    unawaited(_persistPreferences(_preferencesFromState().copyWith(
      dateFormat: format,
    )));
  }

  Future<bool> toggleBiometricLock(bool enabled) async {
    if (enabled) {
      final isAvailable = await _biometricLockService?.isAvailable() ?? false;
      if (!isAvailable) return false;
      final authenticated = await _biometricLockService!.unlock();
      if (!authenticated) return false;
    }
    if (isClosed) return false;
    emit(state.copyWith(isBiometricLockEnabled: enabled));
    unawaited(_persistPreferences(_preferencesFromState().copyWith(
      isBiometricLockEnabled: enabled,
    )));
    return true;
  }

  void toggleLargeText(bool enabled) {
    emit(state.copyWith(isLargeTextEnabled: enabled));
    unawaited(_persistPreferences(_preferencesFromState().copyWith(
      isLargeTextEnabled: enabled,
    )));
  }

  void toggleHighContrast(bool enabled) {
    emit(state.copyWith(isHighContrastEnabled: enabled));
    unawaited(_persistPreferences(_preferencesFromState().copyWith(
      isHighContrastEnabled: enabled,
    )));
  }

  void toggleWatcherVoiceMuted(bool enabled) {
    emit(state.copyWith(isWatcherVoiceMuted: enabled));
    unawaited(_persistPreferences(_preferencesFromState().copyWith(
      isWatcherVoiceMuted: enabled,
    )));
  }

  void toggleWatcherVibration(bool enabled) {
    emit(state.copyWith(isWatcherVibrationEnabled: enabled));
    unawaited(_persistPreferences(_preferencesFromState().copyWith(
      isWatcherVibrationEnabled: enabled,
    )));
  }

  void updateWatcherSoundVolume(double value) {
    final volume = value.clamp(0.0, 1.0).toDouble();
    emit(state.copyWith(watcherSoundVolume: volume));
    unawaited(_persistPreferences(_preferencesFromState().copyWith(
      watcherSoundVolume: volume,
    )));
  }

  void toggleWatcherAutoOpenNext(bool enabled) {
    emit(state.copyWith(isWatcherAutoOpenNextEnabled: enabled));
    unawaited(_persistPreferences(_preferencesFromState().copyWith(
      isWatcherAutoOpenNextEnabled: enabled,
    )));
  }

  void toggleWatcherKeepHistoryVisibleAfterCheckIn(bool enabled) {
    emit(state.copyWith(isWatcherKeepHistoryVisibleAfterCheckIn: enabled));
    unawaited(_persistPreferences(_preferencesFromState().copyWith(
      isWatcherKeepHistoryVisibleAfterCheckIn: enabled,
    )));
  }

  Future<String?> changePassword(String password) =>
      _authRepository.updatePassword(password);

  Future<String?> updateProfile({
    required String displayName,
    required String email,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
    String? locale,
  }) async {
    final error = await _authRepository.updateProfile(
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      bio: bio,
      locale: locale,
    );
    if (error == null && !isClosed) {
      refresh();
    }
    return error;
  }

  Future<void> toggleEventReminders(bool enabled) async {
    emit(state.copyWith(isEventRemindersEnabled: enabled));
    await _persistPreferences(_preferencesFromState());
    await _reconcileReminders();
  }

  Future<void> updateEventReminderLeadTime(int minutes) async {
    if (!ProfilePreferences.reminderLeadTimeOptions.contains(minutes)) {
      return;
    }
    emit(state.copyWith(eventReminderLeadTimeMinutes: minutes));
    await _persistPreferences(_preferencesFromState());
    await _reconcileReminders();
  }

  ProfilePreferences _preferencesFromState() => ProfilePreferences(
    isDarkModeEnabled: state.isDarkModeEnabled,
    isLargeTextEnabled: state.isLargeTextEnabled,
    isHighContrastEnabled: state.isHighContrastEnabled,
    isWatcherVoiceMuted: state.isWatcherVoiceMuted,
    isWatcherVibrationEnabled: state.isWatcherVibrationEnabled,
    watcherSoundVolume: state.watcherSoundVolume,
    isWatcherAutoOpenNextEnabled: state.isWatcherAutoOpenNextEnabled,
    isWatcherKeepHistoryVisibleAfterCheckIn:
      state.isWatcherKeepHistoryVisibleAfterCheckIn,
    isEventRemindersEnabled: state.isEventRemindersEnabled,
    eventReminderLeadTimeMinutes: state.eventReminderLeadTimeMinutes,
    dateFormat: state.dateFormat,
    isBiometricLockEnabled: state.isBiometricLockEnabled,
  );

  Future<void> _persistPreferences(ProfilePreferences preferences) async {
    try {
      await _saveProfilePreferences(preferences);
    } on Object {
      return;
    }
  }

  Future<void> _reconcileReminders() async {
    try {
      await _reminderNotifications?.reconcileLastEventReminders(
        enabled: state.isEventRemindersEnabled,
        leadTime: Duration(minutes: state.eventReminderLeadTimeMinutes),
      );
    } on Object {
      return;
    }
  }

  void clearState() {
    emit(const ProfileScreenState(user: null, isNotificationEnabled: true));
  }

  Future<void> updateNotificationPreference(bool enabled) async {
    emit(
      state.copyWith(
        status: ProfileScreenStatus.savingNotificationPreference,
        isNotificationEnabled: enabled,
        clearErrorMessage: true,
      ),
    );

    final error = await _authRepository.updateNotificationPreference(enabled);
    if (isClosed) return;

    if (error != null) {
      emit(
        state.copyWith(
          status: ProfileScreenStatus.notificationPreferenceError,
          isNotificationEnabled: !enabled,
          errorMessage: error,
        ),
      );
      return;
    }

    emit(state.copyWith(status: ProfileScreenStatus.ready));
  }
}
