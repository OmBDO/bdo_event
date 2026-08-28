import 'package:bdo_event/features/main_screen/domain/entities/main_tab.dart';
import 'package:flutter/material.dart';

class MainScreenDestination {
  final MainTab tab;
  final String label;
  final IconData icon;
  final Widget page;

  const MainScreenDestination({
    required this.tab,
    required this.label,
    required this.icon,
    required this.page,
  });
}