// This is a generated file - do not edit.
//
// Generated from presence.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use userStatusDescriptor instead')
const UserStatus$json = {
  '1': 'UserStatus',
  '2': [
    {'1': 'OFFLINE', '2': 0},
    {'1': 'ONLINE', '2': 1},
    {'1': 'AWAY', '2': 2},
    {'1': 'DO_NOT_DISTURB', '2': 3},
    {'1': 'INVISIBLE', '2': 4},
  ],
};

/// Descriptor for `UserStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userStatusDescriptor = $convert.base64Decode(
    'CgpVc2VyU3RhdHVzEgsKB09GRkxJTkUQABIKCgZPTkxJTkUQARIICgRBV0FZEAISEgoORE9fTk'
    '9UX0RJU1RVUkIQAxINCglJTlZJU0lCTEUQBA==');

@$core.Deprecated('Use updateStatusRequestDescriptor instead')
const UpdateStatusRequest$json = {
  '1': 'UpdateStatusRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.presence.UserStatus',
      '10': 'status'
    },
    {
      '1': 'custom_status_text',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'customStatusText'
    },
  ],
};

/// Descriptor for `UpdateStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateStatusRequestDescriptor = $convert.base64Decode(
    'ChNVcGRhdGVTdGF0dXNSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW'
    '4SNAoGc3RhdHVzGAIgASgOMhwuZ3VhcmR5bi5wcmVzZW5jZS5Vc2VyU3RhdHVzUgZzdGF0dXMS'
    'LAoSY3VzdG9tX3N0YXR1c190ZXh0GAMgASgJUhBjdXN0b21TdGF0dXNUZXh0');

@$core.Deprecated('Use updateStatusResponseDescriptor instead')
const UpdateStatusResponse$json = {
  '1': 'UpdateStatusResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.presence.UpdateStatusSuccess',
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

/// Descriptor for `UpdateStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateStatusResponseDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVTdGF0dXNSZXNwb25zZRJBCgdzdWNjZXNzGAEgASgLMiUuZ3VhcmR5bi5wcmVzZW'
    '5jZS5VcGRhdGVTdGF0dXNTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFy'
    'ZHluLmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use updateStatusSuccessDescriptor instead')
const UpdateStatusSuccess$json = {
  '1': 'UpdateStatusSuccess',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.guardyn.presence.UserStatus',
      '10': 'status'
    },
    {
      '1': 'updated_at',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `UpdateStatusSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateStatusSuccessDescriptor = $convert.base64Decode(
    'ChNVcGRhdGVTdGF0dXNTdWNjZXNzEjQKBnN0YXR1cxgBIAEoDjIcLmd1YXJkeW4ucHJlc2VuY2'
    'UuVXNlclN0YXR1c1IGc3RhdHVzEjgKCnVwZGF0ZWRfYXQYAiABKAsyGS5ndWFyZHluLmNvbW1v'
    'bi5UaW1lc3RhbXBSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use getStatusRequestDescriptor instead')
const GetStatusRequest$json = {
  '1': 'GetStatusRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatusRequestDescriptor = $convert.base64Decode(
    'ChBHZXRTdGF0dXNSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW4SFw'
    'oHdXNlcl9pZBgCIAEoCVIGdXNlcklk');

@$core.Deprecated('Use getStatusResponseDescriptor instead')
const GetStatusResponse$json = {
  '1': 'GetStatusResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.presence.GetStatusSuccess',
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

/// Descriptor for `GetStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatusResponseDescriptor = $convert.base64Decode(
    'ChFHZXRTdGF0dXNSZXNwb25zZRI+CgdzdWNjZXNzGAEgASgLMiIuZ3VhcmR5bi5wcmVzZW5jZS'
    '5HZXRTdGF0dXNTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFyZHluLmNv'
    'bW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use getStatusSuccessDescriptor instead')
const GetStatusSuccess$json = {
  '1': 'GetStatusSuccess',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.presence.UserStatus',
      '10': 'status'
    },
    {
      '1': 'custom_status_text',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'customStatusText'
    },
    {
      '1': 'last_seen',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'lastSeen'
    },
    {'1': 'is_typing', '3': 5, '4': 1, '5': 8, '10': 'isTyping'},
  ],
};

/// Descriptor for `GetStatusSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getStatusSuccessDescriptor = $convert.base64Decode(
    'ChBHZXRTdGF0dXNTdWNjZXNzEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBI0CgZzdGF0dXMYAi'
    'ABKA4yHC5ndWFyZHluLnByZXNlbmNlLlVzZXJTdGF0dXNSBnN0YXR1cxIsChJjdXN0b21fc3Rh'
    'dHVzX3RleHQYAyABKAlSEGN1c3RvbVN0YXR1c1RleHQSNgoJbGFzdF9zZWVuGAQgASgLMhkuZ3'
    'VhcmR5bi5jb21tb24uVGltZXN0YW1wUghsYXN0U2VlbhIbCglpc190eXBpbmcYBSABKAhSCGlz'
    'VHlwaW5n');

