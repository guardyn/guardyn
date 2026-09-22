// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CryptoStatus {

 bool get initialized; bool get postQuantumAvailable; String get version;
/// Create a copy of CryptoStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CryptoStatusCopyWith<CryptoStatus> get copyWith => _$CryptoStatusCopyWithImpl<CryptoStatus>(this as CryptoStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CryptoStatus&&(identical(other.initialized, initialized) || other.initialized == initialized)&&(identical(other.postQuantumAvailable, postQuantumAvailable) || other.postQuantumAvailable == postQuantumAvailable)&&(identical(other.version, version) || other.version == version));
}


@override
int get hashCode => Object.hash(runtimeType,initialized,postQuantumAvailable,version);

@override
String toString() {
  return 'CryptoStatus(initialized: $initialized, postQuantumAvailable: $postQuantumAvailable, version: $version)';
}


}

/// @nodoc
abstract mixin class $CryptoStatusCopyWith<$Res>  {
  factory $CryptoStatusCopyWith(CryptoStatus value, $Res Function(CryptoStatus) _then) = _$CryptoStatusCopyWithImpl;
@useResult
$Res call({
 bool initialized, bool postQuantumAvailable, String version
});




}
/// @nodoc
class _$CryptoStatusCopyWithImpl<$Res>
    implements $CryptoStatusCopyWith<$Res> {
  _$CryptoStatusCopyWithImpl(this._self, this._then);

  final CryptoStatus _self;
  final $Res Function(CryptoStatus) _then;

/// Create a copy of CryptoStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? initialized = null,Object? postQuantumAvailable = null,Object? version = null,}) {
  return _then(_self.copyWith(
initialized: null == initialized ? _self.initialized : initialized // ignore: cast_nullable_to_non_nullable
as bool,postQuantumAvailable: null == postQuantumAvailable ? _self.postQuantumAvailable : postQuantumAvailable // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CryptoStatus].
extension CryptoStatusPatterns on CryptoStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CryptoStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CryptoStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CryptoStatus value)  $default,){
final _that = this;
switch (_that) {
case _CryptoStatus():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CryptoStatus value)?  $default,){
final _that = this;
switch (_that) {
case _CryptoStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool initialized,  bool postQuantumAvailable,  String version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CryptoStatus() when $default != null:
return $default(_that.initialized,_that.postQuantumAvailable,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool initialized,  bool postQuantumAvailable,  String version)  $default,) {final _that = this;
switch (_that) {
case _CryptoStatus():
return $default(_that.initialized,_that.postQuantumAvailable,_that.version);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool initialized,  bool postQuantumAvailable,  String version)?  $default,) {final _that = this;
switch (_that) {
case _CryptoStatus() when $default != null:
return $default(_that.initialized,_that.postQuantumAvailable,_that.version);case _:
  return null;

}
}

}

/// @nodoc


class _CryptoStatus implements CryptoStatus {
  const _CryptoStatus({required this.initialized, required this.postQuantumAvailable, required this.version});
  

@override final  bool initialized;
@override final  bool postQuantumAvailable;
@override final  String version;

/// Create a copy of CryptoStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CryptoStatusCopyWith<_CryptoStatus> get copyWith => __$CryptoStatusCopyWithImpl<_CryptoStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CryptoStatus&&(identical(other.initialized, initialized) || other.initialized == initialized)&&(identical(other.postQuantumAvailable, postQuantumAvailable) || other.postQuantumAvailable == postQuantumAvailable)&&(identical(other.version, version) || other.version == version));
}


@override
int get hashCode => Object.hash(runtimeType,initialized,postQuantumAvailable,version);

@override
String toString() {
  return 'CryptoStatus(initialized: $initialized, postQuantumAvailable: $postQuantumAvailable, version: $version)';
}


}

