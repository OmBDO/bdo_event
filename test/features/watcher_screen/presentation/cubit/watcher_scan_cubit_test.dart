import 'dart:convert';

import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:bdo_event/core/util/registration_code_codec.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/watcher_screen/data/datasource/watcher_remote_data_source.dart';
import 'package:bdo_event/features/watcher_screen/data/repositories/watcher_repository.dart';
import 'package:bdo_event/features/watcher_screen/domain/model/scan_dashboard.dart';
import 'package:bdo_event/features/watcher_screen/domain/model/scan_history_entry.dart';
import 'package:bdo_event/features/watcher_screen/domain/usecases/check_in_registration.dart';
import 'package:bdo_event/features/watcher_screen/domain/usecases/load_scan_dashboard.dart';
import 'package:bdo_event/features/watcher_screen/domain/usecases/validate_registration.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_cubit.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final validJson = jsonEncode({
    'type': AppIdentifiers.qrRegistrationType,
    'eventId': 'event-1',
    'token': 'token-1',
  });

  test('rejects validation for users without scan permission', () async {
    final store = FakeWatcherStore();
    final cubit = createCubit(store, role: UserRole.user);

    await cubit.validate(validJson);

    expect(cubit.state.status, WatcherScanStatus.failure);
    expect(cubit.state.message, AppText.watcherAccessRequired);
    expect(store.validationCalls, 0);
    await cubit.close();
  });

  test('validates JSON and records trimmed display name', () async {
    final store = FakeWatcherStore(
      validationResult: {
        'event_id': 'event-1',
        'user_id': 'user-1',
        'display_name': '  Asha  ',
      },
    );
    final cubit = createCubit(store);

    await cubit.validate(validJson);

    expect(cubit.state.status, WatcherScanStatus.valid);
    expect(cubit.state.registrationToken, 'token-1');
    expect(cubit.state.history.single.displayName, 'Asha');
    expect(cubit.state.message, AppText.registrationValid);
    await cubit.close();
  });

  test('validates compact registration codes', () async {
    final code = RegistrationCodeCodec.encode(eventId: 'event-1', token: 'token-1');
    final store = FakeWatcherStore(
      validationResult: {'event_id': 'event-1', 'user_id': 'user-1'},
    );
    final cubit = createCubit(store);

    await cubit.validate(code);

    expect(cubit.state.status, WatcherScanStatus.valid);
    expect(cubit.state.registrationToken, 'token-1');
    await cubit.close();
  });

  test('rejects malformed and incomplete registration values', () async {
    final cubit = createCubit(FakeWatcherStore());

    await cubit.validate('not-json-or-code');
    expect(cubit.state.status, WatcherScanStatus.invalid);
    cubit.reset();
    await cubit.validate(jsonEncode({'type': 'wrong'}));
    expect(cubit.state.status, WatcherScanStatus.invalid);
    await cubit.close();
  });

  test('maps check-in outcomes and updates history', () async {
    final store = FakeWatcherStore(
      validationResult: {'event_id': 'event-1', 'user_id': 'user-1'},
      checkInResult: 'checked_in',
    );
    final cubit = createCubit(store);
    await cubit.validate(validJson);

    await cubit.checkIn(autoOpenNext: false);

    expect(cubit.state.status, WatcherScanStatus.idle);
    expect(cubit.state.history.single.status, 'Checked in');
    expect(cubit.state.message, AppText.checkedIn);
    await cubit.close();
  });

  test('auto-opens the next pending scan after check-in', () async {
    final store = FakeWatcherStore(
      validationResult: {'event_id': 'event-1', 'user_id': 'user-1'},
    );
    final cubit = createCubit(store);
    await cubit.validate(validJson);
    cubit.emit(cubit.state.copyWith(
      history: [
        const ScanHistoryEntry(
          registrationToken: 'token-2',
          userId: 'user-2',
          eventId: 'event-2',
          status: 'Ready to check in',
        ),
        ...cubit.state.history,
      ],
    ));

    await cubit.checkIn();

    expect(cubit.state.status, WatcherScanStatus.valid);
    expect(cubit.state.registrationToken, 'token-2');
    expect(cubit.state.eventId, 'event-2');
    await cubit.close();
  });

  test('keeps a valid scan when dashboard loading fails', () async {
    final store = FakeWatcherStore(
      validationResult: {'event_id': 'event-1', 'user_id': 'user-1'},
      dashboardError: StateError('dashboard unavailable'),
    );
    final cubit = createCubit(store);

    await cubit.validate(validJson);

    expect(cubit.state.status, WatcherScanStatus.valid);
    expect(cubit.state.registrationToken, 'token-1');
    await cubit.close();
  });

  test('maps check-in exceptions to a failure state', () async {
    final store = FakeWatcherStore(
      validationResult: {'event_id': 'event-1', 'user_id': 'user-1'},
      checkInError: StateError('check-in unavailable'),
    );
    final cubit = createCubit(store);
    await cubit.validate(validJson);

    await cubit.checkIn();

    expect(cubit.state.status, WatcherScanStatus.failure);
    expect(cubit.state.message, AppText.unableToCheckIn);
    await cubit.close();
  });

  test('checkInAll reports partial failures and updates successful entries',
      () async {
    final store = FakeWatcherStore(
      checkInResults: {'token-1': 'checked_in'},
      checkInErrors: {'token-2': StateError('failed')},
    );
    final cubit = createCubit(store);
    cubit.emit(cubit.state.copyWith(
      history: const [
        ScanHistoryEntry(
          registrationToken: 'token-1',
          userId: 'user-1',
          eventId: 'event-1',
          status: 'Ready to check in',
        ),
        ScanHistoryEntry(
          registrationToken: 'token-2',
          userId: 'user-2',
          eventId: 'event-2',
          status: 'Ready to check in',
        ),
      ],
    ));

    await cubit.checkInAll(autoOpenNext: false);

    expect(cubit.state.history.first.status, 'Checked in');
    expect(cubit.state.history.last.status, 'Ready to check in');
    expect(cubit.state.status, WatcherScanStatus.idle);
    await cubit.close();
  });

  test('reset and clearState return the scanner to idle and empty state', () async {
    final cubit = createCubit(FakeWatcherStore());
    cubit.emit(cubit.state.copyWith(
      status: WatcherScanStatus.failure,
      message: 'error',
      history: const [
        ScanHistoryEntry(
          registrationToken: 'token-1',
          userId: 'user-1',
          status: 'Checked in',
        ),
      ],
    ));

    cubit.reset();
    expect(cubit.state.status, WatcherScanStatus.idle);
    expect(cubit.state.history, hasLength(1));
    cubit.clearState();
    expect(cubit.state, const WatcherScanState());
    await cubit.close();
  });

  test('closed Cubit ignores validation and check-in', () async {
    final store = FakeWatcherStore(
      validationResult: {'event_id': 'event-1', 'user_id': 'user-1'},
    );
    final cubit = createCubit(store);
    await cubit.close();

    await cubit.validate(validJson);
    await cubit.checkIn();

    expect(store.validationCalls, 0);
  });
}

