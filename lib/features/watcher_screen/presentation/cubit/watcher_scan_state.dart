import 'package:bdo_event/features/watcher_screen/domain/model/scan_history_entry.dart';
import 'package:equatable/equatable.dart';

enum WatcherScanStatus { idle, scanning, valid, checkingIn, invalid, failure }

class WatcherScanState extends Equatable {
  const WatcherScanState({
    this.status = WatcherScanStatus.idle,
    this.eventId,
    this.registrationToken,
    this.userId,
    this.message,
    this.history = const [],
    this.checkedInCount,
    this.expectedCount,
  });

  final WatcherScanStatus status;
  final String? eventId;
  final String? registrationToken;
  final String? userId;
  final String? message;
  final List<ScanHistoryEntry> history;
  final int? checkedInCount;
  final int? expectedCount;

  WatcherScanState copyWith({
    WatcherScanStatus? status,
    String? eventId,
    String? registrationToken,
    String? userId,
    String? message,
    List<ScanHistoryEntry>? history,
    int? checkedInCount,
    int? expectedCount,
    bool clearResult = false,
    bool clearMessage = false,
  }) => WatcherScanState(
    status: status ?? this.status,
    eventId: clearResult ? null : eventId ?? this.eventId,
    registrationToken:
      clearResult ? null : registrationToken ?? this.registrationToken,
    userId: clearResult ? null : userId ?? this.userId,
    message: clearMessage ? null : message ?? this.message,
    history: history ?? this.history,
    checkedInCount: checkedInCount ?? this.checkedInCount,
    expectedCount: expectedCount ?? this.expectedCount,
  );

  @override
  List<Object?> get props => [
    status,
    eventId,
    registrationToken,
    userId,
    message,
    history,
    checkedInCount,
    expectedCount,
  ];
}