// Location: lib/core/utils/keyboard_tracker.dart
import 'package:flutter/material.dart';

class AppKeyboardTracker with WidgetsBindingObserver {
  // A global broadcaster monitoring whether the keyboard is active
  static final ValueNotifier<bool> isKeyboardVisible = ValueNotifier<bool>(
    false,
  );

  static final AppKeyboardTracker _instance = AppKeyboardTracker._internal();
  factory AppKeyboardTracker() => _instance;
  AppKeyboardTracker._internal();

  /// Starts listening to global system viewport modifications
  static void initialize() {
    WidgetsBinding.instance.addObserver(_instance);
  }

  /// Clears observer linkage channels safely
  static void dispose() {
    WidgetsBinding.instance.removeObserver(_instance);
  }

  @override
  void didChangeMetrics() {
    // Looks up the current structural bottom inset dimensions of your device screen
    final bottomInset = WidgetsBinding
        .instance
        .platformDispatcher
        .views
        .first
        .viewInsets
        .bottom;

    // If the view inset is greater than 0, the software keyboard is actively open
    isKeyboardVisible.value = bottomInset > 0;
  }
}
