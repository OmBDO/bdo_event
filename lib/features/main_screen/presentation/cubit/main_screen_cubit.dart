import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/features/main_screen/domain/entities/main_tab.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_state.dart';

class MainScreenCubit extends Cubit<MainScreenState> {
  MainScreenCubit() : super(const MainScreenState());

  void finishLoading() {
    if (!isClosed) {
      emit(state.copyWith(status: MainScreenStatus.ready));
    }
  }

  void selectTab(MainTab tab) {
    if (tab == state.currentTab) return;
    emit(state.copyWith(currentTab: tab));
  }
}