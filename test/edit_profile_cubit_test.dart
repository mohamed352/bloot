import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:bloot/features/profile/domain/entities/user_profile.dart';
import 'package:bloot/features/profile/domain/repositories/profile_repository.dart';
import 'package:bloot/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:bloot/features/profile/presentation/cubit/edit_profile_state.dart';

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

  EditProfileCubit buildCubit() =>
      EditProfileCubit(profileRepository: profileRepository);

  group('saveProfile', () {
    blocTest<EditProfileCubit, EditProfileState>(
      'writes avatarUrl to Firestore even though the upload preview already '
      'updated the in-memory profile (regression: avatar change was lost)',
      build: () {
        when(() => profileRepository.updateProfile(any()))
            .thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadProfile(profile);
        // Simulate pickAndUploadAvatar: updates the in-memory profile with
        // the new URL for preview purposes.
        cubit.applyUploadedAvatar('https://example.com/new_avatar.jpg');
        await cubit.saveProfile(
          avatarUrl: 'https://example.com/new_avatar.jpg',
        );
      },
      verify: (_) {
        final captured = verify(
          () => profileRepository.updateProfile(captureAny()),
        ).captured;
        expect(captured, isNotEmpty);
        final data = captured.first as Map<String, dynamic>;
        expect(data['avatarUrl'], 'https://example.com/new_avatar.jpg');
      },
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'does not call updateProfile when nothing changed',
      build: () => buildCubit(),
      act: (cubit) async {
        cubit.loadProfile(profile);
        await cubit.saveProfile(
          displayName: 'Ali',
          username: 'ali_ahmed',
        );
      },
      verify: (_) {
        verifyNever(() => profileRepository.updateProfile(any()));
      },
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'does not rewrite avatarUrl on a second save after it was persisted',
      build: () {
        when(() => profileRepository.updateProfile(any()))
            .thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) async {
        cubit.loadProfile(profile);
        cubit.applyUploadedAvatar('https://example.com/new_avatar.jpg');
        await cubit.saveProfile(
          avatarUrl: 'https://example.com/new_avatar.jpg',
        );
        await cubit.saveProfile(
          avatarUrl: 'https://example.com/new_avatar.jpg',
        );
      },
      verify: (_) {
        verify(() => profileRepository.updateProfile(any())).called(1);
      },
    );
  });
}
