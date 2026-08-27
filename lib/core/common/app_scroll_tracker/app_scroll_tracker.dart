// Location: lib/core/utils/scroll_tracker.dart
import 'package:flutter/material.dart';

class AppScrollTracker {
  // A shared controller instance targeting only your specific CustomScrollView
  static final ScrollController eventScrollController = ScrollController();

  // A ultra-lightweight real-time dynamic value broadcaster
  static final ValueNotifier<double> scrollOffsetNotifier =
      ValueNotifier<double>(0.0);

  // Initialize tracking linkage loop listeners
  static void initialize() {
    eventScrollController.addListener(() {
      // Updates the tracker instantly on every single pixel frame modification
      scrollOffsetNotifier.value = eventScrollController.offset;
    });
  }

  /// Resets both the scroll position and the notifier value to zero
  static void reset({bool animate = false}) {
    // 1. Reset the notifier value immediately
    scrollOffsetNotifier.value = 0.0;

    // 2. Reset the scroll position if the controller is attached to a viewport
    if (eventScrollController.hasClients) {
      if (animate) {
        eventScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        eventScrollController.jumpTo(0.0);
      }
    }
  }

  // Proper memory disposal cleanup routine
  static void dispose() {
    eventScrollController.dispose();
    scrollOffsetNotifier.dispose(); // Added to prevent memory leaks
  }
}