/// @nodoc
abstract mixin class _$CryptoStatusCopyWith<$Res> implements $CryptoStatusCopyWith<$Res> {
  factory _$CryptoStatusCopyWith(_CryptoStatus value, $Res Function(_CryptoStatus) _then) = __$CryptoStatusCopyWithImpl;
@override @useResult
$Res call({
 bool initialized, bool postQuantumAvailable, String version
});




}
/// @nodoc
class __$CryptoStatusCopyWithImpl<$Res>
    implements _$CryptoStatusCopyWith<$Res> {
  __$CryptoStatusCopyWithImpl(this._self, this._then);

  final _CryptoStatus _self;
  final $Res Function(_CryptoStatus) _then;

/// Create a copy of CryptoStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? initialized = null,Object? postQuantumAvailable = null,Object? version = null,}) {
  return _then(_CryptoStatus(
initialized: null == initialized ? _self.initialized : initialized // ignore: cast_nullable_to_non_nullable
as bool,postQuantumAvailable: null == postQuantumAvailable ? _self.postQuantumAvailable : postQuantumAvailable // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$EncryptedData {

 Uint8List get ciphertext; Uint8List get nonce; Uint8List get tag;
/// Create a copy of EncryptedData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EncryptedDataCopyWith<EncryptedData> get copyWith => _$EncryptedDataCopyWithImpl<EncryptedData>(this as EncryptedData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EncryptedData&&const DeepCollectionEquality().equals(other.ciphertext, ciphertext)&&const DeepCollectionEquality().equals(other.nonce, nonce)&&const DeepCollectionEquality().equals(other.tag, tag));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(ciphertext),const DeepCollectionEquality().hash(nonce),const DeepCollectionEquality().hash(tag));

@override
String toString() {
  return 'EncryptedData(ciphertext: $ciphertext, nonce: $nonce, tag: $tag)';
}


}

/// @nodoc
abstract mixin class $EncryptedDataCopyWith<$Res>  {
  factory $EncryptedDataCopyWith(EncryptedData value, $Res Function(EncryptedData) _then) = _$EncryptedDataCopyWithImpl;
@useResult
$Res call({
 Uint8List ciphertext, Uint8List nonce, Uint8List tag
});




}
/// @nodoc
class _$EncryptedDataCopyWithImpl<$Res>
    implements $EncryptedDataCopyWith<$Res> {
  _$EncryptedDataCopyWithImpl(this._self, this._then);

  final EncryptedData _self;
  final $Res Function(EncryptedData) _then;

/// Create a copy of EncryptedData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ciphertext = null,Object? nonce = null,Object? tag = null,}) {
  return _then(_self.copyWith(
ciphertext: null == ciphertext ? _self.ciphertext : ciphertext // ignore: cast_nullable_to_non_nullable
as Uint8List,nonce: null == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as Uint8List,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}

}


/// Adds pattern-matching-related methods to [EncryptedData].
extension EncryptedDataPatterns on EncryptedData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EncryptedData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EncryptedData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EncryptedData value)  $default,){
final _that = this;
switch (_that) {
case _EncryptedData():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EncryptedData value)?  $default,){
final _that = this;
switch (_that) {
case _EncryptedData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uint8List ciphertext,  Uint8List nonce,  Uint8List tag)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EncryptedData() when $default != null:
return $default(_that.ciphertext,_that.nonce,_that.tag);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uint8List ciphertext,  Uint8List nonce,  Uint8List tag)  $default,) {final _that = this;
switch (_that) {
case _EncryptedData():
return $default(_that.ciphertext,_that.nonce,_that.tag);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uint8List ciphertext,  Uint8List nonce,  Uint8List tag)?  $default,) {final _that = this;
switch (_that) {
case _EncryptedData() when $default != null:
return $default(_that.ciphertext,_that.nonce,_that.tag);case _:
  return null;

}
}

}

/// @nodoc


