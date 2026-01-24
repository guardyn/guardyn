// This is a generated file - do not edit.
//
// Generated from messaging.proto.

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

@$core.Deprecated('Use messageTypeDescriptor instead')
const MessageType$json = {
  '1': 'MessageType',
  '2': [
    {'1': 'TEXT', '2': 0},
    {'1': 'IMAGE', '2': 1},
    {'1': 'VIDEO', '2': 2},
    {'1': 'AUDIO', '2': 3},
    {'1': 'FILE', '2': 4},
    {'1': 'VOICE_NOTE', '2': 5},
    {'1': 'LOCATION', '2': 6},
  ],
};

/// Descriptor for `MessageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List messageTypeDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlVHlwZRIICgRURVhUEAASCQoFSU1BR0UQARIJCgVWSURFTxACEgkKBUFVRElPEA'
    'MSCAoERklMRRAEEg4KClZPSUNFX05PVEUQBRIMCghMT0NBVElPThAG');

@$core.Deprecated('Use deliveryStatusDescriptor instead')
const DeliveryStatus$json = {
  '1': 'DeliveryStatus',
  '2': [
    {'1': 'PENDING', '2': 0},
    {'1': 'SENT', '2': 1},
    {'1': 'DELIVERED', '2': 2},
    {'1': 'READ', '2': 3},
    {'1': 'FAILED', '2': 4},
  ],
};

/// Descriptor for `DeliveryStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deliveryStatusDescriptor = $convert.base64Decode(
    'Cg5EZWxpdmVyeVN0YXR1cxILCgdQRU5ESU5HEAASCAoEU0VOVBABEg0KCURFTElWRVJFRBACEg'
    'gKBFJFQUQQAxIKCgZGQUlMRUQQBA==');

@$core.Deprecated('Use sendMessageRequestDescriptor instead')
const SendMessageRequest$json = {
  '1': 'SendMessageRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'recipient_user_id', '3': 2, '4': 1, '5': 9, '10': 'recipientUserId'},
    {
      '1': 'recipient_device_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'recipientDeviceId'
    },
    {
      '1': 'encrypted_content',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'encryptedContent'
    },
    {
      '1': 'message_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.guardyn.messaging.MessageType',
      '10': 'messageType'
    },
    {'1': 'client_message_id', '3': 6, '4': 1, '5': 9, '10': 'clientMessageId'},
    {
      '1': 'client_timestamp',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'clientTimestamp'
    },
    {'1': 'media_id', '3': 8, '4': 1, '5': 9, '10': 'mediaId'},
    {
      '1': 'recipient_username',
      '3': 9,
      '4': 1,
      '5': 9,
      '10': 'recipientUsername'
    },
    {'1': 'x3dh_prekey', '3': 10, '4': 1, '5': 9, '10': 'x3dhPrekey'},
    {
      '1': 'thread_reference',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.ThreadReference',
      '10': 'threadReference'
    },
    {
      '1': 'voice_metadata',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.VoiceMessageMetadata',
      '10': 'voiceMetadata'
    },
  ],
};

/// Descriptor for `SendMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageRequestDescriptor = $convert.base64Decode(
    'ChJTZW5kTWVzc2FnZVJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbh'
    'IqChFyZWNpcGllbnRfdXNlcl9pZBgCIAEoCVIPcmVjaXBpZW50VXNlcklkEi4KE3JlY2lwaWVu'
    'dF9kZXZpY2VfaWQYAyABKAlSEXJlY2lwaWVudERldmljZUlkEisKEWVuY3J5cHRlZF9jb250ZW'
    '50GAQgASgMUhBlbmNyeXB0ZWRDb250ZW50EkEKDG1lc3NhZ2VfdHlwZRgFIAEoDjIeLmd1YXJk'
    'eW4ubWVzc2FnaW5nLk1lc3NhZ2VUeXBlUgttZXNzYWdlVHlwZRIqChFjbGllbnRfbWVzc2FnZV'
    '9pZBgGIAEoCVIPY2xpZW50TWVzc2FnZUlkEkQKEGNsaWVudF90aW1lc3RhbXAYByABKAsyGS5n'
    'dWFyZHluLmNvbW1vbi5UaW1lc3RhbXBSD2NsaWVudFRpbWVzdGFtcBIZCghtZWRpYV9pZBgIIA'
    'EoCVIHbWVkaWFJZBItChJyZWNpcGllbnRfdXNlcm5hbWUYCSABKAlSEXJlY2lwaWVudFVzZXJu'
    'YW1lEh8KC3gzZGhfcHJla2V5GAogASgJUgp4M2RoUHJla2V5Ek0KEHRocmVhZF9yZWZlcmVuY2'
    'UYCyABKAsyIi5ndWFyZHluLm1lc3NhZ2luZy5UaHJlYWRSZWZlcmVuY2VSD3RocmVhZFJlZmVy'
    'ZW5jZRJOCg52b2ljZV9tZXRhZGF0YRgMIAEoCzInLmd1YXJkeW4ubWVzc2FnaW5nLlZvaWNlTW'
    'Vzc2FnZU1ldGFkYXRhUg12b2ljZU1ldGFkYXRh');

@$core.Deprecated('Use sendMessageResponseDescriptor instead')
const SendMessageResponse$json = {
  '1': 'SendMessageResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.SendMessageSuccess',
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

/// Descriptor for `SendMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageResponseDescriptor = $convert.base64Decode(
    'ChNTZW5kTWVzc2FnZVJlc3BvbnNlEkEKB3N1Y2Nlc3MYASABKAsyJS5ndWFyZHluLm1lc3NhZ2'
    'luZy5TZW5kTWVzc2FnZVN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJk'
    'eW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use sendMessageSuccessDescriptor instead')
const SendMessageSuccess$json = {
  '1': 'SendMessageSuccess',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {
      '1': 'server_timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'serverTimestamp'
    },
    {
      '1': 'delivery_status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.guardyn.messaging.DeliveryStatus',
      '10': 'deliveryStatus'
    },
  ],
};

/// Descriptor for `SendMessageSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendMessageSuccessDescriptor = $convert.base64Decode(
    'ChJTZW5kTWVzc2FnZVN1Y2Nlc3MSHQoKbWVzc2FnZV9pZBgBIAEoCVIJbWVzc2FnZUlkEkQKEH'
    'NlcnZlcl90aW1lc3RhbXAYAiABKAsyGS5ndWFyZHluLmNvbW1vbi5UaW1lc3RhbXBSD3NlcnZl'
    'clRpbWVzdGFtcBJKCg9kZWxpdmVyeV9zdGF0dXMYAyABKA4yIS5ndWFyZHluLm1lc3NhZ2luZy'
    '5EZWxpdmVyeVN0YXR1c1IOZGVsaXZlcnlTdGF0dXM=');

@$core.Deprecated('Use receiveMessagesRequestDescriptor instead')
const ReceiveMessagesRequest$json = {
  '1': 'ReceiveMessagesRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'include_history', '3': 2, '4': 1, '5': 8, '10': 'includeHistory'},
  ],
};

/// Descriptor for `ReceiveMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List receiveMessagesRequestDescriptor =
    $convert.base64Decode(
        'ChZSZWNlaXZlTWVzc2FnZXNSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG'
        '9rZW4SJwoPaW5jbHVkZV9oaXN0b3J5GAIgASgIUg5pbmNsdWRlSGlzdG9yeQ==');

@$core.Deprecated('Use messageDescriptor instead')
const Message$json = {
  '1': 'Message',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'sender_user_id', '3': 2, '4': 1, '5': 9, '10': 'senderUserId'},
    {'1': 'sender_device_id', '3': 3, '4': 1, '5': 9, '10': 'senderDeviceId'},
    {'1': 'recipient_user_id', '3': 4, '4': 1, '5': 9, '10': 'recipientUserId'},
    {
      '1': 'recipient_device_id',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'recipientDeviceId'
    },
    {
      '1': 'encrypted_content',
      '3': 6,
      '4': 1,
      '5': 12,
      '10': 'encryptedContent'
    },
    {
      '1': 'message_type',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.guardyn.messaging.MessageType',
      '10': 'messageType'
    },
    {'1': 'client_message_id', '3': 8, '4': 1, '5': 9, '10': 'clientMessageId'},
    {
      '1': 'client_timestamp',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'clientTimestamp'
    },
    {
      '1': 'server_timestamp',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'serverTimestamp'
    },
    {
      '1': 'delivery_status',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.guardyn.messaging.DeliveryStatus',
      '10': 'deliveryStatus'
    },
    {'1': 'media_id', '3': 12, '4': 1, '5': 9, '10': 'mediaId'},
    {'1': 'is_deleted', '3': 13, '4': 1, '5': 8, '10': 'isDeleted'},
    {'1': 'x3dh_prekey', '3': 14, '4': 1, '5': 9, '10': 'x3dhPrekey'},
    {
      '1': 'thread_reference',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.ThreadReference',
      '10': 'threadReference'
    },
    {
      '1': 'forward_info',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.ForwardInfo',
      '10': 'forwardInfo'
    },
    {'1': 'edit_version', '3': 17, '4': 1, '5': 5, '10': 'editVersion'},
    {
      '1': 'last_edited_at',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'lastEditedAt'
    },
    {
      '1': 'voice_metadata',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.VoiceMessageMetadata',
      '10': 'voiceMetadata'
    },
    {
      '1': 'reaction_summaries',
      '3': 20,
      '4': 3,
      '5': 11,
      '6': '.guardyn.messaging.ReactionSummary',
      '10': 'reactionSummaries'
    },
  ],
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode(
    'CgdNZXNzYWdlEh0KCm1lc3NhZ2VfaWQYASABKAlSCW1lc3NhZ2VJZBIkCg5zZW5kZXJfdXNlcl'
    '9pZBgCIAEoCVIMc2VuZGVyVXNlcklkEigKEHNlbmRlcl9kZXZpY2VfaWQYAyABKAlSDnNlbmRl'
    'ckRldmljZUlkEioKEXJlY2lwaWVudF91c2VyX2lkGAQgASgJUg9yZWNpcGllbnRVc2VySWQSLg'
    'oTcmVjaXBpZW50X2RldmljZV9pZBgFIAEoCVIRcmVjaXBpZW50RGV2aWNlSWQSKwoRZW5jcnlw'
    'dGVkX2NvbnRlbnQYBiABKAxSEGVuY3J5cHRlZENvbnRlbnQSQQoMbWVzc2FnZV90eXBlGAcgAS'
    'gOMh4uZ3VhcmR5bi5tZXNzYWdpbmcuTWVzc2FnZVR5cGVSC21lc3NhZ2VUeXBlEioKEWNsaWVu'
    'dF9tZXNzYWdlX2lkGAggASgJUg9jbGllbnRNZXNzYWdlSWQSRAoQY2xpZW50X3RpbWVzdGFtcB'
    'gJIAEoCzIZLmd1YXJkeW4uY29tbW9uLlRpbWVzdGFtcFIPY2xpZW50VGltZXN0YW1wEkQKEHNl'
    'cnZlcl90aW1lc3RhbXAYCiABKAsyGS5ndWFyZHluLmNvbW1vbi5UaW1lc3RhbXBSD3NlcnZlcl'
    'RpbWVzdGFtcBJKCg9kZWxpdmVyeV9zdGF0dXMYCyABKA4yIS5ndWFyZHluLm1lc3NhZ2luZy5E'
    'ZWxpdmVyeVN0YXR1c1IOZGVsaXZlcnlTdGF0dXMSGQoIbWVkaWFfaWQYDCABKAlSB21lZGlhSW'
    'QSHQoKaXNfZGVsZXRlZBgNIAEoCFIJaXNEZWxldGVkEh8KC3gzZGhfcHJla2V5GA4gASgJUgp4'
    'M2RoUHJla2V5Ek0KEHRocmVhZF9yZWZlcmVuY2UYDyABKAsyIi5ndWFyZHluLm1lc3NhZ2luZy'
    '5UaHJlYWRSZWZlcmVuY2VSD3RocmVhZFJlZmVyZW5jZRJBCgxmb3J3YXJkX2luZm8YECABKAsy'
    'Hi5ndWFyZHluLm1lc3NhZ2luZy5Gb3J3YXJkSW5mb1ILZm9yd2FyZEluZm8SIQoMZWRpdF92ZX'
    'JzaW9uGBEgASgFUgtlZGl0VmVyc2lvbhI/Cg5sYXN0X2VkaXRlZF9hdBgSIAEoCzIZLmd1YXJk'
    'eW4uY29tbW9uLlRpbWVzdGFtcFIMbGFzdEVkaXRlZEF0Ek4KDnZvaWNlX21ldGFkYXRhGBMgAS'
    'gLMicuZ3VhcmR5bi5tZXNzYWdpbmcuVm9pY2VNZXNzYWdlTWV0YWRhdGFSDXZvaWNlTWV0YWRh'
    'dGESUQoScmVhY3Rpb25fc3VtbWFyaWVzGBQgAygLMiIuZ3VhcmR5bi5tZXNzYWdpbmcuUmVhY3'
    'Rpb25TdW1tYXJ5UhFyZWFjdGlvblN1bW1hcmllcw==');

