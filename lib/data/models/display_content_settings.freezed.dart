// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'display_content_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisplayContentSettings {

@JsonKey(unknownEnumValue: DisplayContentType.main) DisplayContentType get contentType;
/// Create a copy of DisplayContentSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DisplayContentSettingsCopyWith<DisplayContentSettings> get copyWith => _$DisplayContentSettingsCopyWithImpl<DisplayContentSettings>(this as DisplayContentSettings, _$identity);

  /// Serializes this DisplayContentSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DisplayContentSettings&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contentType);

@override
String toString() {
  return 'DisplayContentSettings(contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $DisplayContentSettingsCopyWith<$Res>  {
  factory $DisplayContentSettingsCopyWith(DisplayContentSettings value, $Res Function(DisplayContentSettings) _then) = _$DisplayContentSettingsCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: DisplayContentType.main) DisplayContentType contentType
});




}
/// @nodoc
class _$DisplayContentSettingsCopyWithImpl<$Res>
    implements $DisplayContentSettingsCopyWith<$Res> {
  _$DisplayContentSettingsCopyWithImpl(this._self, this._then);

  final DisplayContentSettings _self;
  final $Res Function(DisplayContentSettings) _then;

/// Create a copy of DisplayContentSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contentType = null,}) {
  return _then(_self.copyWith(
contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as DisplayContentType,
  ));
}

}


/// Adds pattern-matching-related methods to [DisplayContentSettings].
extension DisplayContentSettingsPatterns on DisplayContentSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DisplayContentSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DisplayContentSettings() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DisplayContentSettings value)  $default,){
final _that = this;
switch (_that) {
case _DisplayContentSettings():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DisplayContentSettings value)?  $default,){
final _that = this;
switch (_that) {
case _DisplayContentSettings() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: DisplayContentType.main)  DisplayContentType contentType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DisplayContentSettings() when $default != null:
return $default(_that.contentType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: DisplayContentType.main)  DisplayContentType contentType)  $default,) {final _that = this;
switch (_that) {
case _DisplayContentSettings():
return $default(_that.contentType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: DisplayContentType.main)  DisplayContentType contentType)?  $default,) {final _that = this;
switch (_that) {
case _DisplayContentSettings() when $default != null:
return $default(_that.contentType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DisplayContentSettings implements DisplayContentSettings {
  const _DisplayContentSettings({@JsonKey(unknownEnumValue: DisplayContentType.main) this.contentType = DisplayContentType.main});
  factory _DisplayContentSettings.fromJson(Map<String, dynamic> json) => _$DisplayContentSettingsFromJson(json);

@override@JsonKey(unknownEnumValue: DisplayContentType.main) final  DisplayContentType contentType;

/// Create a copy of DisplayContentSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DisplayContentSettingsCopyWith<_DisplayContentSettings> get copyWith => __$DisplayContentSettingsCopyWithImpl<_DisplayContentSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DisplayContentSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DisplayContentSettings&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,contentType);

@override
String toString() {
  return 'DisplayContentSettings(contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class _$DisplayContentSettingsCopyWith<$Res> implements $DisplayContentSettingsCopyWith<$Res> {
  factory _$DisplayContentSettingsCopyWith(_DisplayContentSettings value, $Res Function(_DisplayContentSettings) _then) = __$DisplayContentSettingsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: DisplayContentType.main) DisplayContentType contentType
});




}
/// @nodoc
class __$DisplayContentSettingsCopyWithImpl<$Res>
    implements _$DisplayContentSettingsCopyWith<$Res> {
  __$DisplayContentSettingsCopyWithImpl(this._self, this._then);

  final _DisplayContentSettings _self;
  final $Res Function(_DisplayContentSettings) _then;

/// Create a copy of DisplayContentSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contentType = null,}) {
  return _then(_DisplayContentSettings(
contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as DisplayContentType,
  ));
}


}

// dart format on
