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

  const phone = '+966501234567';
  const otp = '123456';
  const name = 'Ali';
  const username = 'ali_ahmed';
  const user = User(
    uid: 'u1',
    phoneNumber: phone,
    displayName: name,
    username: username,
    isProfileComplete: true,
  );

  AuthCubit buildCubit() => AuthCubit(
        authRepository: authRepository,
        remoteConfigService: remoteConfigService,
      );

  group('sendOtp', () {
    blocTest<AuthCubit, AuthState>(
      'emits loading then otpSent on success',
      build: buildCubit,
      act: (cubit) => cubit.sendOtp(phone),
      setUp: () {
        when(() => authRepository.sendOtp(phone)).thenAnswer((_) async {});
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.otpSent(phoneNumber: phone),
      ],
      verify: (_) {
        verify(() => authRepository.sendOtp(phone)).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'emits loading then error on failure',
      build: buildCubit,
      act: (cubit) => cubit.sendOtp(phone),
      setUp: () {
        when(() => authRepository.sendOtp(phone))
            .thenThrow(const AuthException('Failed to send'));
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.error(message: 'Failed to send'),
      ],
    );
  });

  group('resendOtp', () {
    blocTest<AuthCubit, AuthState>(
      'emits error when no phone number was stored',
      build: buildCubit,
      act: (cubit) => cubit.resendOtp(),
      expect: () => [
        const AuthState.error(
          message: 'Phone number not found. Please start over.',
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits loading then otpSent when phone is available',
      build: buildCubit,
      act: (cubit) async {
        await cubit.sendOtp(phone);
        await cubit.resendOtp();
      },
      setUp: () {
        when(() => authRepository.sendOtp(phone)).thenAnswer((_) async {});
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.otpSent(phoneNumber: phone),
        const AuthState.loading(),
        const AuthState.otpSent(phoneNumber: phone),
      ],
      verify: (_) {
        verify(() => authRepository.sendOtp(phone)).called(2);
      },
    );
  });

  group('verifyOtp', () {
    blocTest<AuthCubit, AuthState>(
      'emits authenticated when profile is complete',
      build: buildCubit,
      act: (cubit) => cubit.verifyOtp(otp),
      setUp: () {
        when(() => authRepository.verifyOtp(otp)).thenAnswer((_) async {});
        when(() => authRepository.isProfileComplete())
            .thenAnswer((_) async => true);
        when(() => authRepository.getCurrentUser())
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
      act: (cubit) => cubit.verifyOtp(otp),
      setUp: () {
        when(() => authRepository.verifyOtp(otp)).thenAnswer((_) async {});
        when(() => authRepository.isProfileComplete())
            .thenAnswer((_) async => false);
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.profileRequired(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits error when OTP verification fails',
      build: buildCubit,
      act: (cubit) => cubit.verifyOtp(otp),
      setUp: () {
        when(() => authRepository.verifyOtp(otp))
            .thenThrow(const AuthException('Invalid OTP'));
      },
      expect: () => [
        const AuthState.loading(),
        const AuthState.error(message: 'Invalid OTP'),
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
            .thenAnswer((_) async => const User(uid: 'u1', phoneNumber: phone));
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
