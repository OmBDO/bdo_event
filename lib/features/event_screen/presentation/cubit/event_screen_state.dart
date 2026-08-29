import 'package:bdo_event/core/model/event_model/event_model.dart';

class EventScreenState {
  final int selectedTab;
  final List<String> tabs;
  final List<Event> events;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const EventScreenState({
    this.selectedTab = 0,
    this.tabs = const ['Upcoming', 'My Events', 'Past'],
    this.events = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  List<Event> get currentTabEvents {
    if (selectedTab == 0) return events;
    if (selectedTab == 1) return events.take(2).toList();
    return events.take(1).toList();
  }

  EventScreenState copyWith({
    int? selectedTab,
    List<Event>? events,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) => EventScreenState(
    selectedTab: selectedTab ?? this.selectedTab,
    tabs: tabs,
    events: events ?? this.events,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    error: clearError ? null : error ?? this.error,
  );
}