class _EncryptedData implements EncryptedData {
  const _EncryptedData({required this.ciphertext, required this.nonce, required this.tag});
  

@override final  Uint8List ciphertext;
@override final  Uint8List nonce;
@override final  Uint8List tag;

/// Create a copy of EncryptedData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EncryptedDataCopyWith<_EncryptedData> get copyWith => __$EncryptedDataCopyWithImpl<_EncryptedData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EncryptedData&&const DeepCollectionEquality().equals(other.ciphertext, ciphertext)&&const DeepCollectionEquality().equals(other.nonce, nonce)&&const DeepCollectionEquality().equals(other.tag, tag));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(ciphertext),const DeepCollectionEquality().hash(nonce),const DeepCollectionEquality().hash(tag));

@override
String toString() {
  return 'EncryptedData(ciphertext: $ciphertext, nonce: $nonce, tag: $tag)';
}


}

/// @nodoc
abstract mixin class _$EncryptedDataCopyWith<$Res> implements $EncryptedDataCopyWith<$Res> {
  factory _$EncryptedDataCopyWith(_EncryptedData value, $Res Function(_EncryptedData) _then) = __$EncryptedDataCopyWithImpl;
@override @useResult
$Res call({
 Uint8List ciphertext, Uint8List nonce, Uint8List tag
});




}
/// @nodoc
class __$EncryptedDataCopyWithImpl<$Res>
    implements _$EncryptedDataCopyWith<$Res> {
  __$EncryptedDataCopyWithImpl(this._self, this._then);

  final _EncryptedData _self;
  final $Res Function(_EncryptedData) _then;

/// Create a copy of EncryptedData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ciphertext = null,Object? nonce = null,Object? tag = null,}) {
  return _then(_EncryptedData(
ciphertext: null == ciphertext ? _self.ciphertext : ciphertext // ignore: cast_nullable_to_non_nullable
as Uint8List,nonce: null == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as Uint8List,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}


}

/// @nodoc
mixin _$HybridKeyBundle {

 Uint8List get x25519Public; Uint8List get x25519Private; Uint8List get mlKemPublic; Uint8List get mlKemPrivate;
/// Create a copy of HybridKeyBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HybridKeyBundleCopyWith<HybridKeyBundle> get copyWith => _$HybridKeyBundleCopyWithImpl<HybridKeyBundle>(this as HybridKeyBundle, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HybridKeyBundle&&const DeepCollectionEquality().equals(other.x25519Public, x25519Public)&&const DeepCollectionEquality().equals(other.x25519Private, x25519Private)&&const DeepCollectionEquality().equals(other.mlKemPublic, mlKemPublic)&&const DeepCollectionEquality().equals(other.mlKemPrivate, mlKemPrivate));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(x25519Public),const DeepCollectionEquality().hash(x25519Private),const DeepCollectionEquality().hash(mlKemPublic),const DeepCollectionEquality().hash(mlKemPrivate));

@override
String toString() {
  return 'HybridKeyBundle(x25519Public: $x25519Public, x25519Private: $x25519Private, mlKemPublic: $mlKemPublic, mlKemPrivate: $mlKemPrivate)';
}


}

/// @nodoc
abstract mixin class $HybridKeyBundleCopyWith<$Res>  {
  factory $HybridKeyBundleCopyWith(HybridKeyBundle value, $Res Function(HybridKeyBundle) _then) = _$HybridKeyBundleCopyWithImpl;
@useResult
$Res call({
 Uint8List x25519Public, Uint8List x25519Private, Uint8List mlKemPublic, Uint8List mlKemPrivate
});




}
/// @nodoc
class _$HybridKeyBundleCopyWithImpl<$Res>
    implements $HybridKeyBundleCopyWith<$Res> {
  _$HybridKeyBundleCopyWithImpl(this._self, this._then);

  final HybridKeyBundle _self;
  final $Res Function(HybridKeyBundle) _then;

/// Create a copy of HybridKeyBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x25519Public = null,Object? x25519Private = null,Object? mlKemPublic = null,Object? mlKemPrivate = null,}) {
  return _then(_self.copyWith(
x25519Public: null == x25519Public ? _self.x25519Public : x25519Public // ignore: cast_nullable_to_non_nullable
as Uint8List,x25519Private: null == x25519Private ? _self.x25519Private : x25519Private // ignore: cast_nullable_to_non_nullable
as Uint8List,mlKemPublic: null == mlKemPublic ? _self.mlKemPublic : mlKemPublic // ignore: cast_nullable_to_non_nullable
as Uint8List,mlKemPrivate: null == mlKemPrivate ? _self.mlKemPrivate : mlKemPrivate // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}

}


/// Adds pattern-matching-related methods to [HybridKeyBundle].
extension HybridKeyBundlePatterns on HybridKeyBundle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HybridKeyBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HybridKeyBundle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HybridKeyBundle value)  $default,){
final _that = this;
switch (_that) {
case _HybridKeyBundle():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HybridKeyBundle value)?  $default,){
final _that = this;
switch (_that) {
case _HybridKeyBundle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uint8List x25519Public,  Uint8List x25519Private,  Uint8List mlKemPublic,  Uint8List mlKemPrivate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HybridKeyBundle() when $default != null:
return $default(_that.x25519Public,_that.x25519Private,_that.mlKemPublic,_that.mlKemPrivate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uint8List x25519Public,  Uint8List x25519Private,  Uint8List mlKemPublic,  Uint8List mlKemPrivate)  $default,) {final _that = this;
switch (_that) {
case _HybridKeyBundle():
return $default(_that.x25519Public,_that.x25519Private,_that.mlKemPublic,_that.mlKemPrivate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uint8List x25519Public,  Uint8List x25519Private,  Uint8List mlKemPublic,  Uint8List mlKemPrivate)?  $default,) {final _that = this;
switch (_that) {
case _HybridKeyBundle() when $default != null:
return $default(_that.x25519Public,_that.x25519Private,_that.mlKemPublic,_that.mlKemPrivate);case _:
  return null;

}
}

}

/// @nodoc


class _HybridKeyBundle implements HybridKeyBundle {
  const _HybridKeyBundle({required this.x25519Public, required this.x25519Private, required this.mlKemPublic, required this.mlKemPrivate});
  

@override final  Uint8List x25519Public;
@override final  Uint8List x25519Private;
@override final  Uint8List mlKemPublic;
@override final  Uint8List mlKemPrivate;

/// Create a copy of HybridKeyBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HybridKeyBundleCopyWith<_HybridKeyBundle> get copyWith => __$HybridKeyBundleCopyWithImpl<_HybridKeyBundle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HybridKeyBundle&&const DeepCollectionEquality().equals(other.x25519Public, x25519Public)&&const DeepCollectionEquality().equals(other.x25519Private, x25519Private)&&const DeepCollectionEquality().equals(other.mlKemPublic, mlKemPublic)&&const DeepCollectionEquality().equals(other.mlKemPrivate, mlKemPrivate));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(x25519Public),const DeepCollectionEquality().hash(x25519Private),const DeepCollectionEquality().hash(mlKemPublic),const DeepCollectionEquality().hash(mlKemPrivate));

@override
String toString() {
  return 'HybridKeyBundle(x25519Public: $x25519Public, x25519Private: $x25519Private, mlKemPublic: $mlKemPublic, mlKemPrivate: $mlKemPrivate)';
}


}

/// @nodoc
abstract mixin class _$HybridKeyBundleCopyWith<$Res> implements $HybridKeyBundleCopyWith<$Res> {
  factory _$HybridKeyBundleCopyWith(_HybridKeyBundle value, $Res Function(_HybridKeyBundle) _then) = __$HybridKeyBundleCopyWithImpl;
@override @useResult
$Res call({
 Uint8List x25519Public, Uint8List x25519Private, Uint8List mlKemPublic, Uint8List mlKemPrivate
});




}
/// @nodoc
class __$HybridKeyBundleCopyWithImpl<$Res>
    implements _$HybridKeyBundleCopyWith<$Res> {
  __$HybridKeyBundleCopyWithImpl(this._self, this._then);

  final _HybridKeyBundle _self;
  final $Res Function(_HybridKeyBundle) _then;

/// Create a copy of HybridKeyBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x25519Public = null,Object? x25519Private = null,Object? mlKemPublic = null,Object? mlKemPrivate = null,}) {
  return _then(_HybridKeyBundle(
x25519Public: null == x25519Public ? _self.x25519Public : x25519Public // ignore: cast_nullable_to_non_nullable
as Uint8List,x25519Private: null == x25519Private ? _self.x25519Private : x25519Private // ignore: cast_nullable_to_non_nullable
as Uint8List,mlKemPublic: null == mlKemPublic ? _self.mlKemPublic : mlKemPublic // ignore: cast_nullable_to_non_nullable
as Uint8List,mlKemPrivate: null == mlKemPrivate ? _self.mlKemPrivate : mlKemPrivate // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}


}

/// @nodoc
mixin _$HybridPeerBundle {

 Uint8List get identityKey; Uint8List get signedPrekey; Uint8List get signedPrekeySignature; Uint8List? get oneTimePrekey; Uint8List? get pqPrekey; Uint8List? get pqPrekeySignature;
/// Create a copy of HybridPeerBundle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HybridPeerBundleCopyWith<HybridPeerBundle> get copyWith => _$HybridPeerBundleCopyWithImpl<HybridPeerBundle>(this as HybridPeerBundle, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HybridPeerBundle&&const DeepCollectionEquality().equals(other.identityKey, identityKey)&&const DeepCollectionEquality().equals(other.signedPrekey, signedPrekey)&&const DeepCollectionEquality().equals(other.signedPrekeySignature, signedPrekeySignature)&&const DeepCollectionEquality().equals(other.oneTimePrekey, oneTimePrekey)&&const DeepCollectionEquality().equals(other.pqPrekey, pqPrekey)&&const DeepCollectionEquality().equals(other.pqPrekeySignature, pqPrekeySignature));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(identityKey),const DeepCollectionEquality().hash(signedPrekey),const DeepCollectionEquality().hash(signedPrekeySignature),const DeepCollectionEquality().hash(oneTimePrekey),const DeepCollectionEquality().hash(pqPrekey),const DeepCollectionEquality().hash(pqPrekeySignature));

@override
String toString() {
  return 'HybridPeerBundle(identityKey: $identityKey, signedPrekey: $signedPrekey, signedPrekeySignature: $signedPrekeySignature, oneTimePrekey: $oneTimePrekey, pqPrekey: $pqPrekey, pqPrekeySignature: $pqPrekeySignature)';
}


}

/// @nodoc
abstract mixin class $HybridPeerBundleCopyWith<$Res>  {
  factory $HybridPeerBundleCopyWith(HybridPeerBundle value, $Res Function(HybridPeerBundle) _then) = _$HybridPeerBundleCopyWithImpl;
@useResult
$Res call({
 Uint8List identityKey, Uint8List signedPrekey, Uint8List signedPrekeySignature, Uint8List? oneTimePrekey, Uint8List? pqPrekey, Uint8List? pqPrekeySignature
});




}
/// @nodoc
class _$HybridPeerBundleCopyWithImpl<$Res>
    implements $HybridPeerBundleCopyWith<$Res> {
  _$HybridPeerBundleCopyWithImpl(this._self, this._then);

  final HybridPeerBundle _self;
  final $Res Function(HybridPeerBundle) _then;

/// Create a copy of HybridPeerBundle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identityKey = null,Object? signedPrekey = null,Object? signedPrekeySignature = null,Object? oneTimePrekey = freezed,Object? pqPrekey = freezed,Object? pqPrekeySignature = freezed,}) {
  return _then(_self.copyWith(
identityKey: null == identityKey ? _self.identityKey : identityKey // ignore: cast_nullable_to_non_nullable
as Uint8List,signedPrekey: null == signedPrekey ? _self.signedPrekey : signedPrekey // ignore: cast_nullable_to_non_nullable
as Uint8List,signedPrekeySignature: null == signedPrekeySignature ? _self.signedPrekeySignature : signedPrekeySignature // ignore: cast_nullable_to_non_nullable
as Uint8List,oneTimePrekey: freezed == oneTimePrekey ? _self.oneTimePrekey : oneTimePrekey // ignore: cast_nullable_to_non_nullable
as Uint8List?,pqPrekey: freezed == pqPrekey ? _self.pqPrekey : pqPrekey // ignore: cast_nullable_to_non_nullable
as Uint8List?,pqPrekeySignature: freezed == pqPrekeySignature ? _self.pqPrekeySignature : pqPrekeySignature // ignore: cast_nullable_to_non_nullable
as Uint8List?,
  ));
}

}


/// Adds pattern-matching-related methods to [HybridPeerBundle].
extension HybridPeerBundlePatterns on HybridPeerBundle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HybridPeerBundle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HybridPeerBundle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HybridPeerBundle value)  $default,){
final _that = this;
switch (_that) {
case _HybridPeerBundle():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HybridPeerBundle value)?  $default,){
final _that = this;
switch (_that) {
case _HybridPeerBundle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uint8List identityKey,  Uint8List signedPrekey,  Uint8List signedPrekeySignature,  Uint8List? oneTimePrekey,  Uint8List? pqPrekey,  Uint8List? pqPrekeySignature)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HybridPeerBundle() when $default != null:
return $default(_that.identityKey,_that.signedPrekey,_that.signedPrekeySignature,_that.oneTimePrekey,_that.pqPrekey,_that.pqPrekeySignature);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uint8List identityKey,  Uint8List signedPrekey,  Uint8List signedPrekeySignature,  Uint8List? oneTimePrekey,  Uint8List? pqPrekey,  Uint8List? pqPrekeySignature)  $default,) {final _that = this;
switch (_that) {
case _HybridPeerBundle():
return $default(_that.identityKey,_that.signedPrekey,_that.signedPrekeySignature,_that.oneTimePrekey,_that.pqPrekey,_that.pqPrekeySignature);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uint8List identityKey,  Uint8List signedPrekey,  Uint8List signedPrekeySignature,  Uint8List? oneTimePrekey,  Uint8List? pqPrekey,  Uint8List? pqPrekeySignature)?  $default,) {final _that = this;
switch (_that) {
case _HybridPeerBundle() when $default != null:
return $default(_that.identityKey,_that.signedPrekey,_that.signedPrekeySignature,_that.oneTimePrekey,_that.pqPrekey,_that.pqPrekeySignature);case _:
  return null;

}
}

}

