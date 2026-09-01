import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_state.dart';
import 'package:bdo_event/features/calendar_screen/domain/usecases/load_registered_events.dart';
import 'package:bdo_event/core/notifications/event_reminder_notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreenCubit extends Cubit<CalendarScreenState> {
  CalendarScreenCubit({
    required this._loadRegisteredEvents,
    required this._authRepository,
    this._reminderNotifications,
    this._preferences,
  }) : super(const CalendarScreenState());

  final LoadRegisteredEvents _loadRegisteredEvents;
  final AuthRepositoryContract _authRepository;
  final EventReminderNotificationService? _reminderNotifications;
  final SharedPreferences? _preferences;
  int _loadGeneration = 0;

  Future<void> loadRegistrations() async {
    if (isClosed) return;
    final userId = _authRepository.currentUser?.id;
    if (userId == null) {
      _loadGeneration++;
      emit(state.copyWith(status: CalendarScreenStatus.ready));
      return;
    }

    final loadGeneration = ++_loadGeneration;
    emit(state.copyWith(status: CalendarScreenStatus.loading));
    try {
      final events = await _loadRegisteredEvents(userId);
      if (isClosed || loadGeneration != _loadGeneration) return;
      final reminderNotifications = _reminderNotifications;
      if (reminderNotifications != null) {
        await _reconcileReminders(reminderNotifications, events);
      }
      if (!isClosed && loadGeneration == _loadGeneration) {
        emit(
          state.copyWith(events: events, status: CalendarScreenStatus.ready),
        );
      }
    } on Object catch (error) {
      if (!isClosed && loadGeneration == _loadGeneration) {
        emit(
          state.copyWith(
            status: CalendarScreenStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> _reconcileReminders(
    EventReminderNotificationService reminderNotifications,
    List<Event> events,
  ) async {
    try {
      await reminderNotifications.reconcileEventReminders(
        events,
        enabled: _preferences?.getBool('event_reminders_enabled') ?? true,
        leadTime: Duration(
          minutes: _preferences?.getInt('event_reminder_lead_time') ?? 1440,
        ),
      );
    } on Object {
      return;
    }
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query.trim().toLowerCase()));
  }

  void clearState() {
    _loadGeneration++;
    emit(const CalendarScreenState(status: CalendarScreenStatus.ready));
  }
}
