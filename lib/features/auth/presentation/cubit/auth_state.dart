import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/auth/domain/entities/user.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.otpSent() = AuthOtpSent;
  const factory AuthState.otpVerified() = AuthOtpVerified;
  const factory AuthState.profileRequired() = AuthProfileRequired;
  const factory AuthState.authenticated({required User user}) =
      AuthAuthenticated;
  const factory AuthState.error({required String message}) = AuthError;
}
