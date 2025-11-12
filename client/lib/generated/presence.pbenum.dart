// This is a generated file - do not edit.
//
// Generated from presence.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class UserStatus extends $pb.ProtobufEnum {
  static const UserStatus OFFLINE =
      UserStatus._(0, _omitEnumNames ? '' : 'OFFLINE');
  static const UserStatus ONLINE =
      UserStatus._(1, _omitEnumNames ? '' : 'ONLINE');
  static const UserStatus AWAY = UserStatus._(2, _omitEnumNames ? '' : 'AWAY');
  static const UserStatus DO_NOT_DISTURB =
      UserStatus._(3, _omitEnumNames ? '' : 'DO_NOT_DISTURB');
  static const UserStatus INVISIBLE =
      UserStatus._(4, _omitEnumNames ? '' : 'INVISIBLE');

  static const $core.List<UserStatus> values = <UserStatus>[
    OFFLINE,
    ONLINE,
    AWAY,
    DO_NOT_DISTURB,
    INVISIBLE,
  ];

  static final $core.List<UserStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static UserStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UserStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
