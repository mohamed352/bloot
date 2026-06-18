import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/features/profile/domain/entities/achievement.dart';
import 'package:bloot/features/profile/domain/entities/game_history.dart';
import 'package:bloot/features/profile/domain/entities/user_profile.dart';
import 'package:bloot/features/profile/domain/repositories/profile_repository.dart';
import 'package:bloot/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bloot/features/profile/presentation/cubit/profile_state.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepository profileRepository;

  setUp(() {
    profileRepository = MockProfileRepository();
  });

  const profile = UserProfile(
    uid: 'u1',
    displayName: 'Ali',
    username: 'ali_ahmed',
  );

  const gameHistory = GameHistory(
    id: 'h1',
    won: true,
    score: '152-120',
    type: 'hokm',
  );

  const achievement = Achievement(
    id: 'a1',
    title: 'First Win',
  );

  ProfileCubit buildCubit() => ProfileCubit(profileRepository: profileRepository);

  group('loadProfile for current user', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits loaded state with profile, history, and achievements',
      build: () {
        when(() => profileRepository.watchCurrentUserProfile()).thenAnswer(
          (_) => Stream.value(profile),
        );
        when(() => profileRepository.getGameHistory('u1'))
            .thenAnswer((_) async => [gameHistory]);
        when(() => profileRepository.getAchievements('u1'))
            .thenAnswer((_) async => [achievement]);
        return buildCubit();
      },
      act: (cubit) => cubit.loadProfile('me'),
      expect: () => [
        const ProfileState.loading(),
        const ProfileState.loaded(
          profile: profile,
          gameHistory: [gameHistory],
          achievements: [achievement],
        ),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits error when profile not found',
      build: () {
        when(() => profileRepository.watchCurrentUserProfile()).thenAnswer(
          (_) => Stream.value(null),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadProfile('me'),
      expect: () => [
        const ProfileState.loading(),
        const ProfileState.error(
          message: 'Profile not found. Please complete your profile.',
        ),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits error when stream fails',
      build: () {
        when(() => profileRepository.watchCurrentUserProfile())
            .thenAnswer((_) => Stream.error(Exception('network')));
        return buildCubit();
      },
      act: (cubit) => cubit.loadProfile('me'),
      expect: () => [
        const ProfileState.loading(),
        isA<ProfileError>(),
      ],
    );
  });

  group('loadProfile for other user', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits loaded state with profile, history, and achievements',
      build: buildCubit,
      setUp: () {
        when(() => profileRepository.getUserProfile('u2'))
            .thenAnswer((_) async => profile);
        when(() => profileRepository.getGameHistory('u2'))
            .thenAnswer((_) async => [gameHistory]);
        when(() => profileRepository.getAchievements('u2'))
            .thenAnswer((_) async => [achievement]);
      },
      act: (cubit) => cubit.loadProfile('u2'),
      expect: () => [
        const ProfileState.loading(),
        const ProfileState.loaded(
          profile: profile,
          gameHistory: [gameHistory],
          achievements: [achievement],
        ),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits error when user not found',
      build: buildCubit,
      setUp: () {
        when(() => profileRepository.getUserProfile('u2'))
            .thenAnswer((_) async => null);
      },
      act: (cubit) => cubit.loadProfile('u2'),
      expect: () => [
        const ProfileState.loading(),
        const ProfileState.error(message: 'User not found.'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits error when fetch fails',
      build: buildCubit,
      setUp: () {
        when(() => profileRepository.getUserProfile('u2'))
            .thenThrow(Exception('network'));
      },
      act: (cubit) => cubit.loadProfile('u2'),
      expect: () => [
        const ProfileState.loading(),
        const ProfileState.error(message: 'Failed to load profile.'),
      ],
    );
  });
}
