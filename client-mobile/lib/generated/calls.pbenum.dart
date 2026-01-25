// This is a generated file - do not edit.
//
// Generated from calls.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class CallType extends $pb.ProtobufEnum {
  static const CallType UNKNOWN_CALL_TYPE =
      CallType._(0, _omitEnumNames ? '' : 'UNKNOWN_CALL_TYPE');
  static const CallType VOICE = CallType._(1, _omitEnumNames ? '' : 'VOICE');
  static const CallType VIDEO = CallType._(2, _omitEnumNames ? '' : 'VIDEO');

  static const $core.List<CallType> values = <CallType>[
    UNKNOWN_CALL_TYPE,
    VOICE,
    VIDEO,
  ];

  static final $core.List<CallType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static CallType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CallType._(super.value, super.name);
}

class CallState extends $pb.ProtobufEnum {
  static const CallState UNKNOWN_STATE =
      CallState._(0, _omitEnumNames ? '' : 'UNKNOWN_STATE');
  static const CallState INITIATING =
      CallState._(1, _omitEnumNames ? '' : 'INITIATING');
  static const CallState RINGING =
      CallState._(2, _omitEnumNames ? '' : 'RINGING');
  static const CallState CONNECTING =
      CallState._(3, _omitEnumNames ? '' : 'CONNECTING');
  static const CallState CONNECTED =
      CallState._(4, _omitEnumNames ? '' : 'CONNECTED');
  static const CallState ON_HOLD =
      CallState._(5, _omitEnumNames ? '' : 'ON_HOLD');
  static const CallState ENDED = CallState._(6, _omitEnumNames ? '' : 'ENDED');
  static const CallState FAILED =
      CallState._(7, _omitEnumNames ? '' : 'FAILED');

  static const $core.List<CallState> values = <CallState>[
    UNKNOWN_STATE,
    INITIATING,
    RINGING,
    CONNECTING,
    CONNECTED,
    ON_HOLD,
    ENDED,
    FAILED,
  ];

  static final $core.List<CallState?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static CallState? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CallState._(super.value, super.name);
}

class CallEndReason extends $pb.ProtobufEnum {
  static const CallEndReason UNKNOWN_REASON =
      CallEndReason._(0, _omitEnumNames ? '' : 'UNKNOWN_REASON');
  static const CallEndReason COMPLETED =
      CallEndReason._(1, _omitEnumNames ? '' : 'COMPLETED');
  static const CallEndReason DECLINED =
      CallEndReason._(2, _omitEnumNames ? '' : 'DECLINED');
  static const CallEndReason MISSED =
      CallEndReason._(3, _omitEnumNames ? '' : 'MISSED');
  static const CallEndReason BUSY =
      CallEndReason._(4, _omitEnumNames ? '' : 'BUSY');
  static const CallEndReason FAILED_CONNECTION =
      CallEndReason._(5, _omitEnumNames ? '' : 'FAILED_CONNECTION');
  static const CallEndReason CANCELLED =
      CallEndReason._(6, _omitEnumNames ? '' : 'CANCELLED');

  static const $core.List<CallEndReason> values = <CallEndReason>[
    UNKNOWN_REASON,
    COMPLETED,
    DECLINED,
    MISSED,
    BUSY,
    FAILED_CONNECTION,
    CANCELLED,
  ];

  static final $core.List<CallEndReason?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static CallEndReason? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CallEndReason._(super.value, super.name);
}

class SdpType extends $pb.ProtobufEnum {
  static const SdpType UNKNOWN_SDP_TYPE =
      SdpType._(0, _omitEnumNames ? '' : 'UNKNOWN_SDP_TYPE');
  static const SdpType OFFER = SdpType._(1, _omitEnumNames ? '' : 'OFFER');
  static const SdpType ANSWER = SdpType._(2, _omitEnumNames ? '' : 'ANSWER');
  static const SdpType PRANSWER =
      SdpType._(3, _omitEnumNames ? '' : 'PRANSWER');
  static const SdpType ROLLBACK =
      SdpType._(4, _omitEnumNames ? '' : 'ROLLBACK');

  static const $core.List<SdpType> values = <SdpType>[
    UNKNOWN_SDP_TYPE,
    OFFER,
    ANSWER,
    PRANSWER,
    ROLLBACK,
  ];

  static final $core.List<SdpType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static SdpType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SdpType._(super.value, super.name);
}

class CallQuality extends $pb.ProtobufEnum {
  static const CallQuality UNKNOWN_QUALITY =
      CallQuality._(0, _omitEnumNames ? '' : 'UNKNOWN_QUALITY');
  static const CallQuality EXCELLENT =
      CallQuality._(1, _omitEnumNames ? '' : 'EXCELLENT');
  static const CallQuality GOOD =
      CallQuality._(2, _omitEnumNames ? '' : 'GOOD');
  static const CallQuality FAIR =
      CallQuality._(3, _omitEnumNames ? '' : 'FAIR');
  static const CallQuality POOR =
      CallQuality._(4, _omitEnumNames ? '' : 'POOR');

  static const $core.List<CallQuality> values = <CallQuality>[
    UNKNOWN_QUALITY,
    EXCELLENT,
    GOOD,
    FAIR,
    POOR,
  ];

  static final $core.List<CallQuality?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static CallQuality? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CallQuality._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
