import 'package:equatable/equatable.dart';

class RegisteredEventState extends Equatable {
  static const _unchanged = Object();

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
    Object? registrationToken = _unchanged,
    String? error,
    bool clearError = false,
  }) {
    return RegisteredEventState(
      isCancelling: isCancelling ?? this.isCancelling,
      isLoadingToken: isLoadingToken ?? this.isLoadingToken,
      registrationToken: identical(registrationToken, _unchanged)
          ? this.registrationToken
          : registrationToken as String?,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    isCancelling,
    isLoadingToken,
    registrationToken,
    error,
  ];
}
