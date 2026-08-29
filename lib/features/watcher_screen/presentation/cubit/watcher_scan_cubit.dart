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
      final payload = _decodeRegistrationValue(rawValue);
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
              displayName: result['display_name'] as String?,
              eventId: result['event_id'] as String?,
              status: 'Ready to check in',
            ),
            ...state.history,
          ].take(20).toList(),
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

  Map<String, dynamic>? _decodeRegistrationValue(String rawValue) {
    try {
      final payload = jsonDecode(rawValue);
      return payload is Map<String, dynamic> ? payload : null;
    } on FormatException {
      if (!rawValue.startsWith('BDO1')) return null;
      try {
        final encoded = rawValue.substring(4);
        if (encoded.isEmpty || encoded.length.isOdd) return null;
        final bytes = <int>[];
        for (var index = 0; index < encoded.length; index += 2) {
          bytes.add(int.parse(encoded.substring(index, index + 2), radix: 16));
        }
        final decoded = utf8.decode(bytes);
        final separator = decoded.lastIndexOf('|');
        if (separator <= 0 || separator == decoded.length - 1) return null;
        return {
          'type': AppIdentifiers.qrRegistrationType,
          'eventId': decoded.substring(0, separator),
          'token': decoded.substring(separator + 1),
        };
      } on FormatException {
        return null;
      }
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

  Future<void> checkInAll() async {
    final pending = state.history
        .where((entry) => entry.status == 'Ready to check in')
        .toList();
    if (pending.isEmpty || state.status == WatcherScanStatus.checkingIn) return;

    emit(state.copyWith(status: WatcherScanStatus.checkingIn));
    for (final entry in pending) {
      final eventId = entry.eventId;
      if (eventId == null) continue;
      try {
        final result = await _checkInRegistration(
          token: entry.registrationToken,
          eventId: eventId,
        );
        final updatedHistory = state.history.map((current) {
          if (current.registrationToken != entry.registrationToken) {
            return current;
          }
          return current.copyWith(status: _checkInStatus(result));
        }).toList();
        emit(state.copyWith(history: updatedHistory));
      } on Object {
        // Keep failed entries pending so the watcher can retry them.
      }
    }
    if (!isClosed) {
      emit(
        state.copyWith(
          status: WatcherScanStatus.idle,
          clearResult: true,
          message: AppText.checkedIn,
        ),
      );
    }
    final eventId = pending.first.eventId;
    if (eventId != null) await _loadDashboard(eventId);
  }

  String _checkInStatus(String result) => switch (result) {
    'checked_in' => 'Checked in',
    'already_checked_in' => 'Already checked in',
    _ => 'Unavailable',
  };

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
