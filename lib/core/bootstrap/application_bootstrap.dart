import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/notifications/event_reminder_notification_service.dart';
import 'package:bdo_event/dotenv.dart';
import 'package:bdo_event/features/auth_screen/presentation/cubit/auth_screen_cubit.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_cubit.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef SupabaseInitializer = Future<void> Function({
  required String url,
  required String publishableKey,
});

typedef PreferencesLoader = Future<SharedPreferences> Function();
typedef DependencyConfigurator = void Function({
  SharedPreferences? preferences,
});
typedef AsyncInitializer = Future<void> Function();
typedef SyncInitializer = void Function();

class ApplicationBootstrap {
  ApplicationBootstrap({
    this.loadEnvironment = DotEnvInitialization.initialize,
    this.initializeSupabase = _initializeSupabase,
    this.loadPreferences = SharedPreferences.getInstance,
    this.configureDependencies = _configureDependencies,
    this.initializeNotifications = _initializeNotifications,
    this.restoreSession = _restoreSession,
    this.refreshProfile = _refreshProfile,
    this.loadRegistrations = _loadRegistrations,
    this.finishLoading = _finishLoading,
  });

  final Future<DotEnvInitialization?> Function() loadEnvironment;
  final SupabaseInitializer initializeSupabase;
  final PreferencesLoader loadPreferences;
  final DependencyConfigurator configureDependencies;
  final AsyncInitializer initializeNotifications;
  final AsyncInitializer restoreSession;
  final SyncInitializer refreshProfile;
  final AsyncInitializer loadRegistrations;
  final SyncInitializer finishLoading;

  Future<bool> initialize() async {
    final environment = await loadEnvironment();
    if (environment == null) return false;

    await initializeSupabase(
      url: environment.supabaseUrl,
      publishableKey: environment.supabaseAnonKey,
    );
    final preferences = await loadPreferences();
    configureDependencies(preferences: preferences);
    await initializeNotifications();
    await restoreSession();
    refreshProfile();
    await loadRegistrations();
    finishLoading();
    return true;
  }

  static Future<void> _initializeSupabase({
    required String url,
    required String publishableKey,
  }) async {
    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
    );
  }

  static void _configureDependencies({SharedPreferences? preferences}) {
    configureDependencies(preferences: preferences);
  }

  static Future<void> _initializeNotifications() =>
      getIt<EventReminderNotificationService>().initialize();

  static Future<void> _restoreSession() =>
      getIt<AuthScreenCubit>().checkActiveSession();

  static void _refreshProfile() => getIt<ProfileScreenCubit>().refresh();

  static Future<void> _loadRegistrations() =>
      getIt<CalendarScreenCubit>().loadRegistrations();

  static void _finishLoading() => getIt<MainScreenCubit>().finishLoading();
}
