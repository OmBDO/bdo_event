import 'package:flutter/services.dart';

abstract interface class WatcherFeedbackAdapter {
  Future<void> mediumImpact();
}

class SystemWatcherFeedbackAdapter implements WatcherFeedbackAdapter {
  const SystemWatcherFeedbackAdapter();

  @override
  Future<void> mediumImpact() => HapticFeedback.mediumImpact();
}
