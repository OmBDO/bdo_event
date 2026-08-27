import 'package:bdo_event/core/theme/appcolor.dart';
import 'package:bdo_event/features/event_screen/widget/event_card.dart';
import 'package:bdo_event/features/event_screen/widget/event_tab.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final List<String> tabs = ['Upcoming', 'My Events', 'Past'];

  final List<String> locations = [
    'Jombang, East Java',
    'Jakarta, Indonesia',
    'Bandung, Indonesia',
  ];

  String selectedLocation = 'Jombang, East Java';

  void onNotificationClick() {}

  List<EventCard> list = [
    EventCard(
      title: 'Tech Meetup',
      date: 'Aug 30, 2026',
      time: '6:00 PM',
      location: 'Conference Room A',
    ),

    EventCard(
      title: 'Company Hackathon',
      date: 'Sep 02, 2026',
      time: '10:00 AM',
      location: 'Main Auditorium',
    ),

    EventCard(
      title: 'Team Building Event',
      date: 'Sep 05, 2026',
      time: '4:00 PM',
      location: 'Company Campus',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          // 2. Control the direction of the color blend flow
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // 3. Define the exact color stops to match the reference look
          colors: [
            Color(0xFFB1D4FA), // 🔹 Richer Sky Blue (was 0xFFE2EDF8)
            Color(0xFFFFF1E6), // ☀️ Warmer Peach Blend (was 0xFFFFF6F0)
            Color(0xFFF9CBB0), // 🔸 Deeper Sunset Orange (was 0xFFFCE3D2)
          ],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.paleCream,
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: Row(
                    children: [
                      // Expanded(
                      //   child: EventDropdown(
                      //     selectedLocation: selectedLocation,
                      //     locations: locations,
                      //     onChanged: (value) {
                      //       setState(() {
                      //         selectedLocation = value;
                      //       });
                      //     },
                      //   ),
                      // ),

                      const Spacer(),
                      Container(
                        width: 34, // 👈 17 radius * 2 = 34 diameter matches avatar perfectly
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.softOrange,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: IconButton(
                          onPressed: onNotificationClick,
                          icon: const Icon(
                            Icons.notification_add_outlined,
                            size: 19,
                          ), // 👈 Icon size matches avatar icon
                          color: AppColors.lightBlue,
                          padding: EdgeInsets.zero, // 👈 Strips padding to prevent expanding the circle
                          constraints: const BoxConstraints(),
                        ),
                      ),

                      const Gap(10),

                      // 2. Profile Avatar (Matching Size)
                      Container(
                        width: 34, // 👈 Mirror dimensions exactly
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.softOrange,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person,
                          size: 19,
                          color: AppColors.softOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(20),
                // Tabs
                Flexible(
                  flex: 1,
                  child: EventTab(titles: tabs, isSelected: true, onTap: () {}),
                ),

                const SizedBox(height: 20),
                // Events
                Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return list[index];
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
