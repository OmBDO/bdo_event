import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/prefs/recent_event_store.dart';
import 'package:bdo_event/core/notifications/event_reminder_notification_service.dart';
import 'package:bdo_event/core/common/supabase_request_logger/supabase_request_logger.dart';
import 'package:bdo_event/features/auth_screen/data/datasource/auth_remote_data_source.dart';
import 'package:bdo_event/features/auth_screen/data/repositories/auth_repository.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/auth_screen/presentation/cubit/auth_screen_cubit.dart';
import 'package:bdo_event/features/auth_screen/signin_screen/presentation/cubit/signin_cubit.dart';
import 'package:bdo_event/features/auth_screen/signup_screen/presentation/cubit/signup_cubit.dart';
import 'package:bdo_event/features/calendar_screen/data/datasource/registration_remote_data_source.dart';
import 'package:bdo_event/features/calendar_screen/data/repositories/calendar_repository.dart';
import 'package:bdo_event/features/calendar_screen/domain/repositories/calendar_repository.dart';
import 'package:bdo_event/features/calendar_screen/domain/usecases/load_registered_events.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_cubit.dart';
import 'package:bdo_event/features/event_detail_screen/data/repositories/registered_event_repository.dart'
    as event_detail;
import 'package:bdo_event/features/event_detail_screen/data/datasource/registration_remote_data_source.dart'
    as event_detail_data_source;
import 'package:bdo_event/features/event_detail_screen/domain/usecases/registration_use_cases.dart';
import 'package:bdo_event/features/event_detail_screen/domain/repositories/registration_repository.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_cubit.dart';
import 'package:bdo_event/features/event_screen/data/datasource/event_remote_data_source.dart';
import 'package:bdo_event/features/event_screen/data/repositories/event_repository.dart';
import 'package:bdo_event/features/event_screen/domain/repositories/event_repository.dart';
import 'package:bdo_event/features/event_screen/domain/usecases/event_use_cases.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/data/datasource/profile_preferences_local_data_source.dart';
import 'package:bdo_event/features/profile_screen/data/repositories/profile_preferences_repository.dart';
import 'package:bdo_event/features/profile_screen/domain/repositories/profile_preferences_repository.dart';
import 'package:bdo_event/features/profile_screen/domain/usecases/load_profile_preferences.dart';
import 'package:bdo_event/features/profile_screen/domain/usecases/save_profile_preferences.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:bdo_event/features/registered_screen/data/repositories/registered_event_repository.dart';
import 'package:bdo_event/features/registered_screen/data/datasource/registered_event_remote_data_source.dart';
import 'package:bdo_event/features/registered_screen/domain/usecases/cancel_registered_event.dart';
import 'package:bdo_event/features/registered_screen/domain/repositories/registered_event_repository.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_cubit.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_cubit.dart';
import 'package:bdo_event/features/watcher_screen/data/datasource/watcher_remote_data_source.dart';
import 'package:bdo_event/features/watcher_screen/data/repositories/watcher_repository.dart';
import 'package:bdo_event/features/watcher_screen/domain/repositories/watcher_repository_contract.dart';
import 'package:bdo_event/features/watcher_screen/domain/usecases/check_in_registration.dart';
import 'package:bdo_event/features/watcher_screen/domain/usecases/load_scan_dashboard.dart';
import 'package:bdo_event/features/watcher_screen/domain/usecases/validate_registration.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

