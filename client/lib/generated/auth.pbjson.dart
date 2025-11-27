// This is a generated file - do not edit.
//
// Generated from auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use registerRequestDescriptor instead')
const RegisterRequest$json = {
  '1': 'RegisterRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'device_name', '3': 4, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'device_type', '3': 5, '4': 1, '5': 9, '10': 'deviceType'},
    {
      '1': 'key_bundle',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.KeyBundle',
      '10': 'keyBundle'
    },
  ],
};

/// Descriptor for `RegisterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerRequestDescriptor = $convert.base64Decode(
    'Cg9SZWdpc3RlclJlcXVlc3QSGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1lEhoKCHBhc3N3b3'
    'JkGAIgASgJUghwYXNzd29yZBIUCgVlbWFpbBgDIAEoCVIFZW1haWwSHwoLZGV2aWNlX25hbWUY'
    'BCABKAlSCmRldmljZU5hbWUSHwoLZGV2aWNlX3R5cGUYBSABKAlSCmRldmljZVR5cGUSOAoKa2'
    'V5X2J1bmRsZRgGIAEoCzIZLmd1YXJkeW4uY29tbW9uLktleUJ1bmRsZVIJa2V5QnVuZGxl');

@$core.Deprecated('Use registerResponseDescriptor instead')
const RegisterResponse$json = {
  '1': 'RegisterResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.auth.RegisterSuccess',
      '9': 0,
      '10': 'success'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `RegisterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerResponseDescriptor = $convert.base64Decode(
    'ChBSZWdpc3RlclJlc3BvbnNlEjkKB3N1Y2Nlc3MYASABKAsyHS5ndWFyZHluLmF1dGguUmVnaX'
    'N0ZXJTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFyZHluLmNvbW1vbi5F'
    'cnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use registerSuccessDescriptor instead')
const RegisterSuccess$json = {
  '1': 'RegisterSuccess',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'access_token', '3': 3, '4': 1, '5': 9, '10': 'accessToken'},
    {
      '1': 'access_token_expires_in',
      '3': 4,
      '4': 1,
      '5': 13,
      '10': 'accessTokenExpiresIn'
    },
    {'1': 'refresh_token', '3': 5, '4': 1, '5': 9, '10': 'refreshToken'},
    {
      '1': 'refresh_token_expires_in',
      '3': 6,
      '4': 1,
      '5': 13,
      '10': 'refreshTokenExpiresIn'
    },
    {
      '1': 'created_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `RegisterSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerSuccessDescriptor = $convert.base64Decode(
    'Cg9SZWdpc3RlclN1Y2Nlc3MSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhsKCWRldmljZV9pZB'
    'gCIAEoCVIIZGV2aWNlSWQSIQoMYWNjZXNzX3Rva2VuGAMgASgJUgthY2Nlc3NUb2tlbhI1Chdh'
    'Y2Nlc3NfdG9rZW5fZXhwaXJlc19pbhgEIAEoDVIUYWNjZXNzVG9rZW5FeHBpcmVzSW4SIwoNcm'
    'VmcmVzaF90b2tlbhgFIAEoCVIMcmVmcmVzaFRva2VuEjcKGHJlZnJlc2hfdG9rZW5fZXhwaXJl'
    'c19pbhgGIAEoDVIVcmVmcmVzaFRva2VuRXhwaXJlc0luEjgKCmNyZWF0ZWRfYXQYByABKAsyGS'
    '5ndWFyZHluLmNvbW1vbi5UaW1lc3RhbXBSCWNyZWF0ZWRBdA==');

@$core.Deprecated('Use loginRequestDescriptor instead')
const LoginRequest$json = {
  '1': 'LoginRequest',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'device_id', '3': 3, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'device_name', '3': 4, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'device_type', '3': 5, '4': 1, '5': 9, '10': 'deviceType'},
    {
      '1': 'key_bundle',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.KeyBundle',
      '10': 'keyBundle'
    },
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlcXVlc3QSGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1lEhoKCHBhc3N3b3JkGA'
    'IgASgJUghwYXNzd29yZBIbCglkZXZpY2VfaWQYAyABKAlSCGRldmljZUlkEh8KC2RldmljZV9u'
    'YW1lGAQgASgJUgpkZXZpY2VOYW1lEh8KC2RldmljZV90eXBlGAUgASgJUgpkZXZpY2VUeXBlEj'
    'gKCmtleV9idW5kbGUYBiABKAsyGS5ndWFyZHluLmNvbW1vbi5LZXlCdW5kbGVSCWtleUJ1bmRs'
    'ZQ==');

