// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dart_types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CallState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallState()';
}


}

/// @nodoc
class $CallStateCopyWith<$Res>  {
$CallStateCopyWith(CallState _, $Res Function(CallState) __);
}


/// Adds pattern-matching-related methods to [CallState].
extension CallStatePatterns on CallState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CallState_Null value)?  null_,TResult Function( CallState_Early value)?  early,TResult Function( CallState_Incoming value)?  incoming,TResult Function( CallState_Calling value)?  calling,TResult Function( CallState_Connecting value)?  connecting,TResult Function( CallState_Confirmed value)?  confirmed,TResult Function( CallState_Disconnected value)?  disconnected,TResult Function( CallState_Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CallState_Null() when null_ != null:
return null_(_that);case CallState_Early() when early != null:
return early(_that);case CallState_Incoming() when incoming != null:
return incoming(_that);case CallState_Calling() when calling != null:
return calling(_that);case CallState_Connecting() when connecting != null:
return connecting(_that);case CallState_Confirmed() when confirmed != null:
return confirmed(_that);case CallState_Disconnected() when disconnected != null:
return disconnected(_that);case CallState_Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CallState_Null value)  null_,required TResult Function( CallState_Early value)  early,required TResult Function( CallState_Incoming value)  incoming,required TResult Function( CallState_Calling value)  calling,required TResult Function( CallState_Connecting value)  connecting,required TResult Function( CallState_Confirmed value)  confirmed,required TResult Function( CallState_Disconnected value)  disconnected,required TResult Function( CallState_Error value)  error,}){
final _that = this;
switch (_that) {
case CallState_Null():
return null_(_that);case CallState_Early():
return early(_that);case CallState_Incoming():
return incoming(_that);case CallState_Calling():
return calling(_that);case CallState_Connecting():
return connecting(_that);case CallState_Confirmed():
return confirmed(_that);case CallState_Disconnected():
return disconnected(_that);case CallState_Error():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CallState_Null value)?  null_,TResult? Function( CallState_Early value)?  early,TResult? Function( CallState_Incoming value)?  incoming,TResult? Function( CallState_Calling value)?  calling,TResult? Function( CallState_Connecting value)?  connecting,TResult? Function( CallState_Confirmed value)?  confirmed,TResult? Function( CallState_Disconnected value)?  disconnected,TResult? Function( CallState_Error value)?  error,}){
final _that = this;
switch (_that) {
case CallState_Null() when null_ != null:
return null_(_that);case CallState_Early() when early != null:
return early(_that);case CallState_Incoming() when incoming != null:
return incoming(_that);case CallState_Calling() when calling != null:
return calling(_that);case CallState_Connecting() when connecting != null:
return connecting(_that);case CallState_Confirmed() when confirmed != null:
return confirmed(_that);case CallState_Disconnected() when disconnected != null:
return disconnected(_that);case CallState_Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  null_,TResult Function()?  early,TResult Function()?  incoming,TResult Function()?  calling,TResult Function()?  connecting,TResult Function()?  confirmed,TResult Function()?  disconnected,TResult Function( String field0)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CallState_Null() when null_ != null:
return null_();case CallState_Early() when early != null:
return early();case CallState_Incoming() when incoming != null:
return incoming();case CallState_Calling() when calling != null:
return calling();case CallState_Connecting() when connecting != null:
return connecting();case CallState_Confirmed() when confirmed != null:
return confirmed();case CallState_Disconnected() when disconnected != null:
return disconnected();case CallState_Error() when error != null:
return error(_that.field0);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  null_,required TResult Function()  early,required TResult Function()  incoming,required TResult Function()  calling,required TResult Function()  connecting,required TResult Function()  confirmed,required TResult Function()  disconnected,required TResult Function( String field0)  error,}) {final _that = this;
switch (_that) {
case CallState_Null():
return null_();case CallState_Early():
return early();case CallState_Incoming():
return incoming();case CallState_Calling():
return calling();case CallState_Connecting():
return connecting();case CallState_Confirmed():
return confirmed();case CallState_Disconnected():
return disconnected();case CallState_Error():
return error(_that.field0);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  null_,TResult? Function()?  early,TResult? Function()?  incoming,TResult? Function()?  calling,TResult? Function()?  connecting,TResult? Function()?  confirmed,TResult? Function()?  disconnected,TResult? Function( String field0)?  error,}) {final _that = this;
switch (_that) {
case CallState_Null() when null_ != null:
return null_();case CallState_Early() when early != null:
return early();case CallState_Incoming() when incoming != null:
return incoming();case CallState_Calling() when calling != null:
return calling();case CallState_Connecting() when connecting != null:
return connecting();case CallState_Confirmed() when confirmed != null:
return confirmed();case CallState_Disconnected() when disconnected != null:
return disconnected();case CallState_Error() when error != null:
return error(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class CallState_Null extends CallState {
  const CallState_Null(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallState_Null);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallState.null_()';
}


}




/// @nodoc


class CallState_Early extends CallState {
  const CallState_Early(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallState_Early);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallState.early()';
}


}




/// @nodoc


class CallState_Incoming extends CallState {
  const CallState_Incoming(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallState_Incoming);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallState.incoming()';
}


}




/// @nodoc


class CallState_Calling extends CallState {
  const CallState_Calling(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallState_Calling);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallState.calling()';
}


}




/// @nodoc


class CallState_Connecting extends CallState {
  const CallState_Connecting(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallState_Connecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallState.connecting()';
}


}




/// @nodoc


class CallState_Confirmed extends CallState {
  const CallState_Confirmed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallState_Confirmed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallState.confirmed()';
}


}




/// @nodoc


class CallState_Disconnected extends CallState {
  const CallState_Disconnected(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallState_Disconnected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CallState.disconnected()';
}


}




/// @nodoc


class CallState_Error extends CallState {
  const CallState_Error(this.field0): super._();
  

 final  String field0;

/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallState_ErrorCopyWith<CallState_Error> get copyWith => _$CallState_ErrorCopyWithImpl<CallState_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallState_Error&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'CallState.error(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $CallState_ErrorCopyWith<$Res> implements $CallStateCopyWith<$Res> {
  factory $CallState_ErrorCopyWith(CallState_Error value, $Res Function(CallState_Error) _then) = _$CallState_ErrorCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$CallState_ErrorCopyWithImpl<$Res>
    implements $CallState_ErrorCopyWith<$Res> {
  _$CallState_ErrorCopyWithImpl(this._self, this._then);

  final CallState_Error _self;
  final $Res Function(CallState_Error) _then;

/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(CallState_Error(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
