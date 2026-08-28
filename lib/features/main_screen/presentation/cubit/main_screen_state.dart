import 'package:bdo_event/features/main_screen/domain/entities/main_tab.dart';

enum MainScreenStatus { loading, ready }

class MainScreenState {
  final MainScreenStatus status;
  final MainTab currentTab;

  const MainScreenState({
    this.status = MainScreenStatus.loading,
    this.currentTab = MainTab.events,
  });

  MainScreenState copyWith({
    MainScreenStatus? status,
    MainTab? currentTab,
  }) => MainScreenState(
    status: status ?? this.status,
    currentTab: currentTab ?? this.currentTab,
  );
}