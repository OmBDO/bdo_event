import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/core/common/footer_height_tracker/footer_height_tracker.dart';
import 'package:flutter/material.dart';

class FooterController {
  final GlobalKey footerKey = GlobalKey();

  void calculateFooterHeight() {
    final RenderBox? renderBox =
        footerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      // Extract the exact, actual height including padding and device density scales
      double totalRenderedHeight = renderBox.size.height;

      // Update our global value stream broadcaster
      FooterHeightTracker.heightNotifier.value = totalRenderedHeight;
    }
  }

  void resetAppScrollTracker() {
    AppScrollTracker.reset();
  }
}