@$core.Deprecated('Use reactionSummaryDescriptor instead')
const ReactionSummary$json = {
  '1': 'ReactionSummary',
  '2': [
    {'1': 'emoji', '3': 1, '4': 1, '5': 9, '10': 'emoji'},
    {'1': 'count', '3': 2, '4': 1, '5': 5, '10': 'count'},
    {'1': 'user_reacted', '3': 3, '4': 1, '5': 8, '10': 'userReacted'},
  ],
};

/// Descriptor for `ReactionSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reactionSummaryDescriptor = $convert.base64Decode(
    'Cg9SZWFjdGlvblN1bW1hcnkSFAoFZW1vamkYASABKAlSBWVtb2ppEhQKBWNvdW50GAIgASgFUg'
    'Vjb3VudBIhCgx1c2VyX3JlYWN0ZWQYAyABKAhSC3VzZXJSZWFjdGVk');

@$core.Deprecated('Use getMessagesRequestDescriptor instead')
const GetMessagesRequest$json = {
  '1': 'GetMessagesRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {
      '1': 'conversation_user_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'conversationUserId'
    },
    {'1': 'conversation_id', '3': 6, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'pagination',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.PaginationRequest',
      '10': 'pagination'
    },
    {'1': 'limit', '3': 7, '4': 1, '5': 5, '10': 'limit'},
    {
      '1': 'start_time',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'endTime'
    },
  ],
};

/// Descriptor for `GetMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMessagesRequestDescriptor = $convert.base64Decode(
    'ChJHZXRNZXNzYWdlc1JlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbh'
    'IwChRjb252ZXJzYXRpb25fdXNlcl9pZBgCIAEoCVISY29udmVyc2F0aW9uVXNlcklkEicKD2Nv'
    'bnZlcnNhdGlvbl9pZBgGIAEoCVIOY29udmVyc2F0aW9uSWQSQQoKcGFnaW5hdGlvbhgDIAEoCz'
    'IhLmd1YXJkeW4uY29tbW9uLlBhZ2luYXRpb25SZXF1ZXN0UgpwYWdpbmF0aW9uEhQKBWxpbWl0'
    'GAcgASgFUgVsaW1pdBI4CgpzdGFydF90aW1lGAQgASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZX'
    'N0YW1wUglzdGFydFRpbWUSNAoIZW5kX3RpbWUYBSABKAsyGS5ndWFyZHluLmNvbW1vbi5UaW1l'
    'c3RhbXBSB2VuZFRpbWU=');

@$core.Deprecated('Use getMessagesResponseDescriptor instead')
const GetMessagesResponse$json = {
  '1': 'GetMessagesResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.GetMessagesSuccess',
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

/// Descriptor for `GetMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMessagesResponseDescriptor = $convert.base64Decode(
    'ChNHZXRNZXNzYWdlc1Jlc3BvbnNlEkEKB3N1Y2Nlc3MYASABKAsyJS5ndWFyZHluLm1lc3NhZ2'
    'luZy5HZXRNZXNzYWdlc1N1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJk'
    'eW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use getMessagesSuccessDescriptor instead')
const GetMessagesSuccess$json = {
  '1': 'GetMessagesSuccess',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.guardyn.messaging.Message',
      '10': 'messages'
    },
    {
      '1': 'pagination',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.PaginationResponse',
      '10': 'pagination'
    },
    {'1': 'has_more', '3': 3, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `GetMessagesSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMessagesSuccessDescriptor = $convert.base64Decode(
    'ChJHZXRNZXNzYWdlc1N1Y2Nlc3MSNgoIbWVzc2FnZXMYASADKAsyGi5ndWFyZHluLm1lc3NhZ2'
    'luZy5NZXNzYWdlUghtZXNzYWdlcxJCCgpwYWdpbmF0aW9uGAIgASgLMiIuZ3VhcmR5bi5jb21t'
    'b24uUGFnaW5hdGlvblJlc3BvbnNlUgpwYWdpbmF0aW9uEhkKCGhhc19tb3JlGAMgASgIUgdoYX'
    'NNb3Jl');

@$core.Deprecated('Use getConversationsRequestDescriptor instead')
const GetConversationsRequest$json = {
  '1': 'GetConversationsRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'limit', '3': 2, '4': 1, '5': 13, '10': 'limit'},
  ],
};

/// Descriptor for `GetConversationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConversationsRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRDb252ZXJzYXRpb25zUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1'
        'Rva2VuEhQKBWxpbWl0GAIgASgNUgVsaW1pdA==');

@$core.Deprecated('Use getConversationsResponseDescriptor instead')
const GetConversationsResponse$json = {
  '1': 'GetConversationsResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.GetConversationsSuccess',
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

/// Descriptor for `GetConversationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConversationsResponseDescriptor = $convert.base64Decode(
    'ChhHZXRDb252ZXJzYXRpb25zUmVzcG9uc2USRgoHc3VjY2VzcxgBIAEoCzIqLmd1YXJkeW4ubW'
    'Vzc2FnaW5nLkdldENvbnZlcnNhdGlvbnNTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiAB'
    'KAsyHS5ndWFyZHluLmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use getConversationsSuccessDescriptor instead')
const GetConversationsSuccess$json = {
  '1': 'GetConversationsSuccess',
  '2': [
    {
      '1': 'conversations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.guardyn.messaging.Conversation',
      '10': 'conversations'
    },
  ],
};

/// Descriptor for `GetConversationsSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConversationsSuccessDescriptor =
    $convert.base64Decode(
        'ChdHZXRDb252ZXJzYXRpb25zU3VjY2VzcxJFCg1jb252ZXJzYXRpb25zGAEgAygLMh8uZ3Vhcm'
        'R5bi5tZXNzYWdpbmcuQ29udmVyc2F0aW9uUg1jb252ZXJzYXRpb25z');

@$core.Deprecated('Use conversationDescriptor instead')
const Conversation$json = {
  '1': 'Conversation',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 3, '4': 1, '5': 9, '10': 'username'},
    {
      '1': 'last_message',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.Message',
      '10': 'lastMessage'
    },
    {'1': 'unread_count', '3': 5, '4': 1, '5': 13, '10': 'unreadCount'},
    {
      '1': 'updated_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `Conversation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationDescriptor = $convert.base64Decode(
    'CgxDb252ZXJzYXRpb24SJwoPY29udmVyc2F0aW9uX2lkGAEgASgJUg5jb252ZXJzYXRpb25JZB'
    'IXCgd1c2VyX2lkGAIgASgJUgZ1c2VySWQSGgoIdXNlcm5hbWUYAyABKAlSCHVzZXJuYW1lEj0K'
    'DGxhc3RfbWVzc2FnZRgEIAEoCzIaLmd1YXJkeW4ubWVzc2FnaW5nLk1lc3NhZ2VSC2xhc3RNZX'
    'NzYWdlEiEKDHVucmVhZF9jb3VudBgFIAEoDVILdW5yZWFkQ291bnQSOAoKdXBkYXRlZF9hdBgG'
    'IAEoCzIZLmd1YXJkeW4uY29tbW9uLlRpbWVzdGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use markAsReadRequestDescriptor instead')
const MarkAsReadRequest$json = {
  '1': 'MarkAsReadRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'message_ids', '3': 2, '4': 3, '5': 9, '10': 'messageIds'},
  ],
};

/// Descriptor for `MarkAsReadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markAsReadRequestDescriptor = $convert.base64Decode(
    'ChFNYXJrQXNSZWFkUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2VuEh'
    '8KC21lc3NhZ2VfaWRzGAIgAygJUgptZXNzYWdlSWRz');

@$core.Deprecated('Use markAsReadResponseDescriptor instead')
const MarkAsReadResponse$json = {
  '1': 'MarkAsReadResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.MarkAsReadSuccess',
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

/// Descriptor for `MarkAsReadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markAsReadResponseDescriptor = $convert.base64Decode(
    'ChJNYXJrQXNSZWFkUmVzcG9uc2USQAoHc3VjY2VzcxgBIAEoCzIkLmd1YXJkeW4ubWVzc2FnaW'
    '5nLk1hcmtBc1JlYWRTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFyZHlu'
    'LmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use markAsReadSuccessDescriptor instead')
