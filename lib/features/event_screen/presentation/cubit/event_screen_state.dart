import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/core/util/event_schedule.dart';

class EventScreenState {
  final int selectedTab;
  final List<String> tabs;
  final List<Event> events;
  final Set<String> registeredEventIds;
  final Set<String> savedEventIds;
  final List<String> recentEventIds;
  final bool isLoading;
  final bool isSaving;
  final Set<String> deletingEventIds;
  final bool hasLoaded;
  final String? error;

  const EventScreenState({
    this.selectedTab = 0,
    this.tabs = AppText.eventTabs,
    this.events = const [],
    this.registeredEventIds = const {},
    this.savedEventIds = const {},
    this.recentEventIds = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.deletingEventIds = const {},
    this.hasLoaded = false,
    this.error,
  });

  List<Event> get currentTabEvents {
    final now = DateTime.now();
    if (selectedTab == 2) {
      return events
          .where((event) => EventSchedule.isFinished(event, now: now))
          .toList();
    }

    final upcomingEvents = events.where(
      (event) => EventSchedule.isUpcoming(event, now: now),
    );

    if (selectedTab == 1) {
      return upcomingEvents
          .where((event) => registeredEventIds.contains(event.id))
          .toList();
    }

    return upcomingEvents
        .where((event) => !registeredEventIds.contains(event.id))
        .toList();
  }

  EventScreenState copyWith({
    int? selectedTab,
    List<Event>? events,
    Set<String>? registeredEventIds,
    Set<String>? savedEventIds,
    List<String>? recentEventIds,
    bool? isLoading,
    bool? isSaving,
    Set<String>? deletingEventIds,
    bool? hasLoaded,
    String? error,
    bool clearError = false,
  }) => EventScreenState(
    selectedTab: selectedTab ?? this.selectedTab,
    tabs: tabs,
    events: events ?? this.events,
    registeredEventIds: registeredEventIds ?? this.registeredEventIds,
    savedEventIds: savedEventIds ?? this.savedEventIds,
    recentEventIds: recentEventIds ?? this.recentEventIds,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    deletingEventIds: deletingEventIds ?? this.deletingEventIds,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    error: clearError ? null : error ?? this.error,
  );
}
