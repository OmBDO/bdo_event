import 'dart:convert';

import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WatcherScanCubit extends Cubit<WatcherScanState> {
  WatcherScanCubit({required this._eventStore, required this._authRepository})
    : super(const WatcherScanState());

  final EventStore _eventStore;
  final AuthRepositoryContract _authRepository;

  Future<void> validate(String rawValue) async {
    if (state.status != WatcherScanStatus.idle || isClosed) return;
    if (!_authRepository.can(UserPermission.scanRegistrations)) {
      emit(
        state.copyWith(
          status: WatcherScanStatus.failure,
          message: AppText.watcherAccessRequired,
        ),
      );
      return;
    }

    try {
      final payload = jsonDecode(rawValue);
      if (payload is! Map<String, dynamic> ||
          payload['type'] != AppIdentifiers.qrRegistrationType ||
          payload['eventId'] is! String ||
          payload['token'] is! String) {
        emit(
          state.copyWith(
            status: WatcherScanStatus.invalid,
            message: AppText.invalidRegistrationQr,
          ),
        );
        return;
      }

      emit(state.copyWith(status: WatcherScanStatus.scanning));
      final result = await _eventStore.validateRegistration(
        token: payload['token'] as String,
        eventId: payload['eventId'] as String,
      );
      if (result == null) {
        emit(
          state.copyWith(
            status: WatcherScanStatus.invalid,
            message: AppText.invalidRegistrationQr,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: WatcherScanStatus.valid,
          eventId: result['event_id'] as String?,
          registrationToken: payload['token'] as String,
          userId: result['user_id'] as String?,
          message: AppText.registrationValid,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: WatcherScanStatus.failure,
          message: AppText.invalidRegistrationQr,
        ),
      );
    }
  }

  Future<void> checkIn() async {
    final eventId = state.eventId;
    final token = state.registrationToken;
    if (
        eventId == null ||
        token == null ||
        state.status != WatcherScanStatus.valid ||
        isClosed) {
      return;
    }
    emit(state.copyWith(status: WatcherScanStatus.checkingIn));
    try {
      final result = await _eventStore.checkInRegistration(
        token: token,
        eventId: eventId,
      );
      emit(
        state.copyWith(
          status: WatcherScanStatus.valid,
          message: switch (result) {
            'checked_in' => AppText.checkedIn,
            'already_checked_in' => AppText.alreadyCheckedIn,
            _ => AppText.checkInUnavailable,
          },
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: WatcherScanStatus.failure,
          message: AppText.unableToCheckIn,
        ),
      );
    }
  }

  void reset() => emit(const WatcherScanState());
}
