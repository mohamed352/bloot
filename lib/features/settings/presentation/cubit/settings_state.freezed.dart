// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsState()';
}


}

/// @nodoc
class $SettingsStateCopyWith<$Res>  {
$SettingsStateCopyWith(SettingsState _, $Res Function(SettingsState) __);
}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SettingsInitial value)?  initial,TResult Function( SettingsLoaded value)?  loaded,TResult Function( SettingsError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SettingsInitial() when initial != null:
return initial(_that);case SettingsLoaded() when loaded != null:
return loaded(_that);case SettingsError() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SettingsInitial value)  initial,required TResult Function( SettingsLoaded value)  loaded,required TResult Function( SettingsError value)  error,}){
final _that = this;
switch (_that) {
case SettingsInitial():
return initial(_that);case SettingsLoaded():
return loaded(_that);case SettingsError():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SettingsInitial value)?  initial,TResult? Function( SettingsLoaded value)?  loaded,TResult? Function( SettingsError value)?  error,}){
final _that = this;
switch (_that) {
case SettingsInitial() when initial != null:
return initial(_that);case SettingsLoaded() when loaded != null:
return loaded(_that);case SettingsError() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( bool voiceChatEnabled,  bool cameraEnabled,  bool autoRotateGame,  bool soundEffectsEnabled,  bool backgroundMusicEnabled,  bool showOnlineStatus,  String gameSpeed,  String speakerMode,  String profileVisibility)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SettingsInitial() when initial != null:
return initial();case SettingsLoaded() when loaded != null:
return loaded(_that.voiceChatEnabled,_that.cameraEnabled,_that.autoRotateGame,_that.soundEffectsEnabled,_that.backgroundMusicEnabled,_that.showOnlineStatus,_that.gameSpeed,_that.speakerMode,_that.profileVisibility);case SettingsError() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( bool voiceChatEnabled,  bool cameraEnabled,  bool autoRotateGame,  bool soundEffectsEnabled,  bool backgroundMusicEnabled,  bool showOnlineStatus,  String gameSpeed,  String speakerMode,  String profileVisibility)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case SettingsInitial():
return initial();case SettingsLoaded():
return loaded(_that.voiceChatEnabled,_that.cameraEnabled,_that.autoRotateGame,_that.soundEffectsEnabled,_that.backgroundMusicEnabled,_that.showOnlineStatus,_that.gameSpeed,_that.speakerMode,_that.profileVisibility);case SettingsError():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( bool voiceChatEnabled,  bool cameraEnabled,  bool autoRotateGame,  bool soundEffectsEnabled,  bool backgroundMusicEnabled,  bool showOnlineStatus,  String gameSpeed,  String speakerMode,  String profileVisibility)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case SettingsInitial() when initial != null:
return initial();case SettingsLoaded() when loaded != null:
return loaded(_that.voiceChatEnabled,_that.cameraEnabled,_that.autoRotateGame,_that.soundEffectsEnabled,_that.backgroundMusicEnabled,_that.showOnlineStatus,_that.gameSpeed,_that.speakerMode,_that.profileVisibility);case SettingsError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class SettingsInitial implements SettingsState {
  const SettingsInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsState.initial()';
}


}




/// @nodoc


class SettingsLoaded implements SettingsState {
  const SettingsLoaded({required this.voiceChatEnabled, required this.cameraEnabled, required this.autoRotateGame, required this.soundEffectsEnabled, required this.backgroundMusicEnabled, required this.showOnlineStatus, required this.gameSpeed, required this.speakerMode, required this.profileVisibility});
  

 final  bool voiceChatEnabled;
 final  bool cameraEnabled;
 final  bool autoRotateGame;
 final  bool soundEffectsEnabled;
 final  bool backgroundMusicEnabled;
 final  bool showOnlineStatus;
 final  String gameSpeed;
 final  String speakerMode;
 final  String profileVisibility;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsLoadedCopyWith<SettingsLoaded> get copyWith => _$SettingsLoadedCopyWithImpl<SettingsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsLoaded&&(identical(other.voiceChatEnabled, voiceChatEnabled) || other.voiceChatEnabled == voiceChatEnabled)&&(identical(other.cameraEnabled, cameraEnabled) || other.cameraEnabled == cameraEnabled)&&(identical(other.autoRotateGame, autoRotateGame) || other.autoRotateGame == autoRotateGame)&&(identical(other.soundEffectsEnabled, soundEffectsEnabled) || other.soundEffectsEnabled == soundEffectsEnabled)&&(identical(other.backgroundMusicEnabled, backgroundMusicEnabled) || other.backgroundMusicEnabled == backgroundMusicEnabled)&&(identical(other.showOnlineStatus, showOnlineStatus) || other.showOnlineStatus == showOnlineStatus)&&(identical(other.gameSpeed, gameSpeed) || other.gameSpeed == gameSpeed)&&(identical(other.speakerMode, speakerMode) || other.speakerMode == speakerMode)&&(identical(other.profileVisibility, profileVisibility) || other.profileVisibility == profileVisibility));
}


