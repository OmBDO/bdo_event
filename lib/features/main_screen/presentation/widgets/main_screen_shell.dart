import 'package:bdo_event/core/common/app_keyboard_tracker/app_keyboard_tracker.dart';
import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/core/common/footer_element/element/footer_element.dart';
import 'package:bdo_event/core/common/header_element/element/header_element.dart';
import 'package:bdo_event/features/main_screen/domain/entities/main_tab.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_cubit.dart';
import 'package:bdo_event/features/main_screen/presentation/widgets/main_screen_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreenShell extends StatelessWidget {
  const MainScreenShell({
    super.key,
    required this.destinations,
    required this.currentTab,
    required this.onLogoutSelected,
  });

  final List<MainScreenDestination> destinations;
  final MainTab currentTab;
  final VoidCallback onLogoutSelected;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MainScreenCubit>();
    final selectedIndex = destinations.indexWhere(
      (destination) => destination.tab == currentTab,
    );
    final currentIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB1D4FA), Color(0xFFFFF1E6), Color(0xFFF9CBB0)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  AppScrollTracker.scrollOffsetNotifier.value =
                      notification.metrics.pixels;
                  return false;
                },
                child: IndexedStack(
                  index: currentIndex,
                  children: [
                    for (final destination in destinations) destination.page,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HeaderElement(
                currentScreenIndex: currentIndex,
                onProfileSelected: () => cubit.selectTab(MainTab.profile),
                onLogoutSelected: onLogoutSelected,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: AppKeyboardTracker.isKeyboardVisible,
                builder: (context, isKeyboardOpen, child) => AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastOutSlowIn,
                  child: isKeyboardOpen
                      ? const SizedBox.shrink()
                      : FooterElement(
                          currentIndex: currentIndex,
                          items: [
                            for (final destination in destinations)
                              FooterItem(
                                icon: destination.icon,
                                label: destination.label,
                              ),
                          ],
                          onTap: (index) => cubit.selectTab(
                            destinations[index].tab,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
