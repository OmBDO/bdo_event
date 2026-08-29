import 'package:equatable/equatable.dart';

class ScanHistoryEntry extends Equatable {
  const ScanHistoryEntry({
    required this.registrationToken,
    required this.userId,
    this.displayName,
    this.eventId,
    required this.status,
  });

  final String registrationToken;
  final String? userId;
  final String? displayName;
  final String? eventId;
  final String status;

  ScanHistoryEntry copyWith({String? status}) => ScanHistoryEntry(
    registrationToken: registrationToken,
    userId: userId,
    displayName: displayName,
    eventId: eventId,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [
    registrationToken,
    userId,
    displayName,
    eventId,
    status,
  ];
}