WatcherScanCubit createCubit(
  FakeWatcherStore store, {
  UserRole role = UserRole.watcher,
}) {
  final repository = WatcherRepository(WatcherRemoteDataSourceImpl(store));
  return WatcherScanCubit(
    validateRegistration: ValidateRegistration(repository),
    checkInRegistration: CheckInRegistration(repository),
    loadScanDashboard: LoadScanDashboard(repository),
    authRepository: FakeAuthRepository(role),
  );
}

class FakeWatcherStore implements WatcherStore {
  FakeWatcherStore({
    this.validationResult,
    this.checkInResult = 'checked_in',
    this.checkInError,
    this.dashboardError,
    this.checkInResults = const {},
    this.checkInErrors = const {},
  });

  final Map<String, dynamic>? validationResult;
  final String checkInResult;
  final Object? checkInError;
  final Object? dashboardError;
  final Map<String, String> checkInResults;
  final Map<String, Object> checkInErrors;
  int validationCalls = 0;

  @override
  Future<Map<String, dynamic>?> validateRegistration({required String token, required String eventId}) async {
    validationCalls++;
    return validationResult;
  }

  @override
  Future<String> checkInRegistration({
    required String token,
    required String eventId,
  }) async {
    final error = checkInErrors[token] ?? checkInError;
    if (error != null) throw error;
    return checkInResults[token] ?? checkInResult;
  }

  @override
  Future<int> loadAttendanceCount(String eventId) async {
    if (dashboardError != null) throw dashboardError!;
    return 1;
  }
  @override
  Future<int> loadCheckedInCount(String eventId) async => 0;
}

class FakeAuthRepository implements AuthRepositoryContract {
  FakeAuthRepository(UserRole role)
    : currentUser = User(
        id: 'user-1',
        displayName: 'Watcher',
        email: 'watcher@example.com',
        roles: {role},
        createdAt: DateTime.utc(2026, 8, 1),
      );

  @override
  final User currentUser;
  @override
  bool can(UserPermission permission) => currentUser.hasPermission(permission);
  @override
  bool canDelete(Event event) => false;
  @override
  bool canUpdate(Event event) => false;
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> register({required String name, required String email, required String password, required UserRole requestedRole}) async => null;
  @override
  Future<String?> login({required String email, required String password}) async => null;
  @override
  Future<String?> updatePassword(String password) async => null;
  @override
  Future<String?> updateProfile({required String displayName, required String email, String? photoUrl, String? phoneNumber, String? bio, String? locale}) async => null;
  @override
  Future<void> logout() async {}
  @override
  Future<String?> logoutEverywhere() async => null;
  @override
  Future<String?> updateNotificationPreference(bool enable) async => null;
}
