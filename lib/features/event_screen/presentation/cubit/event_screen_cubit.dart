import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/calendar_screen/domain/usecases/load_registered_events.dart';
import 'package:bdo_event/features/event_screen/domain/usecases/event_use_cases.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:bdo_event/core/prefs/recent_event_store.dart';

class EventScreenCubit extends Cubit<EventScreenState> {
  EventScreenCubit({
    required this._loadEvents,
    this._loadRegisteredEvents,
    required this._createEvent,
    required this._updateEvent,
    required this._deleteEvent,
    required this._authRepository,
    this._recentEventStore,
    this._preferences,
  }) : super(const EventScreenState());

  final LoadEvents _loadEvents;
  final LoadRegisteredEvents? _loadRegisteredEvents;
  final CreateEvent _createEvent;
  final UpdateEvent _updateEvent;
  final DeleteEvent _deleteEvent;
  final AuthRepositoryContract _authRepository;
  final SharedPreferences? _preferences;
  final RecentEventStore? _recentEventStore;
  static const _savedEventIdsKey = 'saved_event_ids';

  Future<void> load({bool force = false}) async {
    if (isClosed) return;
    if (!force && (state.hasLoaded || state.isLoading)) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final events = await _loadEvents();
      final userId = _authRepository.currentUser?.id;
      final registeredEvents = userId == null || _loadRegisteredEvents == null
          ? const <Event>[]
          : await _loadRegisteredEvents(userId);
      if (!isClosed) {
        emit(
          state.copyWith(
            events: events,
            registeredEventIds: registeredEvents
                .map((event) => event.id)
                .toSet(),
            savedEventIds:
                _preferences?.getStringList(_savedEventIdsKey)?.toSet() ??
                const {},
            recentEventIds:
                _recentEventStore?.readIds(userId: userId) ?? const [],
            isLoading: false,
            hasLoaded: true,
          ),
        );
      }
    } on Object {
      if (!isClosed) {
        emit(
          state.copyWith(isLoading: false, error: AppText.unableToLoadEvents),
        );
      }
    }
  }

  Future<String?> save(Event event, {required bool isEditing}) async {
    final user = _authRepository.currentUser;
    if (user == null) return AppText.pleaseSignInToManageEvents;
    if (isClosed) return AppText.unableToSaveEvent;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final result = isEditing
          ? await _updateEvent(event)
          : await _createEvent(event, user);
      if (!isClosed) {
        emit(
          state.copyWith(
            events: result.events.isEmpty ? state.events : result.events,
            isSaving: false,
            error: result.error,
          ),
        );
      }
      return result.error;
    } on Object {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSaving: false,
            error: isEditing
                ? AppText.unableToUpdateEvent
                : AppText.unableToSaveEvent,
          ),
        );
      }
      return isEditing
          ? AppText.unableToUpdateEvent
          : AppText.unableToSaveEvent;
    }
  }

  Future<String?> delete(Event event) async {
    if (state.deletingEventIds.contains(event.id)) return null;
    emit(
      state.copyWith(
        events: state.events
            .where((current) => current.id != event.id)
            .toList(),
        deletingEventIds: {...state.deletingEventIds, event.id},
        clearError: true,
      ),
    );
    try {
      final result = await _deleteEvent(event);
      if (!isClosed) {
        final remainingDeletes = {...state.deletingEventIds}..remove(event.id);
        final nextEvents = result.error == null
            ? result.events
            : [...state.events, event];
        emit(
          state.copyWith(
            events: nextEvents,
            deletingEventIds: remainingDeletes,
            error: result.error,
          ),
        );
      }
      return result.error;
    } on Object {
      if (!isClosed) {
        final remainingDeletes = {...state.deletingEventIds}..remove(event.id);
        emit(
          state.copyWith(
            events: [...state.events, event],
            deletingEventIds: remainingDeletes,
            error: AppText.unableToDeleteEvent,
          ),
        );
      }
      return AppText.unableToDeleteEvent;
    }
  }

  bool canUpdate(Event event) => _authRepository.canUpdate(event);

  bool canDelete(Event event) => _authRepository.canDelete(event);

  void toggleSavedEvent(Event event) {
    final savedEventIds = {...state.savedEventIds};
    if (!savedEventIds.add(event.id)) {
      savedEventIds.remove(event.id);
    }
    emit(state.copyWith(savedEventIds: savedEventIds));
    _preferences?.setStringList(_savedEventIdsKey, savedEventIds.toList());
  }

  void changeTab(int index) {
    if (index == state.selectedTab) return;
    AppScrollTracker.reset(animate: false);
    emit(state.copyWith(selectedTab: index));
  }

  void clearState() {
    emit(const EventScreenState());
  }
}