const MarkAsReadSuccess$json = {
  '1': 'MarkAsReadSuccess',
  '2': [
    {'1': 'messages_marked', '3': 1, '4': 1, '5': 13, '10': 'messagesMarked'},
    {'1': 'marked_count', '3': 2, '4': 1, '5': 5, '10': 'markedCount'},
    {
      '1': 'timestamp',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `MarkAsReadSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markAsReadSuccessDescriptor = $convert.base64Decode(
    'ChFNYXJrQXNSZWFkU3VjY2VzcxInCg9tZXNzYWdlc19tYXJrZWQYASABKA1SDm1lc3NhZ2VzTW'
    'Fya2VkEiEKDG1hcmtlZF9jb3VudBgCIAEoBVILbWFya2VkQ291bnQSNwoJdGltZXN0YW1wGAMg'
    'ASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW1wUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use deleteMessageRequestDescriptor instead')
const DeleteMessageRequest$json = {
  '1': 'DeleteMessageRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 4, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'delete_for_everyone',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'deleteForEveryone'
    },
  ],
};

/// Descriptor for `DeleteMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteMessageRequestDescriptor = $convert.base64Decode(
    'ChREZWxldGVNZXNzYWdlUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2'
    'VuEh0KCm1lc3NhZ2VfaWQYAiABKAlSCW1lc3NhZ2VJZBInCg9jb252ZXJzYXRpb25faWQYBCAB'
    'KAlSDmNvbnZlcnNhdGlvbklkEi4KE2RlbGV0ZV9mb3JfZXZlcnlvbmUYAyABKAhSEWRlbGV0ZU'
    'ZvckV2ZXJ5b25l');

@$core.Deprecated('Use deleteMessageResponseDescriptor instead')
const DeleteMessageResponse$json = {
  '1': 'DeleteMessageResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.DeleteMessageSuccess',
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

/// Descriptor for `DeleteMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteMessageResponseDescriptor = $convert.base64Decode(
    'ChVEZWxldGVNZXNzYWdlUmVzcG9uc2USQwoHc3VjY2VzcxgBIAEoCzInLmd1YXJkeW4ubWVzc2'
    'FnaW5nLkRlbGV0ZU1lc3NhZ2VTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5n'
    'dWFyZHluLmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use deleteMessageSuccessDescriptor instead')
const DeleteMessageSuccess$json = {
  '1': 'DeleteMessageSuccess',
  '2': [
    {'1': 'deleted', '3': 1, '4': 1, '5': 8, '10': 'deleted'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {
      '1': 'timestamp',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `DeleteMessageSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteMessageSuccessDescriptor = $convert.base64Decode(
    'ChREZWxldGVNZXNzYWdlU3VjY2VzcxIYCgdkZWxldGVkGAEgASgIUgdkZWxldGVkEh0KCm1lc3'
    'NhZ2VfaWQYAiABKAlSCW1lc3NhZ2VJZBI3Cgl0aW1lc3RhbXAYAyABKAsyGS5ndWFyZHluLmNv'
    'bW1vbi5UaW1lc3RhbXBSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use clearChatRequestDescriptor instead')
const ClearChatRequest$json = {
  '1': 'ClearChatRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `ClearChatRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearChatRequestDescriptor = $convert.base64Decode(
    'ChBDbGVhckNoYXRSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW4SJw'
    'oPY29udmVyc2F0aW9uX2lkGAIgASgJUg5jb252ZXJzYXRpb25JZA==');

@$core.Deprecated('Use clearChatResponseDescriptor instead')
const ClearChatResponse$json = {
  '1': 'ClearChatResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.ClearChatSuccess',
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

/// Descriptor for `ClearChatResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearChatResponseDescriptor = $convert.base64Decode(
    'ChFDbGVhckNoYXRSZXNwb25zZRI/CgdzdWNjZXNzGAEgASgLMiMuZ3VhcmR5bi5tZXNzYWdpbm'
    'cuQ2xlYXJDaGF0U3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0uZ3VhcmR5bi5j'
    'b21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use clearChatSuccessDescriptor instead')
const ClearChatSuccess$json = {
  '1': 'ClearChatSuccess',
  '2': [
    {'1': 'deleted_count', '3': 1, '4': 1, '5': 13, '10': 'deletedCount'},
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `ClearChatSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clearChatSuccessDescriptor = $convert.base64Decode(
    'ChBDbGVhckNoYXRTdWNjZXNzEiMKDWRlbGV0ZWRfY291bnQYASABKA1SDGRlbGV0ZWRDb3VudB'
    'I3Cgl0aW1lc3RhbXAYAiABKAsyGS5ndWFyZHluLmNvbW1vbi5UaW1lc3RhbXBSCXRpbWVzdGFt'
    'cA==');

@$core.Deprecated('Use typingIndicatorRequestDescriptor instead')
const TypingIndicatorRequest$json = {
  '1': 'TypingIndicatorRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'recipient_user_id', '3': 2, '4': 1, '5': 9, '10': 'recipientUserId'},
    {'1': 'is_typing', '3': 3, '4': 1, '5': 8, '10': 'isTyping'},
    {'1': 'group_id', '3': 4, '4': 1, '5': 9, '10': 'groupId'},
  ],
};

/// Descriptor for `TypingIndicatorRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingIndicatorRequestDescriptor = $convert.base64Decode(
    'ChZUeXBpbmdJbmRpY2F0b3JSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG'
    '9rZW4SKgoRcmVjaXBpZW50X3VzZXJfaWQYAiABKAlSD3JlY2lwaWVudFVzZXJJZBIbCglpc190'
    'eXBpbmcYAyABKAhSCGlzVHlwaW5nEhkKCGdyb3VwX2lkGAQgASgJUgdncm91cElk');

@$core.Deprecated('Use typingIndicatorResponseDescriptor instead')
const TypingIndicatorResponse$json = {
  '1': 'TypingIndicatorResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.TypingIndicatorSuccess',
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

/// Descriptor for `TypingIndicatorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingIndicatorResponseDescriptor = $convert.base64Decode(
    'ChdUeXBpbmdJbmRpY2F0b3JSZXNwb25zZRJFCgdzdWNjZXNzGAEgASgLMikuZ3VhcmR5bi5tZX'
    'NzYWdpbmcuVHlwaW5nSW5kaWNhdG9yU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgL'
    'Mh0uZ3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use typingIndicatorSuccessDescriptor instead')
const TypingIndicatorSuccess$json = {
  '1': 'TypingIndicatorSuccess',
  '2': [
    {'1': 'sent', '3': 1, '4': 1, '5': 8, '10': 'sent'},
  ],
};

/// Descriptor for `TypingIndicatorSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingIndicatorSuccessDescriptor =
    $convert.base64Decode(
        'ChZUeXBpbmdJbmRpY2F0b3JTdWNjZXNzEhIKBHNlbnQYASABKAhSBHNlbnQ=');

@$core.Deprecated('Use createGroupRequestDescriptor instead')
const CreateGroupRequest$json = {
  '1': 'CreateGroupRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'group_name', '3': 2, '4': 1, '5': 9, '10': 'groupName'},
    {'1': 'member_user_ids', '3': 3, '4': 3, '5': 9, '10': 'memberUserIds'},
    {'1': 'mls_group_state', '3': 4, '4': 1, '5': 12, '10': 'mlsGroupState'},
    {'1': 'icon_media_id', '3': 5, '4': 1, '5': 9, '10': 'iconMediaId'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `CreateGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVHcm91cFJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbh'
    'IdCgpncm91cF9uYW1lGAIgASgJUglncm91cE5hbWUSJgoPbWVtYmVyX3VzZXJfaWRzGAMgAygJ'
    'Ug1tZW1iZXJVc2VySWRzEiYKD21sc19ncm91cF9zdGF0ZRgEIAEoDFINbWxzR3JvdXBTdGF0ZR'
    'IiCg1pY29uX21lZGlhX2lkGAUgASgJUgtpY29uTWVkaWFJZBIgCgtkZXNjcmlwdGlvbhgGIAEo'
    'CVILZGVzY3JpcHRpb24=');

@$core.Deprecated('Use createGroupResponseDescriptor instead')
const CreateGroupResponse$json = {
  '1': 'CreateGroupResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.CreateGroupSuccess',
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

/// Descriptor for `CreateGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupResponseDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVHcm91cFJlc3BvbnNlEkEKB3N1Y2Nlc3MYASABKAsyJS5ndWFyZHluLm1lc3NhZ2'
    'luZy5DcmVhdGVHcm91cFN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJk'
    'eW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use createGroupSuccessDescriptor instead')
const CreateGroupSuccess$json = {
  '1': 'CreateGroupSuccess',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 9, '10': 'groupId'},
    {
      '1': 'created_at',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `CreateGroupSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupSuccessDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVHcm91cFN1Y2Nlc3MSGQoIZ3JvdXBfaWQYASABKAlSB2dyb3VwSWQSOAoKY3JlYX'
    'RlZF9hdBgCIAEoCzIZLmd1YXJkeW4uY29tbW9uLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use addGroupMemberRequestDescriptor instead')
const AddGroupMemberRequest$json = {
  '1': 'AddGroupMemberRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'member_user_id', '3': 3, '4': 1, '5': 9, '10': 'memberUserId'},
    {'1': 'member_device_id', '3': 4, '4': 1, '5': 9, '10': 'memberDeviceId'},
    {'1': 'mls_group_state', '3': 5, '4': 1, '5': 12, '10': 'mlsGroupState'},
  ],
};

/// Descriptor for `AddGroupMemberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addGroupMemberRequestDescriptor = $convert.base64Decode(
    'ChVBZGRHcm91cE1lbWJlclJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2'
    'tlbhIZCghncm91cF9pZBgCIAEoCVIHZ3JvdXBJZBIkCg5tZW1iZXJfdXNlcl9pZBgDIAEoCVIM'
    'bWVtYmVyVXNlcklkEigKEG1lbWJlcl9kZXZpY2VfaWQYBCABKAlSDm1lbWJlckRldmljZUlkEi'
    'YKD21sc19ncm91cF9zdGF0ZRgFIAEoDFINbWxzR3JvdXBTdGF0ZQ==');

@$core.Deprecated('Use addGroupMemberResponseDescriptor instead')
const AddGroupMemberResponse$json = {
  '1': 'AddGroupMemberResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.AddGroupMemberSuccess',
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

/// Descriptor for `AddGroupMemberResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addGroupMemberResponseDescriptor = $convert.base64Decode(
    'ChZBZGRHcm91cE1lbWJlclJlc3BvbnNlEkQKB3N1Y2Nlc3MYASABKAsyKC5ndWFyZHluLm1lc3'
    'NhZ2luZy5BZGRHcm91cE1lbWJlclN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzId'
    'Lmd1YXJkeW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use addGroupMemberSuccessDescriptor instead')
const AddGroupMemberSuccess$json = {
  '1': 'AddGroupMemberSuccess',
  '2': [
    {'1': 'added', '3': 1, '4': 1, '5': 8, '10': 'added'},
  ],
};

/// Descriptor for `AddGroupMemberSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addGroupMemberSuccessDescriptor =
    $convert.base64Decode(
        'ChVBZGRHcm91cE1lbWJlclN1Y2Nlc3MSFAoFYWRkZWQYASABKAhSBWFkZGVk');

@$core.Deprecated('Use removeGroupMemberRequestDescriptor instead')
const RemoveGroupMemberRequest$json = {
  '1': 'RemoveGroupMemberRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'member_user_id', '3': 3, '4': 1, '5': 9, '10': 'memberUserId'},
    {'1': 'mls_group_state', '3': 4, '4': 1, '5': 12, '10': 'mlsGroupState'},
  ],
};

/// Descriptor for `RemoveGroupMemberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeGroupMemberRequestDescriptor = $convert.base64Decode(
    'ChhSZW1vdmVHcm91cE1lbWJlclJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3'
    'NUb2tlbhIZCghncm91cF9pZBgCIAEoCVIHZ3JvdXBJZBIkCg5tZW1iZXJfdXNlcl9pZBgDIAEo'
    'CVIMbWVtYmVyVXNlcklkEiYKD21sc19ncm91cF9zdGF0ZRgEIAEoDFINbWxzR3JvdXBTdGF0ZQ'
    '==');

@$core.Deprecated('Use removeGroupMemberResponseDescriptor instead')
const RemoveGroupMemberResponse$json = {
  '1': 'RemoveGroupMemberResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.RemoveGroupMemberSuccess',
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

/// Descriptor for `RemoveGroupMemberResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeGroupMemberResponseDescriptor = $convert.base64Decode(
    'ChlSZW1vdmVHcm91cE1lbWJlclJlc3BvbnNlEkcKB3N1Y2Nlc3MYASABKAsyKy5ndWFyZHluLm'
    '1lc3NhZ2luZy5SZW1vdmVHcm91cE1lbWJlclN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgC'
    'IAEoCzIdLmd1YXJkeW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use removeGroupMemberSuccessDescriptor instead')
const RemoveGroupMemberSuccess$json = {
  '1': 'RemoveGroupMemberSuccess',
  '2': [
    {'1': 'removed', '3': 1, '4': 1, '5': 8, '10': 'removed'},
  ],
};

/// Descriptor for `RemoveGroupMemberSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeGroupMemberSuccessDescriptor =
    $convert.base64Decode(
        'ChhSZW1vdmVHcm91cE1lbWJlclN1Y2Nlc3MSGAoHcmVtb3ZlZBgBIAEoCFIHcmVtb3ZlZA==');

@$core.Deprecated('Use changeMemberRoleRequestDescriptor instead')
const ChangeMemberRoleRequest$json = {
  '1': 'ChangeMemberRoleRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'target_user_id', '3': 3, '4': 1, '5': 9, '10': 'targetUserId'},
    {'1': 'new_role', '3': 4, '4': 1, '5': 9, '10': 'newRole'},
  ],
};

/// Descriptor for `ChangeMemberRoleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeMemberRoleRequestDescriptor = $convert.base64Decode(
    'ChdDaGFuZ2VNZW1iZXJSb2xlUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1'
    'Rva2VuEhkKCGdyb3VwX2lkGAIgASgJUgdncm91cElkEiQKDnRhcmdldF91c2VyX2lkGAMgASgJ'
    'Ugx0YXJnZXRVc2VySWQSGQoIbmV3X3JvbGUYBCABKAlSB25ld1JvbGU=');

@$core.Deprecated('Use changeMemberRoleResponseDescriptor instead')
const ChangeMemberRoleResponse$json = {
  '1': 'ChangeMemberRoleResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.ChangeMemberRoleSuccess',
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

/// Descriptor for `ChangeMemberRoleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeMemberRoleResponseDescriptor = $convert.base64Decode(
    'ChhDaGFuZ2VNZW1iZXJSb2xlUmVzcG9uc2USRgoHc3VjY2VzcxgBIAEoCzIqLmd1YXJkeW4ubW'
    'Vzc2FnaW5nLkNoYW5nZU1lbWJlclJvbGVTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiAB'
    'KAsyHS5ndWFyZHluLmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use changeMemberRoleSuccessDescriptor instead')
const ChangeMemberRoleSuccess$json = {
  '1': 'ChangeMemberRoleSuccess',
  '2': [
    {'1': 'changed', '3': 1, '4': 1, '5': 8, '10': 'changed'},
    {'1': 'new_role', '3': 2, '4': 1, '5': 9, '10': 'newRole'},
  ],
};

/// Descriptor for `ChangeMemberRoleSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeMemberRoleSuccessDescriptor =
    $convert.base64Decode(
        'ChdDaGFuZ2VNZW1iZXJSb2xlU3VjY2VzcxIYCgdjaGFuZ2VkGAEgASgIUgdjaGFuZ2VkEhkKCG'
        '5ld19yb2xlGAIgASgJUgduZXdSb2xl');

@$core.Deprecated('Use sendGroupMessageRequestDescriptor instead')
const SendGroupMessageRequest$json = {
  '1': 'SendGroupMessageRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {
      '1': 'encrypted_content',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'encryptedContent'
    },
    {
      '1': 'message_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.guardyn.messaging.MessageType',
      '10': 'messageType'
    },
    {'1': 'client_message_id', '3': 5, '4': 1, '5': 9, '10': 'clientMessageId'},
    {
      '1': 'client_timestamp',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'clientTimestamp'
    },
    {'1': 'media_id', '3': 7, '4': 1, '5': 9, '10': 'mediaId'},
    {
      '1': 'thread_reference',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.ThreadReference',
      '10': 'threadReference'
    },
    {
      '1': 'voice_metadata',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.VoiceMessageMetadata',
      '10': 'voiceMetadata'
    },
  ],
};

/// Descriptor for `SendGroupMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendGroupMessageRequestDescriptor = $convert.base64Decode(
    'ChdTZW5kR3JvdXBNZXNzYWdlUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1'
    'Rva2VuEhkKCGdyb3VwX2lkGAIgASgJUgdncm91cElkEisKEWVuY3J5cHRlZF9jb250ZW50GAMg'
    'ASgMUhBlbmNyeXB0ZWRDb250ZW50EkEKDG1lc3NhZ2VfdHlwZRgEIAEoDjIeLmd1YXJkeW4ubW'
    'Vzc2FnaW5nLk1lc3NhZ2VUeXBlUgttZXNzYWdlVHlwZRIqChFjbGllbnRfbWVzc2FnZV9pZBgF'
    'IAEoCVIPY2xpZW50TWVzc2FnZUlkEkQKEGNsaWVudF90aW1lc3RhbXAYBiABKAsyGS5ndWFyZH'
    'luLmNvbW1vbi5UaW1lc3RhbXBSD2NsaWVudFRpbWVzdGFtcBIZCghtZWRpYV9pZBgHIAEoCVIH'
    'bWVkaWFJZBJNChB0aHJlYWRfcmVmZXJlbmNlGAggASgLMiIuZ3VhcmR5bi5tZXNzYWdpbmcuVG'
    'hyZWFkUmVmZXJlbmNlUg90aHJlYWRSZWZlcmVuY2USTgoOdm9pY2VfbWV0YWRhdGEYCSABKAsy'
    'Jy5ndWFyZHluLm1lc3NhZ2luZy5Wb2ljZU1lc3NhZ2VNZXRhZGF0YVINdm9pY2VNZXRhZGF0YQ'
    '==');

@$core.Deprecated('Use sendGroupMessageResponseDescriptor instead')
const SendGroupMessageResponse$json = {
  '1': 'SendGroupMessageResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.SendGroupMessageSuccess',
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

/// Descriptor for `SendGroupMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendGroupMessageResponseDescriptor = $convert.base64Decode(
    'ChhTZW5kR3JvdXBNZXNzYWdlUmVzcG9uc2USRgoHc3VjY2VzcxgBIAEoCzIqLmd1YXJkeW4ubW'
    'Vzc2FnaW5nLlNlbmRHcm91cE1lc3NhZ2VTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiAB'
    'KAsyHS5ndWFyZHluLmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use sendGroupMessageSuccessDescriptor instead')
const SendGroupMessageSuccess$json = {
  '1': 'SendGroupMessageSuccess',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {
      '1': 'server_timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'serverTimestamp'
    },
  ],
};

/// Descriptor for `SendGroupMessageSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendGroupMessageSuccessDescriptor = $convert.base64Decode(
    'ChdTZW5kR3JvdXBNZXNzYWdlU3VjY2VzcxIdCgptZXNzYWdlX2lkGAEgASgJUgltZXNzYWdlSW'
    'QSRAoQc2VydmVyX3RpbWVzdGFtcBgCIAEoCzIZLmd1YXJkeW4uY29tbW9uLlRpbWVzdGFtcFIP'
    'c2VydmVyVGltZXN0YW1w');

@$core.Deprecated('Use getGroupMessagesRequestDescriptor instead')
const GetGroupMessagesRequest$json = {
  '1': 'GetGroupMessagesRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {
      '1': 'pagination',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.PaginationRequest',
      '10': 'pagination'
    },
    {'1': 'limit', '3': 6, '4': 1, '5': 5, '10': 'limit'},
    {
      '1': 'start_time',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'endTime'
    },
  ],
};

