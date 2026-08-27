// Location: lib/features/event_screen/controller/event_controller.dart
import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/model/location_model/location_model.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class EventController extends GetxController {
  final List<String> tabs = ['Upcoming', 'My Events', 'Past'];
  final List<Location> locations = [
    const Location(
      id: 'mumbai',
      name: 'Mumbai',
      city: 'Mumbai',
      country: 'India',
    ),
    const Location(
      id: 'bangalore',
      name: 'Bangalore',
      city: 'Bangalore',
      country: 'India',
    ),
    const Location(
      id: 'gurgaon',
      name: 'Gurgaon',
      city: 'Gurgaon',
      country: 'India',
    ),
  ];

  Location selectedLocation = const Location(
    id: 'mumbai',
    name: 'Mumbai',
    city: 'Mumbai',
    country: 'India',
  );
  int selectedTab = 0;

  void changeTab(int index) {
    if (selectedTab == index) return;
    selectedTab = index;
    AppScrollTracker.reset(animate: false);
    update();
  }

  // Pure, clean data declarations optimized for your OpenContainer UI loop
  final List<Event> list = [
    Event(
      id: 'tech-meetup',
      title: 'Tech Meetup',
      date: 'Aug 30, 2026',
      imageUrl: "assets/festivals/1_may.png",
      location: 'Conference Room A',
    ),
    Event(
      id: 'company-hackathon',
      title: 'Company Hackathon',
      date: 'Sep 02, 2026',
      imageUrl: "assets/festivals/diwali.png",
      location: 'Main Auditorium',
    ),
    Event(
      id: 'team-building',
      title: 'Team Building Event',
      date: 'Sep 05, 2026',
      imageUrl: "assets/festivals/ganapati.png",
      location: 'Company Campus',
    ),
  ];

  final List<Event> list2 = [
    Event(
      id: 'tech-meetup',
      title: 'Tech Meetup',
      date: 'Aug 30, 2026',
      imageUrl: "assets/festivals/1_may.png",
      location: 'Conference Room A',
    ),
    Event(
      id: 'company-hackathon',
      title: 'Company Hackathon',
      date: 'Sep 02, 2026',
      imageUrl: "assets/festivals/diwali.png",
      location: 'Main Auditorium',
    ),
  ];

  final List<Event> list3 = [
    Event(
      id: 'tech-meetup',
      title: 'Tech Meetup',
      date: 'Aug 30, 2026',
      imageUrl: "assets/festivals/1_may.png",
      location: 'Conference Room A',
    ),
  ];

  late final List<List<Event>> eventList = [list, list2, list3];
}
