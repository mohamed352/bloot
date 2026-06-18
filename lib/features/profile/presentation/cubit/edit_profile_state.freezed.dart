// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditProfileState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditProfileState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditProfileState()';
}


}

/// @nodoc
class $EditProfileStateCopyWith<$Res>  {
$EditProfileStateCopyWith(EditProfileState _, $Res Function(EditProfileState) __);
}


/// Adds pattern-matching-related methods to [EditProfileState].
extension EditProfileStatePatterns on EditProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EditProfileInitial value)?  initial,TResult Function( EditProfileLoading value)?  loading,TResult Function( EditProfileLoaded value)?  loaded,TResult Function( EditProfileSaving value)?  saving,TResult Function( EditProfileSaved value)?  saved,TResult Function( EditProfileError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EditProfileInitial() when initial != null:
return initial(_that);case EditProfileLoading() when loading != null:
return loading(_that);case EditProfileLoaded() when loaded != null:
return loaded(_that);case EditProfileSaving() when saving != null:
return saving(_that);case EditProfileSaved() when saved != null:
return saved(_that);case EditProfileError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EditProfileInitial value)  initial,required TResult Function( EditProfileLoading value)  loading,required TResult Function( EditProfileLoaded value)  loaded,required TResult Function( EditProfileSaving value)  saving,required TResult Function( EditProfileSaved value)  saved,required TResult Function( EditProfileError value)  error,}){
final _that = this;
switch (_that) {
case EditProfileInitial():
return initial(_that);case EditProfileLoading():
return loading(_that);case EditProfileLoaded():
return loaded(_that);case EditProfileSaving():
return saving(_that);case EditProfileSaved():
return saved(_that);case EditProfileError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EditProfileInitial value)?  initial,TResult? Function( EditProfileLoading value)?  loading,TResult? Function( EditProfileLoaded value)?  loaded,TResult? Function( EditProfileSaving value)?  saving,TResult? Function( EditProfileSaved value)?  saved,TResult? Function( EditProfileError value)?  error,}){
final _that = this;
switch (_that) {
case EditProfileInitial() when initial != null:
return initial(_that);case EditProfileLoading() when loading != null:
return loading(_that);case EditProfileLoaded() when loaded != null:
return loaded(_that);case EditProfileSaving() when saving != null:
return saving(_that);case EditProfileSaved() when saved != null:
return saved(_that);case EditProfileError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( UserProfile profile,  bool hasChanges)?  loaded,TResult Function()?  saving,TResult Function()?  saved,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EditProfileInitial() when initial != null:
return initial();case EditProfileLoading() when loading != null:
return loading();case EditProfileLoaded() when loaded != null:
return loaded(_that.profile,_that.hasChanges);case EditProfileSaving() when saving != null:
return saving();case EditProfileSaved() when saved != null:
return saved();case EditProfileError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( UserProfile profile,  bool hasChanges)  loaded,required TResult Function()  saving,required TResult Function()  saved,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case EditProfileInitial():
return initial();case EditProfileLoading():
return loading();case EditProfileLoaded():
return loaded(_that.profile,_that.hasChanges);case EditProfileSaving():
return saving();case EditProfileSaved():
return saved();case EditProfileError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( UserProfile profile,  bool hasChanges)?  loaded,TResult? Function()?  saving,TResult? Function()?  saved,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case EditProfileInitial() when initial != null:
return initial();case EditProfileLoading() when loading != null:
return loading();case EditProfileLoaded() when loaded != null:
return loaded(_that.profile,_that.hasChanges);case EditProfileSaving() when saving != null:
return saving();case EditProfileSaved() when saved != null:
return saved();case EditProfileError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class EditProfileInitial implements EditProfileState {
  const EditProfileInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditProfileInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditProfileState.initial()';
}


}




/// @nodoc


class EditProfileLoading implements EditProfileState {
  const EditProfileLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditProfileLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditProfileState.loading()';
}


}




/// @nodoc


class EditProfileLoaded implements EditProfileState {
  const EditProfileLoaded({required this.profile, required this.hasChanges});
  

 final  UserProfile profile;
 final  bool hasChanges;

/// Create a copy of EditProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditProfileLoadedCopyWith<EditProfileLoaded> get copyWith => _$EditProfileLoadedCopyWithImpl<EditProfileLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditProfileLoaded&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.hasChanges, hasChanges) || other.hasChanges == hasChanges));
}


@override
int get hashCode => Object.hash(runtimeType,profile,hasChanges);

@override
String toString() {
  return 'EditProfileState.loaded(profile: $profile, hasChanges: $hasChanges)';
}


}

/// @nodoc
abstract mixin class $EditProfileLoadedCopyWith<$Res> implements $EditProfileStateCopyWith<$Res> {
  factory $EditProfileLoadedCopyWith(EditProfileLoaded value, $Res Function(EditProfileLoaded) _then) = _$EditProfileLoadedCopyWithImpl;
@useResult
$Res call({
 UserProfile profile, bool hasChanges
});




}
/// @nodoc
class _$EditProfileLoadedCopyWithImpl<$Res>
    implements $EditProfileLoadedCopyWith<$Res> {
  _$EditProfileLoadedCopyWithImpl(this._self, this._then);

  final EditProfileLoaded _self;
  final $Res Function(EditProfileLoaded) _then;

/// Create a copy of EditProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? profile = null,Object? hasChanges = null,}) {
  return _then(EditProfileLoaded(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile,hasChanges: null == hasChanges ? _self.hasChanges : hasChanges // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class EditProfileSaving implements EditProfileState {
  const EditProfileSaving();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditProfileSaving);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditProfileState.saving()';
}


}




/// @nodoc


class EditProfileSaved implements EditProfileState {
  const EditProfileSaved();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditProfileSaved);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditProfileState.saved()';
}


}




/// @nodoc


class EditProfileError implements EditProfileState {
  const EditProfileError({required this.message});
  

 final  String message;

/// Create a copy of EditProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditProfileErrorCopyWith<EditProfileError> get copyWith => _$EditProfileErrorCopyWithImpl<EditProfileError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditProfileError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'EditProfileState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $EditProfileErrorCopyWith<$Res> implements $EditProfileStateCopyWith<$Res> {
  factory $EditProfileErrorCopyWith(EditProfileError value, $Res Function(EditProfileError) _then) = _$EditProfileErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$EditProfileErrorCopyWithImpl<$Res>
    implements $EditProfileErrorCopyWith<$Res> {
  _$EditProfileErrorCopyWithImpl(this._self, this._then);

  final EditProfileError _self;
  final $Res Function(EditProfileError) _then;

/// Create a copy of EditProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(EditProfileError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
