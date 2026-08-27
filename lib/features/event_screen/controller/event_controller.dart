import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/features/event_detail_screen/page/event_detail_screen.dart';
import 'package:bdo_event/features/event_screen/widget/event_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class EventController extends GetxController {
  final List<String> tabs = ['Upcoming', 'My Events', 'Past'];
  final List<String> locations = ['Mumbai', 'Bangalore', 'Gurgaon'];

  String selectedLocation = 'Jombang, East Java';
  int selectedTab = 0;

  /// Call this function from your UI View when a tab is tapped
  void changeTab(int index) {
    if (selectedTab == index) return; // Skip if tapping the active tab

    selectedTab = index;

    // Reset the global scroll tracker and position instantly
    AppScrollTracker.reset(animate: false);

    update(); // Notifies GetBuilder widgets to redraw the list view
  }

  // Your list declarations remain the same
  final List<EventCard> list = [
    EventCard(
      title: 'Tech Meetup',
      date: 'Aug 30, 2026',
      imageUrl: "assets/festivals/1_may.png",
      location: 'Conference Room A',
      onTap: (context) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => EventDetailPage()));
      },
    ),
    EventCard(
      title: 'Company Hackathon',
      date: 'Sep 02, 2026',
      imageUrl: "assets/festivals/diwali.png",
      location: 'Main Auditorium',
    ),
    EventCard(
      title: 'Team Building Event',
      date: 'Sep 05, 2026',
      imageUrl: "assets/festivals/ganapati.png",
      location: 'Company Campus',
    ),
  ];

  final List<EventCard> list2 = [
    EventCard(
      title: 'Tech Meetup',
      date: 'Aug 30, 2026',
      imageUrl: "assets/festivals/1_may.png",
      location: 'Conference Room A',
    ),
    EventCard(
      title: 'Company Hackathon',
      date: 'Sep 02, 2026',
      imageUrl: "assets/festivals/diwali.png",
      location: 'Main Auditorium',
    ),
    EventCard(
      title: 'Team Building Event',
      date: 'Sep 05, 2026',
      imageUrl: "assets/festivals/ganapati.png",
      location: 'Company Campus',
    ),
  ];

  final List<EventCard> list3 = [
    EventCard(
      title: 'Tech Meetup',
      date: 'Aug 30, 2026',
      imageUrl: "assets/festivals/1_may.png",
      location: 'Conference Room A',
    ),
    EventCard(
      title: 'Company Hackathon',
      date: 'Sep 02, 2026',
      imageUrl: "assets/festivals/diwali.png",
      location: 'Main Auditorium',
    ),
    EventCard(
      title: 'Team Building Event',
      date: 'Sep 05, 2026',
      imageUrl: "assets/festivals/ganapati.png",
      location: 'Company Campus',
    ),
  ];

  late final List<List<EventCard>> eventList = [list, list2, list3];
}
