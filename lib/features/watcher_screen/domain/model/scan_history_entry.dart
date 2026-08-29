import 'package:equatable/equatable.dart';

class ScanHistoryEntry extends Equatable {
  const ScanHistoryEntry({
    required this.registrationToken,
    required this.userId,
    required this.status,
  });

  final String registrationToken;
  final String? userId;
  final String status;

  ScanHistoryEntry copyWith({String? status}) => ScanHistoryEntry(
    registrationToken: registrationToken,
    userId: userId,
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [registrationToken, userId, status];
}
