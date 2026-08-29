import 'package:equatable/equatable.dart';

enum AuthStep { loading, signIn, signUp, authenticated }

class AuthScreenState extends Equatable {
  const AuthScreenState({
    this.step = AuthStep.loading,
    this.preFilledEmail,
  });

  final AuthStep step;
  final String? preFilledEmail;

  AuthScreenState copyWith({
    AuthStep? step,
    String? preFilledEmail,
    bool clearEmail = false,
  }) {
    return AuthScreenState(
      step: step ?? this.step,
      preFilledEmail: clearEmail ? null : preFilledEmail ?? this.preFilledEmail,
    );
  }

  @override
  List<Object?> get props => [step, preFilledEmail];
}
