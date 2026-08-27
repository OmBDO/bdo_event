// Location: lib/core/utils/footer_height_tracker.dart
import 'package:flutter/material.dart';

class FooterHeightTracker {
  // A global reactive variable holding the exact footer height in real time
  static final ValueNotifier<double> heightNotifier = ValueNotifier<double>(
    100.0,
  ); // 100 is a safe starting fallback
}