@$core.Deprecated('Use subscribeRequestDescriptor instead')
const SubscribeRequest$json = {
  '1': 'SubscribeRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'user_ids', '3': 2, '4': 3, '5': 9, '10': 'userIds'},
  ],
};

/// Descriptor for `SubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeRequestDescriptor = $convert.base64Decode(
    'ChBTdWJzY3JpYmVSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW4SGQ'
    'oIdXNlcl9pZHMYAiADKAlSB3VzZXJJZHM=');

@$core.Deprecated('Use presenceUpdateDescriptor instead')
const PresenceUpdate$json = {
  '1': 'PresenceUpdate',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.presence.UserStatus',
      '10': 'status'
    },
    {
      '1': 'custom_status_text',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'customStatusText'
    },
    {
      '1': 'last_seen',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'lastSeen'
    },
    {
      '1': 'updated_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'updatedAt'
    },
    {'1': 'is_typing', '3': 6, '4': 1, '5': 8, '10': 'isTyping'},
    {
      '1': 'typing_in_conversation_with',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'typingInConversationWith'
    },
  ],
};

/// Descriptor for `PresenceUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List presenceUpdateDescriptor = $convert.base64Decode(
    'Cg5QcmVzZW5jZVVwZGF0ZRIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSNAoGc3RhdHVzGAIgAS'
    'gOMhwuZ3VhcmR5bi5wcmVzZW5jZS5Vc2VyU3RhdHVzUgZzdGF0dXMSLAoSY3VzdG9tX3N0YXR1'
    'c190ZXh0GAMgASgJUhBjdXN0b21TdGF0dXNUZXh0EjYKCWxhc3Rfc2VlbhgEIAEoCzIZLmd1YX'
    'JkeW4uY29tbW9uLlRpbWVzdGFtcFIIbGFzdFNlZW4SOAoKdXBkYXRlZF9hdBgFIAEoCzIZLmd1'
    'YXJkeW4uY29tbW9uLlRpbWVzdGFtcFIJdXBkYXRlZEF0EhsKCWlzX3R5cGluZxgGIAEoCFIIaX'
    'NUeXBpbmcSPQobdHlwaW5nX2luX2NvbnZlcnNhdGlvbl93aXRoGAcgASgJUhh0eXBpbmdJbkNv'
    'bnZlcnNhdGlvbldpdGg=');

@$core.Deprecated('Use updateLastSeenRequestDescriptor instead')
const UpdateLastSeenRequest$json = {
  '1': 'UpdateLastSeenRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
  ],
};

/// Descriptor for `UpdateLastSeenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateLastSeenRequestDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVMYXN0U2VlblJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2'
    'tlbg==');

@$core.Deprecated('Use updateLastSeenResponseDescriptor instead')
const UpdateLastSeenResponse$json = {
  '1': 'UpdateLastSeenResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.presence.UpdateLastSeenSuccess',
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

/// Descriptor for `UpdateLastSeenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateLastSeenResponseDescriptor = $convert.base64Decode(
    'ChZVcGRhdGVMYXN0U2VlblJlc3BvbnNlEkMKB3N1Y2Nlc3MYASABKAsyJy5ndWFyZHluLnByZX'
    'NlbmNlLlVwZGF0ZUxhc3RTZWVuU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0u'
    'Z3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use updateLastSeenSuccessDescriptor instead')
const UpdateLastSeenSuccess$json = {
  '1': 'UpdateLastSeenSuccess',
  '2': [
    {
      '1': 'last_seen',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'lastSeen'
    },
  ],
};

/// Descriptor for `UpdateLastSeenSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateLastSeenSuccessDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVMYXN0U2VlblN1Y2Nlc3MSNgoJbGFzdF9zZWVuGAEgASgLMhkuZ3VhcmR5bi5jb2'
    '1tb24uVGltZXN0YW1wUghsYXN0U2Vlbg==');

@$core.Deprecated('Use getBulkStatusRequestDescriptor instead')
const GetBulkStatusRequest$json = {
  '1': 'GetBulkStatusRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'user_ids', '3': 2, '4': 3, '5': 9, '10': 'userIds'},
  ],
};

