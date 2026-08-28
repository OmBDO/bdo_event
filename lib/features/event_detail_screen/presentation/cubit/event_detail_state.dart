import 'package:equatable/equatable.dart';

class EventDetailState extends Equatable {
  const EventDetailState({
    this.isRegistered = false,
    this.isSubmitting = false,
    this.error,
  });

  final bool isRegistered;
  final bool isSubmitting;
  final String? error;

  EventDetailState copyWith({
    bool? isRegistered,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return EventDetailState(
      isRegistered: isRegistered ?? this.isRegistered,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isRegistered, isSubmitting, error];
}