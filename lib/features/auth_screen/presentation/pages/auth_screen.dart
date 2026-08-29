import 'package:bdo_event/features/auth_screen/signin_screen/presentation/pages/signin_screen.dart';
import 'package:bdo_event/features/auth_screen/signup_screen/presentation/pages/signup_screen.dart';
import 'package:bdo_event/features/auth_screen/presentation/cubit/auth_screen_cubit.dart';
import 'package:bdo_event/features/auth_screen/presentation/cubit/auth_screen_state.dart';
import 'package:bdo_event/features/loading_screen/presentation/pages/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/features/main_screen/presentation/pages/main_screen.dart';
import 'package:bdo_event/features/main_screen/presentation/cubit/main_screen_cubit.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthScreenCubit, AuthScreenState>(
      builder: (context, state) {
          final cubit = context.read<AuthScreenCubit>();
          switch (state.step) {
            case AuthStep.loading:
              return const LoadingScreen();
            case AuthStep.signIn:
              return SigninScreen(
                initialEmail: state.preFilledEmail,
                onShowSignup: cubit.showSignUp,
                onAuthenticated: () {
                  cubit.authenticationSucceeded();
                  context.read<MainScreenCubit>().finishLoading();
                  context.read<ProfileScreenCubit>().refresh();
                  context.read<CalendarScreenCubit>().loadRegistrations();
                },
              );
            case AuthStep.signUp:
              return SignupScreen(
                onShowSignin: cubit.showSignIn,
                onSignedUp: cubit.showSignIn,
              );
            case AuthStep.authenticated:
              return const MainScreen();
          }
      },
    );
  }
}
