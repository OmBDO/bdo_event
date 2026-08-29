import 'package:bdo_event/features/auth_screen/data/repositories/auth_repository.dart';
import 'package:bdo_event/features/auth_screen/presentation/cubit/auth_screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreenCubit extends Cubit<AuthScreenState> {
  AuthScreenCubit({required this._authRepository})
    : super(const AuthScreenState());

  final AuthRepository _authRepository;

  Future<void> checkActiveSession() async {
    try {
      await _authRepository.initialize();
      emit(
        state.copyWith(
          step: _authRepository.currentUser != null
              ? AuthStep.authenticated
              : AuthStep.signIn,
        ),
      );
    } on Object {
      emit(state.copyWith(step: AuthStep.signIn));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    if (!isClosed) emit(state.copyWith(step: AuthStep.signIn));
  }

  void showSignUp() => emit(state.copyWith(step: AuthStep.signUp));

  void showSignIn([String? email]) => emit(
    state.copyWith(
      step: AuthStep.signIn,
      preFilledEmail: email,
      clearEmail: email == null,
    ),
  );

  void authenticationSucceeded() =>
      emit(state.copyWith(step: AuthStep.authenticated));
}