@override
int get hashCode => Object.hash(runtimeType,voiceChatEnabled,cameraEnabled,autoRotateGame,soundEffectsEnabled,backgroundMusicEnabled,showOnlineStatus,gameSpeed,speakerMode,profileVisibility);

@override
String toString() {
  return 'SettingsState.loaded(voiceChatEnabled: $voiceChatEnabled, cameraEnabled: $cameraEnabled, autoRotateGame: $autoRotateGame, soundEffectsEnabled: $soundEffectsEnabled, backgroundMusicEnabled: $backgroundMusicEnabled, showOnlineStatus: $showOnlineStatus, gameSpeed: $gameSpeed, speakerMode: $speakerMode, profileVisibility: $profileVisibility)';
}


}

/// @nodoc
abstract mixin class $SettingsLoadedCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory $SettingsLoadedCopyWith(SettingsLoaded value, $Res Function(SettingsLoaded) _then) = _$SettingsLoadedCopyWithImpl;
@useResult
$Res call({
 bool voiceChatEnabled, bool cameraEnabled, bool autoRotateGame, bool soundEffectsEnabled, bool backgroundMusicEnabled, bool showOnlineStatus, String gameSpeed, String speakerMode, String profileVisibility
});




}
/// @nodoc
class _$SettingsLoadedCopyWithImpl<$Res>
    implements $SettingsLoadedCopyWith<$Res> {
  _$SettingsLoadedCopyWithImpl(this._self, this._then);

  final SettingsLoaded _self;
  final $Res Function(SettingsLoaded) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? voiceChatEnabled = null,Object? cameraEnabled = null,Object? autoRotateGame = null,Object? soundEffectsEnabled = null,Object? backgroundMusicEnabled = null,Object? showOnlineStatus = null,Object? gameSpeed = null,Object? speakerMode = null,Object? profileVisibility = null,}) {
  return _then(SettingsLoaded(
voiceChatEnabled: null == voiceChatEnabled ? _self.voiceChatEnabled : voiceChatEnabled // ignore: cast_nullable_to_non_nullable
as bool,cameraEnabled: null == cameraEnabled ? _self.cameraEnabled : cameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,autoRotateGame: null == autoRotateGame ? _self.autoRotateGame : autoRotateGame // ignore: cast_nullable_to_non_nullable
as bool,soundEffectsEnabled: null == soundEffectsEnabled ? _self.soundEffectsEnabled : soundEffectsEnabled // ignore: cast_nullable_to_non_nullable
as bool,backgroundMusicEnabled: null == backgroundMusicEnabled ? _self.backgroundMusicEnabled : backgroundMusicEnabled // ignore: cast_nullable_to_non_nullable
as bool,showOnlineStatus: null == showOnlineStatus ? _self.showOnlineStatus : showOnlineStatus // ignore: cast_nullable_to_non_nullable
as bool,gameSpeed: null == gameSpeed ? _self.gameSpeed : gameSpeed // ignore: cast_nullable_to_non_nullable
as String,speakerMode: null == speakerMode ? _self.speakerMode : speakerMode // ignore: cast_nullable_to_non_nullable
as String,profileVisibility: null == profileVisibility ? _self.profileVisibility : profileVisibility // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SettingsError implements SettingsState {
  const SettingsError({required this.message});
  

 final  String message;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsErrorCopyWith<SettingsError> get copyWith => _$SettingsErrorCopyWithImpl<SettingsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SettingsState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $SettingsErrorCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory $SettingsErrorCopyWith(SettingsError value, $Res Function(SettingsError) _then) = _$SettingsErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SettingsErrorCopyWithImpl<$Res>
    implements $SettingsErrorCopyWith<$Res> {
  _$SettingsErrorCopyWithImpl(this._self, this._then);

  final SettingsError _self;
  final $Res Function(SettingsError) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SettingsError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