/// Descriptor for `GetGroupMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupMessagesRequestDescriptor = $convert.base64Decode(
    'ChdHZXRHcm91cE1lc3NhZ2VzUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1'
    'Rva2VuEhkKCGdyb3VwX2lkGAIgASgJUgdncm91cElkEkEKCnBhZ2luYXRpb24YAyABKAsyIS5n'
    'dWFyZHluLmNvbW1vbi5QYWdpbmF0aW9uUmVxdWVzdFIKcGFnaW5hdGlvbhIUCgVsaW1pdBgGIA'
    'EoBVIFbGltaXQSOAoKc3RhcnRfdGltZRgEIAEoCzIZLmd1YXJkeW4uY29tbW9uLlRpbWVzdGFt'
    'cFIJc3RhcnRUaW1lEjQKCGVuZF90aW1lGAUgASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW'
    '1wUgdlbmRUaW1l');

@$core.Deprecated('Use getGroupMessagesResponseDescriptor instead')
const GetGroupMessagesResponse$json = {
  '1': 'GetGroupMessagesResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.GetGroupMessagesSuccess',
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

/// Descriptor for `GetGroupMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupMessagesResponseDescriptor = $convert.base64Decode(
    'ChhHZXRHcm91cE1lc3NhZ2VzUmVzcG9uc2USRgoHc3VjY2VzcxgBIAEoCzIqLmd1YXJkeW4ubW'
    'Vzc2FnaW5nLkdldEdyb3VwTWVzc2FnZXNTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiAB'
    'KAsyHS5ndWFyZHluLmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use getGroupMessagesSuccessDescriptor instead')
const GetGroupMessagesSuccess$json = {
  '1': 'GetGroupMessagesSuccess',
  '2': [
    {
      '1': 'messages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.guardyn.messaging.GroupMessage',
      '10': 'messages'
    },
    {
      '1': 'pagination',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.PaginationResponse',
      '10': 'pagination'
    },
  ],
};

/// Descriptor for `GetGroupMessagesSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupMessagesSuccessDescriptor = $convert.base64Decode(
    'ChdHZXRHcm91cE1lc3NhZ2VzU3VjY2VzcxI7CghtZXNzYWdlcxgBIAMoCzIfLmd1YXJkeW4ubW'
    'Vzc2FnaW5nLkdyb3VwTWVzc2FnZVIIbWVzc2FnZXMSQgoKcGFnaW5hdGlvbhgCIAEoCzIiLmd1'
    'YXJkeW4uY29tbW9uLlBhZ2luYXRpb25SZXNwb25zZVIKcGFnaW5hdGlvbg==');

@$core.Deprecated('Use groupMessageDescriptor instead')
const GroupMessage$json = {
  '1': 'GroupMessage',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'sender_user_id', '3': 3, '4': 1, '5': 9, '10': 'senderUserId'},
    {'1': 'sender_device_id', '3': 4, '4': 1, '5': 9, '10': 'senderDeviceId'},
    {'1': 'sender_username', '3': 12, '4': 1, '5': 9, '10': 'senderUsername'},
    {
      '1': 'encrypted_content',
      '3': 5,
      '4': 1,
      '5': 12,
      '10': 'encryptedContent'
    },
    {
      '1': 'message_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.guardyn.messaging.MessageType',
      '10': 'messageType'
    },
    {'1': 'client_message_id', '3': 7, '4': 1, '5': 9, '10': 'clientMessageId'},
    {
      '1': 'client_timestamp',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'clientTimestamp'
    },
    {
      '1': 'server_timestamp',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'serverTimestamp'
    },
    {'1': 'media_id', '3': 10, '4': 1, '5': 9, '10': 'mediaId'},
    {'1': 'is_deleted', '3': 11, '4': 1, '5': 8, '10': 'isDeleted'},
    {
      '1': 'thread_reference',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.ThreadReference',
      '10': 'threadReference'
    },
    {
      '1': 'forward_info',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.ForwardInfo',
      '10': 'forwardInfo'
    },
    {'1': 'edit_version', '3': 15, '4': 1, '5': 5, '10': 'editVersion'},
    {
      '1': 'last_edited_at',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'lastEditedAt'
    },
    {
      '1': 'voice_metadata',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.VoiceMessageMetadata',
      '10': 'voiceMetadata'
    },
    {
      '1': 'reaction_summaries',
      '3': 18,
      '4': 3,
      '5': 11,
      '6': '.guardyn.messaging.ReactionSummary',
      '10': 'reactionSummaries'
    },
  ],
};

/// Descriptor for `GroupMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupMessageDescriptor = $convert.base64Decode(
    'CgxHcm91cE1lc3NhZ2USHQoKbWVzc2FnZV9pZBgBIAEoCVIJbWVzc2FnZUlkEhkKCGdyb3VwX2'
    'lkGAIgASgJUgdncm91cElkEiQKDnNlbmRlcl91c2VyX2lkGAMgASgJUgxzZW5kZXJVc2VySWQS'
    'KAoQc2VuZGVyX2RldmljZV9pZBgEIAEoCVIOc2VuZGVyRGV2aWNlSWQSJwoPc2VuZGVyX3VzZX'
    'JuYW1lGAwgASgJUg5zZW5kZXJVc2VybmFtZRIrChFlbmNyeXB0ZWRfY29udGVudBgFIAEoDFIQ'
    'ZW5jcnlwdGVkQ29udGVudBJBCgxtZXNzYWdlX3R5cGUYBiABKA4yHi5ndWFyZHluLm1lc3NhZ2'
    'luZy5NZXNzYWdlVHlwZVILbWVzc2FnZVR5cGUSKgoRY2xpZW50X21lc3NhZ2VfaWQYByABKAlS'
    'D2NsaWVudE1lc3NhZ2VJZBJEChBjbGllbnRfdGltZXN0YW1wGAggASgLMhkuZ3VhcmR5bi5jb2'
    '1tb24uVGltZXN0YW1wUg9jbGllbnRUaW1lc3RhbXASRAoQc2VydmVyX3RpbWVzdGFtcBgJIAEo'
    'CzIZLmd1YXJkeW4uY29tbW9uLlRpbWVzdGFtcFIPc2VydmVyVGltZXN0YW1wEhkKCG1lZGlhX2'
    'lkGAogASgJUgdtZWRpYUlkEh0KCmlzX2RlbGV0ZWQYCyABKAhSCWlzRGVsZXRlZBJNChB0aHJl'
    'YWRfcmVmZXJlbmNlGA0gASgLMiIuZ3VhcmR5bi5tZXNzYWdpbmcuVGhyZWFkUmVmZXJlbmNlUg'
    '90aHJlYWRSZWZlcmVuY2USQQoMZm9yd2FyZF9pbmZvGA4gASgLMh4uZ3VhcmR5bi5tZXNzYWdp'
    'bmcuRm9yd2FyZEluZm9SC2ZvcndhcmRJbmZvEiEKDGVkaXRfdmVyc2lvbhgPIAEoBVILZWRpdF'
    'ZlcnNpb24SPwoObGFzdF9lZGl0ZWRfYXQYECABKAsyGS5ndWFyZHluLmNvbW1vbi5UaW1lc3Rh'
    'bXBSDGxhc3RFZGl0ZWRBdBJOCg52b2ljZV9tZXRhZGF0YRgRIAEoCzInLmd1YXJkeW4ubWVzc2'
    'FnaW5nLlZvaWNlTWVzc2FnZU1ldGFkYXRhUg12b2ljZU1ldGFkYXRhElEKEnJlYWN0aW9uX3N1'
    'bW1hcmllcxgSIAMoCzIiLmd1YXJkeW4ubWVzc2FnaW5nLlJlYWN0aW9uU3VtbWFyeVIRcmVhY3'
    'Rpb25TdW1tYXJpZXM=');

@$core.Deprecated('Use getGroupsRequestDescriptor instead')
const GetGroupsRequest$json = {
  '1': 'GetGroupsRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `GetGroupsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupsRequestDescriptor = $convert.base64Decode(
    'ChBHZXRHcm91cHNSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW4SFA'
    'oFbGltaXQYAiABKAVSBWxpbWl0EhYKBmN1cnNvchgDIAEoCVIGY3Vyc29y');

@$core.Deprecated('Use getGroupsResponseDescriptor instead')
const GetGroupsResponse$json = {
  '1': 'GetGroupsResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.GetGroupsSuccess',
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

/// Descriptor for `GetGroupsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupsResponseDescriptor = $convert.base64Decode(
    'ChFHZXRHcm91cHNSZXNwb25zZRI/CgdzdWNjZXNzGAEgASgLMiMuZ3VhcmR5bi5tZXNzYWdpbm'
    'cuR2V0R3JvdXBzU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0uZ3VhcmR5bi5j'
    'b21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use getGroupsSuccessDescriptor instead')
const GetGroupsSuccess$json = {
  '1': 'GetGroupsSuccess',
  '2': [
    {
      '1': 'groups',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.guardyn.messaging.GroupInfo',
      '10': 'groups'
    },
    {'1': 'next_cursor', '3': 2, '4': 1, '5': 9, '10': 'nextCursor'},
    {'1': 'has_more', '3': 3, '4': 1, '5': 8, '10': 'hasMore'},
  ],
};

/// Descriptor for `GetGroupsSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupsSuccessDescriptor = $convert.base64Decode(
    'ChBHZXRHcm91cHNTdWNjZXNzEjQKBmdyb3VwcxgBIAMoCzIcLmd1YXJkeW4ubWVzc2FnaW5nLk'
    'dyb3VwSW5mb1IGZ3JvdXBzEh8KC25leHRfY3Vyc29yGAIgASgJUgpuZXh0Q3Vyc29yEhkKCGhh'
    'c19tb3JlGAMgASgIUgdoYXNNb3Jl');

