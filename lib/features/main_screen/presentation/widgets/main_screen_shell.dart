import 'package:bdo_event/core/common/app_keyboard_tracker/app_keyboard_tracker.dart';
import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/core/common/footer_element/element/footer_element.dart';
import 'package:bdo_event/core/common/header_element/element/header_element.dart';
import 'package:bdo_event/core/theme/app_colors.dart';
import 'package:bdo_event/features/main_screen/domain/entities/main_tab.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_cubit.dart';
import 'package:bdo_event/features/main_screen/presentation/widgets/main_screen_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreenShell extends StatefulWidget {
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
  State<MainScreenShell> createState() => _MainScreenShellState();
}

class _MainScreenShellState extends State<MainScreenShell> {
  final _pages = <MainTab, Widget>{};

  @override
  void initState() {
    super.initState();
    AppKeyboardTracker.initialize();
  }

  @override
  void dispose() {
    AppKeyboardTracker.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MainScreenShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final availableTabs = widget.destinations.map((destination) => destination.tab).toSet();
    _pages.removeWhere((tab, page) => !availableTabs.contains(tab));
  }

  @override
  Widget build(BuildContext context) {
    final destinations = widget.destinations;
    final currentTab = widget.currentTab;
    final cubit = context.read<MainScreenCubit>();
    final selectedIndex = destinations.indexWhere(
      (destination) => destination.tab == currentTab,
    );
    final currentIndex = selectedIndex < 0 ? 0 : selectedIndex;
    if (destinations.isNotEmpty) {
      final destination = destinations[currentIndex];
      _pages.putIfAbsent(destination.tab, destination.createPage);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [
                    AppColors.shellStartDark,
                    AppColors.backgroundDark,
                    AppColors.shellEndDark,
                  ]
                : const [
                    AppColors.shellStartLight,
                    AppColors.backgroundLight,
                    AppColors.shellEndLight,
                  ],
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
                    for (final destination in destinations)
                      _pages[destination.tab] ?? const SizedBox.shrink(),
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
                onLogoutSelected: widget.onLogoutSelected,
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
