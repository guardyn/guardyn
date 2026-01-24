// This is a generated file - do not edit.
//
// Generated from notifications.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use pushPlatformDescriptor instead')
const PushPlatform$json = {
  '1': 'PushPlatform',
  '2': [
    {'1': 'UNKNOWN_PLATFORM', '2': 0},
    {'1': 'FCM', '2': 1},
    {'1': 'APNS', '2': 2},
    {'1': 'APNS_SANDBOX', '2': 3},
    {'1': 'WEB_PUSH', '2': 4},
  ],
};

/// Descriptor for `PushPlatform`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List pushPlatformDescriptor = $convert.base64Decode(
    'CgxQdXNoUGxhdGZvcm0SFAoQVU5LTk9XTl9QTEFURk9STRAAEgcKA0ZDTRABEggKBEFQTlMQAh'
    'IQCgxBUE5TX1NBTkRCT1gQAxIMCghXRUJfUFVTSBAE');

@$core.Deprecated('Use muteDurationDescriptor instead')
const MuteDuration$json = {
  '1': 'MuteDuration',
  '2': [
    {'1': 'UNMUTE', '2': 0},
    {'1': 'ONE_HOUR', '2': 1},
    {'1': 'EIGHT_HOURS', '2': 2},
    {'1': 'ONE_DAY', '2': 3},
    {'1': 'SEVEN_DAYS', '2': 4},
    {'1': 'FOREVER', '2': 5},
  ],
};

/// Descriptor for `MuteDuration`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List muteDurationDescriptor = $convert.base64Decode(
    'CgxNdXRlRHVyYXRpb24SCgoGVU5NVVRFEAASDAoIT05FX0hPVVIQARIPCgtFSUdIVF9IT1VSUx'
    'ACEgsKB09ORV9EQVkQAxIOCgpTRVZFTl9EQVlTEAQSCwoHRk9SRVZFUhAF');

@$core.Deprecated('Use notificationTypeDescriptor instead')
const NotificationType$json = {
  '1': 'NotificationType',
  '2': [
    {'1': 'UNKNOWN_TYPE', '2': 0},
    {'1': 'NEW_MESSAGE', '2': 1},
    {'1': 'NEW_REACTION', '2': 2},
    {'1': 'MENTION', '2': 3},
    {'1': 'INCOMING_CALL', '2': 4},
    {'1': 'MISSED_CALL', '2': 5},
    {'1': 'GROUP_INVITE', '2': 6},
    {'1': 'GROUP_UPDATE', '2': 7},
  ],
};

/// Descriptor for `NotificationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List notificationTypeDescriptor = $convert.base64Decode(
    'ChBOb3RpZmljYXRpb25UeXBlEhAKDFVOS05PV05fVFlQRRAAEg8KC05FV19NRVNTQUdFEAESEA'
    'oMTkVXX1JFQUNUSU9OEAISCwoHTUVOVElPThADEhEKDUlOQ09NSU5HX0NBTEwQBBIPCgtNSVNT'
    'RURfQ0FMTBAFEhAKDEdST1VQX0lOVklURRAGEhAKDEdST1VQX1VQREFURRAH');

@$core.Deprecated('Use notificationPriorityDescriptor instead')
const NotificationPriority$json = {
  '1': 'NotificationPriority',
  '2': [
    {'1': 'NORMAL', '2': 0},
    {'1': 'HIGH', '2': 1},
  ],
};

/// Descriptor for `NotificationPriority`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List notificationPriorityDescriptor =
    $convert.base64Decode(
        'ChROb3RpZmljYXRpb25Qcmlvcml0eRIKCgZOT1JNQUwQABIICgRISUdIEAE=');

