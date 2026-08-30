import 'package:bdo_event/core/common/app_keyboard_tracker/app_keyboard_tracker.dart';
import 'package:bdo_event/core/common/calendar_element/element/calendar_element.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/common/footer_height_tracker/footer_height_tracker.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_cubit.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_cubit.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_state.dart';
import 'package:bdo_event/features/calendar_screen/presentation/widgets/search_bar_widget.dart';
import 'package:bdo_event/features/registered_screen/presentation/pages/registered_event_page.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_cubit.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_detail_screen.dart';
import 'package:bdo_event/features/main_screen/domain/entities/main_tab.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_cubit.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event_date_formatter.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:gap/gap.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CalendarScreenView();
  }
}

class _CalendarScreenView extends StatefulWidget {
  const _CalendarScreenView();

  @override
  State<_CalendarScreenView> createState() => _CalendarScreenViewState();
}

class _CalendarScreenViewState extends State<_CalendarScreenView> {
  @override
  void initState() {
    super.initState();
    context.read<EventScreenCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarScreenCubit, CalendarScreenState>(
      builder: (context, state) {
        final eventState = context.watch<EventScreenCubit>().state;
        return SafeArea(
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
                            : CalendarElement(
                                events: eventState.events,
                                onEventTap: (event) async {
                                  final isRegistered = eventState
                                      .registeredEventIds
                                      .contains(event.id);
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => isRegistered
                                          ? BlocProvider(
                                              create: (_) =>
                                                  getIt<RegisteredEventCubit>(),
                                              child: RegisteredEventPage(
                                                event: event,
                                              ),
                                            )
                                          : BlocProvider(
                                              create: (_) =>
                                                  getIt<EventDetailCubit>(),
                                              child: EventDetailPage(
                                                event: event,
                                              ),
                                            ),
                                    ),
                                  );
                                  if (context.mounted) {
                                    await context
                                        .read<CalendarScreenCubit>()
                                        .loadRegistrations();
                                  }
                                },
                              ),
                      );
                    },
                  ),

                  const Gap(AppSpace.space16),

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
                        final theme = Theme.of(context);
                        final hasRegistrations = state.events.isNotEmpty;
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                            padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
                            // decoration: BoxDecoration(
                            //   color: theme.colorScheme.surface.withValues(
                            //     alpha: 0.88,
                            //   ),
                            //   borderRadius: BorderRadius.circular(26),
                            //   border: Border.all(
                            //     color: theme.colorScheme.outlineVariant,
                            //   ),
                            //   boxShadow: [
                            //     BoxShadow(
                            //       color: const Color(0xFF52718A)
                            //           .withValues(alpha: 0.12),
                            //       blurRadius: 18,
                            //       offset: const Offset(0, 8),
                            //     ),
                            //   ],
                            // ),
                            child: Column(
                              children: [
                                Container(
                                  width: 74,
                                  height: 74,
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    hasRegistrations
                                        ? Icons.search_off_rounded
                                        : Icons.event_available_rounded,
                                    size: 36,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const Gap(AppSpace.space20),
                                Text(
                                  hasRegistrations
                                      ? AppText.noEventsFound
                                      : AppText.calendarReady,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: AppSize.text20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Gap(AppSpace.space8),
                                Text(
                                  hasRegistrations
                                      ? AppText.noMatchingEvents
                                      : AppText.registeredEventsWillAppearHere,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                    fontSize: AppSize.text14,
                                    height: 1.45,
                                  ),
                                ),
                                if (!hasRegistrations) ...[
                                  const Gap(AppSpace.space22),
                                  FilledButton.icon(
                                    onPressed: () => context
                                        .read<MainScreenCubit>()
                                        .selectTab(MainTab.events),
                                    icon: const Icon(Icons.explore_outlined),
                                    label: const Text(AppText.exploreEvents),
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor:
                                          theme.colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
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
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) =>
                                          getIt<RegisteredEventCubit>(),
                                      child: RegisteredEventPage(event: event),
                                    ),
                                  ),
                                );
                                if (context.mounted) {
                                  await context
                                      .read<CalendarScreenCubit>()
                                      .loadRegistrations();
                                }
                              },
                              title: Text(
                                event.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${formatEventDate(event.date, context.watch<ProfileScreenCubit>().state.dateFormat)} • ${event.location}',
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
                        separatorBuilder: (context, index) =>
                            const Gap(AppSpace.space10),
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
      },
    );
  }
}
