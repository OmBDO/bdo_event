import 'package:animations/animations.dart';
import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/core/common/footer_height_tracker/footer_height_tracker.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/auth_screen/auth_repository.dart';
import 'package:bdo_event/features/event_screen/my_event_screen/page/create_event_page.dart';
import 'package:bdo_event/features/event_detail_screen/page/event_detail_screen.dart';
import 'package:bdo_event/features/event_screen/controller/event_controller.dart';
import 'package:bdo_event/features/event_screen/repo/event_repository.dart';
import 'package:bdo_event/features/event_screen/widget/event_card.dart';
import 'package:bdo_event/features/event_screen/widget/event_tab.dart';
import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final _eventController = EventController();

  Future<void> _confirmDelete(Event event) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('"${event.title}" will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep event'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;
    final error = await EventRepository.deleteEvent(event);
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    // Keep a direct reference to the active list for readability and accuracy
    return ValueListenableBuilder<List<Event>>(
      valueListenable: AuthRepository.createdEvents,
      builder: (context, createdEvents, child) {
        final currentTabList = _eventController.selectedTab == 0
            ? [..._eventController.list, ...createdEvents]
            : _eventController.eventList[_eventController.selectedTab];

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

                    setState(() => _eventController.changeTab(selectedTab));
                  },
                  selectedTab: _eventController.selectedTab,
                ),
              ),
            ),
            // Inside your SliverList / ListView builder block:
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final cardData = currentTabList[index];

                // 🚀 THE MORPHING FIX: OpenContainer handles the premium expansion transition
                return OpenContainer(
                  transitionType: ContainerTransitionType.fade,
                  transitionDuration: const Duration(milliseconds: 350),
                  openColor: Colors.transparent,
                  closedColor: Colors.transparent,
                  closedElevation: 0,
                  openElevation: 0,
                  closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  openShape: const RoundedRectangleBorder(),
                  tappable: false,

                  // 1. Define the screen the card will morph into
                  openBuilder: (context, closeContainer) {
                    return EventDetailPage(
                      event: cardData.copyWith(
                        isAvailable: _eventController.selectedTab != 2,
                      ),
                    );
                  },

                  // 2. Define the small card before it gets clicked
                  closedBuilder: (context, openContainer) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: openContainer,
                        child: EventCard(
                          event: cardData,
                          onUpdate: AuthRepository.canUpdate(cardData)
                              ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CreateEventPage(event: cardData),
                                  ),
                                )
                              : null,
                          onDelete: AuthRepository.canDelete(cardData)
                              ? () => _confirmDelete(cardData)
                              : null,
                        ),
                      ),
                    );
                  },
                );
              }, childCount: currentTabList.length),
            ),

            ValueListenableBuilder<double>(
              valueListenable: FooterHeightTracker.heightNotifier,
              builder: (context, dynamicHeight, child) {
                return SliverToBoxAdapter(
                  child: SizedBox(height: dynamicHeight),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
