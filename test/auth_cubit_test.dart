import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/features/auth/domain/entities/user.dart';
import 'package:bloot/features/auth/domain/exceptions/auth_exception.dart';
import 'package:bloot/features/auth/domain/repositories/auth_repository.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bloot/features/auth/presentation/cubit/auth_state.dart';
import 'package:bloot/core/services/remote_config_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  late MockAuthRepository authRepository;
  late MockRemoteConfigService remoteConfigService;

  setUp(() {
    authRepository = MockAuthRepository();
    remoteConfigService = MockRemoteConfigService();
    when(() => remoteConfigService.allowNewSignups).thenReturn(true);
  });

  const name = 'Ali';
  const username = 'ali_ahmed';
  const user = User(
    uid: 'u1',
    displayName: name,
    username: username,
    isProfileComplete: true,
  );

  AuthCubit buildCubit() => AuthCubit(
        authRepository: authRepository,
        remoteConfigService: remoteConfigService,
      );

  group('signInWithGoogle', () {
    blocTest<AuthCubit, AuthState>(
      'emits authenticated when profile is complete',
      build: buildCubit,
      act: (cubit) => cubit.signInWithGoogle(),
      setUp: () {
        when(() => authRepository.signInWithGoogle())
            .thenAnswer((_) async => user);
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(user: user),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits profileRequired when profile is incomplete',
      build: buildCubit,
      act: (cubit) => cubit.signInWithGoogle(),
      setUp: () {
        when(() => authRepository.signInWithGoogle())
            .thenAnswer((_) async => const User(uid: 'u1'));
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.profileRequired(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits initial when user cancels',
      build: buildCubit,
      act: (cubit) => cubit.signInWithGoogle(),
      setUp: () {
        when(() => authRepository.signInWithGoogle())
            .thenAnswer((_) async => null);
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.initial(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits error on failure',
      build: buildCubit,
      act: (cubit) => cubit.signInWithGoogle(),
      setUp: () {
        when(() => authRepository.signInWithGoogle())
            .thenThrow(const AuthException('Google sign in failed'));
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.error(message: 'Google sign in failed'),
      ],
    );
  });

  group('signInWithApple', () {
    blocTest<AuthCubit, AuthState>(
      'emits authenticated when profile is complete',
      build: buildCubit,
      act: (cubit) => cubit.signInWithApple(),
      setUp: () {
        when(() => authRepository.signInWithApple())
            .thenAnswer((_) async => user);
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(user: user),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits initial when user cancels',
      build: buildCubit,
      act: (cubit) => cubit.signInWithApple(),
      setUp: () {
        when(() => authRepository.signInWithApple())
            .thenAnswer((_) async => null);
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.initial(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits error on failure',
      build: buildCubit,
      act: (cubit) => cubit.signInWithApple(),
      setUp: () {
        when(() => authRepository.signInWithApple())
            .thenThrow(const AuthException('Apple sign in failed'));
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.error(message: 'Apple sign in failed'),
      ],
    );
  });

  group('completeProfile', () {
    blocTest<AuthCubit, AuthState>(
      'emits loading then authenticated on success',
      build: buildCubit,
      act: (cubit) => cubit.completeProfile(name: name, username: username),
      setUp: () {
        when(
          () => authRepository.completeProfile(
            name: name,
            username: username.toLowerCase(),
          ),
        ).thenAnswer((_) async => user);
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(user: user),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits error when repository fails',
      build: buildCubit,
      act: (cubit) => cubit.completeProfile(name: name, username: username),
      setUp: () {
        when(
          () => authRepository.completeProfile(
            name: name,
            username: username.toLowerCase(),
          ),
        ).thenThrow(const AuthException('Username taken'));
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.error(message: 'Username taken'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits error when new sign-ups are disabled',
      build: buildCubit,
      act: (cubit) => cubit.completeProfile(name: name, username: username),
      setUp: () {
        when(() => remoteConfigService.allowNewSignups).thenReturn(false);
      },
      expect: () => [
        const AuthState.error(
          message: 'New sign-ups are currently disabled.',
        ),
      ],
    );
  });

  group('checkAuthStatus', () {
    blocTest<AuthCubit, AuthState>(
      'emits authenticated for complete user',
      build: buildCubit,
      act: (cubit) => cubit.checkAuthStatus(),
      setUp: () {
        when(() => authRepository.getCurrentUser())
            .thenAnswer((_) async => user);
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(user: user),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits profileRequired for incomplete user',
      build: buildCubit,
      act: (cubit) => cubit.checkAuthStatus(),
      setUp: () {
        when(() => authRepository.getCurrentUser())
            .thenAnswer((_) async => const User(uid: 'u1'));
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.profileRequired(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits initial when no current user',
      build: buildCubit,
      act: (cubit) => cubit.checkAuthStatus(),
      setUp: () {
        when(() => authRepository.getCurrentUser())
            .thenAnswer((_) async => null);
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.initial(),
      ],
    );
  });

  group('signOut', () {
    blocTest<AuthCubit, AuthState>(
      'emits loading then initial',
      build: buildCubit,
      act: (cubit) => cubit.signOut(),
      setUp: () {
        when(() => authRepository.signOut()).thenAnswer((_) async {});
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.initial(),
      ],
    );
  });

  group('deleteAccount', () {
    blocTest<AuthCubit, AuthState>(
      'emits loading then initial on success',
      build: buildCubit,
      act: (cubit) => cubit.deleteAccount(),
      setUp: () {
        when(() => authRepository.deleteAccount()).thenAnswer((_) async {});
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.initial(),
      ],
    );
  });

  group('checkUsernameAvailability', () {
    test('returns false for invalid username', () async {
      final cubit = buildCubit();
      expect(await cubit.checkUsernameAvailability('ab'), isFalse);
    });

    test('returns repository result for valid username', () async {
      when(() => authRepository.isUsernameAvailable('ali_ahmed'))
          .thenAnswer((_) async => true);
      final cubit = buildCubit();
      expect(await cubit.checkUsernameAvailability('Ali_Ahmed'), isTrue);
    });
  });
}
