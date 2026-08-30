import 'package:bdo_event/core/model/event_model/event_model.dart';

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
    this.tabs = const ['Upcoming', 'My Events', 'Past'],
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
    final today = DateTime(now.year, now.month, now.day);

    if (selectedTab == 2) {
      return events.where((event) {
        final date = _parseEventDate(event.date);
        return date != null && date.isBefore(today);
      }).toList();
    }

    final upcomingEvents = events.where((event) {
      final date = _parseEventDate(event.date);
      return date != null && !date.isBefore(today);
    });

    if (selectedTab == 1) {
      return upcomingEvents
          .where((event) => registeredEventIds.contains(event.id))
          .toList();
    }

    return upcomingEvents
        .where((event) => !registeredEventIds.contains(event.id))
        .toList();
  }

  static DateTime? _parseEventDate(String value) {
    final parts = value.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.tryParse(value);
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