/// Descriptor for `GetBulkStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBulkStatusRequestDescriptor = $convert.base64Decode(
    'ChRHZXRCdWxrU3RhdHVzUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2'
    'VuEhkKCHVzZXJfaWRzGAIgAygJUgd1c2VySWRz');

@$core.Deprecated('Use getBulkStatusResponseDescriptor instead')
const GetBulkStatusResponse$json = {
  '1': 'GetBulkStatusResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.presence.GetBulkStatusSuccess',
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

/// Descriptor for `GetBulkStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBulkStatusResponseDescriptor = $convert.base64Decode(
    'ChVHZXRCdWxrU3RhdHVzUmVzcG9uc2USQgoHc3VjY2VzcxgBIAEoCzImLmd1YXJkeW4ucHJlc2'
    'VuY2UuR2V0QnVsa1N0YXR1c1N1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1'
    'YXJkeW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use getBulkStatusSuccessDescriptor instead')
const GetBulkStatusSuccess$json = {
  '1': 'GetBulkStatusSuccess',
  '2': [
    {
      '1': 'presences',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.guardyn.presence.UserPresence',
      '10': 'presences'
    },
  ],
};

/// Descriptor for `GetBulkStatusSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBulkStatusSuccessDescriptor = $convert.base64Decode(
    'ChRHZXRCdWxrU3RhdHVzU3VjY2VzcxI8CglwcmVzZW5jZXMYASADKAsyHi5ndWFyZHluLnByZX'
    'NlbmNlLlVzZXJQcmVzZW5jZVIJcHJlc2VuY2Vz');

@$core.Deprecated('Use userPresenceDescriptor instead')
const UserPresence$json = {
  '1': 'UserPresence',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.presence.UserStatus',
      '10': 'status'
    },
    {
      '1': 'custom_status_text',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'customStatusText'
    },
    {
      '1': 'last_seen',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'lastSeen'
    },
  ],
};

/// Descriptor for `UserPresence`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userPresenceDescriptor = $convert.base64Decode(
    'CgxVc2VyUHJlc2VuY2USFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEjQKBnN0YXR1cxgCIAEoDj'
    'IcLmd1YXJkeW4ucHJlc2VuY2UuVXNlclN0YXR1c1IGc3RhdHVzEiwKEmN1c3RvbV9zdGF0dXNf'
    'dGV4dBgDIAEoCVIQY3VzdG9tU3RhdHVzVGV4dBI2CglsYXN0X3NlZW4YBCABKAsyGS5ndWFyZH'
    'luLmNvbW1vbi5UaW1lc3RhbXBSCGxhc3RTZWVu');

@$core.Deprecated('Use setTypingRequestDescriptor instead')
const SetTypingRequest$json = {
  '1': 'SetTypingRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {
      '1': 'conversation_user_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'conversationUserId'
    },
    {'1': 'is_typing', '3': 3, '4': 1, '5': 8, '10': 'isTyping'},
  ],
};

/// Descriptor for `SetTypingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setTypingRequestDescriptor = $convert.base64Decode(
    'ChBTZXRUeXBpbmdSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW4SMA'
    'oUY29udmVyc2F0aW9uX3VzZXJfaWQYAiABKAlSEmNvbnZlcnNhdGlvblVzZXJJZBIbCglpc190'
    'eXBpbmcYAyABKAhSCGlzVHlwaW5n');

@$core.Deprecated('Use setTypingResponseDescriptor instead')
const SetTypingResponse$json = {
  '1': 'SetTypingResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.presence.SetTypingSuccess',
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

/// Descriptor for `SetTypingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setTypingResponseDescriptor = $convert.base64Decode(
    'ChFTZXRUeXBpbmdSZXNwb25zZRI+CgdzdWNjZXNzGAEgASgLMiIuZ3VhcmR5bi5wcmVzZW5jZS'
    '5TZXRUeXBpbmdTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFyZHluLmNv'
    'bW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use setTypingSuccessDescriptor instead')
const SetTypingSuccess$json = {
  '1': 'SetTypingSuccess',
  '2': [
    {'1': 'acknowledged', '3': 1, '4': 1, '5': 8, '10': 'acknowledged'},
  ],
};

/// Descriptor for `SetTypingSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setTypingSuccessDescriptor = $convert.base64Decode(
    'ChBTZXRUeXBpbmdTdWNjZXNzEiIKDGFja25vd2xlZGdlZBgBIAEoCFIMYWNrbm93bGVkZ2Vk');

@$core.Deprecated('Use healthRequestDescriptor instead')
const HealthRequest$json = {
  '1': 'HealthRequest',
};

/// Descriptor for `HealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthRequestDescriptor =
    $convert.base64Decode('Cg1IZWFsdGhSZXF1ZXN0');
