import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_state.dart';
import 'package:bdo_event/features/calendar_screen/domain/usecases/load_registered_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarScreenCubit extends Cubit<CalendarScreenState> {
  CalendarScreenCubit({
    required this._loadRegisteredEvents,
    required this._authRepository,
  }) : super(const CalendarScreenState());

  final LoadRegisteredEvents _loadRegisteredEvents;
  final AuthRepositoryContract _authRepository;

  Future<void> loadRegistrations() async {
    final userId = _authRepository.currentUser?.id;
    if (userId == null) {
      emit(state.copyWith(status: CalendarScreenStatus.ready));
      return;
    }

    emit(state.copyWith(status: CalendarScreenStatus.loading));
    try {
      final events = await _loadRegisteredEvents(userId);
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
