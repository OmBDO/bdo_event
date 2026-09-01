import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

class IntegrationAppHarness {
  const IntegrationAppHarness({
    required this.home,
    this.providers = const [],
    this.theme,
    this.darkTheme,
  });

  final Widget home;
  final List<SingleChildWidget> providers;
  final ThemeData? theme;
  final ThemeData? darkTheme;

  Widget build() {
    final app = MaterialApp(home: home, theme: theme, darkTheme: darkTheme);

    if (providers.isEmpty) {
      return app;
    }

    return MultiBlocProvider(providers: providers, child: app);
  }
}
