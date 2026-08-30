import 'dart:async';
import 'dart:convert';

import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/model/user_model/event_attendee.dart';
import 'package:bdo_event/core/model/notification_model/notification_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/event_detail_screen/domain/repositories/registration_repository.dart';
import 'package:bdo_event/features/event_detail_screen/domain/usecases/registration_use_cases.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_cubit.dart';
import 'package:bdo_event/features/event_screen/domain/entities/event_operation_result.dart';
import 'package:bdo_event/features/event_screen/domain/repositories/event_repository.dart';
import 'package:bdo_event/features/event_screen/domain/usecases/event_use_cases.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_cubit.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_state.dart';
import 'package:bdo_event/features/registered_screen/domain/repositories/registered_event_repository.dart';
import 'package:bdo_event/features/registered_screen/domain/usecases/cancel_registered_event.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_cubit.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_cubit.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_state.dart';
import 'package:bdo_event/features/watcher_screen/data/datasource/watcher_remote_data_source.dart';
import 'package:bdo_event/features/watcher_screen/data/repositories/watcher_repository.dart';
import 'package:bdo_event/features/watcher_screen/domain/usecases/check_in_registration.dart';
import 'package:bdo_event/features/watcher_screen/domain/usecases/load_scan_dashboard.dart';
import 'package:bdo_event/features/watcher_screen/domain/usecases/validate_registration.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final event = const Event(
    id: 'event-1',
    title: 'Community Festival',
    date: '2026-09-01',
    location: 'Pune',
    imageUrl: '',
  );

  test('finishLoading moves the main screen out of loading', () {
    final cubit = MainScreenCubit();

    cubit.finishLoading();

    expect(cubit.state.status, MainScreenStatus.ready);
    cubit.close();
  });

  test('event save clears isSaving when the repository throws', () async {
    final repository = FakeEventRepository()..throwOnSave = true;
    final cubit = EventScreenCubit(
      loadEvents: LoadEvents(repository),
      createEvent: CreateEvent(repository),
      updateEvent: UpdateEvent(repository),
      deleteEvent: DeleteEvent(repository),
      authRepository: FakeAuthRepository(),
    );

    final error = await cubit.save(event, isEditing: false);

    expect(error, AppText.unableToSaveEvent);
    expect(cubit.state.isSaving, isFalse);
    expect(cubit.state.error, AppText.unableToSaveEvent);
    await cubit.close();
  });

  test(
    'event registration clears isSubmitting when the repository throws',
    () async {
      final repository = FakeRegistrationRepository()..throwOnRegister = true;
      final cubit = EventDetailCubit(
        registerForEvent: RegisterForEvent(repository),
        cancelEventRegistration: CancelEventRegistration(repository),
        eventStore: FakeEventStore(),
        authRepository: FakeAuthRepository(),
      );

      final error = await cubit.register(event);

      expect(error, AppText.unableToSaveRegistration);
      expect(cubit.state.isSubmitting, isFalse);
      expect(cubit.state.error, AppText.unableToSaveRegistration);
      await cubit.close();
    },
  );

  test(
    'ticket cancellation clears isCancelling when the repository throws',
    () async {
      final repository = FakeRegisteredEventRepository()..throwOnCancel = true;
      final cubit = RegisteredEventCubit(
        cancelRegisteredEvent: CancelRegisteredEvent(repository),
        authRepository: FakeAuthRepository(),
        eventStore: FakeEventStore(),
      );

      final cancelled = await cubit.cancel(event);

      expect(cancelled, isFalse);
      expect(cubit.state.isCancelling, isFalse);
      expect(cubit.state.error, AppText.unableToCancelRegistration);
      await cubit.close();
    },
  );

  test(
    'scanner ignores a second QR validation while the first is pending',
    () async {
      final resultCompleter = Completer<Map<String, dynamic>?>();
      final store = FakeEventStore()..validationResult = resultCompleter.future;
      final repository = WatcherRepository(WatcherRemoteDataSourceImpl(store));
      final cubit = WatcherScanCubit(
        validateRegistration: ValidateRegistration(repository),
        checkInRegistration: CheckInRegistration(repository),
        loadScanDashboard: LoadScanDashboard(repository),
        authRepository: FakeAuthRepository(roles: {UserRole.watcher}),
      );
      final qr = jsonEncode({
        'type': AppIdentifiers.qrRegistrationType,
        'eventId': event.id,
        'token': 'token-1',
      });

      final first = cubit.validate(qr);
      await Future<void>.delayed(Duration.zero);
      final second = cubit.validate(qr);

      expect(cubit.state.status, WatcherScanStatus.scanning);
      expect(store.validationCalls, 1);

      resultCompleter.complete({'event_id': event.id, 'user_id': 'user-1'});
      await Future.wait([first, second]);

      expect(cubit.state.status, WatcherScanStatus.valid);
      expect(store.validationCalls, 1);
      await cubit.close();
    },
  );

  test(
    'watcher dashboard loads aggregate counts without attendee profiles',
    () async {
      final store = FakeEventStore()
        ..attendanceCount = 12
        ..checkedInCount = 4;
      final repository = WatcherRepository(WatcherRemoteDataSourceImpl(store));

      final dashboard = await repository.loadDashboard(event.id);

      expect(dashboard.expectedCount, 12);
      expect(dashboard.checkedInCount, 4);
      expect(store.attendanceCountCalls, 1);
      expect(store.attendeeCalls, 0);
    },
  );

  test(
    'event attendance ignores a stale response from an older request',
    () async {
      final firstResult = Completer<int>();
      final secondResult = Completer<int>();
      final store = FakeEventStore()
        ..attendanceResults['event-1'] = firstResult.future
        ..attendanceResults['event-2'] = secondResult.future;
      final cubit = EventDetailCubit(
        registerForEvent: RegisterForEvent(FakeRegistrationRepository()),
        cancelEventRegistration: CancelEventRegistration(
          FakeRegistrationRepository(),
        ),
        eventStore: store,
        authRepository: FakeAuthRepository(),
      );
      final firstEvent = event.copyWith(id: 'event-1', creatorId: 'user-1');
      final secondEvent = event.copyWith(id: 'event-2', creatorId: 'user-1');

      final firstLoad = cubit.loadAttendanceCount(firstEvent);
      final secondLoad = cubit.loadAttendanceCount(secondEvent);
      secondResult.complete(2);
      firstResult.complete(1);
      await Future.wait([firstLoad, secondLoad]);

      expect(cubit.state.attendanceCount, 2);
      await cubit.close();
    },
  );

  test('ticket token ignores a stale response from an older request', () async {
    final firstResult = Completer<String?>();
    final secondResult = Completer<String?>();
    final store = FakeEventStore()
      ..tokenResults['event-1'] = firstResult.future
      ..tokenResults['event-2'] = secondResult.future;
    final cubit = RegisteredEventCubit(
      cancelRegisteredEvent: CancelRegisteredEvent(
        FakeRegisteredEventRepository(),
      ),
      authRepository: FakeAuthRepository(),
      eventStore: store,
      reminderNotifications: null,
    );

    final firstLoad = cubit.loadToken('event-1');
    final secondLoad = cubit.loadToken('event-2');
    secondResult.complete('token-2');
    firstResult.complete('token-1');
    await Future.wait([firstLoad, secondLoad]);

    expect(cubit.state.registrationToken, 'token-2');
    await cubit.close();
  });
}