@$core.Deprecated('Use groupInfoDescriptor instead')
const GroupInfo$json = {
  '1': 'GroupInfo',
  '2': [
    {'1': 'group_id', '3': 1, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'creator_user_id', '3': 3, '4': 1, '5': 9, '10': 'creatorUserId'},
    {
      '1': 'members',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.guardyn.messaging.GroupMemberInfo',
      '10': 'members'
    },
    {
      '1': 'created_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'createdAt'
    },
    {'1': 'member_count', '3': 6, '4': 1, '5': 5, '10': 'memberCount'},
    {
      '1': 'last_message',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.GroupMessage',
      '10': 'lastMessage'
    },
    {'1': 'icon_media_id', '3': 8, '4': 1, '5': 9, '10': 'iconMediaId'},
    {'1': 'description', '3': 9, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `GroupInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupInfoDescriptor = $convert.base64Decode(
    'CglHcm91cEluZm8SGQoIZ3JvdXBfaWQYASABKAlSB2dyb3VwSWQSEgoEbmFtZRgCIAEoCVIEbm'
    'FtZRImCg9jcmVhdG9yX3VzZXJfaWQYAyABKAlSDWNyZWF0b3JVc2VySWQSPAoHbWVtYmVycxgE'
    'IAMoCzIiLmd1YXJkeW4ubWVzc2FnaW5nLkdyb3VwTWVtYmVySW5mb1IHbWVtYmVycxI4Cgpjcm'
    'VhdGVkX2F0GAUgASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW1wUgljcmVhdGVkQXQSIQoM'
    'bWVtYmVyX2NvdW50GAYgASgFUgttZW1iZXJDb3VudBJCCgxsYXN0X21lc3NhZ2UYByABKAsyHy'
    '5ndWFyZHluLm1lc3NhZ2luZy5Hcm91cE1lc3NhZ2VSC2xhc3RNZXNzYWdlEiIKDWljb25fbWVk'
    'aWFfaWQYCCABKAlSC2ljb25NZWRpYUlkEiAKC2Rlc2NyaXB0aW9uGAkgASgJUgtkZXNjcmlwdG'
    'lvbg==');

@$core.Deprecated('Use groupMemberInfoDescriptor instead')
const GroupMemberInfo$json = {
  '1': 'GroupMemberInfo',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'device_id', '3': 3, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'role', '3': 4, '4': 1, '5': 9, '10': 'role'},
    {
      '1': 'joined_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'joinedAt'
    },
    {'1': 'avatar_media_id', '3': 6, '4': 1, '5': 9, '10': 'avatarMediaId'},
    {'1': 'display_name', '3': 7, '4': 1, '5': 9, '10': 'displayName'},
  ],
};

/// Descriptor for `GroupMemberInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupMemberInfoDescriptor = $convert.base64Decode(
    'Cg9Hcm91cE1lbWJlckluZm8SFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhoKCHVzZXJuYW1lGA'
    'IgASgJUgh1c2VybmFtZRIbCglkZXZpY2VfaWQYAyABKAlSCGRldmljZUlkEhIKBHJvbGUYBCAB'
    'KAlSBHJvbGUSNgoJam9pbmVkX2F0GAUgASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW1wUg'
    'hqb2luZWRBdBImCg9hdmF0YXJfbWVkaWFfaWQYBiABKAlSDWF2YXRhck1lZGlhSWQSIQoMZGlz'
    'cGxheV9uYW1lGAcgASgJUgtkaXNwbGF5TmFtZQ==');

@$core.Deprecated('Use getGroupByIdRequestDescriptor instead')
const GetGroupByIdRequest$json = {
  '1': 'GetGroupByIdRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
  ],
};

/// Descriptor for `GetGroupByIdRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupByIdRequestDescriptor = $convert.base64Decode(
    'ChNHZXRHcm91cEJ5SWRSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW'
    '4SGQoIZ3JvdXBfaWQYAiABKAlSB2dyb3VwSWQ=');

@$core.Deprecated('Use getGroupByIdResponseDescriptor instead')
const GetGroupByIdResponse$json = {
  '1': 'GetGroupByIdResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.GetGroupByIdSuccess',
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

/// Descriptor for `GetGroupByIdResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupByIdResponseDescriptor = $convert.base64Decode(
    'ChRHZXRHcm91cEJ5SWRSZXNwb25zZRJCCgdzdWNjZXNzGAEgASgLMiYuZ3VhcmR5bi5tZXNzYW'
    'dpbmcuR2V0R3JvdXBCeUlkU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0uZ3Vh'
    'cmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use getGroupByIdSuccessDescriptor instead')
const GetGroupByIdSuccess$json = {
  '1': 'GetGroupByIdSuccess',
  '2': [
    {
      '1': 'group',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.GroupInfo',
      '10': 'group'
    },
  ],
};

/// Descriptor for `GetGroupByIdSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGroupByIdSuccessDescriptor = $convert.base64Decode(
    'ChNHZXRHcm91cEJ5SWRTdWNjZXNzEjIKBWdyb3VwGAEgASgLMhwuZ3VhcmR5bi5tZXNzYWdpbm'
    'cuR3JvdXBJbmZvUgVncm91cA==');

@$core.Deprecated('Use updateGroupRequestDescriptor instead')
const UpdateGroupRequest$json = {
  '1': 'UpdateGroupRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'icon_media_id', '3': 4, '4': 1, '5': 9, '10': 'iconMediaId'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `UpdateGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupRequestDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVHcm91cFJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbh'
    'IZCghncm91cF9pZBgCIAEoCVIHZ3JvdXBJZBISCgRuYW1lGAMgASgJUgRuYW1lEiIKDWljb25f'
    'bWVkaWFfaWQYBCABKAlSC2ljb25NZWRpYUlkEiAKC2Rlc2NyaXB0aW9uGAUgASgJUgtkZXNjcm'
    'lwdGlvbg==');

@$core.Deprecated('Use updateGroupResponseDescriptor instead')
const UpdateGroupResponse$json = {
  '1': 'UpdateGroupResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.UpdateGroupSuccess',
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

/// Descriptor for `UpdateGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupResponseDescriptor = $convert.base64Decode(
    'ChNVcGRhdGVHcm91cFJlc3BvbnNlEkEKB3N1Y2Nlc3MYASABKAsyJS5ndWFyZHluLm1lc3NhZ2'
    'luZy5VcGRhdGVHcm91cFN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJk'
    'eW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use updateGroupSuccessDescriptor instead')
const UpdateGroupSuccess$json = {
  '1': 'UpdateGroupSuccess',
  '2': [
    {
      '1': 'group',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.GroupInfo',
      '10': 'group'
    },
  ],
};

/// Descriptor for `UpdateGroupSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateGroupSuccessDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVHcm91cFN1Y2Nlc3MSMgoFZ3JvdXAYASABKAsyHC5ndWFyZHluLm1lc3NhZ2luZy'
    '5Hcm91cEluZm9SBWdyb3Vw');

@$core.Deprecated('Use leaveGroupRequestDescriptor instead')
const LeaveGroupRequest$json = {
  '1': 'LeaveGroupRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
  ],
};

/// Descriptor for `LeaveGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveGroupRequestDescriptor = $convert.base64Decode(
    'ChFMZWF2ZUdyb3VwUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2VuEh'
    'kKCGdyb3VwX2lkGAIgASgJUgdncm91cElk');

@$core.Deprecated('Use leaveGroupResponseDescriptor instead')
const LeaveGroupResponse$json = {
  '1': 'LeaveGroupResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.LeaveGroupSuccess',
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

/// Descriptor for `LeaveGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveGroupResponseDescriptor = $convert.base64Decode(
    'ChJMZWF2ZUdyb3VwUmVzcG9uc2USQAoHc3VjY2VzcxgBIAEoCzIkLmd1YXJkeW4ubWVzc2FnaW'
    '5nLkxlYXZlR3JvdXBTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFyZHlu'
    'LmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use leaveGroupSuccessDescriptor instead')
const LeaveGroupSuccess$json = {
  '1': 'LeaveGroupSuccess',
  '2': [
    {'1': 'left', '3': 1, '4': 1, '5': 8, '10': 'left'},
  ],
};

/// Descriptor for `LeaveGroupSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveGroupSuccessDescriptor = $convert
    .base64Decode('ChFMZWF2ZUdyb3VwU3VjY2VzcxISCgRsZWZ0GAEgASgIUgRsZWZ0');

@$core.Deprecated('Use deleteGroupRequestDescriptor instead')
const DeleteGroupRequest$json = {
  '1': 'DeleteGroupRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
  ],
};

/// Descriptor for `DeleteGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteGroupRequestDescriptor = $convert.base64Decode(
    'ChJEZWxldGVHcm91cFJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbh'
    'IZCghncm91cF9pZBgCIAEoCVIHZ3JvdXBJZA==');

@$core.Deprecated('Use deleteGroupResponseDescriptor instead')
const DeleteGroupResponse$json = {
  '1': 'DeleteGroupResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.DeleteGroupSuccess',
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

/// Descriptor for `DeleteGroupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteGroupResponseDescriptor = $convert.base64Decode(
    'ChNEZWxldGVHcm91cFJlc3BvbnNlEkEKB3N1Y2Nlc3MYASABKAsyJS5ndWFyZHluLm1lc3NhZ2'
    'luZy5EZWxldGVHcm91cFN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJk'
    'eW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use deleteGroupSuccessDescriptor instead')
const DeleteGroupSuccess$json = {
  '1': 'DeleteGroupSuccess',
  '2': [
    {'1': 'deleted', '3': 1, '4': 1, '5': 8, '10': 'deleted'},
    {'1': 'group_id', '3': 2, '4': 1, '5': 9, '10': 'groupId'},
  ],
};

/// Descriptor for `DeleteGroupSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteGroupSuccessDescriptor = $convert.base64Decode(
    'ChJEZWxldGVHcm91cFN1Y2Nlc3MSGAoHZGVsZXRlZBgBIAEoCFIHZGVsZXRlZBIZCghncm91cF'
    '9pZBgCIAEoCVIHZ3JvdXBJZA==');

@$core.Deprecated('Use reactionDescriptor instead')
const Reaction$json = {
  '1': 'Reaction',
  '2': [
    {'1': 'reaction_id', '3': 1, '4': 1, '5': 9, '10': 'reactionId'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'emoji', '3': 4, '4': 1, '5': 9, '10': 'emoji'},
    {
      '1': 'created_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `Reaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reactionDescriptor = $convert.base64Decode(
    'CghSZWFjdGlvbhIfCgtyZWFjdGlvbl9pZBgBIAEoCVIKcmVhY3Rpb25JZBIdCgptZXNzYWdlX2'
    'lkGAIgASgJUgltZXNzYWdlSWQSFwoHdXNlcl9pZBgDIAEoCVIGdXNlcklkEhQKBWVtb2ppGAQg'
    'ASgJUgVlbW9qaRI4CgpjcmVhdGVkX2F0GAUgASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW'
    '1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use addReactionRequestDescriptor instead')
const AddReactionRequest$json = {
  '1': 'AddReactionRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 3, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'emoji', '3': 4, '4': 1, '5': 9, '10': 'emoji'},
    {'1': 'is_group', '3': 5, '4': 1, '5': 8, '10': 'isGroup'},
  ],
};

/// Descriptor for `AddReactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addReactionRequestDescriptor = $convert.base64Decode(
    'ChJBZGRSZWFjdGlvblJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbh'
    'IdCgptZXNzYWdlX2lkGAIgASgJUgltZXNzYWdlSWQSJwoPY29udmVyc2F0aW9uX2lkGAMgASgJ'
    'Ug5jb252ZXJzYXRpb25JZBIUCgVlbW9qaRgEIAEoCVIFZW1vamkSGQoIaXNfZ3JvdXAYBSABKA'
    'hSB2lzR3JvdXA=');

@$core.Deprecated('Use addReactionResponseDescriptor instead')
const AddReactionResponse$json = {
  '1': 'AddReactionResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.AddReactionSuccess',
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

/// Descriptor for `AddReactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addReactionResponseDescriptor = $convert.base64Decode(
    'ChNBZGRSZWFjdGlvblJlc3BvbnNlEkEKB3N1Y2Nlc3MYASABKAsyJS5ndWFyZHluLm1lc3NhZ2'
    'luZy5BZGRSZWFjdGlvblN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJk'
    'eW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use addReactionSuccessDescriptor instead')
const AddReactionSuccess$json = {
  '1': 'AddReactionSuccess',
  '2': [
    {
      '1': 'reaction',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.Reaction',
      '10': 'reaction'
    },
  ],
};

/// Descriptor for `AddReactionSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addReactionSuccessDescriptor = $convert.base64Decode(
    'ChJBZGRSZWFjdGlvblN1Y2Nlc3MSNwoIcmVhY3Rpb24YASABKAsyGy5ndWFyZHluLm1lc3NhZ2'
    'luZy5SZWFjdGlvblIIcmVhY3Rpb24=');

@$core.Deprecated('Use removeReactionRequestDescriptor instead')
const RemoveReactionRequest$json = {
  '1': 'RemoveReactionRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 3, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'emoji', '3': 4, '4': 1, '5': 9, '10': 'emoji'},
    {'1': 'is_group', '3': 5, '4': 1, '5': 8, '10': 'isGroup'},
  ],
};

/// Descriptor for `RemoveReactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeReactionRequestDescriptor = $convert.base64Decode(
    'ChVSZW1vdmVSZWFjdGlvblJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2'
    'tlbhIdCgptZXNzYWdlX2lkGAIgASgJUgltZXNzYWdlSWQSJwoPY29udmVyc2F0aW9uX2lkGAMg'
    'ASgJUg5jb252ZXJzYXRpb25JZBIUCgVlbW9qaRgEIAEoCVIFZW1vamkSGQoIaXNfZ3JvdXAYBS'
    'ABKAhSB2lzR3JvdXA=');

@$core.Deprecated('Use removeReactionResponseDescriptor instead')
const RemoveReactionResponse$json = {
  '1': 'RemoveReactionResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.RemoveReactionSuccess',
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

/// Descriptor for `RemoveReactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeReactionResponseDescriptor = $convert.base64Decode(
    'ChZSZW1vdmVSZWFjdGlvblJlc3BvbnNlEkQKB3N1Y2Nlc3MYASABKAsyKC5ndWFyZHluLm1lc3'
    'NhZ2luZy5SZW1vdmVSZWFjdGlvblN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzId'
    'Lmd1YXJkeW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use removeReactionSuccessDescriptor instead')
