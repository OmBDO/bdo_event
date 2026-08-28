import 'package:equatable/equatable.dart';

class RegisteredEventState extends Equatable {
  const RegisteredEventState({this.isCancelling = false, this.error});

  final bool isCancelling;
  final String? error;

  RegisteredEventState copyWith({
    bool? isCancelling,
    String? error,
    bool clearError = false,
  }) {
    return RegisteredEventState(
      isCancelling: isCancelling ?? this.isCancelling,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isCancelling, error];
}
