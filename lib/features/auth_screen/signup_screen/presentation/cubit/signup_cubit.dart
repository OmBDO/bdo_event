import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/features/auth_screen/signup_screen/presentation/cubit/signup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit({required AuthRepositoryContract authRepository})
    : _authRepository = authRepository,
      super(const SignUpState());

  final AuthRepositoryContract _authRepository;

  void showError(String message) =>
      emit(state.copyWith(isSubmitting: false, error: message));

  Future<String?> submit({
    required String name,
    required String email,
    required String password,
    required UserRole requestedRole,
  }) async {
    if (state.isSubmitting) return AppText.pleaseWait;
    emit(state.copyWith(isSubmitting: true, clearError: true));

    final error = await _authRepository.register(
      name: name,
      email: email,
      password: password,
      requestedRole: requestedRole,
    );
    emit(state.copyWith(isSubmitting: false, error: error));
    return error;
  }
}