const RemoveReactionSuccess$json = {
  '1': 'RemoveReactionSuccess',
  '2': [
    {'1': 'removed', '3': 1, '4': 1, '5': 8, '10': 'removed'},
  ],
};

/// Descriptor for `RemoveReactionSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeReactionSuccessDescriptor =
    $convert.base64Decode(
        'ChVSZW1vdmVSZWFjdGlvblN1Y2Nlc3MSGAoHcmVtb3ZlZBgBIAEoCFIHcmVtb3ZlZA==');

@$core.Deprecated('Use getReactionsRequestDescriptor instead')
const GetReactionsRequest$json = {
  '1': 'GetReactionsRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 3, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_group', '3': 4, '4': 1, '5': 8, '10': 'isGroup'},
  ],
};

/// Descriptor for `GetReactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReactionsRequestDescriptor = $convert.base64Decode(
    'ChNHZXRSZWFjdGlvbnNSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW'
    '4SHQoKbWVzc2FnZV9pZBgCIAEoCVIJbWVzc2FnZUlkEicKD2NvbnZlcnNhdGlvbl9pZBgDIAEo'
    'CVIOY29udmVyc2F0aW9uSWQSGQoIaXNfZ3JvdXAYBCABKAhSB2lzR3JvdXA=');

@$core.Deprecated('Use getReactionsResponseDescriptor instead')
const GetReactionsResponse$json = {
  '1': 'GetReactionsResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.GetReactionsSuccess',
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

/// Descriptor for `GetReactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReactionsResponseDescriptor = $convert.base64Decode(
    'ChRHZXRSZWFjdGlvbnNSZXNwb25zZRJCCgdzdWNjZXNzGAEgASgLMiYuZ3VhcmR5bi5tZXNzYW'
    'dpbmcuR2V0UmVhY3Rpb25zU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0uZ3Vh'
    'cmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use getReactionsSuccessDescriptor instead')
const GetReactionsSuccess$json = {
  '1': 'GetReactionsSuccess',
  '2': [
    {
      '1': 'reactions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.guardyn.messaging.Reaction',
      '10': 'reactions'
    },
  ],
};

/// Descriptor for `GetReactionsSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReactionsSuccessDescriptor = $convert.base64Decode(
    'ChNHZXRSZWFjdGlvbnNTdWNjZXNzEjkKCXJlYWN0aW9ucxgBIAMoCzIbLmd1YXJkeW4ubWVzc2'
    'FnaW5nLlJlYWN0aW9uUglyZWFjdGlvbnM=');

@$core.Deprecated('Use readReceiptDescriptor instead')
const ReadReceipt$json = {
  '1': 'ReadReceipt',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'last_read_message_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'lastReadMessageId'
    },
    {
      '1': 'timestamp',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `ReadReceipt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List readReceiptDescriptor = $convert.base64Decode(
    'CgtSZWFkUmVjZWlwdBInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcnNhdGlvbklkEh'
    'cKB3VzZXJfaWQYAiABKAlSBnVzZXJJZBIvChRsYXN0X3JlYWRfbWVzc2FnZV9pZBgDIAEoCVIR'
    'bGFzdFJlYWRNZXNzYWdlSWQSNwoJdGltZXN0YW1wGAQgASgLMhkuZ3VhcmR5bi5jb21tb24uVG'
    'ltZXN0YW1wUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use sendReadReceiptRequestDescriptor instead')
const SendReadReceiptRequest$json = {
  '1': 'SendReadReceiptRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'last_read_message_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'lastReadMessageId'
    },
    {'1': 'is_group', '3': 4, '4': 1, '5': 8, '10': 'isGroup'},
  ],
};

/// Descriptor for `SendReadReceiptRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendReadReceiptRequestDescriptor = $convert.base64Decode(
    'ChZTZW5kUmVhZFJlY2VpcHRSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG'
    '9rZW4SJwoPY29udmVyc2F0aW9uX2lkGAIgASgJUg5jb252ZXJzYXRpb25JZBIvChRsYXN0X3Jl'
    'YWRfbWVzc2FnZV9pZBgDIAEoCVIRbGFzdFJlYWRNZXNzYWdlSWQSGQoIaXNfZ3JvdXAYBCABKA'
    'hSB2lzR3JvdXA=');

@$core.Deprecated('Use sendReadReceiptResponseDescriptor instead')
const SendReadReceiptResponse$json = {
  '1': 'SendReadReceiptResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.SendReadReceiptSuccess',
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

/// Descriptor for `SendReadReceiptResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendReadReceiptResponseDescriptor = $convert.base64Decode(
    'ChdTZW5kUmVhZFJlY2VpcHRSZXNwb25zZRJFCgdzdWNjZXNzGAEgASgLMikuZ3VhcmR5bi5tZX'
    'NzYWdpbmcuU2VuZFJlYWRSZWNlaXB0U3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgL'
    'Mh0uZ3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use sendReadReceiptSuccessDescriptor instead')
const SendReadReceiptSuccess$json = {
  '1': 'SendReadReceiptSuccess',
  '2': [
    {
      '1': 'timestamp',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'timestamp'
    },
  ],
};

/// Descriptor for `SendReadReceiptSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sendReadReceiptSuccessDescriptor =
    $convert.base64Decode(
        'ChZTZW5kUmVhZFJlY2VpcHRTdWNjZXNzEjcKCXRpbWVzdGFtcBgBIAEoCzIZLmd1YXJkeW4uY2'
        '9tbW9uLlRpbWVzdGFtcFIJdGltZXN0YW1w');

@$core.Deprecated('Use getReadReceiptsRequestDescriptor instead')
const GetReadReceiptsRequest$json = {
  '1': 'GetReadReceiptsRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_group', '3': 3, '4': 1, '5': 8, '10': 'isGroup'},
  ],
};

/// Descriptor for `GetReadReceiptsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReadReceiptsRequestDescriptor = $convert.base64Decode(
    'ChZHZXRSZWFkUmVjZWlwdHNSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG'
    '9rZW4SJwoPY29udmVyc2F0aW9uX2lkGAIgASgJUg5jb252ZXJzYXRpb25JZBIZCghpc19ncm91'
    'cBgDIAEoCFIHaXNHcm91cA==');

@$core.Deprecated('Use getReadReceiptsResponseDescriptor instead')
const GetReadReceiptsResponse$json = {
  '1': 'GetReadReceiptsResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.GetReadReceiptsSuccess',
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

/// Descriptor for `GetReadReceiptsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReadReceiptsResponseDescriptor = $convert.base64Decode(
    'ChdHZXRSZWFkUmVjZWlwdHNSZXNwb25zZRJFCgdzdWNjZXNzGAEgASgLMikuZ3VhcmR5bi5tZX'
    'NzYWdpbmcuR2V0UmVhZFJlY2VpcHRzU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgL'
    'Mh0uZ3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use getReadReceiptsSuccessDescriptor instead')
const GetReadReceiptsSuccess$json = {
  '1': 'GetReadReceiptsSuccess',
  '2': [
    {
      '1': 'receipts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.guardyn.messaging.ReadReceipt',
      '10': 'receipts'
    },
  ],
};

/// Descriptor for `GetReadReceiptsSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReadReceiptsSuccessDescriptor =
    $convert.base64Decode(
        'ChZHZXRSZWFkUmVjZWlwdHNTdWNjZXNzEjoKCHJlY2VpcHRzGAEgAygLMh4uZ3VhcmR5bi5tZX'
        'NzYWdpbmcuUmVhZFJlY2VpcHRSCHJlY2VpcHRz');

@$core.Deprecated('Use threadReferenceDescriptor instead')
const ThreadReference$json = {
  '1': 'ThreadReference',
  '2': [
    {
      '1': 'reply_to_message_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'replyToMessageId'
    },
    {
      '1': 'quoted_content_hash',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'quotedContentHash'
    },
    {'1': 'quoted_sender_id', '3': 3, '4': 1, '5': 9, '10': 'quotedSenderId'},
    {
      '1': 'quoted_sender_name',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'quotedSenderName'
    },
    {
      '1': 'encrypted_quote_preview',
      '3': 5,
      '4': 1,
      '5': 12,
      '10': 'encryptedQuotePreview'
    },
  ],
};

/// Descriptor for `ThreadReference`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List threadReferenceDescriptor = $convert.base64Decode(
    'Cg9UaHJlYWRSZWZlcmVuY2USLQoTcmVwbHlfdG9fbWVzc2FnZV9pZBgBIAEoCVIQcmVwbHlUb0'
    '1lc3NhZ2VJZBIuChNxdW90ZWRfY29udGVudF9oYXNoGAIgASgJUhFxdW90ZWRDb250ZW50SGFz'
    'aBIoChBxdW90ZWRfc2VuZGVyX2lkGAMgASgJUg5xdW90ZWRTZW5kZXJJZBIsChJxdW90ZWRfc2'
    'VuZGVyX25hbWUYBCABKAlSEHF1b3RlZFNlbmRlck5hbWUSNgoXZW5jcnlwdGVkX3F1b3RlX3By'
    'ZXZpZXcYBSABKAxSFWVuY3J5cHRlZFF1b3RlUHJldmlldw==');

@$core.Deprecated('Use forwardInfoDescriptor instead')
const ForwardInfo$json = {
  '1': 'ForwardInfo',
  '2': [
    {
      '1': 'original_message_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'originalMessageId'
    },
    {
      '1': 'original_sender_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'originalSenderId'
    },
    {
      '1': 'original_sender_name',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'originalSenderName'
    },
    {
      '1': 'original_timestamp',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'originalTimestamp'
    },
    {'1': 'forward_count', '3': 5, '4': 1, '5': 5, '10': 'forwardCount'},
  ],
};

/// Descriptor for `ForwardInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forwardInfoDescriptor = $convert.base64Decode(
    'CgtGb3J3YXJkSW5mbxIuChNvcmlnaW5hbF9tZXNzYWdlX2lkGAEgASgJUhFvcmlnaW5hbE1lc3'
    'NhZ2VJZBIsChJvcmlnaW5hbF9zZW5kZXJfaWQYAiABKAlSEG9yaWdpbmFsU2VuZGVySWQSMAoU'
    'b3JpZ2luYWxfc2VuZGVyX25hbWUYAyABKAlSEm9yaWdpbmFsU2VuZGVyTmFtZRJIChJvcmlnaW'
    '5hbF90aW1lc3RhbXAYBCABKAsyGS5ndWFyZHluLmNvbW1vbi5UaW1lc3RhbXBSEW9yaWdpbmFs'
    'VGltZXN0YW1wEiMKDWZvcndhcmRfY291bnQYBSABKAVSDGZvcndhcmRDb3VudA==');

@$core.Deprecated('Use forwardMessageRequestDescriptor instead')
const ForwardMessageRequest$json = {
  '1': 'ForwardMessageRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'source_message_id', '3': 2, '4': 1, '5': 9, '10': 'sourceMessageId'},
    {
      '1': 'source_conversation_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'sourceConversationId'
    },
    {'1': 'source_is_group', '3': 4, '4': 1, '5': 8, '10': 'sourceIsGroup'},
    {
      '1': 'target_conversation_id',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'targetConversationId'
    },
    {'1': 'target_is_group', '3': 6, '4': 1, '5': 8, '10': 'targetIsGroup'},
    {'1': 'target_user_id', '3': 7, '4': 1, '5': 9, '10': 'targetUserId'},
    {
      '1': 'encrypted_content',
      '3': 8,
      '4': 1,
      '5': 12,
      '10': 'encryptedContent'
    },
    {'1': 'client_message_id', '3': 9, '4': 1, '5': 9, '10': 'clientMessageId'},
  ],
};

/// Descriptor for `ForwardMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forwardMessageRequestDescriptor = $convert.base64Decode(
    'ChVGb3J3YXJkTWVzc2FnZVJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2'
    'tlbhIqChFzb3VyY2VfbWVzc2FnZV9pZBgCIAEoCVIPc291cmNlTWVzc2FnZUlkEjQKFnNvdXJj'
    'ZV9jb252ZXJzYXRpb25faWQYAyABKAlSFHNvdXJjZUNvbnZlcnNhdGlvbklkEiYKD3NvdXJjZV'
    '9pc19ncm91cBgEIAEoCFINc291cmNlSXNHcm91cBI0ChZ0YXJnZXRfY29udmVyc2F0aW9uX2lk'
    'GAUgASgJUhR0YXJnZXRDb252ZXJzYXRpb25JZBImCg90YXJnZXRfaXNfZ3JvdXAYBiABKAhSDX'
    'RhcmdldElzR3JvdXASJAoOdGFyZ2V0X3VzZXJfaWQYByABKAlSDHRhcmdldFVzZXJJZBIrChFl'
    'bmNyeXB0ZWRfY29udGVudBgIIAEoDFIQZW5jcnlwdGVkQ29udGVudBIqChFjbGllbnRfbWVzc2'
    'FnZV9pZBgJIAEoCVIPY2xpZW50TWVzc2FnZUlk');

