// This is a generated file - do not edit.
//
// Generated from common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ErrorResponse_ErrorCode extends $pb.ProtobufEnum {
  static const ErrorResponse_ErrorCode UNKNOWN =
      ErrorResponse_ErrorCode._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const ErrorResponse_ErrorCode INVALID_REQUEST =
      ErrorResponse_ErrorCode._(1, _omitEnumNames ? '' : 'INVALID_REQUEST');
  static const ErrorResponse_ErrorCode UNAUTHORIZED =
      ErrorResponse_ErrorCode._(2, _omitEnumNames ? '' : 'UNAUTHORIZED');
  static const ErrorResponse_ErrorCode FORBIDDEN =
      ErrorResponse_ErrorCode._(3, _omitEnumNames ? '' : 'FORBIDDEN');
  static const ErrorResponse_ErrorCode NOT_FOUND =
      ErrorResponse_ErrorCode._(4, _omitEnumNames ? '' : 'NOT_FOUND');
  static const ErrorResponse_ErrorCode CONFLICT =
      ErrorResponse_ErrorCode._(5, _omitEnumNames ? '' : 'CONFLICT');
  static const ErrorResponse_ErrorCode INTERNAL_ERROR =
      ErrorResponse_ErrorCode._(6, _omitEnumNames ? '' : 'INTERNAL_ERROR');
  static const ErrorResponse_ErrorCode SERVICE_UNAVAILABLE =
      ErrorResponse_ErrorCode._(7, _omitEnumNames ? '' : 'SERVICE_UNAVAILABLE');
  static const ErrorResponse_ErrorCode RATE_LIMITED =
      ErrorResponse_ErrorCode._(8, _omitEnumNames ? '' : 'RATE_LIMITED');

  static const $core.List<ErrorResponse_ErrorCode> values =
      <ErrorResponse_ErrorCode>[
    UNKNOWN,
    INVALID_REQUEST,
    UNAUTHORIZED,
    FORBIDDEN,
    NOT_FOUND,
    CONFLICT,
    INTERNAL_ERROR,
    SERVICE_UNAVAILABLE,
    RATE_LIMITED,
  ];

  static final $core.List<ErrorResponse_ErrorCode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static ErrorResponse_ErrorCode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ErrorResponse_ErrorCode._(super.value, super.name);
}

class HealthStatus_Status extends $pb.ProtobufEnum {
  static const HealthStatus_Status UNKNOWN =
      HealthStatus_Status._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const HealthStatus_Status HEALTHY =
      HealthStatus_Status._(1, _omitEnumNames ? '' : 'HEALTHY');
  static const HealthStatus_Status DEGRADED =
      HealthStatus_Status._(2, _omitEnumNames ? '' : 'DEGRADED');
  static const HealthStatus_Status UNHEALTHY =
      HealthStatus_Status._(3, _omitEnumNames ? '' : 'UNHEALTHY');

  static const $core.List<HealthStatus_Status> values = <HealthStatus_Status>[
    UNKNOWN,
    HEALTHY,
    DEGRADED,
    UNHEALTHY,
  ];

  static final $core.List<HealthStatus_Status?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static HealthStatus_Status? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const HealthStatus_Status._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
