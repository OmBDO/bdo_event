import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/prefs/supabase_store.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/core/bootstrap/application_bootstrap.dart';
import 'package:bdo_event/features/auth_screen/presentation/cubit/auth_screen_state.dart';
import 'package:bdo_event/features/auth_screen/presentation/pages/auth_screen.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/theme/app_theme.dart';
import 'package:bdo_event/features/auth_screen/presentation/cubit/auth_screen_cubit.dart';
import 'package:bdo_event/features/auth_screen/signin_screen/presentation/cubit/signin_cubit.dart';
import 'package:bdo_event/features/auth_screen/signup_screen/presentation/cubit/signup_cubit.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_cubit.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_cubit.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_cubit.dart';
import 'package:bdo_event/core/common/configuration_error_app/configuration_error_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:async';

import 'package:bdo_event/core/deep_link/event_deep_link_service.dart';
import 'package:bdo_event/core/deep_link/deep_link_source.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialized = await ApplicationBootstrap().initialize();
  if (!initialized) {
    runApp(const ConfigurationErrorApp());
    return;
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.deepLinkSource, this.home});

  final DeepLinkSource? deepLinkSource;
  final Widget? home;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final DeepLinkSource _deepLinkSource;
  StreamSubscription<Uri>? _deepLinkSubscription;
  String? _pendingEventId;

  @override
  void initState() {
    super.initState();
    _deepLinkSource = widget.deepLinkSource ?? EventDeepLinkService();
    _deepLinkSubscription = _deepLinkSource.uriStream.listen(_handleUri);
    _deepLinkSource.initialUri.then((uri) {
      if (mounted && uri != null) _handleUri(uri);
    });
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  void _handleUri(Uri uri) {
    final eventId = EventDeepLinkService.eventIdFromUri(uri);
    if (eventId == null) return;
    _pendingEventId = eventId;
    _openPendingEvent();
  }

  Future<void> _openPendingEvent() async {
    final eventId = _pendingEventId;
    if (eventId == null ||
        getIt<AuthScreenCubit>().state.step != AuthStep.authenticated) {
      return;
    }
    _pendingEventId = null;

    Event? event;
    try {
      final events = await getIt<EventStore>().readCreatedEvents();
      event = events.where((candidate) => candidate.id == eventId).firstOrNull;
    } on Object {
      return;
    }
    if (!mounted || event == null) return;
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<EventDetailCubit>(),
          child: EventDetailPage(event: event!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthScreenCubit>()),
        BlocProvider.value(value: getIt<SignInCubit>()),
        BlocProvider.value(value: getIt<SignUpCubit>()),
        BlocProvider.value(value: getIt<CalendarScreenCubit>()),
        BlocProvider.value(value: getIt<EventScreenCubit>()),
        BlocProvider.value(value: getIt<MainScreenCubit>()),
        BlocProvider.value(value: getIt<ProfileScreenCubit>()),
        BlocProvider.value(value: getIt<WatcherScanCubit>()),
      ],
      child: Builder(
        builder: (context) {
          final profileState = context.watch<ProfileScreenCubit>().state;
          final highContrast = profileState.isHighContrastEnabled;
          return BlocListener<AuthScreenCubit, AuthScreenState>(
            listener: (_, _) => _openPendingEvent(),
            child: MaterialApp(
              navigatorKey: _navigatorKey,
              title: AppText.appName,
              theme: AppTheme.light(highContrast: highContrast),
              darkTheme: AppTheme.dark(highContrast: highContrast),
              themeMode: profileState.isDarkModeEnabled
                  ? ThemeMode.dark
                  : ThemeMode.light,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: profileState.isLargeTextEnabled
                      ? const TextScaler.linear(1.15)
                      : const TextScaler.linear(1.0),
                ),
                child: child!,
              ),
              debugShowCheckedModeBanner: false,
              home: widget.home ?? const AuthScreen(),
            ),
          );
        },
      ),
    );
  }
}
