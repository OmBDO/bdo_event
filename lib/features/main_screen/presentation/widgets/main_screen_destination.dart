import 'package:bdo_event/features/main_screen/domain/entities/main_tab.dart';
import 'package:flutter/material.dart';

class MainScreenDestination {
  final MainTab tab;
  final String label;
  final IconData icon;
  final Widget? page;
  final Widget Function()? pageBuilder;

  const MainScreenDestination({
    required this.tab,
    required this.label,
    required this.icon,
    this.page,
    this.pageBuilder,
  }) : assert(page != null || pageBuilder != null);

  Widget createPage() => page ?? pageBuilder!();
}