@$core.Deprecated('Use registerDeviceRequestDescriptor instead')
const RegisterDeviceRequest$json = {
  '1': 'RegisterDeviceRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'push_token', '3': 3, '4': 1, '5': 9, '10': 'pushToken'},
    {
      '1': 'platform',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.guardyn.notifications.PushPlatform',
      '10': 'platform'
    },
    {'1': 'device_name', '3': 5, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'app_version', '3': 6, '4': 1, '5': 9, '10': 'appVersion'},
    {'1': 'os_version', '3': 7, '4': 1, '5': 9, '10': 'osVersion'},
  ],
};

/// Descriptor for `RegisterDeviceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerDeviceRequestDescriptor = $convert.base64Decode(
    'ChVSZWdpc3RlckRldmljZVJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2'
    'tlbhIbCglkZXZpY2VfaWQYAiABKAlSCGRldmljZUlkEh0KCnB1c2hfdG9rZW4YAyABKAlSCXB1'
    'c2hUb2tlbhI/CghwbGF0Zm9ybRgEIAEoDjIjLmd1YXJkeW4ubm90aWZpY2F0aW9ucy5QdXNoUG'
    'xhdGZvcm1SCHBsYXRmb3JtEh8KC2RldmljZV9uYW1lGAUgASgJUgpkZXZpY2VOYW1lEh8KC2Fw'
    'cF92ZXJzaW9uGAYgASgJUgphcHBWZXJzaW9uEh0KCm9zX3ZlcnNpb24YByABKAlSCW9zVmVyc2'
    'lvbg==');

@$core.Deprecated('Use registerDeviceResponseDescriptor instead')
const RegisterDeviceResponse$json = {
  '1': 'RegisterDeviceResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.notifications.RegisterDeviceSuccess',
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

/// Descriptor for `RegisterDeviceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerDeviceResponseDescriptor = $convert.base64Decode(
    'ChZSZWdpc3RlckRldmljZVJlc3BvbnNlEkgKB3N1Y2Nlc3MYASABKAsyLC5ndWFyZHluLm5vdG'
    'lmaWNhdGlvbnMuUmVnaXN0ZXJEZXZpY2VTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiAB'
    'KAsyHS5ndWFyZHluLmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use registerDeviceSuccessDescriptor instead')
const RegisterDeviceSuccess$json = {
  '1': 'RegisterDeviceSuccess',
  '2': [
    {'1': 'registration_id', '3': 1, '4': 1, '5': 9, '10': 'registrationId'},
    {
      '1': 'registered_at',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'registeredAt'
    },
  ],
};

/// Descriptor for `RegisterDeviceSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerDeviceSuccessDescriptor = $convert.base64Decode(
    'ChVSZWdpc3RlckRldmljZVN1Y2Nlc3MSJwoPcmVnaXN0cmF0aW9uX2lkGAEgASgJUg5yZWdpc3'
    'RyYXRpb25JZBI+Cg1yZWdpc3RlcmVkX2F0GAIgASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0'
    'YW1wUgxyZWdpc3RlcmVkQXQ=');

@$core.Deprecated('Use unregisterDeviceRequestDescriptor instead')
const UnregisterDeviceRequest$json = {
  '1': 'UnregisterDeviceRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `UnregisterDeviceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unregisterDeviceRequestDescriptor =
    $convert.base64Decode(
        'ChdVbnJlZ2lzdGVyRGV2aWNlUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1'
        'Rva2VuEhsKCWRldmljZV9pZBgCIAEoCVIIZGV2aWNlSWQ=');

@$core.Deprecated('Use unregisterDeviceResponseDescriptor instead')
const UnregisterDeviceResponse$json = {
  '1': 'UnregisterDeviceResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.notifications.UnregisterDeviceSuccess',
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

/// Descriptor for `UnregisterDeviceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unregisterDeviceResponseDescriptor = $convert.base64Decode(
    'ChhVbnJlZ2lzdGVyRGV2aWNlUmVzcG9uc2USSgoHc3VjY2VzcxgBIAEoCzIuLmd1YXJkeW4ubm'
    '90aWZpY2F0aW9ucy5VbnJlZ2lzdGVyRGV2aWNlU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9y'
    'GAIgASgLMh0uZ3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bH'
    'Q=');

@$core.Deprecated('Use unregisterDeviceSuccessDescriptor instead')
const UnregisterDeviceSuccess$json = {
  '1': 'UnregisterDeviceSuccess',
  '2': [
    {'1': 'unregistered', '3': 1, '4': 1, '5': 8, '10': 'unregistered'},
  ],
};

/// Descriptor for `UnregisterDeviceSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unregisterDeviceSuccessDescriptor =
    $convert.base64Decode(
        'ChdVbnJlZ2lzdGVyRGV2aWNlU3VjY2VzcxIiCgx1bnJlZ2lzdGVyZWQYASABKAhSDHVucmVnaX'
        'N0ZXJlZA==');

@$core.Deprecated('Use updatePushTokenRequestDescriptor instead')
const UpdatePushTokenRequest$json = {
  '1': 'UpdatePushTokenRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'new_push_token', '3': 3, '4': 1, '5': 9, '10': 'newPushToken'},
  ],
};

