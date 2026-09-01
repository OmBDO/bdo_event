import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/features/calendar_screen/presentation/pages/calendar_screen.dart';
import 'package:bdo_event/features/event_screen/presentation/pages/my_event_screen.dart';
import 'package:bdo_event/features/event_screen/presentation/pages/event_screen.dart';
import 'package:bdo_event/features/main_screen/domain/entities/main_tab.dart';
import 'package:bdo_event/features/main_screen/presentation/widgets/main_screen_destination.dart';
import 'package:bdo_event/features/profile_screen/presentation/pages/profile_screen.dart';
import 'package:flutter/material.dart';

List<MainScreenDestination> mainScreenDestinations({
  required bool canScan,
  required bool canCreateEvents,
}) => [
  MainScreenDestination(
    tab: MainTab.events,
    label: AppText.event,
    icon: Icons.calendar_month,
    pageBuilder: () => const EventPage(),
  ),
  MainScreenDestination(
    tab: MainTab.registrations,
    label: AppText.register,
    icon: Icons.app_registration_rounded,
    pageBuilder: () => const CalendarScreen(),
  ),
  if (canCreateEvents)
    MainScreenDestination(
      tab: MainTab.createEvent,
      label: AppText.create,
      icon: Icons.add_circle_outline_rounded,
      pageBuilder: () => const MyEventScreen(),
    ),
  // if (canScan)
  //   const MainScreenDestination(
  //     tab: MainTab.watcher,
  //     label: AppText.scanRegistration,
  //     icon: Icons.qr_code_scanner,
  //     page: WatcherScanScreen(),
  //   ),
  MainScreenDestination(
    tab: MainTab.profile,
    label: AppText.profile,
    icon: Icons.account_box,
    pageBuilder: () => const ProfileScreen(),
  ),
];