/// @nodoc


class _HybridPeerBundle implements HybridPeerBundle {
  const _HybridPeerBundle({required this.identityKey, required this.signedPrekey, required this.signedPrekeySignature, this.oneTimePrekey, this.pqPrekey, this.pqPrekeySignature});
  

@override final  Uint8List identityKey;
@override final  Uint8List signedPrekey;
@override final  Uint8List signedPrekeySignature;
@override final  Uint8List? oneTimePrekey;
@override final  Uint8List? pqPrekey;
@override final  Uint8List? pqPrekeySignature;

/// Create a copy of HybridPeerBundle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HybridPeerBundleCopyWith<_HybridPeerBundle> get copyWith => __$HybridPeerBundleCopyWithImpl<_HybridPeerBundle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HybridPeerBundle&&const DeepCollectionEquality().equals(other.identityKey, identityKey)&&const DeepCollectionEquality().equals(other.signedPrekey, signedPrekey)&&const DeepCollectionEquality().equals(other.signedPrekeySignature, signedPrekeySignature)&&const DeepCollectionEquality().equals(other.oneTimePrekey, oneTimePrekey)&&const DeepCollectionEquality().equals(other.pqPrekey, pqPrekey)&&const DeepCollectionEquality().equals(other.pqPrekeySignature, pqPrekeySignature));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(identityKey),const DeepCollectionEquality().hash(signedPrekey),const DeepCollectionEquality().hash(signedPrekeySignature),const DeepCollectionEquality().hash(oneTimePrekey),const DeepCollectionEquality().hash(pqPrekey),const DeepCollectionEquality().hash(pqPrekeySignature));

@override
String toString() {
  return 'HybridPeerBundle(identityKey: $identityKey, signedPrekey: $signedPrekey, signedPrekeySignature: $signedPrekeySignature, oneTimePrekey: $oneTimePrekey, pqPrekey: $pqPrekey, pqPrekeySignature: $pqPrekeySignature)';
}


}

