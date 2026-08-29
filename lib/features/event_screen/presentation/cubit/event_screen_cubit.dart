import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/features/auth_screen/data/repositories/auth_repository.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/event_screen/domain/usecases/event_use_cases.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class EventScreenCubit extends Cubit<EventScreenState> {
  EventScreenCubit({
    required this._loadEvents,
    required this._createEvent,
    required this._updateEvent,
    required this._deleteEvent,
    required this._authRepository,
  }) : super(const EventScreenState());

  final LoadEvents _loadEvents;
  final CreateEvent _createEvent;
  final UpdateEvent _updateEvent;
  final DeleteEvent _deleteEvent;
  final AuthRepository _authRepository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final events = await _loadEvents();
      emit(state.copyWith(events: events, isLoading: false));
    } on Object {
      emit(state.copyWith(isLoading: false, error: AppText.unableToLoadEvents));
    }
  }

  Future<String?> save(Event event, {required bool isEditing}) async {
    final user = _authRepository.currentUser;
    if (user == null) return AppText.pleaseSignInToManageEvents;
    emit(state.copyWith(isSaving: true, clearError: true));
    final result = isEditing
        ? await _updateEvent(event)
        : await _createEvent(event, user);
    emit(state.copyWith(isSaving: false, error: result.error));
    return result.error;
  }

  Future<String?> delete(Event event) async {
    final result = await _deleteEvent(event);
    emit(state.copyWith(error: result.error));
    return result.error;
  }

  bool canUpdate(Event event) => _authRepository.canUpdate(event);

  bool canDelete(Event event) => _authRepository.canDelete(event);

  void changeTab(int index) {
    if (index == state.selectedTab) return;
    AppScrollTracker.reset(animate: false);
    emit(state.copyWith(selectedTab: index));
  }

  void clearState() {
    emit(const EventScreenState());
  }
}
