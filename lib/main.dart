import 'package:bdo_event/dotenv.dart' show DotEnvInitialization;
import 'package:bdo_event/features/auth_screen/presentation/pages/auth_screen.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:bdo_event/features/auth_screen/presentation/cubit/auth_screen_cubit.dart';
import 'package:bdo_event/features/auth_screen/signin_screen/presentation/cubit/signin_cubit.dart';
import 'package:bdo_event/features/auth_screen/signup_screen/presentation/cubit/signup_cubit.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_cubit.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_cubit.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_cubit.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_cubit.dart';
import 'package:bdo_event/core/common/configuration_error_app/configuration_error_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Run isolated configuration container
  final env = await DotEnvInitialization.initialize();
  if (env == null) {
    runApp(const ConfigurationErrorApp());
    return;
  }
  // Initialize native integrations with valid configuration parameters
  await Supabase.initialize(
    url: env.supabaseUrl,
    publishableKey: env.supabaseAnonKey,
  );
  configureDependencies();
  await getIt<AuthScreenCubit>().checkActiveSession();
  await getIt<CalendarScreenCubit>().loadRegistrations();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthScreenCubit>()),
        BlocProvider.value(value: getIt<SignInCubit>()),
        BlocProvider.value(value: getIt<SignUpCubit>()),
        BlocProvider.value(value: getIt<CalendarScreenCubit>()),
        BlocProvider.value(value: getIt<EventDetailCubit>()),
        BlocProvider.value(value: getIt<EventScreenCubit>()),
        BlocProvider.value(value: getIt<MainScreenCubit>()),
        BlocProvider.value(value: getIt<ProfileScreenCubit>()),
        BlocProvider.value(value: getIt<RegisteredEventCubit>()),
        BlocProvider.value(value: getIt<WatcherScanCubit>()),
      ],
      child: MaterialApp(
        title: AppText.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthScreen(),
      ),
    );
  }
}