/// @nodoc
abstract mixin class _$HybridPeerBundleCopyWith<$Res> implements $HybridPeerBundleCopyWith<$Res> {
  factory _$HybridPeerBundleCopyWith(_HybridPeerBundle value, $Res Function(_HybridPeerBundle) _then) = __$HybridPeerBundleCopyWithImpl;
@override @useResult
$Res call({
 Uint8List identityKey, Uint8List signedPrekey, Uint8List signedPrekeySignature, Uint8List? oneTimePrekey, Uint8List? pqPrekey, Uint8List? pqPrekeySignature
});




}
/// @nodoc
class __$HybridPeerBundleCopyWithImpl<$Res>
    implements _$HybridPeerBundleCopyWith<$Res> {
  __$HybridPeerBundleCopyWithImpl(this._self, this._then);

  final _HybridPeerBundle _self;
  final $Res Function(_HybridPeerBundle) _then;

/// Create a copy of HybridPeerBundle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identityKey = null,Object? signedPrekey = null,Object? signedPrekeySignature = null,Object? oneTimePrekey = freezed,Object? pqPrekey = freezed,Object? pqPrekeySignature = freezed,}) {
  return _then(_HybridPeerBundle(
identityKey: null == identityKey ? _self.identityKey : identityKey // ignore: cast_nullable_to_non_nullable
as Uint8List,signedPrekey: null == signedPrekey ? _self.signedPrekey : signedPrekey // ignore: cast_nullable_to_non_nullable
as Uint8List,signedPrekeySignature: null == signedPrekeySignature ? _self.signedPrekeySignature : signedPrekeySignature // ignore: cast_nullable_to_non_nullable
as Uint8List,oneTimePrekey: freezed == oneTimePrekey ? _self.oneTimePrekey : oneTimePrekey // ignore: cast_nullable_to_non_nullable
as Uint8List?,pqPrekey: freezed == pqPrekey ? _self.pqPrekey : pqPrekey // ignore: cast_nullable_to_non_nullable
as Uint8List?,pqPrekeySignature: freezed == pqPrekeySignature ? _self.pqPrekeySignature : pqPrekeySignature // ignore: cast_nullable_to_non_nullable
as Uint8List?,
  ));
}


}

