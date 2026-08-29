import 'dart:convert';

import 'package:bdo_event/core/util/event.resource.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/features/watcher_screen/domain/model/scan_history_entry.dart';
import 'package:bdo_event/features/watcher_screen/domain/usecases/check_in_registration.dart';
import 'package:bdo_event/features/watcher_screen/domain/usecases/load_scan_dashboard.dart';
import 'package:bdo_event/features/watcher_screen/domain/usecases/validate_registration.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WatcherScanCubit extends Cubit<WatcherScanState> {
  WatcherScanCubit({
    required ValidateRegistration validateRegistration,
    required CheckInRegistration checkInRegistration,
    required LoadScanDashboard loadScanDashboard,
    required this._authRepository,
  }) : _validateRegistration = validateRegistration,
       _checkInRegistration = checkInRegistration,
       _loadScanDashboard = loadScanDashboard,
       super(const WatcherScanState());

  final ValidateRegistration _validateRegistration;
  final CheckInRegistration _checkInRegistration;
  final LoadScanDashboard _loadScanDashboard;
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
      final result = await _validateRegistration(
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
          history: [
            ScanHistoryEntry(
              registrationToken: payload['token'] as String,
              userId: result['user_id'] as String?,
              status: 'Ready to check in',
            ),
            ...state.history,
          ].take(5).toList(),
        ),
      );
      await _loadDashboard(result['event_id'] as String);
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
    if (eventId == null ||
        token == null ||
        state.status != WatcherScanStatus.valid ||
        isClosed) {
      return;
    }
    emit(state.copyWith(status: WatcherScanStatus.checkingIn));
    try {
      final result = await _checkInRegistration(token: token, eventId: eventId);
      final updatedHistory = state.history.map((entry) {
        if (entry.registrationToken != token) return entry;
        return entry.copyWith(
          status: result == 'checked_in'
              ? 'Checked in'
              : result == 'already_checked_in'
              ? 'Already checked in'
              : 'Unavailable',
        );
      }).toList();
      emit(
        state.copyWith(
          status: WatcherScanStatus.valid,
          history: updatedHistory,
          message: switch (result) {
            'checked_in' => AppText.checkedIn,
            'already_checked_in' => AppText.alreadyCheckedIn,
            _ => AppText.checkInUnavailable,
          },
        ),
      );
      await _loadDashboard(eventId);
    } on Object {
      emit(
        state.copyWith(
          status: WatcherScanStatus.failure,
          message: AppText.unableToCheckIn,
        ),
      );
    }
  }

  void reset() => emit(
    state.copyWith(
      status: WatcherScanStatus.idle,
      clearResult: true,
      clearMessage: true,
    ),
  );

  Future<void> _loadDashboard(String eventId) async {
    try {
      final dashboard = await _loadScanDashboard(eventId);
      if (!isClosed) {
        emit(
          state.copyWith(
            checkedInCount: dashboard.checkedInCount,
            expectedCount: dashboard.expectedCount,
          ),
        );
      }
    } on Object {
      // Counter access must not prevent a valid scan from being checked in.
    }
  }
}
