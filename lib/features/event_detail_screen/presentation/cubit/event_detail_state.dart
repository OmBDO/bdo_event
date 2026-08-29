import 'package:equatable/equatable.dart';

class EventDetailState extends Equatable {
  const EventDetailState({
    this.isRegistered = false,
    this.isSubmitting = false,
    this.attendanceCount,
    this.isLoadingAttendance = false,
    this.error,
  });

  final bool isRegistered;
  final bool isSubmitting;
  final int? attendanceCount;
  final bool isLoadingAttendance;
  final String? error;

  EventDetailState copyWith({
    bool? isRegistered,
    bool? isSubmitting,
    int? attendanceCount,
    bool? isLoadingAttendance,
    String? error,
    bool clearError = false,
  }) {
    return EventDetailState(
      isRegistered: isRegistered ?? this.isRegistered,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      attendanceCount: attendanceCount ?? this.attendanceCount,
      isLoadingAttendance: isLoadingAttendance ?? this.isLoadingAttendance,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    isRegistered,
    isSubmitting,
    attendanceCount,
    isLoadingAttendance,
    error,
  ];
}