/// @nodoc
mixin _$KeyPair {

 Uint8List get publicKey; Uint8List get privateKey; String get keyType;
/// Create a copy of KeyPair
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeyPairCopyWith<KeyPair> get copyWith => _$KeyPairCopyWithImpl<KeyPair>(this as KeyPair, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeyPair&&const DeepCollectionEquality().equals(other.publicKey, publicKey)&&const DeepCollectionEquality().equals(other.privateKey, privateKey)&&(identical(other.keyType, keyType) || other.keyType == keyType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(publicKey),const DeepCollectionEquality().hash(privateKey),keyType);

@override
String toString() {
  return 'KeyPair(publicKey: $publicKey, privateKey: $privateKey, keyType: $keyType)';
}


}

/// @nodoc
abstract mixin class $KeyPairCopyWith<$Res>  {
  factory $KeyPairCopyWith(KeyPair value, $Res Function(KeyPair) _then) = _$KeyPairCopyWithImpl;
@useResult
$Res call({
 Uint8List publicKey, Uint8List privateKey, String keyType
});




}
/// @nodoc
class _$KeyPairCopyWithImpl<$Res>
    implements $KeyPairCopyWith<$Res> {
  _$KeyPairCopyWithImpl(this._self, this._then);

  final KeyPair _self;
  final $Res Function(KeyPair) _then;

/// Create a copy of KeyPair
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? publicKey = null,Object? privateKey = null,Object? keyType = null,}) {
  return _then(_self.copyWith(
publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as Uint8List,privateKey: null == privateKey ? _self.privateKey : privateKey // ignore: cast_nullable_to_non_nullable
as Uint8List,keyType: null == keyType ? _self.keyType : keyType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [KeyPair].
extension KeyPairPatterns on KeyPair {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeyPair value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeyPair() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeyPair value)  $default,){
final _that = this;
switch (_that) {
case _KeyPair():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeyPair value)?  $default,){
final _that = this;
switch (_that) {
case _KeyPair() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uint8List publicKey,  Uint8List privateKey,  String keyType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeyPair() when $default != null:
return $default(_that.publicKey,_that.privateKey,_that.keyType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uint8List publicKey,  Uint8List privateKey,  String keyType)  $default,) {final _that = this;
switch (_that) {
case _KeyPair():
return $default(_that.publicKey,_that.privateKey,_that.keyType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uint8List publicKey,  Uint8List privateKey,  String keyType)?  $default,) {final _that = this;
switch (_that) {
case _KeyPair() when $default != null:
return $default(_that.publicKey,_that.privateKey,_that.keyType);case _:
  return null;

}
}

}

/// @nodoc


class _KeyPair implements KeyPair {
  const _KeyPair({required this.publicKey, required this.privateKey, required this.keyType});
  

@override final  Uint8List publicKey;
@override final  Uint8List privateKey;
@override final  String keyType;

/// Create a copy of KeyPair
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeyPairCopyWith<_KeyPair> get copyWith => __$KeyPairCopyWithImpl<_KeyPair>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeyPair&&const DeepCollectionEquality().equals(other.publicKey, publicKey)&&const DeepCollectionEquality().equals(other.privateKey, privateKey)&&(identical(other.keyType, keyType) || other.keyType == keyType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(publicKey),const DeepCollectionEquality().hash(privateKey),keyType);

@override
String toString() {
  return 'KeyPair(publicKey: $publicKey, privateKey: $privateKey, keyType: $keyType)';
}


}

/// @nodoc
abstract mixin class _$KeyPairCopyWith<$Res> implements $KeyPairCopyWith<$Res> {
  factory _$KeyPairCopyWith(_KeyPair value, $Res Function(_KeyPair) _then) = __$KeyPairCopyWithImpl;
@override @useResult
$Res call({
 Uint8List publicKey, Uint8List privateKey, String keyType
});




}
/// @nodoc
class __$KeyPairCopyWithImpl<$Res>
    implements _$KeyPairCopyWith<$Res> {
  __$KeyPairCopyWithImpl(this._self, this._then);

  final _KeyPair _self;
  final $Res Function(_KeyPair) _then;

/// Create a copy of KeyPair
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? publicKey = null,Object? privateKey = null,Object? keyType = null,}) {
  return _then(_KeyPair(
publicKey: null == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as Uint8List,privateKey: null == privateKey ? _self.privateKey : privateKey // ignore: cast_nullable_to_non_nullable
as Uint8List,keyType: null == keyType ? _self.keyType : keyType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
