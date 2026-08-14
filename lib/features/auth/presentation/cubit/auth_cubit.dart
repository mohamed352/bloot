import 'dart:io';

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
  }) : _authRepository = authRepository,
       _remoteConfigService = remoteConfigService,
       super(const AuthState.initial());

  final AuthRepository _authRepository;
  final RemoteConfigService _remoteConfigService;

  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user == null) {
        // User canceled the Google sign-in flow.
        emit(const AuthState.initial());
        return;
      }
      AppLogger.info(
        'Google sign-in returned uid=${user.uid}, '
        'isProfileComplete=${user.isProfileComplete}',
        tag: 'AuthCubit',
      );
      if (user.isProfileComplete) {
        AppLogger.setUserId(user.uid);
        AppLogger.setCustomKey('username', user.username);
        emit(AuthState.authenticated(user: user));
      } else {
        emit(
          AuthState.profileRequired(
            prefilledDisplayName: _authRepository.consumePrefillDisplayName(),
          ),
        );
      }
    } on AuthException catch (e) {
      emit(AuthState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to sign in with Google', error: e);
      emit(
        const AuthState.error(
          message: 'Failed to sign in with Google. Please try again.',
        ),
      );
    }
  }

  Future<void> signInWithApple() async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.signInWithApple();
      if (user == null) {
        // User canceled the Apple sign-in flow.
        emit(const AuthState.initial());
        return;
      }
      AppLogger.info(
        'Apple sign-in returned uid=${user.uid}, '
        'isProfileComplete=${user.isProfileComplete}',
        tag: 'AuthCubit',
      );
      if (user.isProfileComplete) {
        AppLogger.setUserId(user.uid);
        AppLogger.setCustomKey('username', user.username);
        emit(AuthState.authenticated(user: user));
      } else {
        emit(
          AuthState.profileRequired(
            prefilledDisplayName: _authRepository.consumePrefillDisplayName(),
          ),
        );
      }
    } on AuthException catch (e) {
      emit(AuthState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to sign in with Apple', error: e);
      emit(
        const AuthState.error(
          message: 'Failed to sign in with Apple. Please try again.',
        ),
      );
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final emailError = AuthValidators.validateEmail(email);
    if (emailError != null) {
      emit(AuthState.error(message: emailError));
      return;
    }
    final passwordError = AuthValidators.validatePassword(password);
    if (passwordError != null) {
      emit(AuthState.error(message: passwordError));
      return;
    }

    emit(const AuthState.loading());
    try {
      final user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      if (user == null) {
        emit(const AuthState.initial());
        return;
      }
      AppLogger.info(
        'Email sign-in returned uid=${user.uid}, '
        'isProfileComplete=${user.isProfileComplete}',
        tag: 'AuthCubit',
      );
      if (user.isProfileComplete) {
        AppLogger.setUserId(user.uid);
        AppLogger.setCustomKey('username', user.username);
        emit(AuthState.authenticated(user: user));
      } else {
        emit(
          AuthState.profileRequired(
            prefilledDisplayName: _authRepository.consumePrefillDisplayName(),
          ),
        );
      }
    } on AuthException catch (e) {
      emit(AuthState.error(message: e.message));
    } catch (e) {
      AppLogger.error('Failed to sign in with email', error: e);
      emit(
        const AuthState.error(
          message: 'Failed to sign in. Please try again.',
        ),
      );
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
        const AuthState.error(message: 'New sign-ups are currently disabled.'),
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
        AppLogger.setUserId(user.uid);
        AppLogger.setCustomKey('username', user.username);
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
      AppLogger.setUserId(null);
      AppLogger.setCustomKey('username', null);
      emit(const AuthState.initial());
    } catch (e) {
      AppLogger.error('Sign out failed', error: e);
      emit(
        const AuthState.error(message: 'Failed to sign out. Please try again.'),
      );
    }
  }

  Future<String?> uploadAvatar(File file) async {
    emit(const AuthState.loading());
    try {
      final url = await _authRepository.uploadAvatar(file);
      emit(const AuthState.initial());
      return url;
    } on AuthException catch (e) {
      emit(AuthState.error(message: e.message));
      return null;
    } catch (e) {
      AppLogger.error('Failed to upload avatar', error: e);
      emit(
        const AuthState.error(
          message: 'Failed to upload avatar. Please try again.',
        ),
      );
      return null;
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
      AppLogger.setUserId(null);
      AppLogger.setCustomKey('username', null);
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
