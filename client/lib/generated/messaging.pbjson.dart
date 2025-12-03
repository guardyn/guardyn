// This is a generated file - do not edit.
//
// Generated from messaging.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

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
    'YW1lEh8KC3gzZGhfcHJla2V5GAogASgJUgp4M2RoUHJla2V5');

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
    'M2RoUHJla2V5');

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

@$core.Deprecated('Use typingIndicatorRequestDescriptor instead')
const TypingIndicatorRequest$json = {
  '1': 'TypingIndicatorRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'recipient_user_id', '3': 2, '4': 1, '5': 9, '10': 'recipientUserId'},
    {'1': 'is_typing', '3': 3, '4': 1, '5': 8, '10': 'isTyping'},
  ],
};

/// Descriptor for `TypingIndicatorRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List typingIndicatorRequestDescriptor = $convert.base64Decode(
    'ChZUeXBpbmdJbmRpY2F0b3JSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG'
    '9rZW4SKgoRcmVjaXBpZW50X3VzZXJfaWQYAiABKAlSD3JlY2lwaWVudFVzZXJJZBIbCglpc190'
    'eXBpbmcYAyABKAhSCGlzVHlwaW5n');

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
  ],
};

/// Descriptor for `CreateGroupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createGroupRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVHcm91cFJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbh'
    'IdCgpncm91cF9uYW1lGAIgASgJUglncm91cE5hbWUSJgoPbWVtYmVyX3VzZXJfaWRzGAMgAygJ'
    'Ug1tZW1iZXJVc2VySWRzEiYKD21sc19ncm91cF9zdGF0ZRgEIAEoDFINbWxzR3JvdXBTdGF0ZQ'
    '==');

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
    'bWVkaWFJZA==');

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
    'lkGAogASgJUgdtZWRpYUlkEh0KCmlzX2RlbGV0ZWQYCyABKAhSCWlzRGVsZXRlZA==');

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
  ],
};

/// Descriptor for `GroupInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupInfoDescriptor = $convert.base64Decode(
    'CglHcm91cEluZm8SGQoIZ3JvdXBfaWQYASABKAlSB2dyb3VwSWQSEgoEbmFtZRgCIAEoCVIEbm'
    'FtZRImCg9jcmVhdG9yX3VzZXJfaWQYAyABKAlSDWNyZWF0b3JVc2VySWQSPAoHbWVtYmVycxgE'
    'IAMoCzIiLmd1YXJkeW4ubWVzc2FnaW5nLkdyb3VwTWVtYmVySW5mb1IHbWVtYmVycxI4Cgpjcm'
    'VhdGVkX2F0GAUgASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW1wUgljcmVhdGVkQXQSIQoM'
    'bWVtYmVyX2NvdW50GAYgASgFUgttZW1iZXJDb3VudBJCCgxsYXN0X21lc3NhZ2UYByABKAsyHy'
    '5ndWFyZHluLm1lc3NhZ2luZy5Hcm91cE1lc3NhZ2VSC2xhc3RNZXNzYWdl');

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
  ],
};

/// Descriptor for `GroupMemberInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupMemberInfoDescriptor = $convert.base64Decode(
    'Cg9Hcm91cE1lbWJlckluZm8SFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhoKCHVzZXJuYW1lGA'
    'IgASgJUgh1c2VybmFtZRIbCglkZXZpY2VfaWQYAyABKAlSCGRldmljZUlkEhIKBHJvbGUYBCAB'
    'KAlSBHJvbGUSNgoJam9pbmVkX2F0GAUgASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW1wUg'
    'hqb2luZWRBdA==');

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

@$core.Deprecated('Use healthRequestDescriptor instead')
const HealthRequest$json = {
  '1': 'HealthRequest',
};

/// Descriptor for `HealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthRequestDescriptor =
    $convert.base64Decode('Cg1IZWFsdGhSZXF1ZXN0');
