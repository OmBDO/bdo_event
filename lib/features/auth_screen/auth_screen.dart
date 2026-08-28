import 'package:bdo_event/features/auth_screen/auth_repository.dart';
import 'package:bdo_event/features/auth_screen/signin/signin_screen.dart';
import 'package:bdo_event/features/auth_screen/signup/signup_screen.dart';
import 'package:bdo_event/features/loading_screen/page/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/features/main_screen/page/main_screen.dart';

enum AuthStep { loading, signIn, signUp, authenticated }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Clear single-source-of-truth runtime engine pointer
  AuthStep _currentStep = AuthStep.loading;
  String? _preFilledEmail;

  @override
  void initState() {
    super.initState();
    _checkActiveSession();
  }

  /// 1. Heavy session loading is performed entirely in the repository layer
  Future<void> _checkActiveSession() async {
    try {
      await AuthRepository.initialize();

      setState(() {
        _currentStep = AuthRepository.currentUser != null
            ? AuthStep.authenticated
            : AuthStep.signIn;
      });
    } catch (e) {
      setState(() => _currentStep = AuthStep.signIn);
    }
  }

  /// 2. Clean explicit screen transition route callbacks
  void _navigateToSignUp() {
    setState(() => _currentStep = AuthStep.signUp);
  }

  void _navigateToSignIn([String? email]) {
    setState(() {
      _currentStep = AuthStep.signIn;
      _preFilledEmail = email;
    });
  }

  void _onAuthenticationSuccess() {
    setState(() => _currentStep = AuthStep.authenticated);
  }

  @override
  Widget build(BuildContext context) {
    // 3. Clear architectural branch tracking with zero nested layout futures
    switch (_currentStep) {
      case AuthStep.loading:
        return const LoadingScreen();

      case AuthStep.signIn:
        return SigninScreen(
          initialEmail: _preFilledEmail,
          onShowSignup: _navigateToSignUp,
          onAuthenticated: _onAuthenticationSuccess,
        );

      case AuthStep.signUp:
        return SignupScreen(
          onShowSignin: _navigateToSignIn,
          onSignedUp: (email) {
            // Direct callback path: passes data backwards cleanly without fake triggers
            _navigateToSignIn(email);
          },
        );

      case AuthStep.authenticated:
        return const MainScreen();
    }
  }
}