/// Descriptor for `UpdatePushTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updatePushTokenRequestDescriptor = $convert.base64Decode(
    'ChZVcGRhdGVQdXNoVG9rZW5SZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG'
    '9rZW4SGwoJZGV2aWNlX2lkGAIgASgJUghkZXZpY2VJZBIkCg5uZXdfcHVzaF90b2tlbhgDIAEo'
    'CVIMbmV3UHVzaFRva2Vu');

@$core.Deprecated('Use updatePushTokenResponseDescriptor instead')
const UpdatePushTokenResponse$json = {
  '1': 'UpdatePushTokenResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.notifications.UpdatePushTokenSuccess',
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

/// Descriptor for `UpdatePushTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updatePushTokenResponseDescriptor = $convert.base64Decode(
    'ChdVcGRhdGVQdXNoVG9rZW5SZXNwb25zZRJJCgdzdWNjZXNzGAEgASgLMi0uZ3VhcmR5bi5ub3'
    'RpZmljYXRpb25zLlVwZGF0ZVB1c2hUb2tlblN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgC'
    'IAEoCzIdLmd1YXJkeW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use updatePushTokenSuccessDescriptor instead')
const UpdatePushTokenSuccess$json = {
  '1': 'UpdatePushTokenSuccess',
  '2': [
    {'1': 'updated', '3': 1, '4': 1, '5': 8, '10': 'updated'},
  ],
};

/// Descriptor for `UpdatePushTokenSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updatePushTokenSuccessDescriptor =
    $convert.base64Decode(
        'ChZVcGRhdGVQdXNoVG9rZW5TdWNjZXNzEhgKB3VwZGF0ZWQYASABKAhSB3VwZGF0ZWQ=');

@$core.Deprecated('Use notificationSettingsDescriptor instead')
const NotificationSettings$json = {
  '1': 'NotificationSettings',
  '2': [
    {
      '1': 'notifications_enabled',
      '3': 1,
      '4': 1,
      '5': 8,
      '10': 'notificationsEnabled'
    },
    {'1': 'sound_enabled', '3': 2, '4': 1, '5': 8, '10': 'soundEnabled'},
    {
      '1': 'vibration_enabled',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'vibrationEnabled'
    },
    {'1': 'show_preview', '3': 4, '4': 1, '5': 8, '10': 'showPreview'},
    {'1': 'show_sender', '3': 5, '4': 1, '5': 8, '10': 'showSender'},
    {
      '1': 'quiet_hours_enabled',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'quietHoursEnabled'
    },
    {'1': 'quiet_hours_start', '3': 7, '4': 1, '5': 5, '10': 'quietHoursStart'},
    {'1': 'quiet_hours_end', '3': 8, '4': 1, '5': 5, '10': 'quietHoursEnd'},
    {
      '1': 'quiet_hours_timezone',
      '3': 9,
      '4': 1,
      '5': 9,
      '10': 'quietHoursTimezone'
    },
    {'1': 'notify_messages', '3': 10, '4': 1, '5': 8, '10': 'notifyMessages'},
    {'1': 'notify_reactions', '3': 11, '4': 1, '5': 8, '10': 'notifyReactions'},
    {'1': 'notify_mentions', '3': 12, '4': 1, '5': 8, '10': 'notifyMentions'},
    {'1': 'notify_calls', '3': 13, '4': 1, '5': 8, '10': 'notifyCalls'},
    {
      '1': 'notify_group_messages',
      '3': 14,
      '4': 1,
      '5': 8,
      '10': 'notifyGroupMessages'
    },
  ],
};

