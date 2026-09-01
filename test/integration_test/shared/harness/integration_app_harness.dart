import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IntegrationAppHarness {
  const IntegrationAppHarness({
    required this.home,
    this.providers = const [],
    this.theme,
    this.darkTheme,
  });

  final Widget home;
  final List<BlocProvider> providers;
  final ThemeData? theme;
  final ThemeData? darkTheme;

  Widget build() {
    return MaterialApp(
      home: MultiBlocProvider(providers: providers, child: home),
      theme: theme,
      darkTheme: darkTheme,
    );
  }
}
