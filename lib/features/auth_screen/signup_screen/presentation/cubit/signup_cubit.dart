import 'package:bdo_event/features/auth_screen/data/repositories/auth_repository.dart';
import 'package:bdo_event/features/auth_screen/signup_screen/presentation/cubit/signup_state.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpCubit extends Cubit<SignUpState> {
    SignUpCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const SignUpState());

  final AuthRepository _authRepository;

  void showError(String message) => emit(
        state.copyWith(
          isSubmitting: false,
          error: message,
        ),
      );

  Future<String?> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.isSubmitting) return AppText.pleaseWait;
    emit(state.copyWith(isSubmitting: true, clearError: true));

    final error = await _authRepository.register(
      name: name,
      email: email,
      password: password,
    );
    emit(state.copyWith(isSubmitting: false, error: error));
    return error;
  }
}
