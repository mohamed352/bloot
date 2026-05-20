import 'package:injectable/injectable.dart';

import 'package:bloot/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bloot/features/auth/data/models/user_model.dart';
import 'package:bloot/features/auth/domain/entities/user.dart';
import 'package:bloot/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<void> sendOtp(String phoneNumber) =>
      _remoteDataSource.sendOtp(phoneNumber);

  @override
  Future<void> verifyOtp(String otp) => _remoteDataSource.verifyOtp(otp);

  @override
  Future<bool> isProfileComplete() => _remoteDataSource.isProfileComplete();

  @override
  Future<User> completeProfile({
    required String name,
    required String username,
    String? avatarUrl,
  }) async {
    final model = await _remoteDataSource.completeProfile(
      name: name,
      username: username,
      avatarUrl: avatarUrl,
    );
    return model.toEntity();
  }

  @override
  Future<User?> getCurrentUser() async {
    final model = await _remoteDataSource.getCurrentUser();
    return model?.toEntity();
  }

  @override
  Future<void> signOut() => _remoteDataSource.signOut();
}
