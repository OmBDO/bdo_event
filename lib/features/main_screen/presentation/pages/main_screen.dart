import 'package:bdo_event/features/auth_screen/presentation/cubit/auth_screen_cubit.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_cubit.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_cubit.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:bdo_event/features/loading_screen/presentation/pages/loading_screen.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_cubit.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_state.dart';
import 'package:bdo_event/features/main_screen/presentation/widgets/main_screen_destinations.dart';
import 'package:bdo_event/features/main_screen/presentation/widgets/main_screen_shell.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:bdo_event/features/registered_screen/presentation/cubit/registered_event_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MainScreenView();
  }
}

class _MainScreenView extends StatelessWidget {
  const _MainScreenView();

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthScreenCubit>().logout();
    if (!context.mounted) return;
    context.read<CalendarScreenCubit>().clearState();
    context.read<EventScreenCubit>().clearState();
    context.read<EventDetailCubit>().clearState();
    context.read<ProfileScreenCubit>().clearState();
    context.read<RegisteredEventCubit>().clearState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainScreenCubit, MainScreenState>(
      builder: (context, state) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
            child: child,
          ),
        ),
        child: state.status == MainScreenStatus.loading
            ? const LoadingScreen(key: ValueKey('loading-screen'))
            : MainScreenShell(
                key: const ValueKey('main-screen'),
                destinations: mainScreenDestinations,
                currentTab: state.currentTab,
                onLogoutSelected: () => _logout(context),
              ),
      ),
    );
  }
}
