import 'package:bdo_event/core/bootstrap/application_bootstrap.dart';
import 'package:bdo_event/core/deep_link/deep_link_source.dart';
import 'package:bdo_event/core/di/app_dependencies.dart' as di;
import 'package:bdo_event/dotenv.dart';
import 'package:bdo_event/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_environment.dart';

class AuthenticatedAppHarness extends ApplicationAppHarness {
  AuthenticatedAppHarness({
    required super.environment,
    required Session session,
  }) : super(session: session);
}

class UnauthenticatedAppHarness extends ApplicationAppHarness {
  UnauthenticatedAppHarness({required super.environment});
}

class ApplicationAppHarness {
  ApplicationAppHarness({required this.environment, this.session});

  final SupabaseEnvironment environment;
  final Session? session;

  static bool _supabaseInitialized = false;

  WidgetTester? _tester;
  bool _startedSupabase = false;
  bool _dependenciesConfigured = false;

  Future<void> start(
    WidgetTester tester, {
    Widget? home,
    DeepLinkSource? deepLinkSource,
    bool resetPreferences = true,
  }) async {
    _tester = tester;

    if (resetPreferences) {
      SharedPreferences.setMockInitialValues(const {});
    }

    final bootstrap = ApplicationBootstrap(
      loadEnvironment: () async => DotEnvInitialization.fromValues(
        url: environment.url,
        anonKey: environment.anonKey,
      ),

      initializeSupabase: ({required url, required publishableKey}) async {
        if (!ApplicationAppHarness._supabaseInitialized) {
          await Supabase.initialize(url: url, publishableKey: publishableKey);

          ApplicationAppHarness._supabaseInitialized = true;
        }

        _startedSupabase = true;

        final currentSession = session;
        final refreshToken = currentSession?.refreshToken;

        if (refreshToken == null) {
          // No session to restore.
        } else {
          await Supabase.instance.client.auth.setSession(refreshToken);
        }
      },

      initializeNotifications: () async {},
    );

    if (!await bootstrap.initialize()) {
      throw StateError('The authenticated app failed to initialize.');
    }

    await tester.pumpWidget(
      app.MyApp(
        deepLinkSource: deepLinkSource ?? const _NoopDeepLinkSource(),
        home: home,
      ),
    );
  }

  Future<void> dispose() async {
    final tester = _tester;
    if (tester != null) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
    if (_startedSupabase) {
      await Supabase.instance.client.auth.signOut();
    }
    if (_dependenciesConfigured) {
      await di.resetDependencies();
    }
    _tester = null;
    _startedSupabase = false;
    _dependenciesConfigured = false;
  }
}

class _NoopDeepLinkSource implements DeepLinkSource {
  const _NoopDeepLinkSource();

  @override
  Stream<Uri> get uriStream => Stream<Uri>.empty();

  @override
  Future<Uri?> get initialUri async => null;
}

Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final stopwatch = Stopwatch()..start();
  while (finder.evaluate().isEmpty) {
    if (stopwatch.elapsed >= timeout) {
      // ignore: deprecated_member_use
      throw TestFailure('Timed out waiting for ${finder.description}.');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}