@$core.Deprecated('Use loginResponseDescriptor instead')
const LoginResponse$json = {
  '1': 'LoginResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.auth.LoginSuccess',
      '9': 0,
      '10': 'success'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `LoginResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginResponseDescriptor = $convert.base64Decode(
    'Cg1Mb2dpblJlc3BvbnNlEjYKB3N1Y2Nlc3MYASABKAsyGi5ndWFyZHluLmF1dGguTG9naW5TdW'
    'NjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFyZHluLmNvbW1vbi5FcnJvclJl'
    'c3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use loginSuccessDescriptor instead')
const LoginSuccess$json = {
  '1': 'LoginSuccess',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'access_token', '3': 3, '4': 1, '5': 9, '10': 'accessToken'},
    {
      '1': 'access_token_expires_in',
      '3': 4,
      '4': 1,
      '5': 13,
      '10': 'accessTokenExpiresIn'
    },
    {'1': 'refresh_token', '3': 5, '4': 1, '5': 9, '10': 'refreshToken'},
    {
      '1': 'refresh_token_expires_in',
      '3': 6,
      '4': 1,
      '5': 13,
      '10': 'refreshTokenExpiresIn'
    },
    {
      '1': 'profile',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.guardyn.auth.UserProfile',
      '10': 'profile'
    },
    {
      '1': 'devices',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.guardyn.auth.DeviceInfo',
      '10': 'devices'
    },
  ],
};

/// Descriptor for `LoginSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginSuccessDescriptor = $convert.base64Decode(
    'CgxMb2dpblN1Y2Nlc3MSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhsKCWRldmljZV9pZBgCIA'
    'EoCVIIZGV2aWNlSWQSIQoMYWNjZXNzX3Rva2VuGAMgASgJUgthY2Nlc3NUb2tlbhI1ChdhY2Nl'
    'c3NfdG9rZW5fZXhwaXJlc19pbhgEIAEoDVIUYWNjZXNzVG9rZW5FeHBpcmVzSW4SIwoNcmVmcm'
    'VzaF90b2tlbhgFIAEoCVIMcmVmcmVzaFRva2VuEjcKGHJlZnJlc2hfdG9rZW5fZXhwaXJlc19p'
    'bhgGIAEoDVIVcmVmcmVzaFRva2VuRXhwaXJlc0luEjMKB3Byb2ZpbGUYByABKAsyGS5ndWFyZH'
    'luLmF1dGguVXNlclByb2ZpbGVSB3Byb2ZpbGUSMgoHZGV2aWNlcxgIIAMoCzIYLmd1YXJkeW4u'
    'YXV0aC5EZXZpY2VJbmZvUgdkZXZpY2Vz');

@$core.Deprecated('Use userProfileDescriptor instead')
const UserProfile$json = {
  '1': 'UserProfile',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'last_seen',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'lastSeen'
    },
  ],
};

/// Descriptor for `UserProfile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userProfileDescriptor = $convert.base64Decode(
    'CgtVc2VyUHJvZmlsZRIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGgoIdXNlcm5hbWUYAiABKA'
    'lSCHVzZXJuYW1lEhQKBWVtYWlsGAMgASgJUgVlbWFpbBI4CgpjcmVhdGVkX2F0GAQgASgLMhku'
    'Z3VhcmR5bi5jb21tb24uVGltZXN0YW1wUgljcmVhdGVkQXQSNgoJbGFzdF9zZWVuGAUgASgLMh'
    'kuZ3VhcmR5bi5jb21tb24uVGltZXN0YW1wUghsYXN0U2Vlbg==');

@$core.Deprecated('Use deviceInfoDescriptor instead')
const DeviceInfo$json = {
  '1': 'DeviceInfo',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'device_name', '3': 2, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'device_type', '3': 3, '4': 1, '5': 9, '10': 'deviceType'},
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'last_seen',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'lastSeen'
    },
    {'1': 'is_current', '3': 6, '4': 1, '5': 8, '10': 'isCurrent'},
  ],
};

/// Descriptor for `DeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceInfoDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VJbmZvEhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQSHwoLZGV2aWNlX25hbW'
    'UYAiABKAlSCmRldmljZU5hbWUSHwoLZGV2aWNlX3R5cGUYAyABKAlSCmRldmljZVR5cGUSOAoK'
    'Y3JlYXRlZF9hdBgEIAEoCzIZLmd1YXJkeW4uY29tbW9uLlRpbWVzdGFtcFIJY3JlYXRlZEF0Ej'
    'YKCWxhc3Rfc2VlbhgFIAEoCzIZLmd1YXJkeW4uY29tbW9uLlRpbWVzdGFtcFIIbGFzdFNlZW4S'
    'HQoKaXNfY3VycmVudBgGIAEoCFIJaXNDdXJyZW50');

