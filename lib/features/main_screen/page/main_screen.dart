import 'package:bdo_event/core/common/app_keyboard_tracker/app_keyboard_tracker.dart';
import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/core/common/footer_element/element/footer_element.dart';
import 'package:bdo_event/core/common/header_element/element/header_element.dart';
import 'package:bdo_event/features/loading_screen/page/loading_screen.dart';
import 'package:bdo_event/features/main_screen/controller/main_controller.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _mainController = MainController();
  @override
  void initState() {
    super.initState();
    // Start the 1-second timer when the widget initializes
    _mainController.loadingFuture = Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _mainController.loadingFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: isLoading
              ? const LoadingScreen(key: ValueKey('loading-screen'))
              : Scaffold(
                  key: const ValueKey('main-screen'),
                  body: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        // 2. Control the direction of the color blend flow
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        // 3. Define the exact color stops to match the reference look
                        colors: [
                          Color(
                            0xFFB1D4FA,
                          ), // 🔹 Richer Sky Blue (was 0xFFE2EDF8)
                          Color(
                            0xFFFFF1E6,
                          ), // ☀️ Warmer Peach Blend (was 0xFFFFF6F0)
                          Color(
                            0xFFF9CBB0,
                          ), // 🔸 Deeper Sunset Orange (was 0xFFFCE3D2)
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
                              index: _mainController.currentIndex,
                              children: _mainController.screens,
                            ),
                          ),
                        ),

                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: HeaderElement(
                            currentScreenIndex: _mainController.currentIndex,
                            onProfileSelected: () {
                              setState(() {
                                _mainController.currentIndex = 3;
                              });
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: ValueListenableBuilder<bool>(
                            valueListenable:
                                AppKeyboardTracker.isKeyboardVisible,
                            builder: (context, isKeyboardOpen, child) {
                              // AnimatedSize handles smooth sliding adjustments automatically
                              return AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.fastOutSlowIn,
                                child: isKeyboardOpen
                                    ? const SizedBox.shrink() // Instantly sets dimensions to zero when typing
                                    : FooterElement(
                                        currentIndex:
                                            _mainController.currentIndex,
                                        onTap: (int value) {
                                          setState(() {
                                            _mainController.currentIndex =
                                                value;
                                          });
                                        },
                                      ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
