import 'package:bdo_event/features/auth_screen/data/repositories/auth_repository.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreenCubit extends Cubit<ProfileScreenState> {
  ProfileScreenCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
      super(
          ProfileScreenState(
            user: authRepository.currentUser,
            isNotificationEnabled:
                authRepository.currentUser?.notificationsEnabled ?? true,
          ),
        );

  final AuthRepository _authRepository;

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
  }

  void toggleDarkMode(bool enabled) {
    emit(state.copyWith(isDarkModeEnabled: enabled));
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
