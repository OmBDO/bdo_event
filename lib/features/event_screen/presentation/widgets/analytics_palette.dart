import 'package:flutter/material.dart';

class AnalyticsPalette {
  const AnalyticsPalette({
    required this.background,
    required this.panel,
    required this.border,
    required this.ink,
    required this.muted,
    required this.teal,
    required this.coral,
    required this.gold,
    required this.lilac,
  });

  final Color background;
  final Color panel;
  final Color border;
  final Color ink;
  final Color muted;
  final Color teal;
  final Color coral;
  final Color gold;
  final Color lilac;

  factory AnalyticsPalette.of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnalyticsPalette(
      background: dark ? const Color(0xFF101719) : const Color(0xFFF3F7F5),
      panel: dark ? const Color(0xFF182326) : Colors.white,
      border: dark ? const Color(0xFF2D3B3D) : const Color(0xFFDCE7E2),
      ink: dark ? const Color(0xFFF2F7F4) : const Color(0xFF132322),
      muted: dark ? const Color(0xFFAABCB8) : const Color(0xFF647773),
      teal: const Color(0xFF00A89A),
      coral: const Color(0xFFFF6F61),
      gold: const Color(0xFFF2B84B),
      lilac: const Color(0xFF9B8AFB),
    );
  }
}