@$core.Deprecated('Use forwardMessageResponseDescriptor instead')
const ForwardMessageResponse$json = {
  '1': 'ForwardMessageResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.ForwardMessageSuccess',
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

/// Descriptor for `ForwardMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forwardMessageResponseDescriptor = $convert.base64Decode(
    'ChZGb3J3YXJkTWVzc2FnZVJlc3BvbnNlEkQKB3N1Y2Nlc3MYASABKAsyKC5ndWFyZHluLm1lc3'
    'NhZ2luZy5Gb3J3YXJkTWVzc2FnZVN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzId'
    'Lmd1YXJkeW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use forwardMessageSuccessDescriptor instead')
const ForwardMessageSuccess$json = {
  '1': 'ForwardMessageSuccess',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {
      '1': 'server_timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'serverTimestamp'
    },
  ],
};

/// Descriptor for `ForwardMessageSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List forwardMessageSuccessDescriptor = $convert.base64Decode(
    'ChVGb3J3YXJkTWVzc2FnZVN1Y2Nlc3MSHQoKbWVzc2FnZV9pZBgBIAEoCVIJbWVzc2FnZUlkEk'
    'QKEHNlcnZlcl90aW1lc3RhbXAYAiABKAsyGS5ndWFyZHluLmNvbW1vbi5UaW1lc3RhbXBSD3Nl'
    'cnZlclRpbWVzdGFtcA==');

@$core.Deprecated('Use editMessageRequestDescriptor instead')
const EditMessageRequest$json = {
  '1': 'EditMessageRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'message_id', '3': 2, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 3, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_group', '3': 4, '4': 1, '5': 8, '10': 'isGroup'},
    {
      '1': 'encrypted_content',
      '3': 5,
      '4': 1,
      '5': 12,
      '10': 'encryptedContent'
    },
    {
      '1': 'client_timestamp',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'clientTimestamp'
    },
  ],
};

/// Descriptor for `EditMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List editMessageRequestDescriptor = $convert.base64Decode(
    'ChJFZGl0TWVzc2FnZVJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbh'
    'IdCgptZXNzYWdlX2lkGAIgASgJUgltZXNzYWdlSWQSJwoPY29udmVyc2F0aW9uX2lkGAMgASgJ'
    'Ug5jb252ZXJzYXRpb25JZBIZCghpc19ncm91cBgEIAEoCFIHaXNHcm91cBIrChFlbmNyeXB0ZW'
    'RfY29udGVudBgFIAEoDFIQZW5jcnlwdGVkQ29udGVudBJEChBjbGllbnRfdGltZXN0YW1wGAYg'
    'ASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW1wUg9jbGllbnRUaW1lc3RhbXA=');

@$core.Deprecated('Use editMessageResponseDescriptor instead')
const EditMessageResponse$json = {
  '1': 'EditMessageResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.EditMessageSuccess',
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

/// Descriptor for `EditMessageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List editMessageResponseDescriptor = $convert.base64Decode(
    'ChNFZGl0TWVzc2FnZVJlc3BvbnNlEkEKB3N1Y2Nlc3MYASABKAsyJS5ndWFyZHluLm1lc3NhZ2'
    'luZy5FZGl0TWVzc2FnZVN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJk'
    'eW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use editMessageSuccessDescriptor instead')
const EditMessageSuccess$json = {
  '1': 'EditMessageSuccess',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'edit_version', '3': 2, '4': 1, '5': 5, '10': 'editVersion'},
    {
      '1': 'server_timestamp',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'serverTimestamp'
    },
  ],
};

/// Descriptor for `EditMessageSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List editMessageSuccessDescriptor = $convert.base64Decode(
    'ChJFZGl0TWVzc2FnZVN1Y2Nlc3MSHQoKbWVzc2FnZV9pZBgBIAEoCVIJbWVzc2FnZUlkEiEKDG'
    'VkaXRfdmVyc2lvbhgCIAEoBVILZWRpdFZlcnNpb24SRAoQc2VydmVyX3RpbWVzdGFtcBgDIAEo'
    'CzIZLmd1YXJkeW4uY29tbW9uLlRpbWVzdGFtcFIPc2VydmVyVGltZXN0YW1w');

@$core.Deprecated('Use messageEditDescriptor instead')
const MessageEdit$json = {
  '1': 'MessageEdit',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {
      '1': 'encrypted_content',
      '3': 2,
      '4': 1,
      '5': 12,
      '10': 'encryptedContent'
    },
    {'1': 'edit_version', '3': 3, '4': 1, '5': 5, '10': 'editVersion'},
    {
      '1': 'edit_timestamp',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'editTimestamp'
    },
    {'1': 'edited_by', '3': 5, '4': 1, '5': 9, '10': 'editedBy'},
  ],
};

/// Descriptor for `MessageEdit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageEditDescriptor = $convert.base64Decode(
    'CgtNZXNzYWdlRWRpdBIdCgptZXNzYWdlX2lkGAEgASgJUgltZXNzYWdlSWQSKwoRZW5jcnlwdG'
    'VkX2NvbnRlbnQYAiABKAxSEGVuY3J5cHRlZENvbnRlbnQSIQoMZWRpdF92ZXJzaW9uGAMgASgF'
    'UgtlZGl0VmVyc2lvbhJACg5lZGl0X3RpbWVzdGFtcBgEIAEoCzIZLmd1YXJkeW4uY29tbW9uLl'
    'RpbWVzdGFtcFINZWRpdFRpbWVzdGFtcBIbCgllZGl0ZWRfYnkYBSABKAlSCGVkaXRlZEJ5');

@$core.Deprecated('Use voiceMessageMetadataDescriptor instead')
const VoiceMessageMetadata$json = {
  '1': 'VoiceMessageMetadata',
  '2': [
    {'1': 'media_id', '3': 1, '4': 1, '5': 9, '10': 'mediaId'},
    {'1': 'duration_ms', '3': 2, '4': 1, '5': 5, '10': 'durationMs'},
    {'1': 'waveform', '3': 3, '4': 1, '5': 12, '10': 'waveform'},
    {'1': 'codec', '3': 4, '4': 1, '5': 9, '10': 'codec'},
    {'1': 'sample_rate', '3': 5, '4': 1, '5': 5, '10': 'sampleRate'},
    {'1': 'bitrate', '3': 6, '4': 1, '5': 5, '10': 'bitrate'},
  ],
};

/// Descriptor for `VoiceMessageMetadata`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List voiceMessageMetadataDescriptor = $convert.base64Decode(
    'ChRWb2ljZU1lc3NhZ2VNZXRhZGF0YRIZCghtZWRpYV9pZBgBIAEoCVIHbWVkaWFJZBIfCgtkdX'
    'JhdGlvbl9tcxgCIAEoBVIKZHVyYXRpb25NcxIaCgh3YXZlZm9ybRgDIAEoDFIId2F2ZWZvcm0S'
    'FAoFY29kZWMYBCABKAlSBWNvZGVjEh8KC3NhbXBsZV9yYXRlGAUgASgFUgpzYW1wbGVSYXRlEh'
    'gKB2JpdHJhdGUYBiABKAVSB2JpdHJhdGU=');