@$core.Deprecated('Use logoutRequestDescriptor instead')
const LogoutRequest$json = {
  '1': 'LogoutRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'all_devices', '3': 2, '4': 1, '5': 8, '10': 'allDevices'},
  ],
};

/// Descriptor for `LogoutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logoutRequestDescriptor = $convert.base64Decode(
    'Cg1Mb2dvdXRSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW4SHwoLYW'
    'xsX2RldmljZXMYAiABKAhSCmFsbERldmljZXM=');

@$core.Deprecated('Use logoutResponseDescriptor instead')
const LogoutResponse$json = {
  '1': 'LogoutResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.auth.LogoutSuccess',
      '9': 0,
      '10': 'success'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `LogoutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logoutResponseDescriptor = $convert.base64Decode(
    'Cg5Mb2dvdXRSZXNwb25zZRI3CgdzdWNjZXNzGAEgASgLMhsuZ3VhcmR5bi5hdXRoLkxvZ291dF'
    'N1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJkeW4uY29tbW9uLkVycm9y'
    'UmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use logoutSuccessDescriptor instead')
const LogoutSuccess$json = {
  '1': 'LogoutSuccess',
  '2': [
    {
      '1': 'sessions_invalidated',
      '3': 1,
      '4': 1,
      '5': 13,
      '10': 'sessionsInvalidated'
    },
  ],
};

/// Descriptor for `LogoutSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logoutSuccessDescriptor = $convert.base64Decode(
    'Cg1Mb2dvdXRTdWNjZXNzEjEKFHNlc3Npb25zX2ludmFsaWRhdGVkGAEgASgNUhNzZXNzaW9uc0'
    'ludmFsaWRhdGVk');

@$core.Deprecated('Use refreshTokenRequestDescriptor instead')
const RefreshTokenRequest$json = {
  '1': 'RefreshTokenRequest',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '10': 'refreshToken'},
  ],
};

/// Descriptor for `RefreshTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokenRequestDescriptor = $convert.base64Decode(
    'ChNSZWZyZXNoVG9rZW5SZXF1ZXN0EiMKDXJlZnJlc2hfdG9rZW4YASABKAlSDHJlZnJlc2hUb2'
    'tlbg==');

@$core.Deprecated('Use refreshTokenResponseDescriptor instead')
const RefreshTokenResponse$json = {
  '1': 'RefreshTokenResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.auth.RefreshTokenSuccess',
      '9': 0,
      '10': 'success'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `RefreshTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokenResponseDescriptor = $convert.base64Decode(
    'ChRSZWZyZXNoVG9rZW5SZXNwb25zZRI9CgdzdWNjZXNzGAEgASgLMiEuZ3VhcmR5bi5hdXRoLl'
    'JlZnJlc2hUb2tlblN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJkeW4u'
    'Y29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use refreshTokenSuccessDescriptor instead')
const RefreshTokenSuccess$json = {
  '1': 'RefreshTokenSuccess',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {
      '1': 'access_token_expires_in',
      '3': 2,
      '4': 1,
      '5': 13,
      '10': 'accessTokenExpiresIn'
    },
    {'1': 'refresh_token', '3': 3, '4': 1, '5': 9, '10': 'refreshToken'},
  ],
};

/// Descriptor for `RefreshTokenSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokenSuccessDescriptor = $convert.base64Decode(
    'ChNSZWZyZXNoVG9rZW5TdWNjZXNzEiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW'
    '4SNQoXYWNjZXNzX3Rva2VuX2V4cGlyZXNfaW4YAiABKA1SFGFjY2Vzc1Rva2VuRXhwaXJlc0lu'
    'EiMKDXJlZnJlc2hfdG9rZW4YAyABKAlSDHJlZnJlc2hUb2tlbg==');

@$core.Deprecated('Use validateTokenRequestDescriptor instead')
const ValidateTokenRequest$json = {
  '1': 'ValidateTokenRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
  ],
};

/// Descriptor for `ValidateTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateTokenRequestDescriptor = $convert.base64Decode(
    'ChRWYWxpZGF0ZVRva2VuUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2'
    'Vu');

