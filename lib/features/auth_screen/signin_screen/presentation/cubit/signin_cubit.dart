import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/auth_screen/signin_screen/presentation/cubit/signin_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit({required this._authRepository}) : super(const SignInState());

  final AuthRepositoryContract _authRepository;

  void showError(String message) =>
      emit(state.copyWith(isSubmitting: false, error: message));

  Future<bool> submit({required String email, required String password}) async {
    if (state.isSubmitting) return false;
    emit(state.copyWith(isSubmitting: true, clearError: true));

    final error = await _authRepository.login(email: email, password: password);
    if (error != null) {
      emit(state.copyWith(isSubmitting: false, error: error));
      return false;
    }

    emit(state.copyWith(isSubmitting: false));
    return true;
  }
}