void configureDependencies({SharedPreferences? preferences}) {
  if (getIt.isRegistered<AuthScreenCubit>()) return;

  if (preferences != null) {
    getIt.registerSingleton<SharedPreferences>(preferences);
  }
  getIt.registerLazySingleton<RecentEventStore>(
    () => RecentEventStore(preferences),
  );

  getIt.registerLazySingleton<SupabaseRequestLogger>(SupabaseRequestLogger.new);
  getIt.registerLazySingleton<EventReminderNotificationService>(
    EventReminderNotificationService.new,
  );
  getIt.registerLazySingleton<SupabaseStore>(
    () => SupabaseStore(logger: getIt()),
  );
  getIt.registerLazySingleton<EventStore>(() => getIt<SupabaseStore>());
  getIt.registerLazySingleton<WatcherRemoteDataSource>(
    () => WatcherRemoteDataSourceImpl(getIt<EventStore>()),
  );
  getIt.registerLazySingleton<WatcherRepositoryContract>(
    () => WatcherRepository(getIt<WatcherRemoteDataSource>()),
  );
  getIt.registerLazySingleton<ValidateRegistration>(
    () => ValidateRegistration(getIt<WatcherRepositoryContract>()),
  );
  getIt.registerLazySingleton<CheckInRegistration>(
    () => CheckInRegistration(getIt<WatcherRepositoryContract>()),
  );
  getIt.registerLazySingleton<LoadScanDashboard>(
    () => LoadScanDashboard(getIt<WatcherRepositoryContract>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(logger: getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(store: getIt(), authDataSource: getIt()),
  );
  getIt.registerLazySingleton<AuthRepositoryContract>(
    () => getIt<AuthRepository>(),
  );
  getIt.registerLazySingleton<ProfilePreferencesLocalDataSource>(
    () => ProfilePreferencesLocalDataSourceImpl(
      getIt.isRegistered<SharedPreferences>()
          ? getIt<SharedPreferences>()
          : null,
    ),
  );
  getIt.registerLazySingleton<ProfilePreferencesRepositoryContract>(
    () => ProfilePreferencesRepository(getIt()),
  );
  getIt.registerLazySingleton<LoadProfilePreferences>(
    () => LoadProfilePreferences(getIt()),
  );
  getIt.registerLazySingleton<SaveProfilePreferences>(
    () => SaveProfilePreferences(getIt()),
  );
  getIt.registerLazySingleton<RegistrationDataSource>(
    () => RegistrationRemoteDataSource(getIt<EventStore>()),
  );
  getIt.registerLazySingleton<CalendarRepositoryContract>(
    () => CalendarRepository(getIt<RegistrationDataSource>()),
  );
  getIt.registerLazySingleton<LoadRegisteredEvents>(
    () => LoadRegisteredEvents(getIt<CalendarRepositoryContract>()),
  );
  getIt.registerLazySingleton<RegisteredEventRemoteDataSource>(
    () => RegisteredEventRemoteDataSource(getIt<CancelEventRegistration>()),
  );
  getIt.registerLazySingleton<RegisteredEventRepositoryContract>(
    () => RegisteredEventRepository(
      dataSource: getIt<RegisteredEventRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<CancelRegisteredEvent>(
    () => CancelRegisteredEvent(getIt()),
  );
  getIt.registerLazySingleton<event_detail_data_source.RegistrationDataSource>(
    () => event_detail_data_source.RegistrationRemoteDataSource(
      getIt<EventStore>(),
    ),
  );
  getIt.registerLazySingleton<RegistrationRepositoryContract>(
    () => event_detail.RegisteredEventRepository(
      dataSource: getIt<event_detail_data_source.RegistrationDataSource>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<RegisterForEvent>(
    () => RegisterForEvent(getIt<RegistrationRepositoryContract>()),
  );
  getIt.registerLazySingleton<CancelEventRegistration>(
    () => CancelEventRegistration(getIt<RegistrationRepositoryContract>()),
  );
  getIt.registerLazySingleton<EventDataSource>(
    () => EventRemoteDataSource(getIt<EventStore>()),
  );
  getIt.registerLazySingleton<EventRepositoryContract>(
    () => EventRepository(
      dataSource: getIt<EventDataSource>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<LoadEvents>(() => LoadEvents(getIt()));
  getIt.registerLazySingleton<CreateEvent>(() => CreateEvent(getIt()));
  getIt.registerLazySingleton<UpdateEvent>(() => UpdateEvent(getIt()));
  getIt.registerLazySingleton<DeleteEvent>(() => DeleteEvent(getIt()));

  getIt.registerSingleton<AuthScreenCubit>(
    AuthScreenCubit(authRepository: getIt()),
  );
  getIt.registerSingleton<SignInCubit>(SignInCubit(authRepository: getIt()));
  getIt.registerSingleton<SignUpCubit>(SignUpCubit(authRepository: getIt()));
  getIt.registerSingleton<CalendarScreenCubit>(
    CalendarScreenCubit(
      loadRegisteredEvents: getIt(),
      authRepository: getIt(),
      reminderNotifications: getIt(),
      _preferences: getIt.isRegistered<SharedPreferences>()
          ? getIt<SharedPreferences>()
          : null,
    ),
  );
  getIt.registerFactory<EventDetailCubit>(
    () => EventDetailCubit(
      registerForEvent: getIt(),
      cancelEventRegistration: getIt(),
      eventStore: getIt(),
      authRepository: getIt(),
    ),
  );
  getIt.registerSingleton<EventScreenCubit>(
    EventScreenCubit(
      loadEvents: getIt(),
      loadRegisteredEvents: getIt(),
      createEvent: getIt(),
      updateEvent: getIt(),
      deleteEvent: getIt(),
      authRepository: getIt(),
      recentEventStore: getIt(),
      preferences: preferences,
    ),
  );
  getIt.registerSingleton<MainScreenCubit>(MainScreenCubit());
  getIt.registerSingleton<ProfileScreenCubit>(
    ProfileScreenCubit(
      authRepository: getIt(),
      loadProfilePreferences: getIt(),
      saveProfilePreferences: getIt(),
      reminderNotifications: getIt(),
    ),
  );
  getIt.registerFactory<RegisteredEventCubit>(
    () => RegisteredEventCubit(
      cancelRegisteredEvent: getIt(),
      authRepository: getIt(),
      eventStore: getIt(),
      reminderNotifications: getIt(),
    ),
  );

  getIt.registerSingleton<WatcherScanCubit>(
    WatcherScanCubit(
      validateRegistration: getIt(),
      checkInRegistration: getIt(),
      loadScanDashboard: getIt(),
      authRepository: getIt(),
    ),
  );
}