/// Descriptor for `NotificationSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationSettingsDescriptor = $convert.base64Decode(
    'ChROb3RpZmljYXRpb25TZXR0aW5ncxIzChVub3RpZmljYXRpb25zX2VuYWJsZWQYASABKAhSFG'
    '5vdGlmaWNhdGlvbnNFbmFibGVkEiMKDXNvdW5kX2VuYWJsZWQYAiABKAhSDHNvdW5kRW5hYmxl'
    'ZBIrChF2aWJyYXRpb25fZW5hYmxlZBgDIAEoCFIQdmlicmF0aW9uRW5hYmxlZBIhCgxzaG93X3'
    'ByZXZpZXcYBCABKAhSC3Nob3dQcmV2aWV3Eh8KC3Nob3dfc2VuZGVyGAUgASgIUgpzaG93U2Vu'
    'ZGVyEi4KE3F1aWV0X2hvdXJzX2VuYWJsZWQYBiABKAhSEXF1aWV0SG91cnNFbmFibGVkEioKEX'
    'F1aWV0X2hvdXJzX3N0YXJ0GAcgASgFUg9xdWlldEhvdXJzU3RhcnQSJgoPcXVpZXRfaG91cnNf'
    'ZW5kGAggASgFUg1xdWlldEhvdXJzRW5kEjAKFHF1aWV0X2hvdXJzX3RpbWV6b25lGAkgASgJUh'
    'JxdWlldEhvdXJzVGltZXpvbmUSJwoPbm90aWZ5X21lc3NhZ2VzGAogASgIUg5ub3RpZnlNZXNz'
    'YWdlcxIpChBub3RpZnlfcmVhY3Rpb25zGAsgASgIUg9ub3RpZnlSZWFjdGlvbnMSJwoPbm90aW'
    'Z5X21lbnRpb25zGAwgASgIUg5ub3RpZnlNZW50aW9ucxIhCgxub3RpZnlfY2FsbHMYDSABKAhS'
    'C25vdGlmeUNhbGxzEjIKFW5vdGlmeV9ncm91cF9tZXNzYWdlcxgOIAEoCFITbm90aWZ5R3JvdX'
    'BNZXNzYWdlcw==');

@$core.Deprecated('Use getNotificationSettingsRequestDescriptor instead')
const GetNotificationSettingsRequest$json = {
  '1': 'GetNotificationSettingsRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
  ],
};

/// Descriptor for `GetNotificationSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNotificationSettingsRequestDescriptor =
    $convert.base64Decode(
        'Ch5HZXROb3RpZmljYXRpb25TZXR0aW5nc1JlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUg'
        'thY2Nlc3NUb2tlbg==');

