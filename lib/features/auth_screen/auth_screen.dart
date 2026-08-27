import 'package:bdo_event/features/auth_screen/auth_repository.dart';
import 'package:bdo_event/features/auth_screen/signin/signin_screen.dart';
import 'package:bdo_event/features/auth_screen/signup/signup_screen.dart';
import 'package:bdo_event/features/loading_screen/page/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/features/zmain_screen/page/main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final Future<void> _initialization;
  bool isSignup = false;
  String? emailAfterSignup;

  @override
  void initState() {
    super.initState();
    _initialization = AuthRepository.initialize();
  }

  void _showSignin(String email) {
    setState(() {
      isSignup = false;
      emailAfterSignup = email.isEmpty ? null : email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingScreen();
        }

        if (AuthRepository.currentUserName != null) {
          return const MainScreen();
        }

        return isSignup
            ? SignupScreen(onShowSignin: _showSignin, onSignedUp: _showSignin)
            : SigninScreen(
                initialEmail: emailAfterSignup,
                onShowSignup: () => setState(() => isSignup = true),
                onAuthenticated: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                  );
                },
              );
      },
    );
  }
}
