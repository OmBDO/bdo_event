import 'package:equatable/equatable.dart';

class RegisteredEventState extends Equatable {
  const RegisteredEventState({
    this.isCancelling = false,
    this.isLoadingToken = false,
    this.registrationToken,
    this.error,
  });

  final bool isCancelling;
  final bool isLoadingToken;
  final String? registrationToken;
  final String? error;

  RegisteredEventState copyWith({
    bool? isCancelling,
    bool? isLoadingToken,
    String? registrationToken,
    String? error,
    bool clearError = false,
  }) {
    return RegisteredEventState(
      isCancelling: isCancelling ?? this.isCancelling,
      isLoadingToken: isLoadingToken ?? this.isLoadingToken,
      registrationToken: registrationToken ?? this.registrationToken,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isCancelling, isLoadingToken, registrationToken, error];
}