@$core.Deprecated('Use getNotificationSettingsResponseDescriptor instead')
const GetNotificationSettingsResponse$json = {
  '1': 'GetNotificationSettingsResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.notifications.GetNotificationSettingsSuccess',
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

/// Descriptor for `GetNotificationSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNotificationSettingsResponseDescriptor =
    $convert.base64Decode(
        'Ch9HZXROb3RpZmljYXRpb25TZXR0aW5nc1Jlc3BvbnNlElEKB3N1Y2Nlc3MYASABKAsyNS5ndW'
        'FyZHluLm5vdGlmaWNhdGlvbnMuR2V0Tm90aWZpY2F0aW9uU2V0dGluZ3NTdWNjZXNzSABSB3N1'
        'Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFyZHluLmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBW'
        'Vycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use getNotificationSettingsSuccessDescriptor instead')
const GetNotificationSettingsSuccess$json = {
  '1': 'GetNotificationSettingsSuccess',
  '2': [
    {
      '1': 'settings',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.notifications.NotificationSettings',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `GetNotificationSettingsSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNotificationSettingsSuccessDescriptor =
    $convert.base64Decode(
        'Ch5HZXROb3RpZmljYXRpb25TZXR0aW5nc1N1Y2Nlc3MSRwoIc2V0dGluZ3MYASABKAsyKy5ndW'
        'FyZHluLm5vdGlmaWNhdGlvbnMuTm90aWZpY2F0aW9uU2V0dGluZ3NSCHNldHRpbmdz');

@$core.Deprecated('Use updateNotificationSettingsRequestDescriptor instead')
const UpdateNotificationSettingsRequest$json = {
  '1': 'UpdateNotificationSettingsRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {
      '1': 'settings',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.notifications.NotificationSettings',
      '10': 'settings'
    },
  ],
};

/// Descriptor for `UpdateNotificationSettingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateNotificationSettingsRequestDescriptor =
    $convert.base64Decode(
        'CiFVcGRhdGVOb3RpZmljYXRpb25TZXR0aW5nc1JlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgAS'
        'gJUgthY2Nlc3NUb2tlbhJHCghzZXR0aW5ncxgCIAEoCzIrLmd1YXJkeW4ubm90aWZpY2F0aW9u'
        'cy5Ob3RpZmljYXRpb25TZXR0aW5nc1IIc2V0dGluZ3M=');

@$core.Deprecated('Use updateNotificationSettingsResponseDescriptor instead')
const UpdateNotificationSettingsResponse$json = {
  '1': 'UpdateNotificationSettingsResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.notifications.UpdateNotificationSettingsSuccess',
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

/// Descriptor for `UpdateNotificationSettingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateNotificationSettingsResponseDescriptor =
    $convert.base64Decode(
        'CiJVcGRhdGVOb3RpZmljYXRpb25TZXR0aW5nc1Jlc3BvbnNlElQKB3N1Y2Nlc3MYASABKAsyOC'
        '5ndWFyZHluLm5vdGlmaWNhdGlvbnMuVXBkYXRlTm90aWZpY2F0aW9uU2V0dGluZ3NTdWNjZXNz'
        'SABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFyZHluLmNvbW1vbi5FcnJvclJlc3Bvbn'
        'NlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use updateNotificationSettingsSuccessDescriptor instead')
const UpdateNotificationSettingsSuccess$json = {
  '1': 'UpdateNotificationSettingsSuccess',
  '2': [
    {'1': 'updated', '3': 1, '4': 1, '5': 8, '10': 'updated'},
  ],
};

/// Descriptor for `UpdateNotificationSettingsSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateNotificationSettingsSuccessDescriptor =
    $convert.base64Decode(
        'CiFVcGRhdGVOb3RpZmljYXRpb25TZXR0aW5nc1N1Y2Nlc3MSGAoHdXBkYXRlZBgBIAEoCFIHdX'
        'BkYXRlZA==');

@$core.Deprecated('Use muteConversationRequestDescriptor instead')
const MuteConversationRequest$json = {
  '1': 'MuteConversationRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_group', '3': 3, '4': 1, '5': 8, '10': 'isGroup'},
    {
      '1': 'duration',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.guardyn.notifications.MuteDuration',
      '10': 'duration'
    },
  ],
};

/// Descriptor for `MuteConversationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List muteConversationRequestDescriptor = $convert.base64Decode(
    'ChdNdXRlQ29udmVyc2F0aW9uUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1'
    'Rva2VuEicKD2NvbnZlcnNhdGlvbl9pZBgCIAEoCVIOY29udmVyc2F0aW9uSWQSGQoIaXNfZ3Jv'
    'dXAYAyABKAhSB2lzR3JvdXASPwoIZHVyYXRpb24YBCABKA4yIy5ndWFyZHluLm5vdGlmaWNhdG'
    'lvbnMuTXV0ZUR1cmF0aW9uUghkdXJhdGlvbg==');