class FakeAuthRepository implements AuthRepositoryContract {
  FakeAuthRepository({Set<UserRole>? roles})
    : _roles = roles ?? {UserRole.admin};

  final Set<UserRole> _roles;
  final User user = User(
    id: 'user-1',
    displayName: 'Test User',
    email: 'test@example.com',
    roles: const {UserRole.admin},
    createdAt: DateTime(2026),
  );

  @override
  User get currentUser => user.copyWith(roles: _roles);

  @override
  bool can(UserPermission permission) =>
      _roles.expand((role) => role.permissions).contains(permission);

  @override
  bool canUpdate(Event event) => can(UserPermission.updateOwnEvents);

  @override
  bool canDelete(Event event) => can(UserPermission.deleteOwnEvents);

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> login({
    required String email,
    required String password,
  }) async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required UserRole requestedRole,
  }) async => null;

  @override
  Future<String?> logoutEverywhere() {
    // TODO: implement logoutEverywhere
    throw UnimplementedError();
  }

  @override
  Future<String?> updatePassword(String password) {
    // TODO: implement updatePassword
    throw UnimplementedError();
  }

  @override
  Future<String?> updateProfile({
    required String displayName,
    required String email,
  }) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }
}

class FakeEventRepository implements EventRepositoryContract {
  bool throwOnSave = false;

