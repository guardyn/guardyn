// This is a generated file - do not edit.
//
// Generated from media.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;
import 'media.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'media.pbenum.dart';

/// Media metadata stored in database
class MediaMetadata extends $pb.GeneratedMessage {
  factory MediaMetadata({
    $core.String? mediaId,
    $core.String? ownerUserId,
    $core.String? filename,
    MediaType? mediaType,
    $core.String? mimeType,
    $fixnum.Int64? sizeBytes,
    $core.String? checksumSha256,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? updatedAt,
    UploadStatus? status,
    $core.int? width,
    $core.int? height,
    $core.int? durationMs,
    $core.String? thumbnailId,
    $core.bool? isEncrypted,
    $core.List<$core.int>? encryptionKeyId,
    $core.List<$core.int>? iv,
    $core.String? conversationId,
    $core.String? messageId,
    $core.String? storagePath,
  }) {
    final result = create();
    if (mediaId != null) result.mediaId = mediaId;
    if (ownerUserId != null) result.ownerUserId = ownerUserId;
    if (filename != null) result.filename = filename;
    if (mediaType != null) result.mediaType = mediaType;
    if (mimeType != null) result.mimeType = mimeType;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (checksumSha256 != null) result.checksumSha256 = checksumSha256;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (status != null) result.status = status;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (durationMs != null) result.durationMs = durationMs;
    if (thumbnailId != null) result.thumbnailId = thumbnailId;
    if (isEncrypted != null) result.isEncrypted = isEncrypted;
    if (encryptionKeyId != null) result.encryptionKeyId = encryptionKeyId;
    if (iv != null) result.iv = iv;
    if (conversationId != null) result.conversationId = conversationId;
    if (messageId != null) result.messageId = messageId;
    if (storagePath != null) result.storagePath = storagePath;
    return result;
  }

  MediaMetadata._();

