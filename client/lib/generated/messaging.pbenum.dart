// This is a generated file - do not edit.
//
// Generated from messaging.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class MessageType extends $pb.ProtobufEnum {
  static const MessageType TEXT =
      MessageType._(0, _omitEnumNames ? '' : 'TEXT');
  static const MessageType IMAGE =
      MessageType._(1, _omitEnumNames ? '' : 'IMAGE');
  static const MessageType VIDEO =
      MessageType._(2, _omitEnumNames ? '' : 'VIDEO');
  static const MessageType AUDIO =
      MessageType._(3, _omitEnumNames ? '' : 'AUDIO');
  static const MessageType FILE =
      MessageType._(4, _omitEnumNames ? '' : 'FILE');
  static const MessageType VOICE_NOTE =
      MessageType._(5, _omitEnumNames ? '' : 'VOICE_NOTE');
  static const MessageType LOCATION =
      MessageType._(6, _omitEnumNames ? '' : 'LOCATION');

  static const $core.List<MessageType> values = <MessageType>[
    TEXT,
    IMAGE,
    VIDEO,
    AUDIO,
    FILE,
    VOICE_NOTE,
    LOCATION,
  ];

  static final $core.List<MessageType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static MessageType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MessageType._(super.value, super.name);
}

class DeliveryStatus extends $pb.ProtobufEnum {
  static const DeliveryStatus PENDING =
      DeliveryStatus._(0, _omitEnumNames ? '' : 'PENDING');
  static const DeliveryStatus SENT =
      DeliveryStatus._(1, _omitEnumNames ? '' : 'SENT');
  static const DeliveryStatus DELIVERED =
      DeliveryStatus._(2, _omitEnumNames ? '' : 'DELIVERED');
  static const DeliveryStatus READ =
      DeliveryStatus._(3, _omitEnumNames ? '' : 'READ');
  static const DeliveryStatus FAILED =
      DeliveryStatus._(4, _omitEnumNames ? '' : 'FAILED');

  static const $core.List<DeliveryStatus> values = <DeliveryStatus>[
    PENDING,
    SENT,
    DELIVERED,
    READ,
    FAILED,
  ];

  static final $core.List<DeliveryStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static DeliveryStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DeliveryStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
