import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bloot/features/profile/domain/entities/achievement.dart';

part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';

@freezed
abstract class AchievementModel with _$AchievementModel {
  const factory AchievementModel({
    required String id,
    required String title,
    String? description,
    String? iconName,
    DateTime? unlockedAt,
  }) = _AchievementModel;

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);
}

extension AchievementModelX on AchievementModel {
  Achievement toEntity() => Achievement(
        id: id,
        title: title,
        description: description,
        iconName: iconName,
        unlockedAt: unlockedAt,
      );
}