@$core.Deprecated('Use muteConversationResponseDescriptor instead')
const MuteConversationResponse$json = {
  '1': 'MuteConversationResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.notifications.MuteConversationSuccess',
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

/// Descriptor for `MuteConversationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List muteConversationResponseDescriptor = $convert.base64Decode(
    'ChhNdXRlQ29udmVyc2F0aW9uUmVzcG9uc2USSgoHc3VjY2VzcxgBIAEoCzIuLmd1YXJkeW4ubm'
    '90aWZpY2F0aW9ucy5NdXRlQ29udmVyc2F0aW9uU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9y'
    'GAIgASgLMh0uZ3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bH'
    'Q=');

@$core.Deprecated('Use muteConversationSuccessDescriptor instead')
const MuteConversationSuccess$json = {
  '1': 'MuteConversationSuccess',
  '2': [
    {'1': 'muted', '3': 1, '4': 1, '5': 8, '10': 'muted'},
    {
      '1': 'muted_until',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'mutedUntil'
    },
  ],
};

/// Descriptor for `MuteConversationSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List muteConversationSuccessDescriptor = $convert.base64Decode(
    'ChdNdXRlQ29udmVyc2F0aW9uU3VjY2VzcxIUCgVtdXRlZBgBIAEoCFIFbXV0ZWQSOgoLbXV0ZW'
    'RfdW50aWwYAiABKAsyGS5ndWFyZHluLmNvbW1vbi5UaW1lc3RhbXBSCm11dGVkVW50aWw=');

