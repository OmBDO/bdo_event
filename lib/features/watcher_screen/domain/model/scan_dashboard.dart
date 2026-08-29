import 'package:equatable/equatable.dart';

class ScanDashboard extends Equatable {
  const ScanDashboard({
    required this.checkedInCount,
    required this.expectedCount,
  });

  final int checkedInCount;
  final int expectedCount;

  @override
  List<Object> get props => [checkedInCount, expectedCount];
}
