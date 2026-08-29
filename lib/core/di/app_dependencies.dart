import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/common/supabase_request_logger/supabase_request_logger.dart';
import 'package:bdo_event/features/auth_screen/data/datasource/auth_remote_data_source.dart';
import 'package:bdo_event/features/auth_screen/data/repositories/auth_repository.dart';
import 'package:bdo_event/features/auth_screen/presentation/cubit/auth_screen_cubit.dart';
import 'package:bdo_event/features/auth_screen/signin_screen/presentation/cubit/signin_cubit.dart';
import 'package:bdo_event/features/auth_screen/signup_screen/presentation/cubit/signup_cubit.dart';
import 'package:bdo_event/features/calendar_screen/data/datasource/registration_remote_data_source.dart';
import 'package:bdo_event/features/calendar_screen/data/repositories/calendar_repository.dart';
import 'package:bdo_event/features/calendar_screen/domain/usecases/load_registered_events.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_cubit.dart';
import 'package:bdo_event/features/event_detail_screen/data/repositories/registered_event_repository.dart'
    as event_detail;
import 'package:bdo_event/features/event_detail_screen/domain/usecases/registration_use_cases.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_cubit.dart';
import 'package:bdo_event/features/event_screen/data/datasource/event_remote_data_source.dart';
import 'package:bdo_event/features/event_screen/data/repositories/event_repository.dart';
import 'package:bdo_event/features/event_screen/domain/usecases/event_use_cases.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:bdo_event/features/registered_screen/data/repositories/registered_event_repository.dart';
import 'package:bdo_event/features/registered_screen/data/datasource/registered_event_remote_data_source.dart';
import 'package:bdo_event/features/registered_screen/domain/usecases/cancel_registered_event.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_cubit.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  if (getIt.isRegistered<AuthScreenCubit>()) return;

  getIt.registerLazySingleton<SupabaseRequestLogger>(
    SupabaseRequestLogger.new,
  );
  getIt.registerLazySingleton<SupabaseStore>(
    () => SupabaseStore(logger: getIt()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(logger: getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(store: getIt(), authDataSource: getIt()),
  );
  getIt.registerLazySingleton<RegistrationRemoteDataSource>(
    () => RegistrationRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<CalendarRepository>(
    () => CalendarRepository(getIt()),
  );
  getIt.registerLazySingleton<LoadRegisteredEvents>(
    () => LoadRegisteredEvents(getIt()),
  );
  getIt.registerLazySingleton<RegisteredEventRepository>(
    () => RegisteredEventRepository(dataSource: getIt()),
  );
  getIt.registerLazySingleton<RegisteredEventRemoteDataSource>(
    () => RegisteredEventRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<CancelRegisteredEvent>(
    () => CancelRegisteredEvent(getIt()),
  );
  getIt.registerLazySingleton<event_detail.RegisteredEventRepository>(
    () => event_detail.RegisteredEventRepository(
      dataSource: getIt(),
      authRepository: getIt(),
    ),
  );
  getIt.registerLazySingleton<RegisterForEvent>(
    () => RegisterForEvent(getIt<event_detail.RegisteredEventRepository>()),
  );
  getIt.registerLazySingleton<CancelEventRegistration>(
    () => CancelEventRegistration(
      getIt<event_detail.RegisteredEventRepository>(),
    ),
  );
  getIt.registerLazySingleton<EventDataSource>(
    () => EventRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<EventRepository>(
    () => EventRepository(dataSource: getIt(), authRepository: getIt()),
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
    CalendarScreenCubit(loadRegisteredEvents: getIt(), authRepository: getIt()),
  );
  getIt.registerSingleton<EventDetailCubit>(
    EventDetailCubit(
      registerForEvent: getIt(),
      cancelEventRegistration: getIt(),
      eventStore: getIt(),
      authRepository: getIt(),
    ),
  );
  getIt.registerSingleton<EventScreenCubit>(
    EventScreenCubit(
      loadEvents: getIt(),
      createEvent: getIt(),
      updateEvent: getIt(),
      deleteEvent: getIt(),
      authRepository: getIt(),
    ),
  );
  getIt.registerSingleton<MainScreenCubit>(MainScreenCubit());
  getIt.registerSingleton<ProfileScreenCubit>(
    ProfileScreenCubit(authRepository: getIt()),
  );
  getIt.registerSingleton<RegisteredEventCubit>(
    RegisteredEventCubit(
      cancelRegisteredEvent: getIt(),
      authRepository: getIt(),
      eventStore: getIt(),
    ),
  );
  getIt.registerSingleton<WatcherScanCubit>(
    WatcherScanCubit(eventStore: getIt(), authRepository: getIt()),
  );
}