@$core.Deprecated('Use validateTokenResponseDescriptor instead')
const ValidateTokenResponse$json = {
  '1': 'ValidateTokenResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.auth.ValidateTokenSuccess',
      '9': 0,
      '10': 'success'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `ValidateTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateTokenResponseDescriptor = $convert.base64Decode(
    'ChVWYWxpZGF0ZVRva2VuUmVzcG9uc2USPgoHc3VjY2VzcxgBIAEoCzIiLmd1YXJkeW4uYXV0aC'
    '5WYWxpZGF0ZVRva2VuU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0uZ3VhcmR5'
    'bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use validateTokenSuccessDescriptor instead')
const ValidateTokenSuccess$json = {
  '1': 'ValidateTokenSuccess',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {
      '1': 'expires_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'expiresAt'
    },
    {'1': 'permissions', '3': 4, '4': 3, '5': 9, '10': 'permissions'},
  ],
};

/// Descriptor for `ValidateTokenSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateTokenSuccessDescriptor = $convert.base64Decode(
    'ChRWYWxpZGF0ZVRva2VuU3VjY2VzcxIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGwoJZGV2aW'
    'NlX2lkGAIgASgJUghkZXZpY2VJZBI4CgpleHBpcmVzX2F0GAMgASgLMhkuZ3VhcmR5bi5jb21t'
    'b24uVGltZXN0YW1wUglleHBpcmVzQXQSIAoLcGVybWlzc2lvbnMYBCADKAlSC3Blcm1pc3Npb2'
    '5z');

@$core.Deprecated('Use getKeyBundleRequestDescriptor instead')
const GetKeyBundleRequest$json = {
  '1': 'GetKeyBundleRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `GetKeyBundleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getKeyBundleRequestDescriptor = $convert.base64Decode(
    'ChNHZXRLZXlCdW5kbGVSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIbCglkZXZpY2'
    'VfaWQYAiABKAlSCGRldmljZUlk');

@$core.Deprecated('Use getKeyBundleResponseDescriptor instead')
const GetKeyBundleResponse$json = {
  '1': 'GetKeyBundleResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.auth.GetKeyBundleSuccess',
      '9': 0,
      '10': 'success'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `GetKeyBundleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getKeyBundleResponseDescriptor = $convert.base64Decode(
    'ChRHZXRLZXlCdW5kbGVSZXNwb25zZRI9CgdzdWNjZXNzGAEgASgLMiEuZ3VhcmR5bi5hdXRoLk'
    'dldEtleUJ1bmRsZVN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJkeW4u'
    'Y29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use getKeyBundleSuccessDescriptor instead')
const GetKeyBundleSuccess$json = {
  '1': 'GetKeyBundleSuccess',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {
      '1': 'key_bundle',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.KeyBundle',
      '10': 'keyBundle'
    },
  ],
};

/// Descriptor for `GetKeyBundleSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getKeyBundleSuccessDescriptor = $convert.base64Decode(
    'ChNHZXRLZXlCdW5kbGVTdWNjZXNzEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIbCglkZXZpY2'
    'VfaWQYAiABKAlSCGRldmljZUlkEjgKCmtleV9idW5kbGUYAyABKAsyGS5ndWFyZHluLmNvbW1v'
    'bi5LZXlCdW5kbGVSCWtleUJ1bmRsZQ==');

@$core.Deprecated('Use uploadPreKeysRequestDescriptor instead')
const UploadPreKeysRequest$json = {
  '1': 'UploadPreKeysRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'one_time_pre_keys', '3': 2, '4': 3, '5': 12, '10': 'oneTimePreKeys'},
  ],
};

/// Descriptor for `UploadPreKeysRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadPreKeysRequestDescriptor = $convert.base64Decode(
    'ChRVcGxvYWRQcmVLZXlzUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2'
    'VuEikKEW9uZV90aW1lX3ByZV9rZXlzGAIgAygMUg5vbmVUaW1lUHJlS2V5cw==');

