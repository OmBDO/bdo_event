import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_state.dart';
import 'package:bdo_event/features/calendar_screen/domain/usecases/load_registered_events.dart';
import 'package:bdo_event/core/notifications/event_reminder_notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarScreenCubit extends Cubit<CalendarScreenState> {
  CalendarScreenCubit({
    required LoadRegisteredEvents loadRegisteredEvents,
    required AuthRepositoryContract authRepository,
    required EventReminderNotificationService reminderNotifications,
    SharedPreferences? preferences,
  }) : _loadRegisteredEvents = loadRegisteredEvents,
       _authRepository = authRepository,
       _reminderNotifications = reminderNotifications,
       _preferences = preferences,
       super(const CalendarScreenState());

  final LoadRegisteredEvents _loadRegisteredEvents;
  final AuthRepositoryContract _authRepository;
  final EventReminderNotificationService _reminderNotifications;
  final SharedPreferences? _preferences;

  Future<void> loadRegistrations() async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null) {
      emit(state.copyWith(status: CalendarScreenStatus.ready));
      return;
    }

    emit(state.copyWith(status: CalendarScreenStatus.loading));
    try {
      final events = await _loadRegisteredEvents(userId);
      try {
        await _reminderNotifications.reconcileEventReminders(
          events,
          enabled: _preferences?.getBool('event_reminders_enabled') ?? true,
          leadTime: Duration(
            minutes: _preferences?.getInt('event_reminder_lead_time') ?? 1440,
          ),
        );
      } on Object {
        return;
      }
      if (!isClosed) {
        emit(
          state.copyWith(events: events, status: CalendarScreenStatus.ready),
        );
      }
    } on Object catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: CalendarScreenStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query.trim().toLowerCase()));
  }

  void clearState() {
    emit(const CalendarScreenState(status: CalendarScreenStatus.ready));
  }
}
