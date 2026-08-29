import 'package:bdo_event/core/common/app_keyboard_tracker/app_keyboard_tracker.dart';
import 'package:bdo_event/core/common/calendar_element/element/calendar_element.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/common/footer_height_tracker/footer_height_tracker.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_cubit.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_cubit.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_state.dart';
import 'package:bdo_event/features/calendar_screen/presentation/widgets/search_bar_widget.dart';
import 'package:bdo_event/features/registered_screen/presentation/pages/registered_event_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:gap/gap.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CalendarScreenView();
  }
}

class _CalendarScreenView extends StatelessWidget {
  const _CalendarScreenView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarScreenCubit, CalendarScreenState>(
      builder: (context, state) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBarWidget(
                  onChanged: context
                      .read<CalendarScreenCubit>()
                      .updateSearchQuery,
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

                Builder(
                  builder: (context) {
                    final visibleEvents = state.events.where((event) {
                      if (state.searchQuery.isEmpty) return true;
                      return event.title.toLowerCase().contains(
                            state.searchQuery,
                          ) ||
                          event.location.toLowerCase().contains(
                            state.searchQuery,
                          );
                    }).toList();

                    if (visibleEvents.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(24, 20, 24, 30),
                        child: Text(
                          state.events.isEmpty
                              ? AppText.noRegisteredEvents
                              : AppText.noMatchingEvents,
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
                                        BlocProvider(
                                          create: (_) =>
                                              getIt<RegisteredEventCubit>(),
                                          child: RegisteredEventPage(event: event),
                                        ),
                                ),
                              );
                            },
                            title: Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${event.date} • ${event.location}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),

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
      ),
    );
  }
}