  factory MediaMetadata.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MediaMetadata.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MediaMetadata',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mediaId')
    ..aOS(2, _omitFieldNames ? '' : 'ownerUserId')
    ..aOS(3, _omitFieldNames ? '' : 'filename')
    ..aE<MediaType>(4, _omitFieldNames ? '' : 'mediaType',
        enumValues: MediaType.values)
    ..aOS(5, _omitFieldNames ? '' : 'mimeType')
    ..aInt64(6, _omitFieldNames ? '' : 'sizeBytes')
    ..aOS(7, _omitFieldNames ? '' : 'checksumSha256')
    ..aInt64(8, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(9, _omitFieldNames ? '' : 'updatedAt')
    ..aE<UploadStatus>(10, _omitFieldNames ? '' : 'status',
        enumValues: UploadStatus.values)
    ..aI(11, _omitFieldNames ? '' : 'width')
    ..aI(12, _omitFieldNames ? '' : 'height')
    ..aI(13, _omitFieldNames ? '' : 'durationMs')
    ..aOS(14, _omitFieldNames ? '' : 'thumbnailId')
    ..aOB(15, _omitFieldNames ? '' : 'isEncrypted')
    ..a<$core.List<$core.int>>(
        16, _omitFieldNames ? '' : 'encryptionKeyId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        17, _omitFieldNames ? '' : 'iv', $pb.PbFieldType.OY)
    ..aOS(18, _omitFieldNames ? '' : 'conversationId')
    ..aOS(19, _omitFieldNames ? '' : 'messageId')
    ..aOS(20, _omitFieldNames ? '' : 'storagePath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaMetadata clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MediaMetadata copyWith(void Function(MediaMetadata) updates) =>
      super.copyWith((message) => updates(message as MediaMetadata))
          as MediaMetadata;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MediaMetadata create() => MediaMetadata._();
  @$core.override
  MediaMetadata createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MediaMetadata getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MediaMetadata>(create);
  static MediaMetadata? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mediaId => $_getSZ(0);
  @$pb.TagNumber(1)
  set mediaId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMediaId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMediaId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get ownerUserId => $_getSZ(1);
  @$pb.TagNumber(2)
  set ownerUserId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOwnerUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOwnerUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get filename => $_getSZ(2);
  @$pb.TagNumber(3)
  set filename($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFilename() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilename() => $_clearField(3);

  @$pb.TagNumber(4)
  MediaType get mediaType => $_getN(3);
  @$pb.TagNumber(4)
  set mediaType(MediaType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMediaType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMediaType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get mimeType => $_getSZ(4);
  @$pb.TagNumber(5)
  set mimeType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMimeType() => $_has(4);
  @$pb.TagNumber(5)
  void clearMimeType() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get sizeBytes => $_getI64(5);
  @$pb.TagNumber(6)
  set sizeBytes($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSizeBytes() => $_has(5);
  @$pb.TagNumber(6)
  void clearSizeBytes() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get checksumSha256 => $_getSZ(6);
  @$pb.TagNumber(7)
  set checksumSha256($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasChecksumSha256() => $_has(6);
  @$pb.TagNumber(7)
  void clearChecksumSha256() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get createdAt => $_getI64(7);
  @$pb.TagNumber(8)
  set createdAt($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get updatedAt => $_getI64(8);
  @$pb.TagNumber(9)
  set updatedAt($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasUpdatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearUpdatedAt() => $_clearField(9);

  @$pb.TagNumber(10)
  UploadStatus get status => $_getN(9);
  @$pb.TagNumber(10)
  set status(UploadStatus value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasStatus() => $_has(9);
  @$pb.TagNumber(10)
  void clearStatus() => $_clearField(10);

  /// Optional fields
  @$pb.TagNumber(11)
  $core.int get width => $_getIZ(10);
  @$pb.TagNumber(11)
  set width($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasWidth() => $_has(10);
  @$pb.TagNumber(11)
  void clearWidth() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get height => $_getIZ(11);
  @$pb.TagNumber(12)
  set height($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHeight() => $_has(11);
  @$pb.TagNumber(12)
  void clearHeight() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get durationMs => $_getIZ(12);
  @$pb.TagNumber(13)
  set durationMs($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasDurationMs() => $_has(12);
  @$pb.TagNumber(13)
  void clearDurationMs() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get thumbnailId => $_getSZ(13);
  @$pb.TagNumber(14)
  set thumbnailId($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasThumbnailId() => $_has(13);
  @$pb.TagNumber(14)
  void clearThumbnailId() => $_clearField(14);

  /// E2EE fields
  @$pb.TagNumber(15)
  $core.bool get isEncrypted => $_getBF(14);
  @$pb.TagNumber(15)
  set isEncrypted($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasIsEncrypted() => $_has(14);
  @$pb.TagNumber(15)
  void clearIsEncrypted() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.List<$core.int> get encryptionKeyId => $_getN(15);
  @$pb.TagNumber(16)
  set encryptionKeyId($core.List<$core.int> value) => $_setBytes(15, value);
  @$pb.TagNumber(16)
  $core.bool hasEncryptionKeyId() => $_has(15);
  @$pb.TagNumber(16)
  void clearEncryptionKeyId() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.List<$core.int> get iv => $_getN(16);
  @$pb.TagNumber(17)
  set iv($core.List<$core.int> value) => $_setBytes(16, value);
  @$pb.TagNumber(17)
  $core.bool hasIv() => $_has(16);
  @$pb.TagNumber(17)
  void clearIv() => $_clearField(17);

  /// Context
  @$pb.TagNumber(18)
  $core.String get conversationId => $_getSZ(17);
  @$pb.TagNumber(18)
  set conversationId($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasConversationId() => $_has(17);
  @$pb.TagNumber(18)
  void clearConversationId() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get messageId => $_getSZ(18);
  @$pb.TagNumber(19)
  set messageId($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasMessageId() => $_has(18);
  @$pb.TagNumber(19)
  void clearMessageId() => $_clearField(19);

  /// Storage info
  @$pb.TagNumber(20)
  $core.String get storagePath => $_getSZ(19);
  @$pb.TagNumber(20)
  set storagePath($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasStoragePath() => $_has(19);
  @$pb.TagNumber(20)
  void clearStoragePath() => $_clearField(20);
}

enum UploadMediaRequest_Content { header, chunk, notSet }

/// Upload request (streaming)
class UploadMediaRequest extends $pb.GeneratedMessage {
  factory UploadMediaRequest({
    UploadMediaHeader? header,
    $core.List<$core.int>? chunk,
  }) {
    final result = create();
    if (header != null) result.header = header;
    if (chunk != null) result.chunk = chunk;
    return result;
  }

  UploadMediaRequest._();

  factory UploadMediaRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadMediaRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, UploadMediaRequest_Content>
      _UploadMediaRequest_ContentByTag = {
    1: UploadMediaRequest_Content.header,
    2: UploadMediaRequest_Content.chunk,
    0: UploadMediaRequest_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadMediaRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<UploadMediaHeader>(1, _omitFieldNames ? '' : 'header',
        subBuilder: UploadMediaHeader.create)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'chunk', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMediaRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMediaRequest copyWith(void Function(UploadMediaRequest) updates) =>
      super.copyWith((message) => updates(message as UploadMediaRequest))
          as UploadMediaRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadMediaRequest create() => UploadMediaRequest._();
  @$core.override
  UploadMediaRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadMediaRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadMediaRequest>(create);
  static UploadMediaRequest? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  UploadMediaRequest_Content whichContent() =>
      _UploadMediaRequest_ContentByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearContent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  UploadMediaHeader get header => $_getN(0);
  @$pb.TagNumber(1)
  set header(UploadMediaHeader value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHeader() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeader() => $_clearField(1);
  @$pb.TagNumber(1)
  UploadMediaHeader ensureHeader() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get chunk => $_getN(1);
  @$pb.TagNumber(2)
  set chunk($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChunk() => $_has(1);
  @$pb.TagNumber(2)
  void clearChunk() => $_clearField(2);
}

/// Header sent as first message in upload stream
class UploadMediaHeader extends $pb.GeneratedMessage {
  factory UploadMediaHeader({
    $core.String? filename,
    MediaType? mediaType,
    $core.String? mimeType,
    $fixnum.Int64? sizeBytes,
    $core.String? checksumSha256,
    $core.bool? isEncrypted,
    $core.List<$core.int>? encryptionKeyId,
    $core.List<$core.int>? iv,
    $core.String? conversationId,
    $core.String? messageId,
  }) {
    final result = create();
    if (filename != null) result.filename = filename;
    if (mediaType != null) result.mediaType = mediaType;
    if (mimeType != null) result.mimeType = mimeType;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (checksumSha256 != null) result.checksumSha256 = checksumSha256;
    if (isEncrypted != null) result.isEncrypted = isEncrypted;
    if (encryptionKeyId != null) result.encryptionKeyId = encryptionKeyId;
    if (iv != null) result.iv = iv;
    if (conversationId != null) result.conversationId = conversationId;
    if (messageId != null) result.messageId = messageId;
    return result;
  }

  UploadMediaHeader._();

  factory UploadMediaHeader.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadMediaHeader.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadMediaHeader',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..aE<MediaType>(2, _omitFieldNames ? '' : 'mediaType',
        enumValues: MediaType.values)
    ..aOS(3, _omitFieldNames ? '' : 'mimeType')
    ..aInt64(4, _omitFieldNames ? '' : 'sizeBytes')
    ..aOS(5, _omitFieldNames ? '' : 'checksumSha256')
    ..aOB(6, _omitFieldNames ? '' : 'isEncrypted')
    ..a<$core.List<$core.int>>(
        7, _omitFieldNames ? '' : 'encryptionKeyId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        8, _omitFieldNames ? '' : 'iv', $pb.PbFieldType.OY)
    ..aOS(9, _omitFieldNames ? '' : 'conversationId')
    ..aOS(10, _omitFieldNames ? '' : 'messageId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMediaHeader clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMediaHeader copyWith(void Function(UploadMediaHeader) updates) =>
      super.copyWith((message) => updates(message as UploadMediaHeader))
          as UploadMediaHeader;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadMediaHeader create() => UploadMediaHeader._();
  @$core.override
  UploadMediaHeader createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadMediaHeader getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadMediaHeader>(create);
  static UploadMediaHeader? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => $_clearField(1);

  @$pb.TagNumber(2)
  MediaType get mediaType => $_getN(1);
  @$pb.TagNumber(2)
  set mediaType(MediaType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMediaType() => $_has(1);
  @$pb.TagNumber(2)
  void clearMediaType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mimeType => $_getSZ(2);
  @$pb.TagNumber(3)
  set mimeType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMimeType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMimeType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sizeBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set sizeBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearSizeBytes() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get checksumSha256 => $_getSZ(4);
  @$pb.TagNumber(5)
  set checksumSha256($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasChecksumSha256() => $_has(4);
  @$pb.TagNumber(5)
  void clearChecksumSha256() => $_clearField(5);

  /// E2EE fields (if file is client-side encrypted)
  @$pb.TagNumber(6)
  $core.bool get isEncrypted => $_getBF(5);
  @$pb.TagNumber(6)
  set isEncrypted($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsEncrypted() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsEncrypted() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get encryptionKeyId => $_getN(6);
  @$pb.TagNumber(7)
  set encryptionKeyId($core.List<$core.int> value) => $_setBytes(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEncryptionKeyId() => $_has(6);
  @$pb.TagNumber(7)
  void clearEncryptionKeyId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get iv => $_getN(7);
  @$pb.TagNumber(8)
  set iv($core.List<$core.int> value) => $_setBytes(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIv() => $_has(7);
  @$pb.TagNumber(8)
  void clearIv() => $_clearField(8);

  /// Context
  @$pb.TagNumber(9)
  $core.String get conversationId => $_getSZ(8);
  @$pb.TagNumber(9)
  set conversationId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasConversationId() => $_has(8);
  @$pb.TagNumber(9)
  void clearConversationId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get messageId => $_getSZ(9);
  @$pb.TagNumber(10)
  set messageId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMessageId() => $_has(9);
  @$pb.TagNumber(10)
  void clearMessageId() => $_clearField(10);
}

/// Upload response
class UploadMediaResponse extends $pb.GeneratedMessage {
  factory UploadMediaResponse({
    $core.String? mediaId,
    UploadStatus? status,
    MediaMetadata? metadata,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (mediaId != null) result.mediaId = mediaId;
    if (status != null) result.status = status;
    if (metadata != null) result.metadata = metadata;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  UploadMediaResponse._();

  factory UploadMediaResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadMediaResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadMediaResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mediaId')
    ..aE<UploadStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: UploadStatus.values)
    ..aOM<MediaMetadata>(3, _omitFieldNames ? '' : 'metadata',
        subBuilder: MediaMetadata.create)
    ..aOS(4, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMediaResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadMediaResponse copyWith(void Function(UploadMediaResponse) updates) =>
      super.copyWith((message) => updates(message as UploadMediaResponse))
          as UploadMediaResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadMediaResponse create() => UploadMediaResponse._();
  @$core.override
  UploadMediaResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadMediaResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadMediaResponse>(create);
  static UploadMediaResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mediaId => $_getSZ(0);
  @$pb.TagNumber(1)
  set mediaId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMediaId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMediaId() => $_clearField(1);

  @$pb.TagNumber(2)
  UploadStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(UploadStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  MediaMetadata get metadata => $_getN(2);
  @$pb.TagNumber(3)
  set metadata(MediaMetadata value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMetadata() => $_has(2);
  @$pb.TagNumber(3)
  void clearMetadata() => $_clearField(3);
  @$pb.TagNumber(3)
  MediaMetadata ensureMetadata() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get errorMessage => $_getSZ(3);
  @$pb.TagNumber(4)
  set errorMessage($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasErrorMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearErrorMessage() => $_clearField(4);
}

/// Download request
class DownloadMediaRequest extends $pb.GeneratedMessage {
  factory DownloadMediaRequest({
    $core.String? mediaId,
    $fixnum.Int64? offset,
    $fixnum.Int64? length,
  }) {
    final result = create();
    if (mediaId != null) result.mediaId = mediaId;
    if (offset != null) result.offset = offset;
    if (length != null) result.length = length;
    return result;
  }

  DownloadMediaRequest._();

  factory DownloadMediaRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DownloadMediaRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DownloadMediaRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mediaId')
    ..aInt64(2, _omitFieldNames ? '' : 'offset')
    ..aInt64(3, _omitFieldNames ? '' : 'length')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadMediaRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadMediaRequest copyWith(void Function(DownloadMediaRequest) updates) =>
      super.copyWith((message) => updates(message as DownloadMediaRequest))
          as DownloadMediaRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadMediaRequest create() => DownloadMediaRequest._();
  @$core.override
  DownloadMediaRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DownloadMediaRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadMediaRequest>(create);
  static DownloadMediaRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mediaId => $_getSZ(0);
  @$pb.TagNumber(1)
  set mediaId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMediaId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMediaId() => $_clearField(1);

  /// Optional: request specific byte range (for resumable downloads)
  @$pb.TagNumber(2)
  $fixnum.Int64 get offset => $_getI64(1);
  @$pb.TagNumber(2)
  set offset($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get length => $_getI64(2);
  @$pb.TagNumber(3)
  set length($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLength() => $_has(2);
  @$pb.TagNumber(3)
  void clearLength() => $_clearField(3);
}

enum DownloadMediaResponse_Content { metadata, chunk, notSet }

/// Download response (streaming)
class DownloadMediaResponse extends $pb.GeneratedMessage {
  factory DownloadMediaResponse({
    MediaMetadata? metadata,
    $core.List<$core.int>? chunk,
  }) {
    final result = create();
    if (metadata != null) result.metadata = metadata;
    if (chunk != null) result.chunk = chunk;
    return result;
  }

  DownloadMediaResponse._();

  factory DownloadMediaResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DownloadMediaResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, DownloadMediaResponse_Content>
      _DownloadMediaResponse_ContentByTag = {
    1: DownloadMediaResponse_Content.metadata,
    2: DownloadMediaResponse_Content.chunk,
    0: DownloadMediaResponse_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DownloadMediaResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<MediaMetadata>(1, _omitFieldNames ? '' : 'metadata',
        subBuilder: MediaMetadata.create)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'chunk', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadMediaResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadMediaResponse copyWith(
          void Function(DownloadMediaResponse) updates) =>
      super.copyWith((message) => updates(message as DownloadMediaResponse))
          as DownloadMediaResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadMediaResponse create() => DownloadMediaResponse._();
  @$core.override
  DownloadMediaResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DownloadMediaResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadMediaResponse>(create);
  static DownloadMediaResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  DownloadMediaResponse_Content whichContent() =>
      _DownloadMediaResponse_ContentByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearContent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  MediaMetadata get metadata => $_getN(0);
  @$pb.TagNumber(1)
  set metadata(MediaMetadata value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMetadata() => $_has(0);
  @$pb.TagNumber(1)
  void clearMetadata() => $_clearField(1);
  @$pb.TagNumber(1)
  MediaMetadata ensureMetadata() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get chunk => $_getN(1);
  @$pb.TagNumber(2)
  set chunk($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChunk() => $_has(1);
  @$pb.TagNumber(2)
  void clearChunk() => $_clearField(2);
}

/// Get metadata request
class GetMediaMetadataRequest extends $pb.GeneratedMessage {
  factory GetMediaMetadataRequest({
    $core.String? mediaId,
  }) {
    final result = create();
    if (mediaId != null) result.mediaId = mediaId;
    return result;
  }

  GetMediaMetadataRequest._();

  factory GetMediaMetadataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMediaMetadataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMediaMetadataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mediaId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMediaMetadataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMediaMetadataRequest copyWith(
          void Function(GetMediaMetadataRequest) updates) =>
      super.copyWith((message) => updates(message as GetMediaMetadataRequest))
          as GetMediaMetadataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMediaMetadataRequest create() => GetMediaMetadataRequest._();
  @$core.override
  GetMediaMetadataRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMediaMetadataRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMediaMetadataRequest>(create);
  static GetMediaMetadataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mediaId => $_getSZ(0);
  @$pb.TagNumber(1)
  set mediaId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMediaId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMediaId() => $_clearField(1);
}

/// Get metadata response
class GetMediaMetadataResponse extends $pb.GeneratedMessage {
  factory GetMediaMetadataResponse({
    MediaMetadata? metadata,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (metadata != null) result.metadata = metadata;
    if (error != null) result.error = error;
    return result;
  }

  GetMediaMetadataResponse._();

  factory GetMediaMetadataResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMediaMetadataResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMediaMetadataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOM<MediaMetadata>(1, _omitFieldNames ? '' : 'metadata',
        subBuilder: MediaMetadata.create)
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMediaMetadataResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMediaMetadataResponse copyWith(
          void Function(GetMediaMetadataResponse) updates) =>
      super.copyWith((message) => updates(message as GetMediaMetadataResponse))
          as GetMediaMetadataResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMediaMetadataResponse create() => GetMediaMetadataResponse._();
  @$core.override
  GetMediaMetadataResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMediaMetadataResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMediaMetadataResponse>(create);
  static GetMediaMetadataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MediaMetadata get metadata => $_getN(0);
  @$pb.TagNumber(1)
  set metadata(MediaMetadata value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMetadata() => $_has(0);
  @$pb.TagNumber(1)
  void clearMetadata() => $_clearField(1);
  @$pb.TagNumber(1)
  MediaMetadata ensureMetadata() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

/// Delete media request
class DeleteMediaRequest extends $pb.GeneratedMessage {
  factory DeleteMediaRequest({
    $core.String? mediaId,
  }) {
    final result = create();
    if (mediaId != null) result.mediaId = mediaId;
    return result;
  }

  DeleteMediaRequest._();

  factory DeleteMediaRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteMediaRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteMediaRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mediaId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteMediaRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteMediaRequest copyWith(void Function(DeleteMediaRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteMediaRequest))
          as DeleteMediaRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteMediaRequest create() => DeleteMediaRequest._();
  @$core.override
  DeleteMediaRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteMediaRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteMediaRequest>(create);
  static DeleteMediaRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mediaId => $_getSZ(0);
  @$pb.TagNumber(1)
  set mediaId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMediaId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMediaId() => $_clearField(1);
}

/// Delete media response
class DeleteMediaResponse extends $pb.GeneratedMessage {
  factory DeleteMediaResponse({
    $core.bool? success,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  DeleteMediaResponse._();

  factory DeleteMediaResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteMediaResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteMediaResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOM<$1.ErrorResponse>(2, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteMediaResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteMediaResponse copyWith(void Function(DeleteMediaResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteMediaResponse))
          as DeleteMediaResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteMediaResponse create() => DeleteMediaResponse._();
  @$core.override
  DeleteMediaResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteMediaResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteMediaResponse>(create);
  static DeleteMediaResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.ErrorResponse get error => $_getN(1);
  @$pb.TagNumber(2)
  set error($1.ErrorResponse value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.ErrorResponse ensureError() => $_ensure(1);
}

/// Get upload URL for direct S3 upload
class GetUploadUrlRequest extends $pb.GeneratedMessage {
  factory GetUploadUrlRequest({
    $core.String? filename,
    $core.String? mimeType,
    $fixnum.Int64? sizeBytes,
    $core.String? conversationId,
  }) {
    final result = create();
    if (filename != null) result.filename = filename;
    if (mimeType != null) result.mimeType = mimeType;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (conversationId != null) result.conversationId = conversationId;
    return result;
  }

  GetUploadUrlRequest._();

  factory GetUploadUrlRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUploadUrlRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUploadUrlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..aOS(2, _omitFieldNames ? '' : 'mimeType')
    ..aInt64(3, _omitFieldNames ? '' : 'sizeBytes')
    ..aOS(4, _omitFieldNames ? '' : 'conversationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUploadUrlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUploadUrlRequest copyWith(void Function(GetUploadUrlRequest) updates) =>
      super.copyWith((message) => updates(message as GetUploadUrlRequest))
          as GetUploadUrlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUploadUrlRequest create() => GetUploadUrlRequest._();
  @$core.override
  GetUploadUrlRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUploadUrlRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUploadUrlRequest>(create);
  static GetUploadUrlRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get mimeType => $_getSZ(1);
  @$pb.TagNumber(2)
  set mimeType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMimeType() => $_has(1);
  @$pb.TagNumber(2)
  void clearMimeType() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get sizeBytes => $_getI64(2);
  @$pb.TagNumber(3)
  set sizeBytes($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSizeBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearSizeBytes() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get conversationId => $_getSZ(3);
  @$pb.TagNumber(4)
  set conversationId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConversationId() => $_has(3);
  @$pb.TagNumber(4)
  void clearConversationId() => $_clearField(4);
}

/// Upload URL response
class GetUploadUrlResponse extends $pb.GeneratedMessage {
  factory GetUploadUrlResponse({
    $core.String? uploadUrl,
    $core.String? mediaId,
    $fixnum.Int64? expiresAt,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? headers,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (uploadUrl != null) result.uploadUrl = uploadUrl;
    if (mediaId != null) result.mediaId = mediaId;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (headers != null) result.headers.addEntries(headers);
    if (error != null) result.error = error;
    return result;
  }

  GetUploadUrlResponse._();

  factory GetUploadUrlResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUploadUrlResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUploadUrlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'uploadUrl')
    ..aOS(2, _omitFieldNames ? '' : 'mediaId')
    ..aInt64(3, _omitFieldNames ? '' : 'expiresAt')
    ..m<$core.String, $core.String>(4, _omitFieldNames ? '' : 'headers',
        entryClassName: 'GetUploadUrlResponse.HeadersEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('guardyn.media'))
    ..aOM<$1.ErrorResponse>(5, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUploadUrlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUploadUrlResponse copyWith(void Function(GetUploadUrlResponse) updates) =>
      super.copyWith((message) => updates(message as GetUploadUrlResponse))
          as GetUploadUrlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUploadUrlResponse create() => GetUploadUrlResponse._();
  @$core.override
  GetUploadUrlResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUploadUrlResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUploadUrlResponse>(create);
  static GetUploadUrlResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uploadUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set uploadUrl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUploadUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUploadUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get mediaId => $_getSZ(1);
  @$pb.TagNumber(2)
  set mediaId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMediaId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMediaId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get expiresAt => $_getI64(2);
  @$pb.TagNumber(3)
  set expiresAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresAt() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, $core.String> get headers => $_getMap(3);

  @$pb.TagNumber(5)
  $1.ErrorResponse get error => $_getN(4);
  @$pb.TagNumber(5)
  set error($1.ErrorResponse value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.ErrorResponse ensureError() => $_ensure(4);
}

/// Get download URL request
class GetDownloadUrlRequest extends $pb.GeneratedMessage {
  factory GetDownloadUrlRequest({
    $core.String? mediaId,
  }) {
    final result = create();
    if (mediaId != null) result.mediaId = mediaId;
    return result;
  }

  GetDownloadUrlRequest._();

  factory GetDownloadUrlRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDownloadUrlRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDownloadUrlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mediaId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadUrlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadUrlRequest copyWith(
          void Function(GetDownloadUrlRequest) updates) =>
      super.copyWith((message) => updates(message as GetDownloadUrlRequest))
          as GetDownloadUrlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDownloadUrlRequest create() => GetDownloadUrlRequest._();
  @$core.override
  GetDownloadUrlRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDownloadUrlRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDownloadUrlRequest>(create);
  static GetDownloadUrlRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mediaId => $_getSZ(0);
  @$pb.TagNumber(1)
  set mediaId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMediaId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMediaId() => $_clearField(1);
}

/// Download URL response
class GetDownloadUrlResponse extends $pb.GeneratedMessage {
  factory GetDownloadUrlResponse({
    $core.String? downloadUrl,
    $fixnum.Int64? expiresAt,
    MediaMetadata? metadata,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (downloadUrl != null) result.downloadUrl = downloadUrl;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (metadata != null) result.metadata = metadata;
    if (error != null) result.error = error;
    return result;
  }

  GetDownloadUrlResponse._();

  factory GetDownloadUrlResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDownloadUrlResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDownloadUrlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'downloadUrl')
    ..aInt64(2, _omitFieldNames ? '' : 'expiresAt')
    ..aOM<MediaMetadata>(3, _omitFieldNames ? '' : 'metadata',
        subBuilder: MediaMetadata.create)
    ..aOM<$1.ErrorResponse>(4, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadUrlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDownloadUrlResponse copyWith(
          void Function(GetDownloadUrlResponse) updates) =>
      super.copyWith((message) => updates(message as GetDownloadUrlResponse))
          as GetDownloadUrlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDownloadUrlResponse create() => GetDownloadUrlResponse._();
  @$core.override
  GetDownloadUrlResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDownloadUrlResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDownloadUrlResponse>(create);
  static GetDownloadUrlResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get downloadUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set downloadUrl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDownloadUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearDownloadUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expiresAt => $_getI64(1);
  @$pb.TagNumber(2)
  set expiresAt($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpiresAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiresAt() => $_clearField(2);

  @$pb.TagNumber(3)
  MediaMetadata get metadata => $_getN(2);
  @$pb.TagNumber(3)
  set metadata(MediaMetadata value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMetadata() => $_has(2);
  @$pb.TagNumber(3)
  void clearMetadata() => $_clearField(3);
  @$pb.TagNumber(3)
  MediaMetadata ensureMetadata() => $_ensure(2);

  @$pb.TagNumber(4)
  $1.ErrorResponse get error => $_getN(3);
  @$pb.TagNumber(4)
  set error($1.ErrorResponse value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.ErrorResponse ensureError() => $_ensure(3);
}

/// Generate thumbnail request
class GenerateThumbnailRequest extends $pb.GeneratedMessage {
  factory GenerateThumbnailRequest({
    $core.String? mediaId,
    $core.int? maxWidth,
    $core.int? maxHeight,
    $core.String? format,
    $core.int? quality,
  }) {
    final result = create();
    if (mediaId != null) result.mediaId = mediaId;
    if (maxWidth != null) result.maxWidth = maxWidth;
    if (maxHeight != null) result.maxHeight = maxHeight;
    if (format != null) result.format = format;
    if (quality != null) result.quality = quality;
    return result;
  }

  GenerateThumbnailRequest._();

  factory GenerateThumbnailRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateThumbnailRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateThumbnailRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mediaId')
    ..aI(2, _omitFieldNames ? '' : 'maxWidth')
    ..aI(3, _omitFieldNames ? '' : 'maxHeight')
    ..aOS(4, _omitFieldNames ? '' : 'format')
    ..aI(5, _omitFieldNames ? '' : 'quality')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateThumbnailRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateThumbnailRequest copyWith(
          void Function(GenerateThumbnailRequest) updates) =>
      super.copyWith((message) => updates(message as GenerateThumbnailRequest))
          as GenerateThumbnailRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateThumbnailRequest create() => GenerateThumbnailRequest._();
  @$core.override
  GenerateThumbnailRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateThumbnailRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateThumbnailRequest>(create);
  static GenerateThumbnailRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mediaId => $_getSZ(0);
  @$pb.TagNumber(1)
  set mediaId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMediaId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMediaId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get maxWidth => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxWidth($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxWidth() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxWidth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get maxHeight => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxHeight($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxHeight() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get format => $_getSZ(3);
  @$pb.TagNumber(4)
  set format($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFormat() => $_has(3);
  @$pb.TagNumber(4)
  void clearFormat() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get quality => $_getIZ(4);
  @$pb.TagNumber(5)
  set quality($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasQuality() => $_has(4);
  @$pb.TagNumber(5)
  void clearQuality() => $_clearField(5);
}

/// Generate thumbnail response
class GenerateThumbnailResponse extends $pb.GeneratedMessage {
  factory GenerateThumbnailResponse({
    $core.String? thumbnailId,
    MediaMetadata? metadata,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (thumbnailId != null) result.thumbnailId = thumbnailId;
    if (metadata != null) result.metadata = metadata;
    if (error != null) result.error = error;
    return result;
  }

  GenerateThumbnailResponse._();

  factory GenerateThumbnailResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateThumbnailResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateThumbnailResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'thumbnailId')
    ..aOM<MediaMetadata>(2, _omitFieldNames ? '' : 'metadata',
        subBuilder: MediaMetadata.create)
    ..aOM<$1.ErrorResponse>(3, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateThumbnailResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateThumbnailResponse copyWith(
          void Function(GenerateThumbnailResponse) updates) =>
      super.copyWith((message) => updates(message as GenerateThumbnailResponse))
          as GenerateThumbnailResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateThumbnailResponse create() => GenerateThumbnailResponse._();
  @$core.override
  GenerateThumbnailResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateThumbnailResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateThumbnailResponse>(create);
  static GenerateThumbnailResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get thumbnailId => $_getSZ(0);
  @$pb.TagNumber(1)
  set thumbnailId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasThumbnailId() => $_has(0);
  @$pb.TagNumber(1)
  void clearThumbnailId() => $_clearField(1);

  @$pb.TagNumber(2)
  MediaMetadata get metadata => $_getN(1);
  @$pb.TagNumber(2)
  set metadata(MediaMetadata value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMetadata() => $_has(1);
  @$pb.TagNumber(2)
  void clearMetadata() => $_clearField(2);
  @$pb.TagNumber(2)
  MediaMetadata ensureMetadata() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.ErrorResponse get error => $_getN(2);
  @$pb.TagNumber(3)
  set error($1.ErrorResponse value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.ErrorResponse ensureError() => $_ensure(2);
}

/// List media request
class ListMediaRequest extends $pb.GeneratedMessage {
  factory ListMediaRequest({
    $core.String? userId,
    $core.String? conversationId,
    $core.Iterable<MediaType>? mediaTypes,
    $core.int? limit,
    $core.String? cursor,
    $core.String? sortBy,
    $core.bool? ascending,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (conversationId != null) result.conversationId = conversationId;
    if (mediaTypes != null) result.mediaTypes.addAll(mediaTypes);
    if (limit != null) result.limit = limit;
    if (cursor != null) result.cursor = cursor;
    if (sortBy != null) result.sortBy = sortBy;
    if (ascending != null) result.ascending = ascending;
    return result;
  }

  ListMediaRequest._();

  factory ListMediaRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListMediaRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMediaRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..pc<MediaType>(3, _omitFieldNames ? '' : 'mediaTypes', $pb.PbFieldType.KE,
        valueOf: MediaType.valueOf,
        enumValues: MediaType.values,
        defaultEnumValue: MediaType.MEDIA_TYPE_UNKNOWN)
    ..aI(4, _omitFieldNames ? '' : 'limit')
    ..aOS(5, _omitFieldNames ? '' : 'cursor')
    ..aOS(6, _omitFieldNames ? '' : 'sortBy')
    ..aOB(7, _omitFieldNames ? '' : 'ascending')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMediaRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMediaRequest copyWith(void Function(ListMediaRequest) updates) =>
      super.copyWith((message) => updates(message as ListMediaRequest))
          as ListMediaRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMediaRequest create() => ListMediaRequest._();
  @$core.override
  ListMediaRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListMediaRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMediaRequest>(create);
  static ListMediaRequest? _defaultInstance;

  /// Filter by owner
  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);

  /// Filter by conversation
  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  /// Filter by type
  @$pb.TagNumber(3)
  $pb.PbList<MediaType> get mediaTypes => $_getList(2);

  /// Pagination
  @$pb.TagNumber(4)
  $core.int get limit => $_getIZ(3);
  @$pb.TagNumber(4)
  set limit($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLimit() => $_has(3);
  @$pb.TagNumber(4)
  void clearLimit() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cursor => $_getSZ(4);
  @$pb.TagNumber(5)
  set cursor($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCursor() => $_has(4);
  @$pb.TagNumber(5)
  void clearCursor() => $_clearField(5);

  /// Sort
  @$pb.TagNumber(6)
  $core.String get sortBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set sortBy($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSortBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearSortBy() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get ascending => $_getBF(6);
  @$pb.TagNumber(7)
  set ascending($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAscending() => $_has(6);
  @$pb.TagNumber(7)
  void clearAscending() => $_clearField(7);
}

/// List media response
class ListMediaResponse extends $pb.GeneratedMessage {
  factory ListMediaResponse({
    $core.Iterable<MediaMetadata>? items,
    $core.String? nextCursor,
    $core.int? totalCount,
    $1.ErrorResponse? error,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    if (nextCursor != null) result.nextCursor = nextCursor;
    if (totalCount != null) result.totalCount = totalCount;
    if (error != null) result.error = error;
    return result;
  }

  ListMediaResponse._();

  factory ListMediaResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListMediaResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMediaResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'guardyn.media'),
      createEmptyInstance: create)
    ..pPM<MediaMetadata>(1, _omitFieldNames ? '' : 'items',
        subBuilder: MediaMetadata.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextCursor')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..aOM<$1.ErrorResponse>(4, _omitFieldNames ? '' : 'error',
        subBuilder: $1.ErrorResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMediaResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMediaResponse copyWith(void Function(ListMediaResponse) updates) =>
      super.copyWith((message) => updates(message as ListMediaResponse))
          as ListMediaResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMediaResponse create() => ListMediaResponse._();
  @$core.override
  ListMediaResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListMediaResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMediaResponse>(create);
  static ListMediaResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MediaMetadata> get items => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextCursor => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextCursor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextCursor() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextCursor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $1.ErrorResponse get error => $_getN(3);
  @$pb.TagNumber(4)
  set error($1.ErrorResponse value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.ErrorResponse ensureError() => $_ensure(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