@$core.Deprecated('Use uploadPreKeysResponseDescriptor instead')
const UploadPreKeysResponse$json = {
  '1': 'UploadPreKeysResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.auth.UploadPreKeysSuccess',
      '9': 0,
      '10': 'success'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `UploadPreKeysResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadPreKeysResponseDescriptor = $convert.base64Decode(
    'ChVVcGxvYWRQcmVLZXlzUmVzcG9uc2USPgoHc3VjY2VzcxgBIAEoCzIiLmd1YXJkeW4uYXV0aC'
    '5VcGxvYWRQcmVLZXlzU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0uZ3VhcmR5'
    'bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use uploadPreKeysSuccessDescriptor instead')
const UploadPreKeysSuccess$json = {
  '1': 'UploadPreKeysSuccess',
  '2': [
    {'1': 'keys_uploaded', '3': 1, '4': 1, '5': 13, '10': 'keysUploaded'},
    {
      '1': 'total_keys_available',
      '3': 2,
      '4': 1,
      '5': 13,
      '10': 'totalKeysAvailable'
    },
  ],
};

/// Descriptor for `UploadPreKeysSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadPreKeysSuccessDescriptor = $convert.base64Decode(
    'ChRVcGxvYWRQcmVLZXlzU3VjY2VzcxIjCg1rZXlzX3VwbG9hZGVkGAEgASgNUgxrZXlzVXBsb2'
    'FkZWQSMAoUdG90YWxfa2V5c19hdmFpbGFibGUYAiABKA1SEnRvdGFsS2V5c0F2YWlsYWJsZQ==');

@$core.Deprecated('Use uploadMlsKeyPackageRequestDescriptor instead')
const UploadMlsKeyPackageRequest$json = {
  '1': 'UploadMlsKeyPackageRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'key_package', '3': 2, '4': 1, '5': 12, '10': 'keyPackage'},
  ],
};

/// Descriptor for `UploadMlsKeyPackageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadMlsKeyPackageRequestDescriptor =
    $convert.base64Decode(
        'ChpVcGxvYWRNbHNLZXlQYWNrYWdlUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2'
        'Vzc1Rva2VuEh8KC2tleV9wYWNrYWdlGAIgASgMUgprZXlQYWNrYWdl');

@$core.Deprecated('Use uploadMlsKeyPackageResponseDescriptor instead')
const UploadMlsKeyPackageResponse$json = {
  '1': 'UploadMlsKeyPackageResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.auth.UploadMlsKeyPackageSuccess',
      '9': 0,
      '10': 'success'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `UploadMlsKeyPackageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadMlsKeyPackageResponseDescriptor = $convert.base64Decode(
    'ChtVcGxvYWRNbHNLZXlQYWNrYWdlUmVzcG9uc2USRAoHc3VjY2VzcxgBIAEoCzIoLmd1YXJkeW'
    '4uYXV0aC5VcGxvYWRNbHNLZXlQYWNrYWdlU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIg'
    'ASgLMh0uZ3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use uploadMlsKeyPackageSuccessDescriptor instead')
const UploadMlsKeyPackageSuccess$json = {
  '1': 'UploadMlsKeyPackageSuccess',
  '2': [
    {'1': 'package_id', '3': 1, '4': 1, '5': 9, '10': 'packageId'},
    {
      '1': 'uploaded_at',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'uploadedAt'
    },
  ],
};

/// Descriptor for `UploadMlsKeyPackageSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadMlsKeyPackageSuccessDescriptor =
    $convert.base64Decode(
        'ChpVcGxvYWRNbHNLZXlQYWNrYWdlU3VjY2VzcxIdCgpwYWNrYWdlX2lkGAEgASgJUglwYWNrYW'
        'dlSWQSOgoLdXBsb2FkZWRfYXQYAiABKAsyGS5ndWFyZHluLmNvbW1vbi5UaW1lc3RhbXBSCnVw'
        'bG9hZGVkQXQ=');

@$core.Deprecated('Use getMlsKeyPackageRequestDescriptor instead')
const GetMlsKeyPackageRequest$json = {
  '1': 'GetMlsKeyPackageRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `GetMlsKeyPackageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMlsKeyPackageRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRNbHNLZXlQYWNrYWdlUmVxdWVzdBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGwoJZG'
        'V2aWNlX2lkGAIgASgJUghkZXZpY2VJZA==');

@$core.Deprecated('Use getMlsKeyPackageResponseDescriptor instead')
const GetMlsKeyPackageResponse$json = {
  '1': 'GetMlsKeyPackageResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.auth.GetMlsKeyPackageSuccess',
      '9': 0,
      '10': 'success'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `GetMlsKeyPackageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMlsKeyPackageResponseDescriptor = $convert.base64Decode(
    'ChhHZXRNbHNLZXlQYWNrYWdlUmVzcG9uc2USQQoHc3VjY2VzcxgBIAEoCzIlLmd1YXJkeW4uYX'
    'V0aC5HZXRNbHNLZXlQYWNrYWdlU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0u'
    'Z3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use getMlsKeyPackageSuccessDescriptor instead')
const GetMlsKeyPackageSuccess$json = {
  '1': 'GetMlsKeyPackageSuccess',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'key_package', '3': 3, '4': 1, '5': 12, '10': 'keyPackage'},
    {'1': 'package_id', '3': 4, '4': 1, '5': 9, '10': 'packageId'},
  ],
};

/// Descriptor for `GetMlsKeyPackageSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMlsKeyPackageSuccessDescriptor = $convert.base64Decode(
    'ChdHZXRNbHNLZXlQYWNrYWdlU3VjY2VzcxIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGwoJZG'
    'V2aWNlX2lkGAIgASgJUghkZXZpY2VJZBIfCgtrZXlfcGFja2FnZRgDIAEoDFIKa2V5UGFja2Fn'
    'ZRIdCgpwYWNrYWdlX2lkGAQgASgJUglwYWNrYWdlSWQ=');

@$core.Deprecated('Use searchUsersRequestDescriptor instead')
const SearchUsersRequest$json = {
  '1': 'SearchUsersRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'query', '3': 2, '4': 1, '5': 9, '10': 'query'},
    {'1': 'limit', '3': 3, '4': 1, '5': 13, '10': 'limit'},
  ],
};

/// Descriptor for `SearchUsersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUsersRequestDescriptor = $convert.base64Decode(
    'ChJTZWFyY2hVc2Vyc1JlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbh'
    'IUCgVxdWVyeRgCIAEoCVIFcXVlcnkSFAoFbGltaXQYAyABKA1SBWxpbWl0');

