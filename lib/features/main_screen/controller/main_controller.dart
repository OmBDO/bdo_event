import 'package:bdo_event/features/calendar_screen/page/calendar_screen.dart';
import 'package:bdo_event/features/create_event_screen/page/create_event_page.dart';
import 'package:bdo_event/features/event_screen/page/event_screen.dart';
import 'package:bdo_event/features/profile_screen/page/profile_screen.dart';
import 'package:flutter/material.dart';

class MainController {
  final GlobalKey footerKey = GlobalKey();
  int currentIndex = 0;
  late Future<void> loadingFuture;

  // List of screens for the bottom navigation bar
  final List<Widget> screens = [
    const EventPage(),
    const CalendarScreen(),
    const CreateEventPage(),
    const ProfileScreen(),
  ];
}
