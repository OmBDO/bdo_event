import 'package:bdo_event/core/model/event_model/event_model.dart';

enum CalendarScreenStatus { initial, loading, ready, failure }

class CalendarScreenState {
  const CalendarScreenState({
    this.searchQuery = '',
    this.events = const [],
    this.status = CalendarScreenStatus.initial,
    this.errorMessage,
  });

  final String searchQuery;
  final List<Event> events;
  final CalendarScreenStatus status;
  final String? errorMessage;

  CalendarScreenState copyWith({
    String? searchQuery,
    List<Event>? events,
    CalendarScreenStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) => CalendarScreenState(
    searchQuery: searchQuery ?? this.searchQuery,
    events: events ?? this.events,
    status: status ?? this.status,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}
