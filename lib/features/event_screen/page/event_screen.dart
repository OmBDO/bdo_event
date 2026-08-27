import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/core/common/footer_height_tracker/footer_height_tracker.dart';
import 'package:bdo_event/features/event_screen/controller/event_controller.dart';
import 'package:bdo_event/features/event_screen/widget/event_tab.dart';
import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final _eventController = EventController();

  @override
  Widget build(BuildContext context) {
    // Keep a direct reference to the active list for readability and accuracy
    final currentTabList =
        _eventController.eventList[_eventController.selectedTab];

    return CustomScrollView(
      controller: AppScrollTracker.eventScrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: const Color.fromARGB(0, 255, 193, 7),
          flexibleSpace: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.bottomLeft,
            child: EventTab(
              titles: _eventController.tabs,
              onTap: (selectedTab) {
                if (_eventController.selectedTab == selectedTab) return;

                setState(() {
                  _eventController.selectedTab = selectedTab;
                });

                // Reset the scroll position to the top instantly when the tab changes
                AppScrollTracker.reset(animate: false);
              },
              selectedTab: _eventController.selectedTab,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return currentTabList[index];
            },
            // FIX: Dynamically read the length of the currently active tab list
            childCount: currentTabList.length,
          ),
        ),
        ValueListenableBuilder<double>(
          valueListenable: FooterHeightTracker.heightNotifier,
          builder: (context, dynamicHeight, child) {
            return SliverToBoxAdapter(child: SizedBox(height: dynamicHeight));
          },
        ),
      ],
    );
  }
}
