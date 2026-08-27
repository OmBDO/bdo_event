import 'package:bdo_event/features/calendar_screen/screen/calendar_screen.dart';
import 'package:bdo_event/features/event_screen/page/event_screen.dart';
import 'package:bdo_event/features/profile_screen/pages/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class MainController extends GetxController {
  final GlobalKey footerKey = GlobalKey();
  int currentIndex = 0;
  late Future<void> loadingFuture;

  // List of screens for the bottom navigation bar
  final List<Widget> screens = [
    const EventPage(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];
}