@$core.Deprecated('Use searchUsersResponseDescriptor instead')
const SearchUsersResponse$json = {
  '1': 'SearchUsersResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.auth.SearchUsersSuccess',
      '9': 0,
      '10': 'success'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `SearchUsersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUsersResponseDescriptor = $convert.base64Decode(
    'ChNTZWFyY2hVc2Vyc1Jlc3BvbnNlEjwKB3N1Y2Nlc3MYASABKAsyIC5ndWFyZHluLmF1dGguU2'
    'VhcmNoVXNlcnNTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFyZHluLmNv'
    'bW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use searchUsersSuccessDescriptor instead')
const SearchUsersSuccess$json = {
  '1': 'SearchUsersSuccess',
  '2': [
    {
      '1': 'users',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.guardyn.auth.UserSearchResult',
      '10': 'users'
    },
  ],
};

/// Descriptor for `SearchUsersSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchUsersSuccessDescriptor = $convert.base64Decode(
    'ChJTZWFyY2hVc2Vyc1N1Y2Nlc3MSNAoFdXNlcnMYASADKAsyHi5ndWFyZHluLmF1dGguVXNlcl'
    'NlYXJjaFJlc3VsdFIFdXNlcnM=');

@$core.Deprecated('Use userSearchResultDescriptor instead')
const UserSearchResult$json = {
  '1': 'UserSearchResult',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {
      '1': 'created_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `UserSearchResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userSearchResultDescriptor = $convert.base64Decode(
    'ChBVc2VyU2VhcmNoUmVzdWx0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIaCgh1c2VybmFtZR'
    'gCIAEoCVIIdXNlcm5hbWUSOAoKY3JlYXRlZF9hdBgDIAEoCzIZLmd1YXJkeW4uY29tbW9uLlRp'
    'bWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use getUserProfileRequestDescriptor instead')
const GetUserProfileRequest$json = {
  '1': 'GetUserProfileRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetUserProfileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserProfileRequestDescriptor =
    $convert.base64Decode(
        'ChVHZXRVc2VyUHJvZmlsZVJlcXVlc3QSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklk');

@$core.Deprecated('Use getUserProfileResponseDescriptor instead')
const GetUserProfileResponse$json = {
  '1': 'GetUserProfileResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.auth.UserProfile',
      '9': 0,
      '10': 'success'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `GetUserProfileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUserProfileResponseDescriptor = $convert.base64Decode(
    'ChZHZXRVc2VyUHJvZmlsZVJlc3BvbnNlEjUKB3N1Y2Nlc3MYASABKAsyGS5ndWFyZHluLmF1dG'
    'guVXNlclByb2ZpbGVIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJkeW4uY29tbW9u'
    'LkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use healthRequestDescriptor instead')
const HealthRequest$json = {
  '1': 'HealthRequest',
};

/// Descriptor for `HealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthRequestDescriptor =
    $convert.base64Decode('Cg1IZWFsdGhSZXF1ZXN0');
