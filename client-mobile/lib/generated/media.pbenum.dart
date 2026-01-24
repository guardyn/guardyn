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

import 'package:protobuf/protobuf.dart' as $pb;

/// Media type enumeration
class MediaType extends $pb.ProtobufEnum {
  static const MediaType MEDIA_TYPE_UNKNOWN =
      MediaType._(0, _omitEnumNames ? '' : 'MEDIA_TYPE_UNKNOWN');
  static const MediaType MEDIA_TYPE_IMAGE =
      MediaType._(1, _omitEnumNames ? '' : 'MEDIA_TYPE_IMAGE');
  static const MediaType MEDIA_TYPE_VIDEO =
      MediaType._(2, _omitEnumNames ? '' : 'MEDIA_TYPE_VIDEO');
  static const MediaType MEDIA_TYPE_AUDIO =
      MediaType._(3, _omitEnumNames ? '' : 'MEDIA_TYPE_AUDIO');
  static const MediaType MEDIA_TYPE_DOCUMENT =
      MediaType._(4, _omitEnumNames ? '' : 'MEDIA_TYPE_DOCUMENT');
  static const MediaType MEDIA_TYPE_OTHER =
      MediaType._(5, _omitEnumNames ? '' : 'MEDIA_TYPE_OTHER');

  static const $core.List<MediaType> values = <MediaType>[
    MEDIA_TYPE_UNKNOWN,
    MEDIA_TYPE_IMAGE,
    MEDIA_TYPE_VIDEO,
    MEDIA_TYPE_AUDIO,
    MEDIA_TYPE_DOCUMENT,
    MEDIA_TYPE_OTHER,
  ];

  static final $core.List<MediaType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static MediaType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MediaType._(super.value, super.name);
}

/// Upload status
class UploadStatus extends $pb.ProtobufEnum {
  static const UploadStatus UPLOAD_STATUS_UNKNOWN =
      UploadStatus._(0, _omitEnumNames ? '' : 'UPLOAD_STATUS_UNKNOWN');
  static const UploadStatus UPLOAD_STATUS_PENDING =
      UploadStatus._(1, _omitEnumNames ? '' : 'UPLOAD_STATUS_PENDING');
  static const UploadStatus UPLOAD_STATUS_PROCESSING =
      UploadStatus._(2, _omitEnumNames ? '' : 'UPLOAD_STATUS_PROCESSING');
  static const UploadStatus UPLOAD_STATUS_COMPLETED =
      UploadStatus._(3, _omitEnumNames ? '' : 'UPLOAD_STATUS_COMPLETED');
  static const UploadStatus UPLOAD_STATUS_FAILED =
      UploadStatus._(4, _omitEnumNames ? '' : 'UPLOAD_STATUS_FAILED');

  static const $core.List<UploadStatus> values = <UploadStatus>[
    UPLOAD_STATUS_UNKNOWN,
    UPLOAD_STATUS_PENDING,
    UPLOAD_STATUS_PROCESSING,
    UPLOAD_STATUS_COMPLETED,
    UPLOAD_STATUS_FAILED,
  ];

  static final $core.List<UploadStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static UploadStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UploadStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