  @override
  Future<List<Event>> loadEvents() async => const [];

  @override
  Future<EventOperationResult> createEvent(Event event, User user) async {
    if (throwOnSave) throw StateError('create failed');
    return EventOperationResult([event]);
  }

  @override
  Future<EventOperationResult> updateEvent(Event event) async {
    if (throwOnSave) throw StateError('update failed');
    return EventOperationResult([event]);
  }

  @override
  Future<EventOperationResult> deleteEvent(Event event) async =>
      EventOperationResult([event]);
}

class FakeRegistrationRepository implements RegistrationRepositoryContract {
  bool throwOnRegister = false;

  @override
  Future<bool> isUserRegistered(String eventId) async => false;

  @override
  Future<String?> registerEvent(Event event) async {
    if (throwOnRegister) throw StateError('register failed');
    return null;
  }

  @override
  Future<String?> cancelRegistration(Event event) async => null;
}

class FakeRegisteredEventRepository
    implements RegisteredEventRepositoryContract {
  bool throwOnCancel = false;

  @override
  Future<String?> cancelRegistration(Event event) async {
    if (throwOnCancel) throw StateError('cancel failed');
    return null;
  }
}

class FakeEventStore implements EventStore {
  Future<Map<String, dynamic>?> validationResult = Future.value(null);
  final Map<String, Future<int>> attendanceResults = {};
  final Map<String, Future<String?>> tokenResults = {};
  int validationCalls = 0;
  int attendanceCount = 0;
  int checkedInCount = 0;
  int attendanceCountCalls = 0;
  int attendeeCalls = 0;

  @override
  Future<List<Event>> readCreatedEvents() async => const [];

  @override
  Future<void> createEvent(Event event) async {}

  @override
  Future<void> updateEvent(Event event) async {}

  @override
  Future<void> deleteEvent(String eventId) async {}

  @override
  Future<List<Event>> loadRegistrations(String userId) async => const [];

  @override
  Future<Map<String, int>> loadRegistrationCounts(
    List<String> eventIds,
  ) async => const {};

  @override
  Future<void> activateRegistration(String userId, Event event) async {}

  @override
  Future<void> revokeRegistration(String userId, String eventId) async {}

  @override
  Future<String?> loadRegistrationToken(String userId, String eventId) =>
      tokenResults[eventId] ?? Future.value(null);

  @override
  Future<Map<String, dynamic>?> validateRegistration({
    required String token,
    required String eventId,
  }) {
    validationCalls++;
    return validationResult;
  }

  @override
  Future<String> checkInRegistration({
    required String token,
    required String eventId,
  }) async => 'checked_in';

  @override
  Future<int> loadAttendanceCount(String eventId) {
    attendanceCountCalls++;
    return attendanceResults[eventId] ?? Future.value(attendanceCount);
  }

  @override
  Future<int> loadCheckedInCount(String eventId) async => checkedInCount;

  @override
  Future<List<EventAttendee>> loadEventAttendees(String eventId) async {
    attendeeCalls++;
    return [];
  }

  @override
  Future<List<AppNotification>> loadNotifications() async => [];

  @override
  Future<int> loadUnreadNotificationCount() async => 0;

  @override
  Future<void> markNotificationRead(String notificationId) async {}

  @override
  Future<void> updateArrivalStatus({
    required String eventId,
    required ArrivalStatus status,
  }) async {}

  @override
  Future<List<Map<String, String>>> loadInvitationRecipients() {
    // TODO: implement loadInvitationRecipients
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> loadProfileVisibility(String userId) {
    // TODO: implement loadProfileVisibility
    throw UnimplementedError();
  }

  @override
  Future<void> recordLoginActivity({String? deviceLabel, String? platform}) {
    // TODO: implement recordLoginActivity
    throw UnimplementedError();
  }

  @override
  Future<void> respondToEventInvitation({
    required String eventId,
    required bool accepted,
  }) {
    // TODO: implement respondToEventInvitation
    throw UnimplementedError();
  }

  @override
  Future<void> saveProfileVisibility({
    required String userId,
    required String profileVisibility,
    required String registrationVisibility,
  }) {
    // TODO: implement saveProfileVisibility
    throw UnimplementedError();
  }

  @override
  Future<int> sendEventInvitations({
    required String eventId,
    required List<String> userIds,
  }) {
    // TODO: implement sendEventInvitations
    throw UnimplementedError();
  }
}
