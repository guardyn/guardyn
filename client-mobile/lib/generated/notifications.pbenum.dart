// This is a generated file - do not edit.
//
// Generated from notifications.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class PushPlatform extends $pb.ProtobufEnum {
  static const PushPlatform UNKNOWN_PLATFORM =
      PushPlatform._(0, _omitEnumNames ? '' : 'UNKNOWN_PLATFORM');
  static const PushPlatform FCM =
      PushPlatform._(1, _omitEnumNames ? '' : 'FCM');
  static const PushPlatform APNS =
      PushPlatform._(2, _omitEnumNames ? '' : 'APNS');
  static const PushPlatform APNS_SANDBOX =
      PushPlatform._(3, _omitEnumNames ? '' : 'APNS_SANDBOX');
  static const PushPlatform WEB_PUSH =
      PushPlatform._(4, _omitEnumNames ? '' : 'WEB_PUSH');

  static const $core.List<PushPlatform> values = <PushPlatform>[
    UNKNOWN_PLATFORM,
    FCM,
    APNS,
    APNS_SANDBOX,
    WEB_PUSH,
  ];

  static final $core.List<PushPlatform?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static PushPlatform? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PushPlatform._(super.value, super.name);
}

class MuteDuration extends $pb.ProtobufEnum {
  static const MuteDuration UNMUTE =
      MuteDuration._(0, _omitEnumNames ? '' : 'UNMUTE');
  static const MuteDuration ONE_HOUR =
      MuteDuration._(1, _omitEnumNames ? '' : 'ONE_HOUR');
  static const MuteDuration EIGHT_HOURS =
      MuteDuration._(2, _omitEnumNames ? '' : 'EIGHT_HOURS');
  static const MuteDuration ONE_DAY =
      MuteDuration._(3, _omitEnumNames ? '' : 'ONE_DAY');
  static const MuteDuration SEVEN_DAYS =
      MuteDuration._(4, _omitEnumNames ? '' : 'SEVEN_DAYS');
  static const MuteDuration FOREVER =
      MuteDuration._(5, _omitEnumNames ? '' : 'FOREVER');

  static const $core.List<MuteDuration> values = <MuteDuration>[
    UNMUTE,
    ONE_HOUR,
    EIGHT_HOURS,
    ONE_DAY,
    SEVEN_DAYS,
    FOREVER,
  ];

  static final $core.List<MuteDuration?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static MuteDuration? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MuteDuration._(super.value, super.name);
}

class NotificationType extends $pb.ProtobufEnum {
  static const NotificationType UNKNOWN_TYPE =
      NotificationType._(0, _omitEnumNames ? '' : 'UNKNOWN_TYPE');
  static const NotificationType NEW_MESSAGE =
      NotificationType._(1, _omitEnumNames ? '' : 'NEW_MESSAGE');
  static const NotificationType NEW_REACTION =
      NotificationType._(2, _omitEnumNames ? '' : 'NEW_REACTION');
  static const NotificationType MENTION =
      NotificationType._(3, _omitEnumNames ? '' : 'MENTION');
  static const NotificationType INCOMING_CALL =
      NotificationType._(4, _omitEnumNames ? '' : 'INCOMING_CALL');
  static const NotificationType MISSED_CALL =
      NotificationType._(5, _omitEnumNames ? '' : 'MISSED_CALL');
  static const NotificationType GROUP_INVITE =
      NotificationType._(6, _omitEnumNames ? '' : 'GROUP_INVITE');
  static const NotificationType GROUP_UPDATE =
      NotificationType._(7, _omitEnumNames ? '' : 'GROUP_UPDATE');

  static const $core.List<NotificationType> values = <NotificationType>[
    UNKNOWN_TYPE,
    NEW_MESSAGE,
    NEW_REACTION,
    MENTION,
    INCOMING_CALL,
    MISSED_CALL,
    GROUP_INVITE,
    GROUP_UPDATE,
  ];

  static final $core.List<NotificationType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static NotificationType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NotificationType._(super.value, super.name);
}

class NotificationPriority extends $pb.ProtobufEnum {
  static const NotificationPriority NORMAL =
      NotificationPriority._(0, _omitEnumNames ? '' : 'NORMAL');
  static const NotificationPriority HIGH =
      NotificationPriority._(1, _omitEnumNames ? '' : 'HIGH');

  static const $core.List<NotificationPriority> values = <NotificationPriority>[
    NORMAL,
    HIGH,
  ];

  static final $core.List<NotificationPriority?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static NotificationPriority? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NotificationPriority._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