@$core.Deprecated('Use sendTestNotificationRequestDescriptor instead')
const SendTestNotificationRequest$json = {
  '1': 'SendTestNotificationRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `SendTestNotificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendTestNotificationRequestDescriptor =
    $convert.base64Decode(
        'ChtTZW5kVGVzdE5vdGlmaWNhdGlvblJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2'
        'Nlc3NUb2tlbhIbCglkZXZpY2VfaWQYAiABKAlSCGRldmljZUlk');

@$core.Deprecated('Use sendTestNotificationResponseDescriptor instead')
const SendTestNotificationResponse$json = {
  '1': 'SendTestNotificationResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.notifications.SendTestNotificationSuccess',
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

/// Descriptor for `SendTestNotificationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendTestNotificationResponseDescriptor = $convert.base64Decode(
    'ChxTZW5kVGVzdE5vdGlmaWNhdGlvblJlc3BvbnNlEk4KB3N1Y2Nlc3MYASABKAsyMi5ndWFyZH'
    'luLm5vdGlmaWNhdGlvbnMuU2VuZFRlc3ROb3RpZmljYXRpb25TdWNjZXNzSABSB3N1Y2Nlc3MS'
    'NQoFZXJyb3IYAiABKAsyHS5ndWFyZHluLmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQg'
    'gKBnJlc3VsdA==');

@$core.Deprecated('Use sendTestNotificationSuccessDescriptor instead')
const SendTestNotificationSuccess$json = {
  '1': 'SendTestNotificationSuccess',
  '2': [
    {'1': 'devices_notified', '3': 1, '4': 1, '5': 5, '10': 'devicesNotified'},
  ],
};

/// Descriptor for `SendTestNotificationSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendTestNotificationSuccessDescriptor =
    $convert.base64Decode(
        'ChtTZW5kVGVzdE5vdGlmaWNhdGlvblN1Y2Nlc3MSKQoQZGV2aWNlc19ub3RpZmllZBgBIAEoBV'
        'IPZGV2aWNlc05vdGlmaWVk');

@$core.Deprecated('Use pushNotificationPayloadDescriptor instead')
const PushNotificationPayload$json = {
  '1': 'PushNotificationPayload',
  '2': [
    {'1': 'notification_id', '3': 1, '4': 1, '5': 9, '10': 'notificationId'},
    {'1': 'recipient_user_id', '3': 2, '4': 1, '5': 9, '10': 'recipientUserId'},
    {
      '1': 'type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.guardyn.notifications.NotificationType',
      '10': 'type'
    },
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'body', '3': 5, '4': 1, '5': 9, '10': 'body'},
    {'1': 'image_url', '3': 6, '4': 1, '5': 9, '10': 'imageUrl'},
    {'1': 'conversation_id', '3': 7, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_group', '3': 8, '4': 1, '5': 8, '10': 'isGroup'},
    {'1': 'message_id', '3': 9, '4': 1, '5': 9, '10': 'messageId'},
    {
      '1': 'data',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.guardyn.notifications.PushNotificationPayload.DataEntry',
      '10': 'data'
    },
    {
      '1': 'priority',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.guardyn.notifications.NotificationPriority',
      '10': 'priority'
    },
    {'1': 'ttl_seconds', '3': 12, '4': 1, '5': 5, '10': 'ttlSeconds'},
  ],
  '3': [PushNotificationPayload_DataEntry$json],
};

@$core.Deprecated('Use pushNotificationPayloadDescriptor instead')
const PushNotificationPayload_DataEntry$json = {
  '1': 'DataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `PushNotificationPayload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushNotificationPayloadDescriptor = $convert.base64Decode(
    'ChdQdXNoTm90aWZpY2F0aW9uUGF5bG9hZBInCg9ub3RpZmljYXRpb25faWQYASABKAlSDm5vdG'
    'lmaWNhdGlvbklkEioKEXJlY2lwaWVudF91c2VyX2lkGAIgASgJUg9yZWNpcGllbnRVc2VySWQS'
    'OwoEdHlwZRgDIAEoDjInLmd1YXJkeW4ubm90aWZpY2F0aW9ucy5Ob3RpZmljYXRpb25UeXBlUg'
    'R0eXBlEhQKBXRpdGxlGAQgASgJUgV0aXRsZRISCgRib2R5GAUgASgJUgRib2R5EhsKCWltYWdl'
    'X3VybBgGIAEoCVIIaW1hZ2VVcmwSJwoPY29udmVyc2F0aW9uX2lkGAcgASgJUg5jb252ZXJzYX'
    'Rpb25JZBIZCghpc19ncm91cBgIIAEoCFIHaXNHcm91cBIdCgptZXNzYWdlX2lkGAkgASgJUglt'
    'ZXNzYWdlSWQSTAoEZGF0YRgKIAMoCzI4Lmd1YXJkeW4ubm90aWZpY2F0aW9ucy5QdXNoTm90aW'
    'ZpY2F0aW9uUGF5bG9hZC5EYXRhRW50cnlSBGRhdGESRwoIcHJpb3JpdHkYCyABKA4yKy5ndWFy'
    'ZHluLm5vdGlmaWNhdGlvbnMuTm90aWZpY2F0aW9uUHJpb3JpdHlSCHByaW9yaXR5Eh8KC3R0bF'
    '9zZWNvbmRzGAwgASgFUgp0dGxTZWNvbmRzGjcKCURhdGFFbnRyeRIQCgNrZXkYASABKAlSA2tl'
    'eRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use healthRequestDescriptor instead')
const HealthRequest$json = {
  '1': 'HealthRequest',
};

/// Descriptor for `HealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthRequestDescriptor =
    $convert.base64Decode('Cg1IZWFsdGhSZXF1ZXN0');
