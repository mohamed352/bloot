import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_result.freezed.dart';

@freezed
sealed class AppResult<T> with _$AppResult<T> {
  const AppResult._();
  const factory AppResult.success(T data) = _Success<T>;
  const factory AppResult.failure(String message) = _Failure<T>;

  bool get isSuccess => this is _Success<T>;
  bool get isFailure => this is _Failure<T>;
  T? get data => mapOrNull(success: (s) => s.data);
  String? get message => mapOrNull(failure: (f) => f.message);

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    return switch (this) {
      final _Success<T> s => success(s.data),
      final _Failure<T> f => failure(f.message),
    };
  }
}