@$core.Deprecated('Use searchMessagesRequestDescriptor instead')
const SearchMessagesRequest$json = {
  '1': 'SearchMessagesRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'query', '3': 2, '4': 1, '5': 9, '10': 'query'},
    {'1': 'conversation_id', '3': 3, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_group', '3': 4, '4': 1, '5': 8, '10': 'isGroup'},
    {
      '1': 'start_time',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'endTime'
    },
    {
      '1': 'message_types',
      '3': 7,
      '4': 3,
      '5': 14,
      '6': '.guardyn.messaging.MessageType',
      '10': 'messageTypes'
    },
    {'1': 'limit', '3': 8, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'cursor', '3': 9, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `SearchMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchMessagesRequestDescriptor = $convert.base64Decode(
    'ChVTZWFyY2hNZXNzYWdlc1JlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2'
    'tlbhIUCgVxdWVyeRgCIAEoCVIFcXVlcnkSJwoPY29udmVyc2F0aW9uX2lkGAMgASgJUg5jb252'
    'ZXJzYXRpb25JZBIZCghpc19ncm91cBgEIAEoCFIHaXNHcm91cBI4CgpzdGFydF90aW1lGAUgAS'
    'gLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW1wUglzdGFydFRpbWUSNAoIZW5kX3RpbWUYBiAB'
    'KAsyGS5ndWFyZHluLmNvbW1vbi5UaW1lc3RhbXBSB2VuZFRpbWUSQwoNbWVzc2FnZV90eXBlcx'
    'gHIAMoDjIeLmd1YXJkeW4ubWVzc2FnaW5nLk1lc3NhZ2VUeXBlUgxtZXNzYWdlVHlwZXMSFAoF'
    'bGltaXQYCCABKAVSBWxpbWl0EhYKBmN1cnNvchgJIAEoCVIGY3Vyc29y');

@$core.Deprecated('Use searchMessagesResponseDescriptor instead')
const SearchMessagesResponse$json = {
  '1': 'SearchMessagesResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.SearchMessagesSuccess',
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

/// Descriptor for `SearchMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchMessagesResponseDescriptor = $convert.base64Decode(
    'ChZTZWFyY2hNZXNzYWdlc1Jlc3BvbnNlEkQKB3N1Y2Nlc3MYASABKAsyKC5ndWFyZHluLm1lc3'
    'NhZ2luZy5TZWFyY2hNZXNzYWdlc1N1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzId'
    'Lmd1YXJkeW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use searchMessagesSuccessDescriptor instead')
const SearchMessagesSuccess$json = {
  '1': 'SearchMessagesSuccess',
  '2': [
    {
      '1': 'results',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.guardyn.messaging.SearchResult',
      '10': 'results'
    },
    {'1': 'next_cursor', '3': 2, '4': 1, '5': 9, '10': 'nextCursor'},
    {'1': 'has_more', '3': 3, '4': 1, '5': 8, '10': 'hasMore'},
    {'1': 'total_count', '3': 4, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `SearchMessagesSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchMessagesSuccessDescriptor = $convert.base64Decode(
    'ChVTZWFyY2hNZXNzYWdlc1N1Y2Nlc3MSOQoHcmVzdWx0cxgBIAMoCzIfLmd1YXJkeW4ubWVzc2'
    'FnaW5nLlNlYXJjaFJlc3VsdFIHcmVzdWx0cxIfCgtuZXh0X2N1cnNvchgCIAEoCVIKbmV4dEN1'
    'cnNvchIZCghoYXNfbW9yZRgDIAEoCFIHaGFzTW9yZRIfCgt0b3RhbF9jb3VudBgEIAEoBVIKdG'
    '90YWxDb3VudA==');

@$core.Deprecated('Use searchResultDescriptor instead')
const SearchResult$json = {
  '1': 'SearchResult',
  '2': [
    {'1': 'message_id', '3': 1, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_group', '3': 3, '4': 1, '5': 8, '10': 'isGroup'},
    {'1': 'sender_user_id', '3': 4, '4': 1, '5': 9, '10': 'senderUserId'},
    {
      '1': 'encrypted_content',
      '3': 5,
      '4': 1,
      '5': 12,
      '10': 'encryptedContent'
    },
    {
      '1': 'server_timestamp',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'serverTimestamp'
    },
    {
      '1': 'message_type',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.guardyn.messaging.MessageType',
      '10': 'messageType'
    },
    {
      '1': 'conversation_name',
      '3': 8,
      '4': 1,
      '5': 9,
      '10': 'conversationName'
    },
  ],
};

/// Descriptor for `SearchResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchResultDescriptor = $convert.base64Decode(
    'CgxTZWFyY2hSZXN1bHQSHQoKbWVzc2FnZV9pZBgBIAEoCVIJbWVzc2FnZUlkEicKD2NvbnZlcn'
    'NhdGlvbl9pZBgCIAEoCVIOY29udmVyc2F0aW9uSWQSGQoIaXNfZ3JvdXAYAyABKAhSB2lzR3Jv'
    'dXASJAoOc2VuZGVyX3VzZXJfaWQYBCABKAlSDHNlbmRlclVzZXJJZBIrChFlbmNyeXB0ZWRfY2'
    '9udGVudBgFIAEoDFIQZW5jcnlwdGVkQ29udGVudBJEChBzZXJ2ZXJfdGltZXN0YW1wGAYgASgL'
    'MhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW1wUg9zZXJ2ZXJUaW1lc3RhbXASQQoMbWVzc2FnZV'
    '90eXBlGAcgASgOMh4uZ3VhcmR5bi5tZXNzYWdpbmcuTWVzc2FnZVR5cGVSC21lc3NhZ2VUeXBl'
    'EisKEWNvbnZlcnNhdGlvbl9uYW1lGAggASgJUhBjb252ZXJzYXRpb25OYW1l');

@$core.Deprecated('Use disappearingConfigDescriptor instead')
const DisappearingConfig$json = {
  '1': 'DisappearingConfig',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'ttl_seconds', '3': 2, '4': 1, '5': 5, '10': 'ttlSeconds'},
    {'1': 'set_by_user_id', '3': 3, '4': 1, '5': 9, '10': 'setByUserId'},
    {
      '1': 'updated_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `DisappearingConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disappearingConfigDescriptor = $convert.base64Decode(
    'ChJEaXNhcHBlYXJpbmdDb25maWcSJwoPY29udmVyc2F0aW9uX2lkGAEgASgJUg5jb252ZXJzYX'
    'Rpb25JZBIfCgt0dGxfc2Vjb25kcxgCIAEoBVIKdHRsU2Vjb25kcxIjCg5zZXRfYnlfdXNlcl9p'
    'ZBgDIAEoCVILc2V0QnlVc2VySWQSOAoKdXBkYXRlZF9hdBgEIAEoCzIZLmd1YXJkeW4uY29tbW'
    '9uLlRpbWVzdGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use setDisappearingMessagesRequestDescriptor instead')
const SetDisappearingMessagesRequest$json = {
  '1': 'SetDisappearingMessagesRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_group', '3': 3, '4': 1, '5': 8, '10': 'isGroup'},
    {'1': 'ttl_seconds', '3': 4, '4': 1, '5': 5, '10': 'ttlSeconds'},
  ],
};

/// Descriptor for `SetDisappearingMessagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDisappearingMessagesRequestDescriptor =
    $convert.base64Decode(
        'Ch5TZXREaXNhcHBlYXJpbmdNZXNzYWdlc1JlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUg'
        'thY2Nlc3NUb2tlbhInCg9jb252ZXJzYXRpb25faWQYAiABKAlSDmNvbnZlcnNhdGlvbklkEhkK'
        'CGlzX2dyb3VwGAMgASgIUgdpc0dyb3VwEh8KC3R0bF9zZWNvbmRzGAQgASgFUgp0dGxTZWNvbm'
        'Rz');

@$core.Deprecated('Use setDisappearingMessagesResponseDescriptor instead')
const SetDisappearingMessagesResponse$json = {
  '1': 'SetDisappearingMessagesResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.SetDisappearingMessagesSuccess',
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

/// Descriptor for `SetDisappearingMessagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDisappearingMessagesResponseDescriptor =
    $convert.base64Decode(
        'Ch9TZXREaXNhcHBlYXJpbmdNZXNzYWdlc1Jlc3BvbnNlEk0KB3N1Y2Nlc3MYASABKAsyMS5ndW'
        'FyZHluLm1lc3NhZ2luZy5TZXREaXNhcHBlYXJpbmdNZXNzYWdlc1N1Y2Nlc3NIAFIHc3VjY2Vz'
        'cxI1CgVlcnJvchgCIAEoCzIdLmd1YXJkeW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3'
        'JCCAoGcmVzdWx0');

@$core.Deprecated('Use setDisappearingMessagesSuccessDescriptor instead')
const SetDisappearingMessagesSuccess$json = {
  '1': 'SetDisappearingMessagesSuccess',
  '2': [
    {
      '1': 'config',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.DisappearingConfig',
      '10': 'config'
    },
  ],
};

/// Descriptor for `SetDisappearingMessagesSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setDisappearingMessagesSuccessDescriptor =
    $convert.base64Decode(
        'Ch5TZXREaXNhcHBlYXJpbmdNZXNzYWdlc1N1Y2Nlc3MSPQoGY29uZmlnGAEgASgLMiUuZ3Vhcm'
        'R5bi5tZXNzYWdpbmcuRGlzYXBwZWFyaW5nQ29uZmlnUgZjb25maWc=');

@$core.Deprecated('Use getDisappearingConfigRequestDescriptor instead')
const GetDisappearingConfigRequest$json = {
  '1': 'GetDisappearingConfigRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'is_group', '3': 3, '4': 1, '5': 8, '10': 'isGroup'},
  ],
};

/// Descriptor for `GetDisappearingConfigRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDisappearingConfigRequestDescriptor =
    $convert.base64Decode(
        'ChxHZXREaXNhcHBlYXJpbmdDb25maWdSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYW'
        'NjZXNzVG9rZW4SJwoPY29udmVyc2F0aW9uX2lkGAIgASgJUg5jb252ZXJzYXRpb25JZBIZCghp'
        'c19ncm91cBgDIAEoCFIHaXNHcm91cA==');

@$core.Deprecated('Use getDisappearingConfigResponseDescriptor instead')
const GetDisappearingConfigResponse$json = {
  '1': 'GetDisappearingConfigResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.GetDisappearingConfigSuccess',
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

/// Descriptor for `GetDisappearingConfigResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDisappearingConfigResponseDescriptor = $convert.base64Decode(
    'Ch1HZXREaXNhcHBlYXJpbmdDb25maWdSZXNwb25zZRJLCgdzdWNjZXNzGAEgASgLMi8uZ3Vhcm'
    'R5bi5tZXNzYWdpbmcuR2V0RGlzYXBwZWFyaW5nQ29uZmlnU3VjY2Vzc0gAUgdzdWNjZXNzEjUK'
    'BWVycm9yGAIgASgLMh0uZ3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICg'
    'ZyZXN1bHQ=');

@$core.Deprecated('Use getDisappearingConfigSuccessDescriptor instead')
const GetDisappearingConfigSuccess$json = {
  '1': 'GetDisappearingConfigSuccess',
  '2': [
    {
      '1': 'config',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.DisappearingConfig',
      '10': 'config'
    },
  ],
};

/// Descriptor for `GetDisappearingConfigSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDisappearingConfigSuccessDescriptor =
    $convert.base64Decode(
        'ChxHZXREaXNhcHBlYXJpbmdDb25maWdTdWNjZXNzEj0KBmNvbmZpZxgBIAEoCzIlLmd1YXJkeW'
        '4ubWVzc2FnaW5nLkRpc2FwcGVhcmluZ0NvbmZpZ1IGY29uZmln');

@$core.Deprecated('Use healthRequestDescriptor instead')
const HealthRequest$json = {
  '1': 'HealthRequest',
};

/// Descriptor for `HealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthRequestDescriptor =
    $convert.base64Decode('Cg1IZWFsdGhSZXF1ZXN0');

@$core.Deprecated('Use blockUserRequestDescriptor instead')
const BlockUserRequest$json = {
  '1': 'BlockUserRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'blocked_user_id', '3': 2, '4': 1, '5': 9, '10': 'blockedUserId'},
  ],
};

/// Descriptor for `BlockUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockUserRequestDescriptor = $convert.base64Decode(
    'ChBCbG9ja1VzZXJSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW4SJg'
    'oPYmxvY2tlZF91c2VyX2lkGAIgASgJUg1ibG9ja2VkVXNlcklk');

@$core.Deprecated('Use blockUserResponseDescriptor instead')
const BlockUserResponse$json = {
  '1': 'BlockUserResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.BlockUserSuccess',
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

/// Descriptor for `BlockUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockUserResponseDescriptor = $convert.base64Decode(
    'ChFCbG9ja1VzZXJSZXNwb25zZRI/CgdzdWNjZXNzGAEgASgLMiMuZ3VhcmR5bi5tZXNzYWdpbm'
    'cuQmxvY2tVc2VyU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0uZ3VhcmR5bi5j'
    'b21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use blockUserSuccessDescriptor instead')
const BlockUserSuccess$json = {
  '1': 'BlockUserSuccess',
  '2': [
    {'1': 'blocked_user_id', '3': 1, '4': 1, '5': 9, '10': 'blockedUserId'},
    {
      '1': 'blocked_at',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'blockedAt'
    },
  ],
};

/// Descriptor for `BlockUserSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockUserSuccessDescriptor = $convert.base64Decode(
    'ChBCbG9ja1VzZXJTdWNjZXNzEiYKD2Jsb2NrZWRfdXNlcl9pZBgBIAEoCVINYmxvY2tlZFVzZX'
    'JJZBI4CgpibG9ja2VkX2F0GAIgASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW1wUglibG9j'
    'a2VkQXQ=');

@$core.Deprecated('Use unblockUserRequestDescriptor instead')
const UnblockUserRequest$json = {
  '1': 'UnblockUserRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `UnblockUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unblockUserRequestDescriptor = $convert.base64Decode(
    'ChJVbmJsb2NrVXNlclJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbh'
    'IXCgd1c2VyX2lkGAIgASgJUgZ1c2VySWQ=');

@$core.Deprecated('Use unblockUserResponseDescriptor instead')
const UnblockUserResponse$json = {
  '1': 'UnblockUserResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.UnblockUserSuccess',
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

/// Descriptor for `UnblockUserResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unblockUserResponseDescriptor = $convert.base64Decode(
    'ChNVbmJsb2NrVXNlclJlc3BvbnNlEkEKB3N1Y2Nlc3MYASABKAsyJS5ndWFyZHluLm1lc3NhZ2'
    'luZy5VbmJsb2NrVXNlclN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJk'
    'eW4uY29tbW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use unblockUserSuccessDescriptor instead')
const UnblockUserSuccess$json = {
  '1': 'UnblockUserSuccess',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `UnblockUserSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unblockUserSuccessDescriptor =
    $convert.base64Decode(
        'ChJVbmJsb2NrVXNlclN1Y2Nlc3MSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklk');

@$core.Deprecated('Use getBlockedUsersRequestDescriptor instead')
const GetBlockedUsersRequest$json = {
  '1': 'GetBlockedUsersRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
  ],
};

/// Descriptor for `GetBlockedUsersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockedUsersRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRCbG9ja2VkVXNlcnNSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG'
        '9rZW4=');

@$core.Deprecated('Use getBlockedUsersResponseDescriptor instead')
const GetBlockedUsersResponse$json = {
  '1': 'GetBlockedUsersResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.GetBlockedUsersSuccess',
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

/// Descriptor for `GetBlockedUsersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockedUsersResponseDescriptor = $convert.base64Decode(
    'ChdHZXRCbG9ja2VkVXNlcnNSZXNwb25zZRJFCgdzdWNjZXNzGAEgASgLMikuZ3VhcmR5bi5tZX'
    'NzYWdpbmcuR2V0QmxvY2tlZFVzZXJzU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgL'
    'Mh0uZ3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use getBlockedUsersSuccessDescriptor instead')
const GetBlockedUsersSuccess$json = {
  '1': 'GetBlockedUsersSuccess',
  '2': [
    {
      '1': 'blocked_users',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.guardyn.messaging.BlockedUser',
      '10': 'blockedUsers'
    },
  ],
};

/// Descriptor for `GetBlockedUsersSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBlockedUsersSuccessDescriptor =
    $convert.base64Decode(
        'ChZHZXRCbG9ja2VkVXNlcnNTdWNjZXNzEkMKDWJsb2NrZWRfdXNlcnMYASADKAsyHi5ndWFyZH'
        'luLm1lc3NhZ2luZy5CbG9ja2VkVXNlclIMYmxvY2tlZFVzZXJz');

@$core.Deprecated('Use blockedUserDescriptor instead')
const BlockedUser$json = {
  '1': 'BlockedUser',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {
      '1': 'blocked_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'blockedAt'
    },
  ],
};

/// Descriptor for `BlockedUser`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockedUserDescriptor = $convert.base64Decode(
    'CgtCbG9ja2VkVXNlchIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGgoIdXNlcm5hbWUYAiABKA'
    'lSCHVzZXJuYW1lEjgKCmJsb2NrZWRfYXQYAyABKAsyGS5ndWFyZHluLmNvbW1vbi5UaW1lc3Rh'
    'bXBSCWJsb2NrZWRBdA==');

@$core.Deprecated('Use deleteConversationRequestDescriptor instead')
const DeleteConversationRequest$json = {
  '1': 'DeleteConversationRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `DeleteConversationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteConversationRequestDescriptor =
    $convert.base64Decode(
        'ChlEZWxldGVDb252ZXJzYXRpb25SZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZX'
        'NzVG9rZW4SJwoPY29udmVyc2F0aW9uX2lkGAIgASgJUg5jb252ZXJzYXRpb25JZA==');

@$core.Deprecated('Use deleteConversationResponseDescriptor instead')
const DeleteConversationResponse$json = {
  '1': 'DeleteConversationResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.messaging.DeleteConversationSuccess',
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

/// Descriptor for `DeleteConversationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteConversationResponseDescriptor = $convert.base64Decode(
    'ChpEZWxldGVDb252ZXJzYXRpb25SZXNwb25zZRJICgdzdWNjZXNzGAEgASgLMiwuZ3VhcmR5bi'
    '5tZXNzYWdpbmcuRGVsZXRlQ29udmVyc2F0aW9uU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9y'
    'GAIgASgLMh0uZ3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bH'
    'Q=');

@$core.Deprecated('Use deleteConversationSuccessDescriptor instead')
const DeleteConversationSuccess$json = {
  '1': 'DeleteConversationSuccess',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `DeleteConversationSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteConversationSuccessDescriptor =
    $convert.base64Decode(
        'ChlEZWxldGVDb252ZXJzYXRpb25TdWNjZXNzEicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY2'
        '9udmVyc2F0aW9uSWQ=');
