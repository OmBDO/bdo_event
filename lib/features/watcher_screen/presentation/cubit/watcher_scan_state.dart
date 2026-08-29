import 'package:equatable/equatable.dart';

enum WatcherScanStatus { idle, scanning, valid, checkingIn, invalid, failure }

class WatcherScanState extends Equatable {
  const WatcherScanState({
    this.status = WatcherScanStatus.idle,
    this.eventId,
    this.registrationToken,
    this.userId,
    this.message,
  });

  final WatcherScanStatus status;
  final String? eventId;
  final String? registrationToken;
  final String? userId;
  final String? message;

  WatcherScanState copyWith({
    WatcherScanStatus? status,
    String? eventId,
    String? registrationToken,
    String? userId,
    String? message,
    bool clearResult = false,
  }) => WatcherScanState(
    status: status ?? this.status,
    eventId: clearResult ? null : eventId ?? this.eventId,
    registrationToken:
      clearResult ? null : registrationToken ?? this.registrationToken,
    userId: clearResult ? null : userId ?? this.userId,
    message: message ?? this.message,
  );

  @override
  List<Object?> get props => [status, eventId, registrationToken, userId, message];
}