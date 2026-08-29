import 'dart:async';
import 'dart:convert';

import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
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

  test('event registration clears isSubmitting when the repository throws', () async {
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
  });

  test('ticket cancellation clears isCancelling when the repository throws', () async {
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
  });

  test('scanner ignores a second QR validation while the first is pending', () async {
    final resultCompleter = Completer<Map<String, dynamic>?>();
    final store = FakeEventStore()..validationResult = resultCompleter.future;
    final cubit = WatcherScanCubit(
      eventStore: store,
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
  });
}

class FakeAuthRepository implements AuthRepositoryContract {
  FakeAuthRepository({Set<UserRole>? roles}) : _roles = roles ?? {UserRole.admin};

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
  Future<String?> login({required String email, required String password}) async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required UserRole requestedRole,
  }) async => null;
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

class FakeRegisteredEventRepository implements RegisteredEventRepositoryContract {
  bool throwOnCancel = false;

  @override
  Future<String?> cancelRegistration(Event event) async {
    if (throwOnCancel) throw StateError('cancel failed');
    return null;
  }
}

class FakeEventStore implements EventStore {
  Future<Map<String, dynamic>?> validationResult = Future.value(null);
  int validationCalls = 0;

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
  Future<void> writeRegistrations(String userId, List<Event> events) async {}

  @override
  Future<void> activateRegistration(String userId, Event event) async {}

  @override
  Future<void> revokeRegistration(String userId, String eventId) async {}

  @override
  Future<String?> loadRegistrationToken(String userId, String eventId) async => null;

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
  Future<int> loadAttendanceCount(String eventId) async => 0;
}
