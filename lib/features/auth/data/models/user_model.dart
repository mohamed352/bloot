import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/auth/domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    String? displayName,
    String? username,
    String? avatarUrl,
    @Default(false) bool isProfileComplete,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelX on UserModel {
  User toEntity() => User(
    uid: uid,
    displayName: displayName,
    username: username,
    avatarUrl: avatarUrl,
    isProfileComplete: isProfileComplete,
  );
}
