import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/features/auth/domain/exceptions/auth_exception.dart';
import 'package:bloot/features/auth/domain/repositories/auth_repository.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState.initial());

  final AuthRepository _authRepository;
  // TODO: Persist verificationId for OTP verification.
  // ignore: unused_field
  String? _phoneNumber;

  Future<void> sendOtp(String phoneNumber) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.sendOtp(phoneNumber);
      _phoneNumber = phoneNumber;
      emit(const AuthState.otpSent());
    } on AuthException catch (e) {
      emit(AuthState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to send OTP', error: e);
      emit(
        const AuthState.error(message: 'Failed to send OTP. Please try again.'),
      );
    }
  }

  Future<void> verifyOtp(String otp) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.verifyOtp(otp);
      final isComplete = await _authRepository.isProfileComplete();
      if (isComplete) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthState.authenticated(user: user));
        } else {
          emit(
            const AuthState.error(
              message: 'User not found after verification.',
            ),
          );
        }
      } else {
        emit(const AuthState.profileRequired());
      }
    } on AuthException catch (e) {
      emit(AuthState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to verify OTP', error: e);
      emit(const AuthState.error(message: 'Invalid OTP. Please try again.'));
    }
  }

  Future<void> completeProfile({
    required String name,
    required String username,
    String? avatarUrl,
  }) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.completeProfile(
        name: name,
        username: username,
        avatarUrl: avatarUrl,
      );
      emit(AuthState.authenticated(user: user));
    } on AuthException catch (e) {
      emit(AuthState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to complete profile', error: e);
      emit(
        const AuthState.error(
          message: 'Failed to save profile. Please try again.',
        ),
      );
    }
  }

  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthState.authenticated(user: user));
      } else {
        emit(const AuthState.initial());
      }
    } catch (e) {
      AppLogger.error('Auth status check failed', error: e);
      emit(const AuthState.initial());
    }
  }

  Future<void> signOut() async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signOut();
      emit(const AuthState.initial());
    } catch (e) {
      AppLogger.error('Sign out failed', error: e);
      emit(
        const AuthState.error(message: 'Failed to sign out. Please try again.'),
      );
    }
  }
}
