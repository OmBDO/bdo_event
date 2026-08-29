import 'package:equatable/equatable.dart';

class SignInState extends Equatable {
  const SignInState({this.isSubmitting = false, this.error});

  final bool isSubmitting;
  final String? error;

  SignInState copyWith({bool? isSubmitting, String? error, bool clearError = false}) {
    return SignInState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, error];
}
