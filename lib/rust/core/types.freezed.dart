// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PJSUAError {

 String get field0;
/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PJSUAErrorCopyWith<PJSUAError> get copyWith => _$PJSUAErrorCopyWithImpl<PJSUAError>(this as PJSUAError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PJSUAError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PJSUAError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PJSUAErrorCopyWith<$Res>  {
  factory $PJSUAErrorCopyWith(PJSUAError value, $Res Function(PJSUAError) _then) = _$PJSUAErrorCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$PJSUAErrorCopyWithImpl<$Res>
    implements $PJSUAErrorCopyWith<$Res> {
  _$PJSUAErrorCopyWithImpl(this._self, this._then);

  final PJSUAError _self;
  final $Res Function(PJSUAError) _then;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field0 = null,}) {
  return _then(_self.copyWith(
field0: null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PJSUAError].
extension PJSUAErrorPatterns on PJSUAError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PJSUAError_CreationError value)?  creationError,TResult Function( PJSUAError_ConfigError value)?  configError,TResult Function( PJSUAError_InitializationError value)?  initializationError,TResult Function( PJSUAError_TransportError value)?  transportError,TResult Function( PJSUAError_DTMFError value)?  dtmfError,TResult Function( PJSUAError_CallCreationError value)?  callCreationError,TResult Function( PJSUAError_CallStatusUpdateError value)?  callStatusUpdateError,TResult Function( PJSUAError_AccountCreationError value)?  accountCreationError,TResult Function( PJSUAError_PJSUAStartError value)?  pjsuaStartError,TResult Function( PJSUAError_PJSUADestroyError value)?  pjsuaDestroyError,TResult Function( PJSUAError_InputValueError value)?  inputValueError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PJSUAError_CreationError() when creationError != null:
return creationError(_that);case PJSUAError_ConfigError() when configError != null:
return configError(_that);case PJSUAError_InitializationError() when initializationError != null:
return initializationError(_that);case PJSUAError_TransportError() when transportError != null:
return transportError(_that);case PJSUAError_DTMFError() when dtmfError != null:
return dtmfError(_that);case PJSUAError_CallCreationError() when callCreationError != null:
return callCreationError(_that);case PJSUAError_CallStatusUpdateError() when callStatusUpdateError != null:
return callStatusUpdateError(_that);case PJSUAError_AccountCreationError() when accountCreationError != null:
return accountCreationError(_that);case PJSUAError_PJSUAStartError() when pjsuaStartError != null:
return pjsuaStartError(_that);case PJSUAError_PJSUADestroyError() when pjsuaDestroyError != null:
return pjsuaDestroyError(_that);case PJSUAError_InputValueError() when inputValueError != null:
return inputValueError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PJSUAError_CreationError value)  creationError,required TResult Function( PJSUAError_ConfigError value)  configError,required TResult Function( PJSUAError_InitializationError value)  initializationError,required TResult Function( PJSUAError_TransportError value)  transportError,required TResult Function( PJSUAError_DTMFError value)  dtmfError,required TResult Function( PJSUAError_CallCreationError value)  callCreationError,required TResult Function( PJSUAError_CallStatusUpdateError value)  callStatusUpdateError,required TResult Function( PJSUAError_AccountCreationError value)  accountCreationError,required TResult Function( PJSUAError_PJSUAStartError value)  pjsuaStartError,required TResult Function( PJSUAError_PJSUADestroyError value)  pjsuaDestroyError,required TResult Function( PJSUAError_InputValueError value)  inputValueError,}){
final _that = this;
switch (_that) {
case PJSUAError_CreationError():
return creationError(_that);case PJSUAError_ConfigError():
return configError(_that);case PJSUAError_InitializationError():
return initializationError(_that);case PJSUAError_TransportError():
return transportError(_that);case PJSUAError_DTMFError():
return dtmfError(_that);case PJSUAError_CallCreationError():
return callCreationError(_that);case PJSUAError_CallStatusUpdateError():
return callStatusUpdateError(_that);case PJSUAError_AccountCreationError():
return accountCreationError(_that);case PJSUAError_PJSUAStartError():
return pjsuaStartError(_that);case PJSUAError_PJSUADestroyError():
return pjsuaDestroyError(_that);case PJSUAError_InputValueError():
return inputValueError(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PJSUAError_CreationError value)?  creationError,TResult? Function( PJSUAError_ConfigError value)?  configError,TResult? Function( PJSUAError_InitializationError value)?  initializationError,TResult? Function( PJSUAError_TransportError value)?  transportError,TResult? Function( PJSUAError_DTMFError value)?  dtmfError,TResult? Function( PJSUAError_CallCreationError value)?  callCreationError,TResult? Function( PJSUAError_CallStatusUpdateError value)?  callStatusUpdateError,TResult? Function( PJSUAError_AccountCreationError value)?  accountCreationError,TResult? Function( PJSUAError_PJSUAStartError value)?  pjsuaStartError,TResult? Function( PJSUAError_PJSUADestroyError value)?  pjsuaDestroyError,TResult? Function( PJSUAError_InputValueError value)?  inputValueError,}){
final _that = this;
switch (_that) {
case PJSUAError_CreationError() when creationError != null:
return creationError(_that);case PJSUAError_ConfigError() when configError != null:
return configError(_that);case PJSUAError_InitializationError() when initializationError != null:
return initializationError(_that);case PJSUAError_TransportError() when transportError != null:
return transportError(_that);case PJSUAError_DTMFError() when dtmfError != null:
return dtmfError(_that);case PJSUAError_CallCreationError() when callCreationError != null:
return callCreationError(_that);case PJSUAError_CallStatusUpdateError() when callStatusUpdateError != null:
return callStatusUpdateError(_that);case PJSUAError_AccountCreationError() when accountCreationError != null:
return accountCreationError(_that);case PJSUAError_PJSUAStartError() when pjsuaStartError != null:
return pjsuaStartError(_that);case PJSUAError_PJSUADestroyError() when pjsuaDestroyError != null:
return pjsuaDestroyError(_that);case PJSUAError_InputValueError() when inputValueError != null:
return inputValueError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String field0)?  creationError,TResult Function( String field0)?  configError,TResult Function( String field0)?  initializationError,TResult Function( String field0)?  transportError,TResult Function( String field0)?  dtmfError,TResult Function( String field0)?  callCreationError,TResult Function( String field0)?  callStatusUpdateError,TResult Function( String field0)?  accountCreationError,TResult Function( String field0)?  pjsuaStartError,TResult Function( String field0)?  pjsuaDestroyError,TResult Function( String field0)?  inputValueError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PJSUAError_CreationError() when creationError != null:
return creationError(_that.field0);case PJSUAError_ConfigError() when configError != null:
return configError(_that.field0);case PJSUAError_InitializationError() when initializationError != null:
return initializationError(_that.field0);case PJSUAError_TransportError() when transportError != null:
return transportError(_that.field0);case PJSUAError_DTMFError() when dtmfError != null:
return dtmfError(_that.field0);case PJSUAError_CallCreationError() when callCreationError != null:
return callCreationError(_that.field0);case PJSUAError_CallStatusUpdateError() when callStatusUpdateError != null:
return callStatusUpdateError(_that.field0);case PJSUAError_AccountCreationError() when accountCreationError != null:
return accountCreationError(_that.field0);case PJSUAError_PJSUAStartError() when pjsuaStartError != null:
return pjsuaStartError(_that.field0);case PJSUAError_PJSUADestroyError() when pjsuaDestroyError != null:
return pjsuaDestroyError(_that.field0);case PJSUAError_InputValueError() when inputValueError != null:
return inputValueError(_that.field0);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String field0)  creationError,required TResult Function( String field0)  configError,required TResult Function( String field0)  initializationError,required TResult Function( String field0)  transportError,required TResult Function( String field0)  dtmfError,required TResult Function( String field0)  callCreationError,required TResult Function( String field0)  callStatusUpdateError,required TResult Function( String field0)  accountCreationError,required TResult Function( String field0)  pjsuaStartError,required TResult Function( String field0)  pjsuaDestroyError,required TResult Function( String field0)  inputValueError,}) {final _that = this;
switch (_that) {
case PJSUAError_CreationError():
return creationError(_that.field0);case PJSUAError_ConfigError():
return configError(_that.field0);case PJSUAError_InitializationError():
return initializationError(_that.field0);case PJSUAError_TransportError():
return transportError(_that.field0);case PJSUAError_DTMFError():
return dtmfError(_that.field0);case PJSUAError_CallCreationError():
return callCreationError(_that.field0);case PJSUAError_CallStatusUpdateError():
return callStatusUpdateError(_that.field0);case PJSUAError_AccountCreationError():
return accountCreationError(_that.field0);case PJSUAError_PJSUAStartError():
return pjsuaStartError(_that.field0);case PJSUAError_PJSUADestroyError():
return pjsuaDestroyError(_that.field0);case PJSUAError_InputValueError():
return inputValueError(_that.field0);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String field0)?  creationError,TResult? Function( String field0)?  configError,TResult? Function( String field0)?  initializationError,TResult? Function( String field0)?  transportError,TResult? Function( String field0)?  dtmfError,TResult? Function( String field0)?  callCreationError,TResult? Function( String field0)?  callStatusUpdateError,TResult? Function( String field0)?  accountCreationError,TResult? Function( String field0)?  pjsuaStartError,TResult? Function( String field0)?  pjsuaDestroyError,TResult? Function( String field0)?  inputValueError,}) {final _that = this;
switch (_that) {
case PJSUAError_CreationError() when creationError != null:
return creationError(_that.field0);case PJSUAError_ConfigError() when configError != null:
return configError(_that.field0);case PJSUAError_InitializationError() when initializationError != null:
return initializationError(_that.field0);case PJSUAError_TransportError() when transportError != null:
return transportError(_that.field0);case PJSUAError_DTMFError() when dtmfError != null:
return dtmfError(_that.field0);case PJSUAError_CallCreationError() when callCreationError != null:
return callCreationError(_that.field0);case PJSUAError_CallStatusUpdateError() when callStatusUpdateError != null:
return callStatusUpdateError(_that.field0);case PJSUAError_AccountCreationError() when accountCreationError != null:
return accountCreationError(_that.field0);case PJSUAError_PJSUAStartError() when pjsuaStartError != null:
return pjsuaStartError(_that.field0);case PJSUAError_PJSUADestroyError() when pjsuaDestroyError != null:
return pjsuaDestroyError(_that.field0);case PJSUAError_InputValueError() when inputValueError != null:
return inputValueError(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class PJSUAError_CreationError extends PJSUAError {
  const PJSUAError_CreationError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PJSUAError_CreationErrorCopyWith<PJSUAError_CreationError> get copyWith => _$PJSUAError_CreationErrorCopyWithImpl<PJSUAError_CreationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PJSUAError_CreationError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PJSUAError.creationError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PJSUAError_CreationErrorCopyWith<$Res> implements $PJSUAErrorCopyWith<$Res> {
  factory $PJSUAError_CreationErrorCopyWith(PJSUAError_CreationError value, $Res Function(PJSUAError_CreationError) _then) = _$PJSUAError_CreationErrorCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$PJSUAError_CreationErrorCopyWithImpl<$Res>
    implements $PJSUAError_CreationErrorCopyWith<$Res> {
  _$PJSUAError_CreationErrorCopyWithImpl(this._self, this._then);

  final PJSUAError_CreationError _self;
  final $Res Function(PJSUAError_CreationError) _then;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PJSUAError_CreationError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PJSUAError_ConfigError extends PJSUAError {
  const PJSUAError_ConfigError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PJSUAError_ConfigErrorCopyWith<PJSUAError_ConfigError> get copyWith => _$PJSUAError_ConfigErrorCopyWithImpl<PJSUAError_ConfigError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PJSUAError_ConfigError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PJSUAError.configError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PJSUAError_ConfigErrorCopyWith<$Res> implements $PJSUAErrorCopyWith<$Res> {
  factory $PJSUAError_ConfigErrorCopyWith(PJSUAError_ConfigError value, $Res Function(PJSUAError_ConfigError) _then) = _$PJSUAError_ConfigErrorCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$PJSUAError_ConfigErrorCopyWithImpl<$Res>
    implements $PJSUAError_ConfigErrorCopyWith<$Res> {
  _$PJSUAError_ConfigErrorCopyWithImpl(this._self, this._then);

  final PJSUAError_ConfigError _self;
  final $Res Function(PJSUAError_ConfigError) _then;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PJSUAError_ConfigError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PJSUAError_InitializationError extends PJSUAError {
  const PJSUAError_InitializationError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PJSUAError_InitializationErrorCopyWith<PJSUAError_InitializationError> get copyWith => _$PJSUAError_InitializationErrorCopyWithImpl<PJSUAError_InitializationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PJSUAError_InitializationError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PJSUAError.initializationError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PJSUAError_InitializationErrorCopyWith<$Res> implements $PJSUAErrorCopyWith<$Res> {
  factory $PJSUAError_InitializationErrorCopyWith(PJSUAError_InitializationError value, $Res Function(PJSUAError_InitializationError) _then) = _$PJSUAError_InitializationErrorCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$PJSUAError_InitializationErrorCopyWithImpl<$Res>
    implements $PJSUAError_InitializationErrorCopyWith<$Res> {
  _$PJSUAError_InitializationErrorCopyWithImpl(this._self, this._then);

  final PJSUAError_InitializationError _self;
  final $Res Function(PJSUAError_InitializationError) _then;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PJSUAError_InitializationError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PJSUAError_TransportError extends PJSUAError {
  const PJSUAError_TransportError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PJSUAError_TransportErrorCopyWith<PJSUAError_TransportError> get copyWith => _$PJSUAError_TransportErrorCopyWithImpl<PJSUAError_TransportError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PJSUAError_TransportError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PJSUAError.transportError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PJSUAError_TransportErrorCopyWith<$Res> implements $PJSUAErrorCopyWith<$Res> {
  factory $PJSUAError_TransportErrorCopyWith(PJSUAError_TransportError value, $Res Function(PJSUAError_TransportError) _then) = _$PJSUAError_TransportErrorCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$PJSUAError_TransportErrorCopyWithImpl<$Res>
    implements $PJSUAError_TransportErrorCopyWith<$Res> {
  _$PJSUAError_TransportErrorCopyWithImpl(this._self, this._then);

  final PJSUAError_TransportError _self;
  final $Res Function(PJSUAError_TransportError) _then;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PJSUAError_TransportError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PJSUAError_DTMFError extends PJSUAError {
  const PJSUAError_DTMFError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PJSUAError_DTMFErrorCopyWith<PJSUAError_DTMFError> get copyWith => _$PJSUAError_DTMFErrorCopyWithImpl<PJSUAError_DTMFError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PJSUAError_DTMFError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PJSUAError.dtmfError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PJSUAError_DTMFErrorCopyWith<$Res> implements $PJSUAErrorCopyWith<$Res> {
  factory $PJSUAError_DTMFErrorCopyWith(PJSUAError_DTMFError value, $Res Function(PJSUAError_DTMFError) _then) = _$PJSUAError_DTMFErrorCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$PJSUAError_DTMFErrorCopyWithImpl<$Res>
    implements $PJSUAError_DTMFErrorCopyWith<$Res> {
  _$PJSUAError_DTMFErrorCopyWithImpl(this._self, this._then);

  final PJSUAError_DTMFError _self;
  final $Res Function(PJSUAError_DTMFError) _then;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PJSUAError_DTMFError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PJSUAError_CallCreationError extends PJSUAError {
  const PJSUAError_CallCreationError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PJSUAError_CallCreationErrorCopyWith<PJSUAError_CallCreationError> get copyWith => _$PJSUAError_CallCreationErrorCopyWithImpl<PJSUAError_CallCreationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PJSUAError_CallCreationError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PJSUAError.callCreationError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PJSUAError_CallCreationErrorCopyWith<$Res> implements $PJSUAErrorCopyWith<$Res> {
  factory $PJSUAError_CallCreationErrorCopyWith(PJSUAError_CallCreationError value, $Res Function(PJSUAError_CallCreationError) _then) = _$PJSUAError_CallCreationErrorCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$PJSUAError_CallCreationErrorCopyWithImpl<$Res>
    implements $PJSUAError_CallCreationErrorCopyWith<$Res> {
  _$PJSUAError_CallCreationErrorCopyWithImpl(this._self, this._then);

  final PJSUAError_CallCreationError _self;
  final $Res Function(PJSUAError_CallCreationError) _then;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PJSUAError_CallCreationError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PJSUAError_CallStatusUpdateError extends PJSUAError {
  const PJSUAError_CallStatusUpdateError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PJSUAError_CallStatusUpdateErrorCopyWith<PJSUAError_CallStatusUpdateError> get copyWith => _$PJSUAError_CallStatusUpdateErrorCopyWithImpl<PJSUAError_CallStatusUpdateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PJSUAError_CallStatusUpdateError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PJSUAError.callStatusUpdateError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PJSUAError_CallStatusUpdateErrorCopyWith<$Res> implements $PJSUAErrorCopyWith<$Res> {
  factory $PJSUAError_CallStatusUpdateErrorCopyWith(PJSUAError_CallStatusUpdateError value, $Res Function(PJSUAError_CallStatusUpdateError) _then) = _$PJSUAError_CallStatusUpdateErrorCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$PJSUAError_CallStatusUpdateErrorCopyWithImpl<$Res>
    implements $PJSUAError_CallStatusUpdateErrorCopyWith<$Res> {
  _$PJSUAError_CallStatusUpdateErrorCopyWithImpl(this._self, this._then);

  final PJSUAError_CallStatusUpdateError _self;
  final $Res Function(PJSUAError_CallStatusUpdateError) _then;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PJSUAError_CallStatusUpdateError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PJSUAError_AccountCreationError extends PJSUAError {
  const PJSUAError_AccountCreationError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PJSUAError_AccountCreationErrorCopyWith<PJSUAError_AccountCreationError> get copyWith => _$PJSUAError_AccountCreationErrorCopyWithImpl<PJSUAError_AccountCreationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PJSUAError_AccountCreationError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PJSUAError.accountCreationError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PJSUAError_AccountCreationErrorCopyWith<$Res> implements $PJSUAErrorCopyWith<$Res> {
  factory $PJSUAError_AccountCreationErrorCopyWith(PJSUAError_AccountCreationError value, $Res Function(PJSUAError_AccountCreationError) _then) = _$PJSUAError_AccountCreationErrorCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$PJSUAError_AccountCreationErrorCopyWithImpl<$Res>
    implements $PJSUAError_AccountCreationErrorCopyWith<$Res> {
  _$PJSUAError_AccountCreationErrorCopyWithImpl(this._self, this._then);

  final PJSUAError_AccountCreationError _self;
  final $Res Function(PJSUAError_AccountCreationError) _then;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PJSUAError_AccountCreationError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PJSUAError_PJSUAStartError extends PJSUAError {
  const PJSUAError_PJSUAStartError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PJSUAError_PJSUAStartErrorCopyWith<PJSUAError_PJSUAStartError> get copyWith => _$PJSUAError_PJSUAStartErrorCopyWithImpl<PJSUAError_PJSUAStartError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PJSUAError_PJSUAStartError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PJSUAError.pjsuaStartError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PJSUAError_PJSUAStartErrorCopyWith<$Res> implements $PJSUAErrorCopyWith<$Res> {
  factory $PJSUAError_PJSUAStartErrorCopyWith(PJSUAError_PJSUAStartError value, $Res Function(PJSUAError_PJSUAStartError) _then) = _$PJSUAError_PJSUAStartErrorCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$PJSUAError_PJSUAStartErrorCopyWithImpl<$Res>
    implements $PJSUAError_PJSUAStartErrorCopyWith<$Res> {
  _$PJSUAError_PJSUAStartErrorCopyWithImpl(this._self, this._then);

  final PJSUAError_PJSUAStartError _self;
  final $Res Function(PJSUAError_PJSUAStartError) _then;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PJSUAError_PJSUAStartError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PJSUAError_PJSUADestroyError extends PJSUAError {
  const PJSUAError_PJSUADestroyError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PJSUAError_PJSUADestroyErrorCopyWith<PJSUAError_PJSUADestroyError> get copyWith => _$PJSUAError_PJSUADestroyErrorCopyWithImpl<PJSUAError_PJSUADestroyError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PJSUAError_PJSUADestroyError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PJSUAError.pjsuaDestroyError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PJSUAError_PJSUADestroyErrorCopyWith<$Res> implements $PJSUAErrorCopyWith<$Res> {
  factory $PJSUAError_PJSUADestroyErrorCopyWith(PJSUAError_PJSUADestroyError value, $Res Function(PJSUAError_PJSUADestroyError) _then) = _$PJSUAError_PJSUADestroyErrorCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$PJSUAError_PJSUADestroyErrorCopyWithImpl<$Res>
    implements $PJSUAError_PJSUADestroyErrorCopyWith<$Res> {
  _$PJSUAError_PJSUADestroyErrorCopyWithImpl(this._self, this._then);

  final PJSUAError_PJSUADestroyError _self;
  final $Res Function(PJSUAError_PJSUADestroyError) _then;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PJSUAError_PJSUADestroyError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PJSUAError_InputValueError extends PJSUAError {
  const PJSUAError_InputValueError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PJSUAError_InputValueErrorCopyWith<PJSUAError_InputValueError> get copyWith => _$PJSUAError_InputValueErrorCopyWithImpl<PJSUAError_InputValueError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PJSUAError_InputValueError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'PJSUAError.inputValueError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PJSUAError_InputValueErrorCopyWith<$Res> implements $PJSUAErrorCopyWith<$Res> {
  factory $PJSUAError_InputValueErrorCopyWith(PJSUAError_InputValueError value, $Res Function(PJSUAError_InputValueError) _then) = _$PJSUAError_InputValueErrorCopyWithImpl;
@override @useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$PJSUAError_InputValueErrorCopyWithImpl<$Res>
    implements $PJSUAError_InputValueErrorCopyWith<$Res> {
  _$PJSUAError_InputValueErrorCopyWithImpl(this._self, this._then);

  final PJSUAError_InputValueError _self;
  final $Res Function(PJSUAError_InputValueError) _then;

/// Create a copy of PJSUAError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PJSUAError_InputValueError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
