import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IntegrationAppHarness {
  const IntegrationAppHarness({
    required this.home,
    this.providers = const <SingleChildWidget>[],
    this.theme,
    this.darkTheme,
  });

  final Widget home;
  final List<SingleChildWidget> providers;
  final ThemeData? theme;
  final ThemeData? darkTheme;

  Widget build() {
    final configuredHome = providers.isEmpty
        ? home
        : MultiBlocProvider(providers: providers, child: home);
    return MaterialApp(
      home: configuredHome,
      theme: theme,
      darkTheme: darkTheme,
    );
  }
}
