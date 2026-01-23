// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CryptoStatus {
  bool get initialized => throw _privateConstructorUsedError;
  bool get postQuantumAvailable => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;

  /// Create a copy of CryptoStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CryptoStatusCopyWith<CryptoStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CryptoStatusCopyWith<$Res> {
  factory $CryptoStatusCopyWith(
    CryptoStatus value,
    $Res Function(CryptoStatus) then,
  ) = _$CryptoStatusCopyWithImpl<$Res, CryptoStatus>;
  @useResult
  $Res call({bool initialized, bool postQuantumAvailable, String version});
}

/// @nodoc
class _$CryptoStatusCopyWithImpl<$Res, $Val extends CryptoStatus>
    implements $CryptoStatusCopyWith<$Res> {
  _$CryptoStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CryptoStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? initialized = null,
    Object? postQuantumAvailable = null,
    Object? version = null,
  }) {
    return _then(
      _value.copyWith(
            initialized: null == initialized
                ? _value.initialized
                : initialized // ignore: cast_nullable_to_non_nullable
                      as bool,
            postQuantumAvailable: null == postQuantumAvailable
                ? _value.postQuantumAvailable
                : postQuantumAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CryptoStatusImplCopyWith<$Res>
    implements $CryptoStatusCopyWith<$Res> {
  factory _$$CryptoStatusImplCopyWith(
    _$CryptoStatusImpl value,
    $Res Function(_$CryptoStatusImpl) then,
  ) = __$$CryptoStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool initialized, bool postQuantumAvailable, String version});
}

/// @nodoc
class __$$CryptoStatusImplCopyWithImpl<$Res>
    extends _$CryptoStatusCopyWithImpl<$Res, _$CryptoStatusImpl>
    implements _$$CryptoStatusImplCopyWith<$Res> {
  __$$CryptoStatusImplCopyWithImpl(
    _$CryptoStatusImpl _value,
    $Res Function(_$CryptoStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CryptoStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? initialized = null,
    Object? postQuantumAvailable = null,
    Object? version = null,
  }) {
    return _then(
      _$CryptoStatusImpl(
        initialized: null == initialized
            ? _value.initialized
            : initialized // ignore: cast_nullable_to_non_nullable
                  as bool,
        postQuantumAvailable: null == postQuantumAvailable
            ? _value.postQuantumAvailable
            : postQuantumAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$CryptoStatusImpl implements _CryptoStatus {
  const _$CryptoStatusImpl({
    required this.initialized,
    required this.postQuantumAvailable,
    required this.version,
  });

  @override
  final bool initialized;
  @override
  final bool postQuantumAvailable;
  @override
  final String version;

  @override
  String toString() {
    return 'CryptoStatus(initialized: $initialized, postQuantumAvailable: $postQuantumAvailable, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CryptoStatusImpl &&
            (identical(other.initialized, initialized) ||
                other.initialized == initialized) &&
            (identical(other.postQuantumAvailable, postQuantumAvailable) ||
                other.postQuantumAvailable == postQuantumAvailable) &&
            (identical(other.version, version) || other.version == version));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, initialized, postQuantumAvailable, version);

  /// Create a copy of CryptoStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CryptoStatusImplCopyWith<_$CryptoStatusImpl> get copyWith =>
      __$$CryptoStatusImplCopyWithImpl<_$CryptoStatusImpl>(this, _$identity);
}

abstract class _CryptoStatus implements CryptoStatus {
  const factory _CryptoStatus({
    required final bool initialized,
    required final bool postQuantumAvailable,
    required final String version,
  }) = _$CryptoStatusImpl;

  @override
  bool get initialized;
  @override
  bool get postQuantumAvailable;
  @override
  String get version;

  /// Create a copy of CryptoStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CryptoStatusImplCopyWith<_$CryptoStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$EncryptedData {
  Uint8List get ciphertext => throw _privateConstructorUsedError;
  Uint8List get nonce => throw _privateConstructorUsedError;
  Uint8List get tag => throw _privateConstructorUsedError;

  /// Create a copy of EncryptedData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EncryptedDataCopyWith<EncryptedData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EncryptedDataCopyWith<$Res> {
  factory $EncryptedDataCopyWith(
    EncryptedData value,
    $Res Function(EncryptedData) then,
  ) = _$EncryptedDataCopyWithImpl<$Res, EncryptedData>;
  @useResult
  $Res call({Uint8List ciphertext, Uint8List nonce, Uint8List tag});
}

/// @nodoc
class _$EncryptedDataCopyWithImpl<$Res, $Val extends EncryptedData>
    implements $EncryptedDataCopyWith<$Res> {
  _$EncryptedDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EncryptedData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ciphertext = null,
    Object? nonce = null,
    Object? tag = null,
  }) {
    return _then(
      _value.copyWith(
            ciphertext: null == ciphertext
                ? _value.ciphertext
                : ciphertext // ignore: cast_nullable_to_non_nullable
                      as Uint8List,
            nonce: null == nonce
                ? _value.nonce
                : nonce // ignore: cast_nullable_to_non_nullable
                      as Uint8List,
            tag: null == tag
                ? _value.tag
                : tag // ignore: cast_nullable_to_non_nullable
                      as Uint8List,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EncryptedDataImplCopyWith<$Res>
    implements $EncryptedDataCopyWith<$Res> {
  factory _$$EncryptedDataImplCopyWith(
    _$EncryptedDataImpl value,
    $Res Function(_$EncryptedDataImpl) then,
  ) = __$$EncryptedDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Uint8List ciphertext, Uint8List nonce, Uint8List tag});
}

/// @nodoc
class __$$EncryptedDataImplCopyWithImpl<$Res>
    extends _$EncryptedDataCopyWithImpl<$Res, _$EncryptedDataImpl>
    implements _$$EncryptedDataImplCopyWith<$Res> {
  __$$EncryptedDataImplCopyWithImpl(
    _$EncryptedDataImpl _value,
    $Res Function(_$EncryptedDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EncryptedData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ciphertext = null,
    Object? nonce = null,
    Object? tag = null,
  }) {
    return _then(
      _$EncryptedDataImpl(
        ciphertext: null == ciphertext
            ? _value.ciphertext
            : ciphertext // ignore: cast_nullable_to_non_nullable
                  as Uint8List,
        nonce: null == nonce
            ? _value.nonce
            : nonce // ignore: cast_nullable_to_non_nullable
                  as Uint8List,
        tag: null == tag
            ? _value.tag
            : tag // ignore: cast_nullable_to_non_nullable
                  as Uint8List,
      ),
    );
  }
}

/// @nodoc

class _$EncryptedDataImpl implements _EncryptedData {
  const _$EncryptedDataImpl({
    required this.ciphertext,
    required this.nonce,
    required this.tag,
  });

  @override
  final Uint8List ciphertext;
  @override
  final Uint8List nonce;
  @override
  final Uint8List tag;

  @override
  String toString() {
    return 'EncryptedData(ciphertext: $ciphertext, nonce: $nonce, tag: $tag)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EncryptedDataImpl &&
            const DeepCollectionEquality().equals(
              other.ciphertext,
              ciphertext,
            ) &&
            const DeepCollectionEquality().equals(other.nonce, nonce) &&
            const DeepCollectionEquality().equals(other.tag, tag));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(ciphertext),
    const DeepCollectionEquality().hash(nonce),
    const DeepCollectionEquality().hash(tag),
  );

  /// Create a copy of EncryptedData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EncryptedDataImplCopyWith<_$EncryptedDataImpl> get copyWith =>
      __$$EncryptedDataImplCopyWithImpl<_$EncryptedDataImpl>(this, _$identity);
}

abstract class _EncryptedData implements EncryptedData {
  const factory _EncryptedData({
    required final Uint8List ciphertext,
    required final Uint8List nonce,
    required final Uint8List tag,
  }) = _$EncryptedDataImpl;

  @override
  Uint8List get ciphertext;
  @override
  Uint8List get nonce;
  @override
  Uint8List get tag;

  /// Create a copy of EncryptedData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EncryptedDataImplCopyWith<_$EncryptedDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$HybridKeyBundle {
  Uint8List get x25519Public => throw _privateConstructorUsedError;
  Uint8List get x25519Private => throw _privateConstructorUsedError;
  Uint8List get mlKemPublic => throw _privateConstructorUsedError;
  Uint8List get mlKemPrivate => throw _privateConstructorUsedError;

  /// Create a copy of HybridKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HybridKeyBundleCopyWith<HybridKeyBundle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HybridKeyBundleCopyWith<$Res> {
  factory $HybridKeyBundleCopyWith(
    HybridKeyBundle value,
    $Res Function(HybridKeyBundle) then,
  ) = _$HybridKeyBundleCopyWithImpl<$Res, HybridKeyBundle>;
  @useResult
  $Res call({
    Uint8List x25519Public,
    Uint8List x25519Private,
    Uint8List mlKemPublic,
    Uint8List mlKemPrivate,
  });
}

/// @nodoc
class _$HybridKeyBundleCopyWithImpl<$Res, $Val extends HybridKeyBundle>
    implements $HybridKeyBundleCopyWith<$Res> {
  _$HybridKeyBundleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HybridKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x25519Public = null,
    Object? x25519Private = null,
    Object? mlKemPublic = null,
    Object? mlKemPrivate = null,
  }) {
    return _then(
      _value.copyWith(
            x25519Public: null == x25519Public
                ? _value.x25519Public
                : x25519Public // ignore: cast_nullable_to_non_nullable
                      as Uint8List,
            x25519Private: null == x25519Private
                ? _value.x25519Private
                : x25519Private // ignore: cast_nullable_to_non_nullable
                      as Uint8List,
            mlKemPublic: null == mlKemPublic
                ? _value.mlKemPublic
                : mlKemPublic // ignore: cast_nullable_to_non_nullable
                      as Uint8List,
            mlKemPrivate: null == mlKemPrivate
                ? _value.mlKemPrivate
                : mlKemPrivate // ignore: cast_nullable_to_non_nullable
                      as Uint8List,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HybridKeyBundleImplCopyWith<$Res>
    implements $HybridKeyBundleCopyWith<$Res> {
  factory _$$HybridKeyBundleImplCopyWith(
    _$HybridKeyBundleImpl value,
    $Res Function(_$HybridKeyBundleImpl) then,
  ) = __$$HybridKeyBundleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Uint8List x25519Public,
    Uint8List x25519Private,
    Uint8List mlKemPublic,
    Uint8List mlKemPrivate,
  });
}

/// @nodoc
class __$$HybridKeyBundleImplCopyWithImpl<$Res>
    extends _$HybridKeyBundleCopyWithImpl<$Res, _$HybridKeyBundleImpl>
    implements _$$HybridKeyBundleImplCopyWith<$Res> {
  __$$HybridKeyBundleImplCopyWithImpl(
    _$HybridKeyBundleImpl _value,
    $Res Function(_$HybridKeyBundleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HybridKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x25519Public = null,
    Object? x25519Private = null,
    Object? mlKemPublic = null,
    Object? mlKemPrivate = null,
  }) {
    return _then(
      _$HybridKeyBundleImpl(
        x25519Public: null == x25519Public
            ? _value.x25519Public
            : x25519Public // ignore: cast_nullable_to_non_nullable
                  as Uint8List,
        x25519Private: null == x25519Private
            ? _value.x25519Private
            : x25519Private // ignore: cast_nullable_to_non_nullable
                  as Uint8List,
        mlKemPublic: null == mlKemPublic
            ? _value.mlKemPublic
            : mlKemPublic // ignore: cast_nullable_to_non_nullable
                  as Uint8List,
        mlKemPrivate: null == mlKemPrivate
            ? _value.mlKemPrivate
            : mlKemPrivate // ignore: cast_nullable_to_non_nullable
                  as Uint8List,
      ),
    );
  }
}

/// @nodoc

class _$HybridKeyBundleImpl implements _HybridKeyBundle {
  const _$HybridKeyBundleImpl({
    required this.x25519Public,
    required this.x25519Private,
    required this.mlKemPublic,
    required this.mlKemPrivate,
  });

  @override
  final Uint8List x25519Public;
  @override
  final Uint8List x25519Private;
  @override
  final Uint8List mlKemPublic;
  @override
  final Uint8List mlKemPrivate;

  @override
  String toString() {
    return 'HybridKeyBundle(x25519Public: $x25519Public, x25519Private: $x25519Private, mlKemPublic: $mlKemPublic, mlKemPrivate: $mlKemPrivate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HybridKeyBundleImpl &&
            const DeepCollectionEquality().equals(
              other.x25519Public,
              x25519Public,
            ) &&
            const DeepCollectionEquality().equals(
              other.x25519Private,
              x25519Private,
            ) &&
            const DeepCollectionEquality().equals(
              other.mlKemPublic,
              mlKemPublic,
            ) &&
            const DeepCollectionEquality().equals(
              other.mlKemPrivate,
              mlKemPrivate,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(x25519Public),
    const DeepCollectionEquality().hash(x25519Private),
    const DeepCollectionEquality().hash(mlKemPublic),
    const DeepCollectionEquality().hash(mlKemPrivate),
  );

  /// Create a copy of HybridKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HybridKeyBundleImplCopyWith<_$HybridKeyBundleImpl> get copyWith =>
      __$$HybridKeyBundleImplCopyWithImpl<_$HybridKeyBundleImpl>(
        this,
        _$identity,
      );
}

abstract class _HybridKeyBundle implements HybridKeyBundle {
  const factory _HybridKeyBundle({
    required final Uint8List x25519Public,
    required final Uint8List x25519Private,
    required final Uint8List mlKemPublic,
    required final Uint8List mlKemPrivate,
  }) = _$HybridKeyBundleImpl;

  @override
  Uint8List get x25519Public;
  @override
  Uint8List get x25519Private;
  @override
  Uint8List get mlKemPublic;
  @override
  Uint8List get mlKemPrivate;

  /// Create a copy of HybridKeyBundle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HybridKeyBundleImplCopyWith<_$HybridKeyBundleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$KeyPair {
  Uint8List get publicKey => throw _privateConstructorUsedError;
  Uint8List get privateKey => throw _privateConstructorUsedError;
  String get keyType => throw _privateConstructorUsedError;

  /// Create a copy of KeyPair
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeyPairCopyWith<KeyPair> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeyPairCopyWith<$Res> {
  factory $KeyPairCopyWith(KeyPair value, $Res Function(KeyPair) then) =
      _$KeyPairCopyWithImpl<$Res, KeyPair>;
  @useResult
  $Res call({Uint8List publicKey, Uint8List privateKey, String keyType});
}

/// @nodoc
class _$KeyPairCopyWithImpl<$Res, $Val extends KeyPair>
    implements $KeyPairCopyWith<$Res> {
  _$KeyPairCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KeyPair
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicKey = null,
    Object? privateKey = null,
    Object? keyType = null,
  }) {
    return _then(
      _value.copyWith(
            publicKey: null == publicKey
                ? _value.publicKey
                : publicKey // ignore: cast_nullable_to_non_nullable
                      as Uint8List,
            privateKey: null == privateKey
                ? _value.privateKey
                : privateKey // ignore: cast_nullable_to_non_nullable
                      as Uint8List,
            keyType: null == keyType
                ? _value.keyType
                : keyType // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KeyPairImplCopyWith<$Res> implements $KeyPairCopyWith<$Res> {
  factory _$$KeyPairImplCopyWith(
    _$KeyPairImpl value,
    $Res Function(_$KeyPairImpl) then,
  ) = __$$KeyPairImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Uint8List publicKey, Uint8List privateKey, String keyType});
}

/// @nodoc
class __$$KeyPairImplCopyWithImpl<$Res>
    extends _$KeyPairCopyWithImpl<$Res, _$KeyPairImpl>
    implements _$$KeyPairImplCopyWith<$Res> {
  __$$KeyPairImplCopyWithImpl(
    _$KeyPairImpl _value,
    $Res Function(_$KeyPairImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KeyPair
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publicKey = null,
    Object? privateKey = null,
    Object? keyType = null,
  }) {
    return _then(
      _$KeyPairImpl(
        publicKey: null == publicKey
            ? _value.publicKey
            : publicKey // ignore: cast_nullable_to_non_nullable
                  as Uint8List,
        privateKey: null == privateKey
            ? _value.privateKey
            : privateKey // ignore: cast_nullable_to_non_nullable
                  as Uint8List,
        keyType: null == keyType
            ? _value.keyType
            : keyType // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$KeyPairImpl implements _KeyPair {
  const _$KeyPairImpl({
    required this.publicKey,
    required this.privateKey,
    required this.keyType,
  });

  @override
  final Uint8List publicKey;
  @override
  final Uint8List privateKey;
  @override
  final String keyType;

  @override
  String toString() {
    return 'KeyPair(publicKey: $publicKey, privateKey: $privateKey, keyType: $keyType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeyPairImpl &&
            const DeepCollectionEquality().equals(other.publicKey, publicKey) &&
            const DeepCollectionEquality().equals(
              other.privateKey,
              privateKey,
            ) &&
            (identical(other.keyType, keyType) || other.keyType == keyType));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(publicKey),
    const DeepCollectionEquality().hash(privateKey),
    keyType,
  );

  /// Create a copy of KeyPair
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeyPairImplCopyWith<_$KeyPairImpl> get copyWith =>
      __$$KeyPairImplCopyWithImpl<_$KeyPairImpl>(this, _$identity);
}

abstract class _KeyPair implements KeyPair {
  const factory _KeyPair({
    required final Uint8List publicKey,
    required final Uint8List privateKey,
    required final String keyType,
  }) = _$KeyPairImpl;

  @override
  Uint8List get publicKey;
  @override
  Uint8List get privateKey;
  @override
  String get keyType;

  /// Create a copy of KeyPair
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeyPairImplCopyWith<_$KeyPairImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
