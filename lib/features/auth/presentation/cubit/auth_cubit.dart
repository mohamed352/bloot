import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bloot/core/logger/app_logger.dart';
import 'package:bloot/core/services/remote_config_service.dart';
import 'package:bloot/features/auth/domain/exceptions/auth_exception.dart';
import 'package:bloot/features/auth/domain/repositories/auth_repository.dart';
import 'package:bloot/features/auth/domain/utils/auth_validators.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_state.dart';

@singleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    required RemoteConfigService remoteConfigService,
  })  : _authRepository = authRepository,
        _remoteConfigService = remoteConfigService,
        super(const AuthState.initial());

  final AuthRepository _authRepository;
  final RemoteConfigService _remoteConfigService;
  String? _phoneNumber;

  /// The phone number used for the current OTP session.
  String? get phoneNumber => _phoneNumber;

  Future<void> sendOtp(String phoneNumber) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.sendOtp(phoneNumber);
      _phoneNumber = phoneNumber;
      emit(AuthState.otpSent(phoneNumber: phoneNumber));
    } on AuthException catch (e) {
      emit(AuthState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to send OTP', error: e);
      emit(
        const AuthState.error(message: 'Failed to send OTP. Please try again.'),
      );
    }
  }

  Future<void> resendOtp() async {
    final phone = _phoneNumber;
    if (phone == null || phone.isEmpty) {
      emit(
        const AuthState.error(
          message: 'Phone number not found. Please start over.',
        ),
      );
      return;
    }
    emit(const AuthState.loading());
    try {
      await _authRepository.sendOtp(phone);
      emit(AuthState.otpSent(phoneNumber: phone));
    } on AuthException catch (e) {
      emit(AuthState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to resend OTP', error: e);
      emit(
        const AuthState.error(
          message: 'Failed to resend OTP. Please try again.',
        ),
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
    final nameError = AuthValidators.validateDisplayName(name);
    if (nameError != null) {
      emit(AuthState.error(message: nameError));
      return;
    }
    final usernameError = AuthValidators.validateUsername(username);
    if (usernameError != null) {
      emit(AuthState.error(message: usernameError));
      return;
    }

    if (!_remoteConfigService.allowNewSignups) {
      emit(
        const AuthState.error(
          message: 'New sign-ups are currently disabled.',
        ),
      );
      return;
    }

    emit(const AuthState.loading());
    try {
      final normalized = AuthValidators.normalizeUsername(username);
      final user = await _authRepository.completeProfile(
        name: name.trim(),
        username: normalized,
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
      if (user != null && user.isProfileComplete) {
        emit(AuthState.authenticated(user: user));
      } else if (user != null && !user.isProfileComplete) {
        emit(const AuthState.profileRequired());
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
      _phoneNumber = null;
      emit(const AuthState.initial());
    } catch (e) {
      AppLogger.error('Sign out failed', error: e);
      emit(
        const AuthState.error(message: 'Failed to sign out. Please try again.'),
      );
    }
  }

  Future<bool> checkUsernameAvailability(String username) async {
    if (AuthValidators.validateUsername(username) != null) return false;
    try {
      return await _authRepository.isUsernameAvailable(
        AuthValidators.normalizeUsername(username),
      );
    } catch (e) {
      AppLogger.error('Username check failed', error: e);
      return false;
    }
  }

  Future<void> deleteAccount() async {
    emit(const AuthState.loading());
    try {
      await _authRepository.deleteAccount();
      _phoneNumber = null;
      emit(const AuthState.initial());
    } on AuthException catch (e) {
      emit(AuthState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Delete account failed', error: e);
      emit(
        const AuthState.error(
          message: 'Failed to delete account. Please try again.',
        ),
      );
    }
  }
}
