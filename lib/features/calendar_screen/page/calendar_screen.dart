import 'package:bdo_event/core/common/app_keyboard_tracker/app_keyboard_tracker.dart';
import 'package:bdo_event/core/common/calendar_element/element/calendar_element.dart';
import 'package:bdo_event/core/common/footer_height_tracker/footer_height_tracker.dart';
import 'package:bdo_event/features/auth_screen/auth_repository.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/calendar_screen/widget/search_bar_widget.dart';
import 'package:bdo_event/features/registered_screen/page/registered_event_page.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:gap/gap.dart';

class CalendarScreen extends StatefulWidget {
  // FIX: Renamed constructor from invalid keyword 'new'
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBarWidget(
                onChanged: (value) {
                  setState(() => _searchQuery = value.trim().toLowerCase());
                },
              ),

              ValueListenableBuilder<bool>(
                valueListenable: AppKeyboardTracker.isKeyboardVisible,
                builder: (context, isKeyboardOpen, child) {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: isKeyboardOpen
                        ? const SizedBox.shrink()
                        : const CalendarElement(),
                  );
                },
              ),

              const Gap(16),

              ValueListenableBuilder<List<Event>>(
                valueListenable: AuthRepository.registrations,
                builder: (context, registeredEvents, child) {
                  final visibleEvents = registeredEvents.where((event) {
                    if (_searchQuery.isEmpty) return true;
                    return event.title.toLowerCase().contains(_searchQuery) ||
                        event.location.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (visibleEvents.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(24, 20, 24, 30),
                      child: Text(
                        registeredEvents.isEmpty
                            ? 'No registered events yet'
                            : 'No matching events found',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount: visibleEvents.length,
                    itemBuilder: (context, index) {
                      final event = visibleEvents[index];
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    RegisteredEventPage(event: event),
                              ),
                            );
                          },
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${event.date} • ${event.location}'),
                          trailing: const Icon(
                            Icons.qr_code_2_rounded,
                            color: Colors.deepOrange,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: EventImage(
                                path: event.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const Gap(10),
                  );
                },
              ),

              ValueListenableBuilder<double>(
                valueListenable: FooterHeightTracker.heightNotifier,
                builder: (context, dynamicHeight, child) {
                  return SizedBox(height: dynamicHeight);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
