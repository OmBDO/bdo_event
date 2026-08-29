import 'package:equatable/equatable.dart';

class SignUpState extends Equatable {
  const SignUpState({this.isSubmitting = false, this.error});

  final bool isSubmitting;
  final String? error;

  SignUpState copyWith({
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return SignUpState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, error];
}
