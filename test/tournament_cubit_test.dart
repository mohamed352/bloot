import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/features/profile/domain/entities/user_profile.dart';
import 'package:bloot/features/profile/domain/repositories/profile_repository.dart';
import 'package:bloot/features/tournament/domain/entities/tournament.dart';
import 'package:bloot/features/tournament/domain/repositories/tournament_repository.dart';
import 'package:bloot/features/tournament/presentation/cubit/tournament_cubit.dart';
import 'package:bloot/features/tournament/presentation/cubit/tournament_state.dart';

class MockTournamentRepository extends Mock implements TournamentRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockTournamentRepository tournamentRepository;
  late MockProfileRepository profileRepository;

  setUp(() {
    tournamentRepository = MockTournamentRepository();
    profileRepository = MockProfileRepository();
  });

  const tournament = Tournament(
    id: 't1',
    name: 'Summer Cup',
    prize: '1000',
    participants: '8/16',
    status: 'upcoming',
    date: 'Tomorrow',
  );

  const currentUser = UserProfile(uid: 'u1', displayName: 'Ali');

  TournamentCubit buildCubit() => TournamentCubit(
        tournamentRepository: tournamentRepository,
        profileRepository: profileRepository,
      );

  group('loadTournaments', () {
    blocTest<TournamentCubit, TournamentState>(
      'emits loaded state with tournaments',
      build: buildCubit,
      setUp: () {
        when(() => tournamentRepository.getTournaments())
            .thenAnswer((_) async => [tournament]);
      },
      act: (cubit) => cubit.loadTournaments(),
      expect: () => [
        const TournamentState.loading(),
        const TournamentState.loaded(tournaments: [tournament]),
      ],
    );

    blocTest<TournamentCubit, TournamentState>(
      'emits error when repository fails',
      build: buildCubit,
      setUp: () {
        when(() => tournamentRepository.getTournaments())
            .thenThrow(Exception('network'));
      },
      act: (cubit) => cubit.loadTournaments(),
      expect: () => [
        const TournamentState.loading(),
        const TournamentState.error(message: 'Failed to load tournaments.'),
      ],
    );
  });

  group('loadTournament', () {
    blocTest<TournamentCubit, TournamentState>(
      'emits detail loaded state',
      build: buildCubit,
      setUp: () {
        when(() => tournamentRepository.getTournamentById('t1'))
            .thenAnswer((_) async => tournament);
        when(() => profileRepository.getUserProfiles(any()))
            .thenAnswer((_) async => []);
        when(() => profileRepository.getCurrentUserProfile())
            .thenAnswer((_) async => currentUser);
      },
      act: (cubit) => cubit.loadTournament('t1'),
      expect: () => [
        const TournamentState.detailLoading(),
        const TournamentState.detailLoaded(tournament: tournament),
      ],
    );

    blocTest<TournamentCubit, TournamentState>(
      'emits detail error when tournament not found',
      build: buildCubit,
      setUp: () {
        when(() => tournamentRepository.getTournamentById('t1'))
            .thenAnswer((_) async => null);
      },
      act: (cubit) => cubit.loadTournament('t1'),
      expect: () => [
        const TournamentState.detailLoading(),
        const TournamentState.detailError(message: 'Tournament not found.'),
      ],
    );
  });

  group('watchTournament', () {
    blocTest<TournamentCubit, TournamentState>(
      'emits detail loaded on stream events',
      build: () {
        when(() => tournamentRepository.watchTournament('t1')).thenAnswer(
          (_) => Stream.value(tournament),
        );
        when(() => profileRepository.getUserProfiles(any()))
            .thenAnswer((_) async => []);
        when(() => profileRepository.getCurrentUserProfile())
            .thenAnswer((_) async => currentUser);
        return buildCubit();
      },
      act: (cubit) => cubit.watchTournament('t1'),
      expect: () => [
        const TournamentState.detailLoading(),
        const TournamentState.detailLoaded(tournament: tournament),
      ],
    );
  });

  group('joinTournament', () {
    blocTest<TournamentCubit, TournamentState>(
      'emits joining then detail loaded and joined',
      build: buildCubit,
      setUp: () {
        when(() => tournamentRepository.joinTournament('t1'))
            .thenAnswer((_) async => tournament);
        when(() => profileRepository.getUserProfiles(any()))
            .thenAnswer((_) async => []);
      },
      act: (cubit) => cubit.joinTournament('t1'),
      expect: () => [
        const TournamentState.joining(),
        const TournamentState.detailLoaded(tournament: tournament),
        const TournamentState.joined(tournamentId: 't1'),
      ],
    );

    blocTest<TournamentCubit, TournamentState>(
      'emits join error when repository fails',
      build: buildCubit,
      setUp: () {
        when(() => tournamentRepository.joinTournament('t1'))
            .thenThrow(Exception('network'));
      },
      act: (cubit) => cubit.joinTournament('t1'),
      expect: () => [
        const TournamentState.joining(),
        isA<TournamentJoinError>(),
      ],
    );
  });

  group('selectFilter', () {
    blocTest<TournamentCubit, TournamentState>(
      'updates selected filter index',
      build: buildCubit,
      seed: () => const TournamentState.loaded(
        tournaments: [tournament],
      ),
      act: (cubit) => cubit.selectFilter(2),
      expect: () => [
        const TournamentState.loaded(
          tournaments: [tournament],
          selectedFilterIndex: 2,
        ),
      ],
    );
  });
}
