// This is a generated file - do not edit.
//
// Generated from calls.proto.

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

@$core.Deprecated('Use callTypeDescriptor instead')
const CallType$json = {
  '1': 'CallType',
  '2': [
    {'1': 'UNKNOWN_CALL_TYPE', '2': 0},
    {'1': 'VOICE', '2': 1},
    {'1': 'VIDEO', '2': 2},
  ],
};

/// Descriptor for `CallType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List callTypeDescriptor = $convert.base64Decode(
    'CghDYWxsVHlwZRIVChFVTktOT1dOX0NBTExfVFlQRRAAEgkKBVZPSUNFEAESCQoFVklERU8QAg'
    '==');

@$core.Deprecated('Use callStateDescriptor instead')
const CallState$json = {
  '1': 'CallState',
  '2': [
    {'1': 'UNKNOWN_STATE', '2': 0},
    {'1': 'INITIATING', '2': 1},
    {'1': 'RINGING', '2': 2},
    {'1': 'CONNECTING', '2': 3},
    {'1': 'CONNECTED', '2': 4},
    {'1': 'ON_HOLD', '2': 5},
    {'1': 'ENDED', '2': 6},
    {'1': 'FAILED', '2': 7},
  ],
};

/// Descriptor for `CallState`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List callStateDescriptor = $convert.base64Decode(
    'CglDYWxsU3RhdGUSEQoNVU5LTk9XTl9TVEFURRAAEg4KCklOSVRJQVRJTkcQARILCgdSSU5HSU'
    '5HEAISDgoKQ09OTkVDVElORxADEg0KCUNPTk5FQ1RFRBAEEgsKB09OX0hPTEQQBRIJCgVFTkRF'
    'RBAGEgoKBkZBSUxFRBAH');

@$core.Deprecated('Use callEndReasonDescriptor instead')
const CallEndReason$json = {
  '1': 'CallEndReason',
  '2': [
    {'1': 'UNKNOWN_REASON', '2': 0},
    {'1': 'COMPLETED', '2': 1},
    {'1': 'DECLINED', '2': 2},
    {'1': 'MISSED', '2': 3},
    {'1': 'BUSY', '2': 4},
    {'1': 'FAILED_CONNECTION', '2': 5},
    {'1': 'CANCELLED', '2': 6},
  ],
};

/// Descriptor for `CallEndReason`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List callEndReasonDescriptor = $convert.base64Decode(
    'Cg1DYWxsRW5kUmVhc29uEhIKDlVOS05PV05fUkVBU09OEAASDQoJQ09NUExFVEVEEAESDAoIRE'
    'VDTElORUQQAhIKCgZNSVNTRUQQAxIICgRCVVNZEAQSFQoRRkFJTEVEX0NPTk5FQ1RJT04QBRIN'
    'CglDQU5DRUxMRUQQBg==');

@$core.Deprecated('Use sdpTypeDescriptor instead')
const SdpType$json = {
  '1': 'SdpType',
  '2': [
    {'1': 'UNKNOWN_SDP_TYPE', '2': 0},
    {'1': 'OFFER', '2': 1},
    {'1': 'ANSWER', '2': 2},
    {'1': 'PRANSWER', '2': 3},
    {'1': 'ROLLBACK', '2': 4},
  ],
};

/// Descriptor for `SdpType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sdpTypeDescriptor = $convert.base64Decode(
    'CgdTZHBUeXBlEhQKEFVOS05PV05fU0RQX1RZUEUQABIJCgVPRkZFUhABEgoKBkFOU1dFUhACEg'
    'wKCFBSQU5TV0VSEAMSDAoIUk9MTEJBQ0sQBA==');

@$core.Deprecated('Use callQualityDescriptor instead')
const CallQuality$json = {
  '1': 'CallQuality',
  '2': [
    {'1': 'UNKNOWN_QUALITY', '2': 0},
    {'1': 'EXCELLENT', '2': 1},
    {'1': 'GOOD', '2': 2},
    {'1': 'FAIR', '2': 3},
    {'1': 'POOR', '2': 4},
  ],
};

/// Descriptor for `CallQuality`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List callQualityDescriptor = $convert.base64Decode(
    'CgtDYWxsUXVhbGl0eRITCg9VTktOT1dOX1FVQUxJVFkQABINCglFWENFTExFTlQQARIICgRHT0'
    '9EEAISCAoERkFJUhADEggKBFBPT1IQBA==');

@$core.Deprecated('Use initiateCallRequestDescriptor instead')
const InitiateCallRequest$json = {
  '1': 'InitiateCallRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'userId'},
    {'1': 'group_id', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'groupId'},
    {
      '1': 'call_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallType',
      '10': 'callType'
    },
    {
      '1': 'capabilities',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.ClientCapabilities',
      '10': 'capabilities'
    },
  ],
  '8': [
    {'1': 'target'},
  ],
};

/// Descriptor for `InitiateCallRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initiateCallRequestDescriptor = $convert.base64Decode(
    'ChNJbml0aWF0ZUNhbGxSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW'
    '4SGQoHdXNlcl9pZBgCIAEoCUgAUgZ1c2VySWQSGwoIZ3JvdXBfaWQYAyABKAlIAFIHZ3JvdXBJ'
    'ZBI0CgljYWxsX3R5cGUYBCABKA4yFy5ndWFyZHluLmNhbGxzLkNhbGxUeXBlUghjYWxsVHlwZR'
    'JFCgxjYXBhYmlsaXRpZXMYBSABKAsyIS5ndWFyZHluLmNhbGxzLkNsaWVudENhcGFiaWxpdGll'
    'c1IMY2FwYWJpbGl0aWVzQggKBnRhcmdldA==');

@$core.Deprecated('Use clientCapabilitiesDescriptor instead')
const ClientCapabilities$json = {
  '1': 'ClientCapabilities',
  '2': [
    {'1': 'supports_video', '3': 1, '4': 1, '5': 8, '10': 'supportsVideo'},
    {
      '1': 'supports_screen_share',
      '3': 2,
      '4': 1,
      '5': 8,
      '10': 'supportsScreenShare'
    },
    {'1': 'supports_sframe', '3': 3, '4': 1, '5': 8, '10': 'supportsSframe'},
    {'1': 'supported_codecs', '3': 4, '4': 3, '5': 9, '10': 'supportedCodecs'},
    {'1': 'max_video_width', '3': 5, '4': 1, '5': 5, '10': 'maxVideoWidth'},
    {'1': 'max_video_height', '3': 6, '4': 1, '5': 5, '10': 'maxVideoHeight'},
    {'1': 'max_video_fps', '3': 7, '4': 1, '5': 5, '10': 'maxVideoFps'},
  ],
};

/// Descriptor for `ClientCapabilities`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientCapabilitiesDescriptor = $convert.base64Decode(
    'ChJDbGllbnRDYXBhYmlsaXRpZXMSJQoOc3VwcG9ydHNfdmlkZW8YASABKAhSDXN1cHBvcnRzVm'
    'lkZW8SMgoVc3VwcG9ydHNfc2NyZWVuX3NoYXJlGAIgASgIUhNzdXBwb3J0c1NjcmVlblNoYXJl'
    'EicKD3N1cHBvcnRzX3NmcmFtZRgDIAEoCFIOc3VwcG9ydHNTZnJhbWUSKQoQc3VwcG9ydGVkX2'
    'NvZGVjcxgEIAMoCVIPc3VwcG9ydGVkQ29kZWNzEiYKD21heF92aWRlb193aWR0aBgFIAEoBVIN'
    'bWF4VmlkZW9XaWR0aBIoChBtYXhfdmlkZW9faGVpZ2h0GAYgASgFUg5tYXhWaWRlb0hlaWdodB'
    'IiCg1tYXhfdmlkZW9fZnBzGAcgASgFUgttYXhWaWRlb0Zwcw==');

@$core.Deprecated('Use initiateCallResponseDescriptor instead')
const InitiateCallResponse$json = {
  '1': 'InitiateCallResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.InitiateCallSuccess',
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

/// Descriptor for `InitiateCallResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initiateCallResponseDescriptor = $convert.base64Decode(
    'ChRJbml0aWF0ZUNhbGxSZXNwb25zZRI+CgdzdWNjZXNzGAEgASgLMiIuZ3VhcmR5bi5jYWxscy'
    '5Jbml0aWF0ZUNhbGxTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFyZHlu'
    'LmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use initiateCallSuccessDescriptor instead')
const InitiateCallSuccess$json = {
  '1': 'InitiateCallSuccess',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'state',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallState',
      '10': 'state'
    },
    {
      '1': 'created_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'ice_servers',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.guardyn.calls.IceServer',
      '10': 'iceServers'
    },
    {
      '1': 'sframe_key_material',
      '3': 5,
      '4': 1,
      '5': 12,
      '10': 'sframeKeyMaterial'
    },
    {'1': 'sframe_key_id', '3': 6, '4': 1, '5': 13, '10': 'sframeKeyId'},
  ],
};

/// Descriptor for `InitiateCallSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initiateCallSuccessDescriptor = $convert.base64Decode(
    'ChNJbml0aWF0ZUNhbGxTdWNjZXNzEhcKB2NhbGxfaWQYASABKAlSBmNhbGxJZBIuCgVzdGF0ZR'
    'gCIAEoDjIYLmd1YXJkeW4uY2FsbHMuQ2FsbFN0YXRlUgVzdGF0ZRI4CgpjcmVhdGVkX2F0GAMg'
    'ASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW1wUgljcmVhdGVkQXQSOQoLaWNlX3NlcnZlcn'
    'MYBCADKAsyGC5ndWFyZHluLmNhbGxzLkljZVNlcnZlclIKaWNlU2VydmVycxIuChNzZnJhbWVf'
    'a2V5X21hdGVyaWFsGAUgASgMUhFzZnJhbWVLZXlNYXRlcmlhbBIiCg1zZnJhbWVfa2V5X2lkGA'
    'YgASgNUgtzZnJhbWVLZXlJZA==');

@$core.Deprecated('Use iceServerDescriptor instead')
const IceServer$json = {
  '1': 'IceServer',
  '2': [
    {'1': 'urls', '3': 1, '4': 3, '5': 9, '10': 'urls'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'credential', '3': 3, '4': 1, '5': 9, '10': 'credential'},
  ],
};

/// Descriptor for `IceServer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List iceServerDescriptor = $convert.base64Decode(
    'CglJY2VTZXJ2ZXISEgoEdXJscxgBIAMoCVIEdXJscxIaCgh1c2VybmFtZRgCIAEoCVIIdXNlcm'
    '5hbWUSHgoKY3JlZGVudGlhbBgDIAEoCVIKY3JlZGVudGlhbA==');

@$core.Deprecated('Use acceptCallRequestDescriptor instead')
const AcceptCallRequest$json = {
  '1': 'AcceptCallRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'capabilities',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.ClientCapabilities',
      '10': 'capabilities'
    },
  ],
};

/// Descriptor for `AcceptCallRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acceptCallRequestDescriptor = $convert.base64Decode(
    'ChFBY2NlcHRDYWxsUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2VuEh'
    'cKB2NhbGxfaWQYAiABKAlSBmNhbGxJZBJFCgxjYXBhYmlsaXRpZXMYAyABKAsyIS5ndWFyZHlu'
    'LmNhbGxzLkNsaWVudENhcGFiaWxpdGllc1IMY2FwYWJpbGl0aWVz');

@$core.Deprecated('Use acceptCallResponseDescriptor instead')
const AcceptCallResponse$json = {
  '1': 'AcceptCallResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.AcceptCallSuccess',
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

/// Descriptor for `AcceptCallResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acceptCallResponseDescriptor = $convert.base64Decode(
    'ChJBY2NlcHRDYWxsUmVzcG9uc2USPAoHc3VjY2VzcxgBIAEoCzIgLmd1YXJkeW4uY2FsbHMuQW'
    'NjZXB0Q2FsbFN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJkeW4uY29t'
    'bW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use acceptCallSuccessDescriptor instead')
const AcceptCallSuccess$json = {
  '1': 'AcceptCallSuccess',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'state',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallState',
      '10': 'state'
    },
    {
      '1': 'ice_servers',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.guardyn.calls.IceServer',
      '10': 'iceServers'
    },
    {
      '1': 'sframe_key_material',
      '3': 4,
      '4': 1,
      '5': 12,
      '10': 'sframeKeyMaterial'
    },
    {'1': 'sframe_key_id', '3': 5, '4': 1, '5': 13, '10': 'sframeKeyId'},
  ],
};

/// Descriptor for `AcceptCallSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acceptCallSuccessDescriptor = $convert.base64Decode(
    'ChFBY2NlcHRDYWxsU3VjY2VzcxIXCgdjYWxsX2lkGAEgASgJUgZjYWxsSWQSLgoFc3RhdGUYAi'
    'ABKA4yGC5ndWFyZHluLmNhbGxzLkNhbGxTdGF0ZVIFc3RhdGUSOQoLaWNlX3NlcnZlcnMYAyAD'
    'KAsyGC5ndWFyZHluLmNhbGxzLkljZVNlcnZlclIKaWNlU2VydmVycxIuChNzZnJhbWVfa2V5X2'
    '1hdGVyaWFsGAQgASgMUhFzZnJhbWVLZXlNYXRlcmlhbBIiCg1zZnJhbWVfa2V5X2lkGAUgASgN'
    'UgtzZnJhbWVLZXlJZA==');

@$core.Deprecated('Use rejectCallRequestDescriptor instead')
const RejectCallRequest$json = {
  '1': 'RejectCallRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'reason', '3': 3, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `RejectCallRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rejectCallRequestDescriptor = $convert.base64Decode(
    'ChFSZWplY3RDYWxsUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2VuEh'
    'cKB2NhbGxfaWQYAiABKAlSBmNhbGxJZBIWCgZyZWFzb24YAyABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use rejectCallResponseDescriptor instead')
const RejectCallResponse$json = {
  '1': 'RejectCallResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.RejectCallSuccess',
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

/// Descriptor for `RejectCallResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rejectCallResponseDescriptor = $convert.base64Decode(
    'ChJSZWplY3RDYWxsUmVzcG9uc2USPAoHc3VjY2VzcxgBIAEoCzIgLmd1YXJkeW4uY2FsbHMuUm'
    'VqZWN0Q2FsbFN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJkeW4uY29t'
    'bW9uLkVycm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use rejectCallSuccessDescriptor instead')
const RejectCallSuccess$json = {
  '1': 'RejectCallSuccess',
  '2': [
    {'1': 'rejected', '3': 1, '4': 1, '5': 8, '10': 'rejected'},
  ],
};

/// Descriptor for `RejectCallSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rejectCallSuccessDescriptor = $convert.base64Decode(
    'ChFSZWplY3RDYWxsU3VjY2VzcxIaCghyZWplY3RlZBgBIAEoCFIIcmVqZWN0ZWQ=');

@$core.Deprecated('Use endCallRequestDescriptor instead')
const EndCallRequest$json = {
  '1': 'EndCallRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'reason',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallEndReason',
      '10': 'reason'
    },
  ],
};

/// Descriptor for `EndCallRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List endCallRequestDescriptor = $convert.base64Decode(
    'Cg5FbmRDYWxsUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2VuEhcKB2'
    'NhbGxfaWQYAiABKAlSBmNhbGxJZBI0CgZyZWFzb24YAyABKA4yHC5ndWFyZHluLmNhbGxzLkNh'
    'bGxFbmRSZWFzb25SBnJlYXNvbg==');

@$core.Deprecated('Use endCallResponseDescriptor instead')
const EndCallResponse$json = {
  '1': 'EndCallResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.EndCallSuccess',
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

/// Descriptor for `EndCallResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List endCallResponseDescriptor = $convert.base64Decode(
    'Cg9FbmRDYWxsUmVzcG9uc2USOQoHc3VjY2VzcxgBIAEoCzIdLmd1YXJkeW4uY2FsbHMuRW5kQ2'
    'FsbFN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJkeW4uY29tbW9uLkVy'
    'cm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use endCallSuccessDescriptor instead')
const EndCallSuccess$json = {
  '1': 'EndCallSuccess',
  '2': [
    {'1': 'ended', '3': 1, '4': 1, '5': 8, '10': 'ended'},
    {'1': 'duration_seconds', '3': 2, '4': 1, '5': 5, '10': 'durationSeconds'},
  ],
};

/// Descriptor for `EndCallSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List endCallSuccessDescriptor = $convert.base64Decode(
    'Cg5FbmRDYWxsU3VjY2VzcxIUCgVlbmRlZBgBIAEoCFIFZW5kZWQSKQoQZHVyYXRpb25fc2Vjb2'
    '5kcxgCIAEoBVIPZHVyYXRpb25TZWNvbmRz');

@$core.Deprecated('Use leaveCallRequestDescriptor instead')
const LeaveCallRequest$json = {
  '1': 'LeaveCallRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
  ],
};

/// Descriptor for `LeaveCallRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveCallRequestDescriptor = $convert.base64Decode(
    'ChBMZWF2ZUNhbGxSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW4SFw'
    'oHY2FsbF9pZBgCIAEoCVIGY2FsbElk');

@$core.Deprecated('Use leaveCallResponseDescriptor instead')
const LeaveCallResponse$json = {
  '1': 'LeaveCallResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.LeaveCallSuccess',
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

/// Descriptor for `LeaveCallResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveCallResponseDescriptor = $convert.base64Decode(
    'ChFMZWF2ZUNhbGxSZXNwb25zZRI7CgdzdWNjZXNzGAEgASgLMh8uZ3VhcmR5bi5jYWxscy5MZW'
    'F2ZUNhbGxTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFyZHluLmNvbW1v'
    'bi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use leaveCallSuccessDescriptor instead')
const LeaveCallSuccess$json = {
  '1': 'LeaveCallSuccess',
  '2': [
    {'1': 'left', '3': 1, '4': 1, '5': 8, '10': 'left'},
  ],
};

/// Descriptor for `LeaveCallSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaveCallSuccessDescriptor = $convert
    .base64Decode('ChBMZWF2ZUNhbGxTdWNjZXNzEhIKBGxlZnQYASABKAhSBGxlZnQ=');

@$core.Deprecated('Use joinCallRequestDescriptor instead')
const JoinCallRequest$json = {
  '1': 'JoinCallRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'capabilities',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.ClientCapabilities',
      '10': 'capabilities'
    },
  ],
};

/// Descriptor for `JoinCallRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinCallRequestDescriptor = $convert.base64Decode(
    'Cg9Kb2luQ2FsbFJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbhIXCg'
    'djYWxsX2lkGAIgASgJUgZjYWxsSWQSRQoMY2FwYWJpbGl0aWVzGAMgASgLMiEuZ3VhcmR5bi5j'
    'YWxscy5DbGllbnRDYXBhYmlsaXRpZXNSDGNhcGFiaWxpdGllcw==');

@$core.Deprecated('Use joinCallResponseDescriptor instead')
const JoinCallResponse$json = {
  '1': 'JoinCallResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.JoinCallSuccess',
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

/// Descriptor for `JoinCallResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinCallResponseDescriptor = $convert.base64Decode(
    'ChBKb2luQ2FsbFJlc3BvbnNlEjoKB3N1Y2Nlc3MYASABKAsyHi5ndWFyZHluLmNhbGxzLkpvaW'
    '5DYWxsU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0uZ3VhcmR5bi5jb21tb24u'
    'RXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use joinCallSuccessDescriptor instead')
const JoinCallSuccess$json = {
  '1': 'JoinCallSuccess',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'state',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallState',
      '10': 'state'
    },
    {
      '1': 'participants',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.guardyn.calls.CallParticipant',
      '10': 'participants'
    },
    {
      '1': 'ice_servers',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.guardyn.calls.IceServer',
      '10': 'iceServers'
    },
    {
      '1': 'sframe_key_material',
      '3': 5,
      '4': 1,
      '5': 12,
      '10': 'sframeKeyMaterial'
    },
    {'1': 'sframe_key_id', '3': 6, '4': 1, '5': 13, '10': 'sframeKeyId'},
  ],
};

/// Descriptor for `JoinCallSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinCallSuccessDescriptor = $convert.base64Decode(
    'Cg9Kb2luQ2FsbFN1Y2Nlc3MSFwoHY2FsbF9pZBgBIAEoCVIGY2FsbElkEi4KBXN0YXRlGAIgAS'
    'gOMhguZ3VhcmR5bi5jYWxscy5DYWxsU3RhdGVSBXN0YXRlEkIKDHBhcnRpY2lwYW50cxgDIAMo'
    'CzIeLmd1YXJkeW4uY2FsbHMuQ2FsbFBhcnRpY2lwYW50UgxwYXJ0aWNpcGFudHMSOQoLaWNlX3'
    'NlcnZlcnMYBCADKAsyGC5ndWFyZHluLmNhbGxzLkljZVNlcnZlclIKaWNlU2VydmVycxIuChNz'
    'ZnJhbWVfa2V5X21hdGVyaWFsGAUgASgMUhFzZnJhbWVLZXlNYXRlcmlhbBIiCg1zZnJhbWVfa2'
    'V5X2lkGAYgASgNUgtzZnJhbWVLZXlJZA==');

@$core.Deprecated('Use callParticipantDescriptor instead')
const CallParticipant$json = {
  '1': 'CallParticipant',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'is_muted', '3': 3, '4': 1, '5': 8, '10': 'isMuted'},
    {'1': 'has_video', '3': 4, '4': 1, '5': 8, '10': 'hasVideo'},
    {'1': 'is_screen_sharing', '3': 5, '4': 1, '5': 8, '10': 'isScreenSharing'},
    {'1': 'is_speaking', '3': 6, '4': 1, '5': 8, '10': 'isSpeaking'},
    {
      '1': 'joined_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'joinedAt'
    },
  ],
};

/// Descriptor for `CallParticipant`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callParticipantDescriptor = $convert.base64Decode(
    'Cg9DYWxsUGFydGljaXBhbnQSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEiEKDGRpc3BsYXlfbm'
    'FtZRgCIAEoCVILZGlzcGxheU5hbWUSGQoIaXNfbXV0ZWQYAyABKAhSB2lzTXV0ZWQSGwoJaGFz'
    'X3ZpZGVvGAQgASgIUghoYXNWaWRlbxIqChFpc19zY3JlZW5fc2hhcmluZxgFIAEoCFIPaXNTY3'
    'JlZW5TaGFyaW5nEh8KC2lzX3NwZWFraW5nGAYgASgIUgppc1NwZWFraW5nEjYKCWpvaW5lZF9h'
    'dBgHIAEoCzIZLmd1YXJkeW4uY29tbW9uLlRpbWVzdGFtcFIIam9pbmVkQXQ=');

@$core.Deprecated('Use setMuteRequestDescriptor instead')
const SetMuteRequest$json = {
  '1': 'SetMuteRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'muted', '3': 3, '4': 1, '5': 8, '10': 'muted'},
  ],
};

/// Descriptor for `SetMuteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setMuteRequestDescriptor = $convert.base64Decode(
    'Cg5TZXRNdXRlUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2VuEhcKB2'
    'NhbGxfaWQYAiABKAlSBmNhbGxJZBIUCgVtdXRlZBgDIAEoCFIFbXV0ZWQ=');

@$core.Deprecated('Use setMuteResponseDescriptor instead')
const SetMuteResponse$json = {
  '1': 'SetMuteResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.SetMuteSuccess',
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

/// Descriptor for `SetMuteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setMuteResponseDescriptor = $convert.base64Decode(
    'Cg9TZXRNdXRlUmVzcG9uc2USOQoHc3VjY2VzcxgBIAEoCzIdLmd1YXJkeW4uY2FsbHMuU2V0TX'
    'V0ZVN1Y2Nlc3NIAFIHc3VjY2VzcxI1CgVlcnJvchgCIAEoCzIdLmd1YXJkeW4uY29tbW9uLkVy'
    'cm9yUmVzcG9uc2VIAFIFZXJyb3JCCAoGcmVzdWx0');

@$core.Deprecated('Use setMuteSuccessDescriptor instead')
const SetMuteSuccess$json = {
  '1': 'SetMuteSuccess',
  '2': [
    {'1': 'muted', '3': 1, '4': 1, '5': 8, '10': 'muted'},
  ],
};

/// Descriptor for `SetMuteSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setMuteSuccessDescriptor = $convert
    .base64Decode('Cg5TZXRNdXRlU3VjY2VzcxIUCgVtdXRlZBgBIAEoCFIFbXV0ZWQ=');

@$core.Deprecated('Use setVideoRequestDescriptor instead')
const SetVideoRequest$json = {
  '1': 'SetVideoRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'video_enabled', '3': 3, '4': 1, '5': 8, '10': 'videoEnabled'},
  ],
};

/// Descriptor for `SetVideoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setVideoRequestDescriptor = $convert.base64Decode(
    'Cg9TZXRWaWRlb1JlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbhIXCg'
    'djYWxsX2lkGAIgASgJUgZjYWxsSWQSIwoNdmlkZW9fZW5hYmxlZBgDIAEoCFIMdmlkZW9FbmFi'
    'bGVk');

@$core.Deprecated('Use setVideoResponseDescriptor instead')
const SetVideoResponse$json = {
  '1': 'SetVideoResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.SetVideoSuccess',
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

/// Descriptor for `SetVideoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setVideoResponseDescriptor = $convert.base64Decode(
    'ChBTZXRWaWRlb1Jlc3BvbnNlEjoKB3N1Y2Nlc3MYASABKAsyHi5ndWFyZHluLmNhbGxzLlNldF'
    'ZpZGVvU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0uZ3VhcmR5bi5jb21tb24u'
    'RXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use setVideoSuccessDescriptor instead')
const SetVideoSuccess$json = {
  '1': 'SetVideoSuccess',
  '2': [
    {'1': 'video_enabled', '3': 1, '4': 1, '5': 8, '10': 'videoEnabled'},
  ],
};

/// Descriptor for `SetVideoSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setVideoSuccessDescriptor = $convert.base64Decode(
    'Cg9TZXRWaWRlb1N1Y2Nlc3MSIwoNdmlkZW9fZW5hYmxlZBgBIAEoCFIMdmlkZW9FbmFibGVk');

@$core.Deprecated('Use setScreenShareRequestDescriptor instead')
const SetScreenShareRequest$json = {
  '1': 'SetScreenShareRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'screen_share_enabled',
      '3': 3,
      '4': 1,
      '5': 8,
      '10': 'screenShareEnabled'
    },
  ],
};

/// Descriptor for `SetScreenShareRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setScreenShareRequestDescriptor = $convert.base64Decode(
    'ChVTZXRTY3JlZW5TaGFyZVJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2'
    'tlbhIXCgdjYWxsX2lkGAIgASgJUgZjYWxsSWQSMAoUc2NyZWVuX3NoYXJlX2VuYWJsZWQYAyAB'
    'KAhSEnNjcmVlblNoYXJlRW5hYmxlZA==');

@$core.Deprecated('Use setScreenShareResponseDescriptor instead')
const SetScreenShareResponse$json = {
  '1': 'SetScreenShareResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.SetScreenShareSuccess',
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

/// Descriptor for `SetScreenShareResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setScreenShareResponseDescriptor = $convert.base64Decode(
    'ChZTZXRTY3JlZW5TaGFyZVJlc3BvbnNlEkAKB3N1Y2Nlc3MYASABKAsyJC5ndWFyZHluLmNhbG'
    'xzLlNldFNjcmVlblNoYXJlU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0uZ3Vh'
    'cmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use setScreenShareSuccessDescriptor instead')
const SetScreenShareSuccess$json = {
  '1': 'SetScreenShareSuccess',
  '2': [
    {
      '1': 'screen_share_enabled',
      '3': 1,
      '4': 1,
      '5': 8,
      '10': 'screenShareEnabled'
    },
  ],
};

/// Descriptor for `SetScreenShareSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setScreenShareSuccessDescriptor = $convert.base64Decode(
    'ChVTZXRTY3JlZW5TaGFyZVN1Y2Nlc3MSMAoUc2NyZWVuX3NoYXJlX2VuYWJsZWQYASABKAhSEn'
    'NjcmVlblNoYXJlRW5hYmxlZA==');

@$core.Deprecated('Use exchangeIceCandidateRequestDescriptor instead')
const ExchangeIceCandidateRequest$json = {
  '1': 'ExchangeIceCandidateRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'target_user_id', '3': 3, '4': 1, '5': 9, '10': 'targetUserId'},
    {
      '1': 'candidate',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.IceCandidate',
      '10': 'candidate'
    },
  ],
};

/// Descriptor for `ExchangeIceCandidateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exchangeIceCandidateRequestDescriptor = $convert.base64Decode(
    'ChtFeGNoYW5nZUljZUNhbmRpZGF0ZVJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2'
    'Nlc3NUb2tlbhIXCgdjYWxsX2lkGAIgASgJUgZjYWxsSWQSJAoOdGFyZ2V0X3VzZXJfaWQYAyAB'
    'KAlSDHRhcmdldFVzZXJJZBI5CgljYW5kaWRhdGUYBCABKAsyGy5ndWFyZHluLmNhbGxzLkljZU'
    'NhbmRpZGF0ZVIJY2FuZGlkYXRl');

@$core.Deprecated('Use iceCandidateDescriptor instead')
const IceCandidate$json = {
  '1': 'IceCandidate',
  '2': [
    {'1': 'candidate', '3': 1, '4': 1, '5': 9, '10': 'candidate'},
    {'1': 'sdp_mid', '3': 2, '4': 1, '5': 9, '10': 'sdpMid'},
    {'1': 'sdp_mline_index', '3': 3, '4': 1, '5': 5, '10': 'sdpMlineIndex'},
    {
      '1': 'username_fragment',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'usernameFragment'
    },
  ],
};

/// Descriptor for `IceCandidate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List iceCandidateDescriptor = $convert.base64Decode(
    'CgxJY2VDYW5kaWRhdGUSHAoJY2FuZGlkYXRlGAEgASgJUgljYW5kaWRhdGUSFwoHc2RwX21pZB'
    'gCIAEoCVIGc2RwTWlkEiYKD3NkcF9tbGluZV9pbmRleBgDIAEoBVINc2RwTWxpbmVJbmRleBIr'
    'ChF1c2VybmFtZV9mcmFnbWVudBgEIAEoCVIQdXNlcm5hbWVGcmFnbWVudA==');

@$core.Deprecated('Use exchangeIceCandidateResponseDescriptor instead')
const ExchangeIceCandidateResponse$json = {
  '1': 'ExchangeIceCandidateResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.ExchangeIceCandidateSuccess',
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

/// Descriptor for `ExchangeIceCandidateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exchangeIceCandidateResponseDescriptor = $convert.base64Decode(
    'ChxFeGNoYW5nZUljZUNhbmRpZGF0ZVJlc3BvbnNlEkYKB3N1Y2Nlc3MYASABKAsyKi5ndWFyZH'
    'luLmNhbGxzLkV4Y2hhbmdlSWNlQ2FuZGlkYXRlU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9y'
    'GAIgASgLMh0uZ3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bH'
    'Q=');

@$core.Deprecated('Use exchangeIceCandidateSuccessDescriptor instead')
const ExchangeIceCandidateSuccess$json = {
  '1': 'ExchangeIceCandidateSuccess',
  '2': [
    {'1': 'sent', '3': 1, '4': 1, '5': 8, '10': 'sent'},
  ],
};

/// Descriptor for `ExchangeIceCandidateSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exchangeIceCandidateSuccessDescriptor =
    $convert.base64Decode(
        'ChtFeGNoYW5nZUljZUNhbmRpZGF0ZVN1Y2Nlc3MSEgoEc2VudBgBIAEoCFIEc2VudA==');

@$core.Deprecated('Use exchangeSdpRequestDescriptor instead')
const ExchangeSdpRequest$json = {
  '1': 'ExchangeSdpRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
    {'1': 'target_user_id', '3': 3, '4': 1, '5': 9, '10': 'targetUserId'},
    {
      '1': 'sdp',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.SdpMessage',
      '10': 'sdp'
    },
  ],
};

/// Descriptor for `ExchangeSdpRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exchangeSdpRequestDescriptor = $convert.base64Decode(
    'ChJFeGNoYW5nZVNkcFJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbh'
    'IXCgdjYWxsX2lkGAIgASgJUgZjYWxsSWQSJAoOdGFyZ2V0X3VzZXJfaWQYAyABKAlSDHRhcmdl'
    'dFVzZXJJZBIrCgNzZHAYBCABKAsyGS5ndWFyZHluLmNhbGxzLlNkcE1lc3NhZ2VSA3NkcA==');

@$core.Deprecated('Use sdpMessageDescriptor instead')
const SdpMessage$json = {
  '1': 'SdpMessage',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.SdpType',
      '10': 'type'
    },
    {'1': 'sdp', '3': 2, '4': 1, '5': 9, '10': 'sdp'},
  ],
};

/// Descriptor for `SdpMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sdpMessageDescriptor = $convert.base64Decode(
    'CgpTZHBNZXNzYWdlEioKBHR5cGUYASABKA4yFi5ndWFyZHluLmNhbGxzLlNkcFR5cGVSBHR5cG'
    'USEAoDc2RwGAIgASgJUgNzZHA=');

@$core.Deprecated('Use exchangeSdpResponseDescriptor instead')
const ExchangeSdpResponse$json = {
  '1': 'ExchangeSdpResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.ExchangeSdpSuccess',
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

/// Descriptor for `ExchangeSdpResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exchangeSdpResponseDescriptor = $convert.base64Decode(
    'ChNFeGNoYW5nZVNkcFJlc3BvbnNlEj0KB3N1Y2Nlc3MYASABKAsyIS5ndWFyZHluLmNhbGxzLk'
    'V4Y2hhbmdlU2RwU3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0uZ3VhcmR5bi5j'
    'b21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use exchangeSdpSuccessDescriptor instead')
const ExchangeSdpSuccess$json = {
  '1': 'ExchangeSdpSuccess',
  '2': [
    {'1': 'sent', '3': 1, '4': 1, '5': 8, '10': 'sent'},
  ],
};

/// Descriptor for `ExchangeSdpSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exchangeSdpSuccessDescriptor = $convert
    .base64Decode('ChJFeGNoYW5nZVNkcFN1Y2Nlc3MSEgoEc2VudBgBIAEoCFIEc2VudA==');

@$core.Deprecated('Use getCallStateRequestDescriptor instead')
const GetCallStateRequest$json = {
  '1': 'GetCallStateRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
  ],
};

/// Descriptor for `GetCallStateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCallStateRequestDescriptor = $convert.base64Decode(
    'ChNHZXRDYWxsU3RhdGVSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW'
    '4SFwoHY2FsbF9pZBgCIAEoCVIGY2FsbElk');

@$core.Deprecated('Use getCallStateResponseDescriptor instead')
const GetCallStateResponse$json = {
  '1': 'GetCallStateResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.GetCallStateSuccess',
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

/// Descriptor for `GetCallStateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCallStateResponseDescriptor = $convert.base64Decode(
    'ChRHZXRDYWxsU3RhdGVSZXNwb25zZRI+CgdzdWNjZXNzGAEgASgLMiIuZ3VhcmR5bi5jYWxscy'
    '5HZXRDYWxsU3RhdGVTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5ndWFyZHlu'
    'LmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use getCallStateSuccessDescriptor instead')
const GetCallStateSuccess$json = {
  '1': 'GetCallStateSuccess',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'call_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallType',
      '10': 'callType'
    },
    {
      '1': 'state',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallState',
      '10': 'state'
    },
    {'1': 'is_group_call', '3': 4, '4': 1, '5': 8, '10': 'isGroupCall'},
    {'1': 'initiator_id', '3': 5, '4': 1, '5': 9, '10': 'initiatorId'},
    {
      '1': 'participants',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.guardyn.calls.CallParticipant',
      '10': 'participants'
    },
    {
      '1': 'started_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'startedAt'
    },
    {'1': 'duration_seconds', '3': 8, '4': 1, '5': 5, '10': 'durationSeconds'},
  ],
};

/// Descriptor for `GetCallStateSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCallStateSuccessDescriptor = $convert.base64Decode(
    'ChNHZXRDYWxsU3RhdGVTdWNjZXNzEhcKB2NhbGxfaWQYASABKAlSBmNhbGxJZBI0CgljYWxsX3'
    'R5cGUYAiABKA4yFy5ndWFyZHluLmNhbGxzLkNhbGxUeXBlUghjYWxsVHlwZRIuCgVzdGF0ZRgD'
    'IAEoDjIYLmd1YXJkeW4uY2FsbHMuQ2FsbFN0YXRlUgVzdGF0ZRIiCg1pc19ncm91cF9jYWxsGA'
    'QgASgIUgtpc0dyb3VwQ2FsbBIhCgxpbml0aWF0b3JfaWQYBSABKAlSC2luaXRpYXRvcklkEkIK'
    'DHBhcnRpY2lwYW50cxgGIAMoCzIeLmd1YXJkeW4uY2FsbHMuQ2FsbFBhcnRpY2lwYW50UgxwYX'
    'J0aWNpcGFudHMSOAoKc3RhcnRlZF9hdBgHIAEoCzIZLmd1YXJkeW4uY29tbW9uLlRpbWVzdGFt'
    'cFIJc3RhcnRlZEF0EikKEGR1cmF0aW9uX3NlY29uZHMYCCABKAVSD2R1cmF0aW9uU2Vjb25kcw'
    '==');

@$core.Deprecated('Use getCallHistoryRequestDescriptor instead')
const GetCallHistoryRequest$json = {
  '1': 'GetCallHistoryRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'cursor', '3': 3, '4': 1, '5': 9, '10': 'cursor'},
  ],
};

/// Descriptor for `GetCallHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCallHistoryRequestDescriptor = $convert.base64Decode(
    'ChVHZXRDYWxsSGlzdG9yeVJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2'
    'tlbhIUCgVsaW1pdBgCIAEoBVIFbGltaXQSFgoGY3Vyc29yGAMgASgJUgZjdXJzb3I=');

@$core.Deprecated('Use getCallHistoryResponseDescriptor instead')
const GetCallHistoryResponse$json = {
  '1': 'GetCallHistoryResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.GetCallHistorySuccess',
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

/// Descriptor for `GetCallHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCallHistoryResponseDescriptor = $convert.base64Decode(
    'ChZHZXRDYWxsSGlzdG9yeVJlc3BvbnNlEkAKB3N1Y2Nlc3MYASABKAsyJC5ndWFyZHluLmNhbG'
    'xzLkdldENhbGxIaXN0b3J5U3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgLMh0uZ3Vh'
    'cmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use getCallHistorySuccessDescriptor instead')
const GetCallHistorySuccess$json = {
  '1': 'GetCallHistorySuccess',
  '2': [
    {
      '1': 'calls',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.guardyn.calls.CallHistoryEntry',
      '10': 'calls'
    },
    {'1': 'next_cursor', '3': 2, '4': 1, '5': 9, '10': 'nextCursor'},
  ],
};

/// Descriptor for `GetCallHistorySuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCallHistorySuccessDescriptor = $convert.base64Decode(
    'ChVHZXRDYWxsSGlzdG9yeVN1Y2Nlc3MSNQoFY2FsbHMYASADKAsyHy5ndWFyZHluLmNhbGxzLk'
    'NhbGxIaXN0b3J5RW50cnlSBWNhbGxzEh8KC25leHRfY3Vyc29yGAIgASgJUgpuZXh0Q3Vyc29y');

@$core.Deprecated('Use callHistoryEntryDescriptor instead')
const CallHistoryEntry$json = {
  '1': 'CallHistoryEntry',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'call_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallType',
      '10': 'callType'
    },
    {'1': 'is_group_call', '3': 3, '4': 1, '5': 8, '10': 'isGroupCall'},
    {'1': 'group_id', '3': 4, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'other_user_id', '3': 5, '4': 1, '5': 9, '10': 'otherUserId'},
    {'1': 'other_user_name', '3': 6, '4': 1, '5': 9, '10': 'otherUserName'},
    {'1': 'is_outgoing', '3': 7, '4': 1, '5': 8, '10': 'isOutgoing'},
    {
      '1': 'end_reason',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallEndReason',
      '10': 'endReason'
    },
    {
      '1': 'started_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'startedAt'
    },
    {'1': 'duration_seconds', '3': 10, '4': 1, '5': 5, '10': 'durationSeconds'},
  ],
};

/// Descriptor for `CallHistoryEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callHistoryEntryDescriptor = $convert.base64Decode(
    'ChBDYWxsSGlzdG9yeUVudHJ5EhcKB2NhbGxfaWQYASABKAlSBmNhbGxJZBI0CgljYWxsX3R5cG'
    'UYAiABKA4yFy5ndWFyZHluLmNhbGxzLkNhbGxUeXBlUghjYWxsVHlwZRIiCg1pc19ncm91cF9j'
    'YWxsGAMgASgIUgtpc0dyb3VwQ2FsbBIZCghncm91cF9pZBgEIAEoCVIHZ3JvdXBJZBIiCg1vdG'
    'hlcl91c2VyX2lkGAUgASgJUgtvdGhlclVzZXJJZBImCg9vdGhlcl91c2VyX25hbWUYBiABKAlS'
    'DW90aGVyVXNlck5hbWUSHwoLaXNfb3V0Z29pbmcYByABKAhSCmlzT3V0Z29pbmcSOwoKZW5kX3'
    'JlYXNvbhgIIAEoDjIcLmd1YXJkeW4uY2FsbHMuQ2FsbEVuZFJlYXNvblIJZW5kUmVhc29uEjgK'
    'CnN0YXJ0ZWRfYXQYCSABKAsyGS5ndWFyZHluLmNvbW1vbi5UaW1lc3RhbXBSCXN0YXJ0ZWRBdB'
    'IpChBkdXJhdGlvbl9zZWNvbmRzGAogASgFUg9kdXJhdGlvblNlY29uZHM=');

@$core.Deprecated('Use streamCallEventsRequestDescriptor instead')
const StreamCallEventsRequest$json = {
  '1': 'StreamCallEventsRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
  ],
};

/// Descriptor for `StreamCallEventsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamCallEventsRequestDescriptor =
    $convert.base64Decode(
        'ChdTdHJlYW1DYWxsRXZlbnRzUmVxdWVzdBIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1'
        'Rva2VuEhcKB2NhbGxfaWQYAiABKAlSBmNhbGxJZA==');

@$core.Deprecated('Use subscribeToIncomingCallsRequestDescriptor instead')
const SubscribeToIncomingCallsRequest$json = {
  '1': 'SubscribeToIncomingCallsRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
  ],
};

/// Descriptor for `SubscribeToIncomingCallsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeToIncomingCallsRequestDescriptor =
    $convert.base64Decode(
        'Ch9TdWJzY3JpYmVUb0luY29taW5nQ2FsbHNSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCV'
        'ILYWNjZXNzVG9rZW4=');

@$core.Deprecated('Use incomingCallNotificationDescriptor instead')
const IncomingCallNotification$json = {
  '1': 'IncomingCallNotification',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'call_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallType',
      '10': 'callType'
    },
    {'1': 'is_group_call', '3': 3, '4': 1, '5': 8, '10': 'isGroupCall'},
    {
      '1': 'group_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'groupId',
      '17': true
    },
    {'1': 'caller_id', '3': 5, '4': 1, '5': 9, '10': 'callerId'},
    {
      '1': 'caller_display_name',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'callerDisplayName'
    },
    {
      '1': 'caller_avatar_url',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'callerAvatarUrl',
      '17': true
    },
    {
      '1': 'ice_servers',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.guardyn.calls.IceServer',
      '10': 'iceServers'
    },
    {
      '1': 'created_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'createdAt'
    },
  ],
  '8': [
    {'1': '_group_id'},
    {'1': '_caller_avatar_url'},
  ],
};

/// Descriptor for `IncomingCallNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List incomingCallNotificationDescriptor = $convert.base64Decode(
    'ChhJbmNvbWluZ0NhbGxOb3RpZmljYXRpb24SFwoHY2FsbF9pZBgBIAEoCVIGY2FsbElkEjQKCW'
    'NhbGxfdHlwZRgCIAEoDjIXLmd1YXJkeW4uY2FsbHMuQ2FsbFR5cGVSCGNhbGxUeXBlEiIKDWlz'
    'X2dyb3VwX2NhbGwYAyABKAhSC2lzR3JvdXBDYWxsEh4KCGdyb3VwX2lkGAQgASgJSABSB2dyb3'
    'VwSWSIAQESGwoJY2FsbGVyX2lkGAUgASgJUghjYWxsZXJJZBIuChNjYWxsZXJfZGlzcGxheV9u'
    'YW1lGAYgASgJUhFjYWxsZXJEaXNwbGF5TmFtZRIvChFjYWxsZXJfYXZhdGFyX3VybBgHIAEoCU'
    'gBUg9jYWxsZXJBdmF0YXJVcmyIAQESOQoLaWNlX3NlcnZlcnMYCCADKAsyGC5ndWFyZHluLmNh'
    'bGxzLkljZVNlcnZlclIKaWNlU2VydmVycxI4CgpjcmVhdGVkX2F0GAkgASgLMhkuZ3VhcmR5bi'
    '5jb21tb24uVGltZXN0YW1wUgljcmVhdGVkQXRCCwoJX2dyb3VwX2lkQhQKEl9jYWxsZXJfYXZh'
    'dGFyX3VybA==');

@$core.Deprecated('Use callEventDescriptor instead')
const CallEvent$json = {
  '1': 'CallEvent',
  '2': [
    {'1': 'call_id', '3': 1, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'timestamp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'state_changed',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.CallStateChanged',
      '9': 0,
      '10': 'stateChanged'
    },
    {
      '1': 'participant_joined',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.ParticipantJoined',
      '9': 0,
      '10': 'participantJoined'
    },
    {
      '1': 'participant_left',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.ParticipantLeft',
      '9': 0,
      '10': 'participantLeft'
    },
    {
      '1': 'participant_muted',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.ParticipantMuted',
      '9': 0,
      '10': 'participantMuted'
    },
    {
      '1': 'participant_video_changed',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.ParticipantVideoChanged',
      '9': 0,
      '10': 'participantVideoChanged'
    },
    {
      '1': 'participant_screen_share_changed',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.ParticipantScreenShareChanged',
      '9': 0,
      '10': 'participantScreenShareChanged'
    },
    {
      '1': 'participant_speaking',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.ParticipantSpeaking',
      '9': 0,
      '10': 'participantSpeaking'
    },
    {
      '1': 'ice_candidate_received',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.IceCandidateReceived',
      '9': 0,
      '10': 'iceCandidateReceived'
    },
    {
      '1': 'sdp_received',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.SdpReceived',
      '9': 0,
      '10': 'sdpReceived'
    },
    {
      '1': 'sframe_key_rotated',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.SFrameKeyRotated',
      '9': 0,
      '10': 'sframeKeyRotated'
    },
    {
      '1': 'quality_changed',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.CallQualityChanged',
      '9': 0,
      '10': 'qualityChanged'
    },
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `CallEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callEventDescriptor = $convert.base64Decode(
    'CglDYWxsRXZlbnQSFwoHY2FsbF9pZBgBIAEoCVIGY2FsbElkEjcKCXRpbWVzdGFtcBgCIAEoCz'
    'IZLmd1YXJkeW4uY29tbW9uLlRpbWVzdGFtcFIJdGltZXN0YW1wEkYKDXN0YXRlX2NoYW5nZWQY'
    'AyABKAsyHy5ndWFyZHluLmNhbGxzLkNhbGxTdGF0ZUNoYW5nZWRIAFIMc3RhdGVDaGFuZ2VkEl'
    'EKEnBhcnRpY2lwYW50X2pvaW5lZBgEIAEoCzIgLmd1YXJkeW4uY2FsbHMuUGFydGljaXBhbnRK'
    'b2luZWRIAFIRcGFydGljaXBhbnRKb2luZWQSSwoQcGFydGljaXBhbnRfbGVmdBgFIAEoCzIeLm'
    'd1YXJkeW4uY2FsbHMuUGFydGljaXBhbnRMZWZ0SABSD3BhcnRpY2lwYW50TGVmdBJOChFwYXJ0'
    'aWNpcGFudF9tdXRlZBgGIAEoCzIfLmd1YXJkeW4uY2FsbHMuUGFydGljaXBhbnRNdXRlZEgAUh'
    'BwYXJ0aWNpcGFudE11dGVkEmQKGXBhcnRpY2lwYW50X3ZpZGVvX2NoYW5nZWQYByABKAsyJi5n'
    'dWFyZHluLmNhbGxzLlBhcnRpY2lwYW50VmlkZW9DaGFuZ2VkSABSF3BhcnRpY2lwYW50VmlkZW'
    '9DaGFuZ2VkEncKIHBhcnRpY2lwYW50X3NjcmVlbl9zaGFyZV9jaGFuZ2VkGAggASgLMiwuZ3Vh'
    'cmR5bi5jYWxscy5QYXJ0aWNpcGFudFNjcmVlblNoYXJlQ2hhbmdlZEgAUh1wYXJ0aWNpcGFudF'
    'NjcmVlblNoYXJlQ2hhbmdlZBJXChRwYXJ0aWNpcGFudF9zcGVha2luZxgJIAEoCzIiLmd1YXJk'
    'eW4uY2FsbHMuUGFydGljaXBhbnRTcGVha2luZ0gAUhNwYXJ0aWNpcGFudFNwZWFraW5nElsKFm'
    'ljZV9jYW5kaWRhdGVfcmVjZWl2ZWQYCiABKAsyIy5ndWFyZHluLmNhbGxzLkljZUNhbmRpZGF0'
    'ZVJlY2VpdmVkSABSFGljZUNhbmRpZGF0ZVJlY2VpdmVkEj8KDHNkcF9yZWNlaXZlZBgLIAEoCz'
    'IaLmd1YXJkeW4uY2FsbHMuU2RwUmVjZWl2ZWRIAFILc2RwUmVjZWl2ZWQSTwoSc2ZyYW1lX2tl'
    'eV9yb3RhdGVkGAwgASgLMh8uZ3VhcmR5bi5jYWxscy5TRnJhbWVLZXlSb3RhdGVkSABSEHNmcm'
    'FtZUtleVJvdGF0ZWQSTAoPcXVhbGl0eV9jaGFuZ2VkGA0gASgLMiEuZ3VhcmR5bi5jYWxscy5D'
    'YWxsUXVhbGl0eUNoYW5nZWRIAFIOcXVhbGl0eUNoYW5nZWRCBwoFZXZlbnQ=');

@$core.Deprecated('Use callStateChangedDescriptor instead')
const CallStateChanged$json = {
  '1': 'CallStateChanged',
  '2': [
    {
      '1': 'old_state',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallState',
      '10': 'oldState'
    },
    {
      '1': 'new_state',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallState',
      '10': 'newState'
    },
    {
      '1': 'end_reason',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallEndReason',
      '10': 'endReason'
    },
  ],
};

/// Descriptor for `CallStateChanged`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callStateChangedDescriptor = $convert.base64Decode(
    'ChBDYWxsU3RhdGVDaGFuZ2VkEjUKCW9sZF9zdGF0ZRgBIAEoDjIYLmd1YXJkeW4uY2FsbHMuQ2'
    'FsbFN0YXRlUghvbGRTdGF0ZRI1CgluZXdfc3RhdGUYAiABKA4yGC5ndWFyZHluLmNhbGxzLkNh'
    'bGxTdGF0ZVIIbmV3U3RhdGUSOwoKZW5kX3JlYXNvbhgDIAEoDjIcLmd1YXJkeW4uY2FsbHMuQ2'
    'FsbEVuZFJlYXNvblIJZW5kUmVhc29u');

@$core.Deprecated('Use participantJoinedDescriptor instead')
const ParticipantJoined$json = {
  '1': 'ParticipantJoined',
  '2': [
    {
      '1': 'participant',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.CallParticipant',
      '10': 'participant'
    },
  ],
};

/// Descriptor for `ParticipantJoined`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantJoinedDescriptor = $convert.base64Decode(
    'ChFQYXJ0aWNpcGFudEpvaW5lZBJACgtwYXJ0aWNpcGFudBgBIAEoCzIeLmd1YXJkeW4uY2FsbH'
    'MuQ2FsbFBhcnRpY2lwYW50UgtwYXJ0aWNpcGFudA==');

@$core.Deprecated('Use participantLeftDescriptor instead')
const ParticipantLeft$json = {
  '1': 'ParticipantLeft',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `ParticipantLeft`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantLeftDescriptor = $convert.base64Decode(
    'Cg9QYXJ0aWNpcGFudExlZnQSFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEhYKBnJlYXNvbhgCIA'
    'EoCVIGcmVhc29u');

@$core.Deprecated('Use participantMutedDescriptor instead')
const ParticipantMuted$json = {
  '1': 'ParticipantMuted',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'is_muted', '3': 2, '4': 1, '5': 8, '10': 'isMuted'},
  ],
};

/// Descriptor for `ParticipantMuted`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantMutedDescriptor = $convert.base64Decode(
    'ChBQYXJ0aWNpcGFudE11dGVkEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIZCghpc19tdXRlZB'
    'gCIAEoCFIHaXNNdXRlZA==');

@$core.Deprecated('Use participantVideoChangedDescriptor instead')
const ParticipantVideoChanged$json = {
  '1': 'ParticipantVideoChanged',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'has_video', '3': 2, '4': 1, '5': 8, '10': 'hasVideo'},
  ],
};

/// Descriptor for `ParticipantVideoChanged`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantVideoChangedDescriptor =
    $convert.base64Decode(
        'ChdQYXJ0aWNpcGFudFZpZGVvQ2hhbmdlZBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGwoJaG'
        'FzX3ZpZGVvGAIgASgIUghoYXNWaWRlbw==');

@$core.Deprecated('Use participantScreenShareChangedDescriptor instead')
const ParticipantScreenShareChanged$json = {
  '1': 'ParticipantScreenShareChanged',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'is_screen_sharing', '3': 2, '4': 1, '5': 8, '10': 'isScreenSharing'},
  ],
};

/// Descriptor for `ParticipantScreenShareChanged`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantScreenShareChangedDescriptor =
    $convert.base64Decode(
        'Ch1QYXJ0aWNpcGFudFNjcmVlblNoYXJlQ2hhbmdlZBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySW'
        'QSKgoRaXNfc2NyZWVuX3NoYXJpbmcYAiABKAhSD2lzU2NyZWVuU2hhcmluZw==');

@$core.Deprecated('Use participantSpeakingDescriptor instead')
const ParticipantSpeaking$json = {
  '1': 'ParticipantSpeaking',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'is_speaking', '3': 2, '4': 1, '5': 8, '10': 'isSpeaking'},
    {'1': 'audio_level', '3': 3, '4': 1, '5': 2, '10': 'audioLevel'},
  ],
};

/// Descriptor for `ParticipantSpeaking`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantSpeakingDescriptor = $convert.base64Decode(
    'ChNQYXJ0aWNpcGFudFNwZWFraW5nEhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBIfCgtpc19zcG'
    'Vha2luZxgCIAEoCFIKaXNTcGVha2luZxIfCgthdWRpb19sZXZlbBgDIAEoAlIKYXVkaW9MZXZl'
    'bA==');

@$core.Deprecated('Use iceCandidateReceivedDescriptor instead')
const IceCandidateReceived$json = {
  '1': 'IceCandidateReceived',
  '2': [
    {'1': 'from_user_id', '3': 1, '4': 1, '5': 9, '10': 'fromUserId'},
    {
      '1': 'candidate',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.IceCandidate',
      '10': 'candidate'
    },
  ],
};

/// Descriptor for `IceCandidateReceived`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List iceCandidateReceivedDescriptor = $convert.base64Decode(
    'ChRJY2VDYW5kaWRhdGVSZWNlaXZlZBIgCgxmcm9tX3VzZXJfaWQYASABKAlSCmZyb21Vc2VySW'
    'QSOQoJY2FuZGlkYXRlGAIgASgLMhsuZ3VhcmR5bi5jYWxscy5JY2VDYW5kaWRhdGVSCWNhbmRp'
    'ZGF0ZQ==');

@$core.Deprecated('Use sdpReceivedDescriptor instead')
const SdpReceived$json = {
  '1': 'SdpReceived',
  '2': [
    {'1': 'from_user_id', '3': 1, '4': 1, '5': 9, '10': 'fromUserId'},
    {
      '1': 'sdp',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.SdpMessage',
      '10': 'sdp'
    },
  ],
};

/// Descriptor for `SdpReceived`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sdpReceivedDescriptor = $convert.base64Decode(
    'CgtTZHBSZWNlaXZlZBIgCgxmcm9tX3VzZXJfaWQYASABKAlSCmZyb21Vc2VySWQSKwoDc2RwGA'
    'IgASgLMhkuZ3VhcmR5bi5jYWxscy5TZHBNZXNzYWdlUgNzZHA=');

@$core.Deprecated('Use sFrameKeyRotatedDescriptor instead')
const SFrameKeyRotated$json = {
  '1': 'SFrameKeyRotated',
  '2': [
    {'1': 'from_user_id', '3': 1, '4': 1, '5': 9, '10': 'fromUserId'},
    {'1': 'new_key_id', '3': 2, '4': 1, '5': 13, '10': 'newKeyId'},
    {
      '1': 'encrypted_key_material',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'encryptedKeyMaterial'
    },
  ],
};

/// Descriptor for `SFrameKeyRotated`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sFrameKeyRotatedDescriptor = $convert.base64Decode(
    'ChBTRnJhbWVLZXlSb3RhdGVkEiAKDGZyb21fdXNlcl9pZBgBIAEoCVIKZnJvbVVzZXJJZBIcCg'
    'puZXdfa2V5X2lkGAIgASgNUghuZXdLZXlJZBI0ChZlbmNyeXB0ZWRfa2V5X21hdGVyaWFsGAMg'
    'ASgMUhRlbmNyeXB0ZWRLZXlNYXRlcmlhbA==');

@$core.Deprecated('Use callQualityChangedDescriptor instead')
const CallQualityChanged$json = {
  '1': 'CallQualityChanged',
  '2': [
    {
      '1': 'quality',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.guardyn.calls.CallQuality',
      '10': 'quality'
    },
  ],
};

/// Descriptor for `CallQualityChanged`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List callQualityChangedDescriptor = $convert.base64Decode(
    'ChJDYWxsUXVhbGl0eUNoYW5nZWQSNAoHcXVhbGl0eRgBIAEoDjIaLmd1YXJkeW4uY2FsbHMuQ2'
    'FsbFF1YWxpdHlSB3F1YWxpdHk=');

@$core.Deprecated('Use exchangeSFrameKeyRequestDescriptor instead')
const ExchangeSFrameKeyRequest$json = {
  '1': 'ExchangeSFrameKeyRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'key_packages',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.guardyn.calls.ParticipantKeyPackage',
      '10': 'keyPackages'
    },
  ],
};

/// Descriptor for `ExchangeSFrameKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exchangeSFrameKeyRequestDescriptor = $convert.base64Decode(
    'ChhFeGNoYW5nZVNGcmFtZUtleVJlcXVlc3QSIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3'
    'NUb2tlbhIXCgdjYWxsX2lkGAIgASgJUgZjYWxsSWQSRwoMa2V5X3BhY2thZ2VzGAMgAygLMiQu'
    'Z3VhcmR5bi5jYWxscy5QYXJ0aWNpcGFudEtleVBhY2thZ2VSC2tleVBhY2thZ2Vz');

@$core.Deprecated('Use participantKeyPackageDescriptor instead')
const ParticipantKeyPackage$json = {
  '1': 'ParticipantKeyPackage',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {
      '1': 'encrypted_key_material',
      '3': 2,
      '4': 1,
      '5': 12,
      '10': 'encryptedKeyMaterial'
    },
    {'1': 'key_id', '3': 3, '4': 1, '5': 13, '10': 'keyId'},
  ],
};

/// Descriptor for `ParticipantKeyPackage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List participantKeyPackageDescriptor = $convert.base64Decode(
    'ChVQYXJ0aWNpcGFudEtleVBhY2thZ2USFwoHdXNlcl9pZBgBIAEoCVIGdXNlcklkEjQKFmVuY3'
    'J5cHRlZF9rZXlfbWF0ZXJpYWwYAiABKAxSFGVuY3J5cHRlZEtleU1hdGVyaWFsEhUKBmtleV9p'
    'ZBgDIAEoDVIFa2V5SWQ=');

@$core.Deprecated('Use exchangeSFrameKeyResponseDescriptor instead')
const ExchangeSFrameKeyResponse$json = {
  '1': 'ExchangeSFrameKeyResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.ExchangeSFrameKeySuccess',
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

/// Descriptor for `ExchangeSFrameKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exchangeSFrameKeyResponseDescriptor = $convert.base64Decode(
    'ChlFeGNoYW5nZVNGcmFtZUtleVJlc3BvbnNlEkMKB3N1Y2Nlc3MYASABKAsyJy5ndWFyZHluLm'
    'NhbGxzLkV4Y2hhbmdlU0ZyYW1lS2V5U3VjY2Vzc0gAUgdzdWNjZXNzEjUKBWVycm9yGAIgASgL'
    'Mh0uZ3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZUgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use exchangeSFrameKeySuccessDescriptor instead')
const ExchangeSFrameKeySuccess$json = {
  '1': 'ExchangeSFrameKeySuccess',
  '2': [
    {'1': 'distributed', '3': 1, '4': 1, '5': 8, '10': 'distributed'},
    {
      '1': 'participants_count',
      '3': 2,
      '4': 1,
      '5': 5,
      '10': 'participantsCount'
    },
  ],
};

/// Descriptor for `ExchangeSFrameKeySuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exchangeSFrameKeySuccessDescriptor =
    $convert.base64Decode(
        'ChhFeGNoYW5nZVNGcmFtZUtleVN1Y2Nlc3MSIAoLZGlzdHJpYnV0ZWQYASABKAhSC2Rpc3RyaW'
        'J1dGVkEi0KEnBhcnRpY2lwYW50c19jb3VudBgCIAEoBVIRcGFydGljaXBhbnRzQ291bnQ=');

@$core.Deprecated('Use rotateSFrameKeyRequestDescriptor instead')
const RotateSFrameKeyRequest$json = {
  '1': 'RotateSFrameKeyRequest',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'call_id', '3': 2, '4': 1, '5': 9, '10': 'callId'},
    {
      '1': 'key_packages',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.guardyn.calls.ParticipantKeyPackage',
      '10': 'keyPackages'
    },
  ],
};

/// Descriptor for `RotateSFrameKeyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rotateSFrameKeyRequestDescriptor = $convert.base64Decode(
    'ChZSb3RhdGVTRnJhbWVLZXlSZXF1ZXN0EiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG'
    '9rZW4SFwoHY2FsbF9pZBgCIAEoCVIGY2FsbElkEkcKDGtleV9wYWNrYWdlcxgDIAMoCzIkLmd1'
    'YXJkeW4uY2FsbHMuUGFydGljaXBhbnRLZXlQYWNrYWdlUgtrZXlQYWNrYWdlcw==');

@$core.Deprecated('Use rotateSFrameKeyResponseDescriptor instead')
const RotateSFrameKeyResponse$json = {
  '1': 'RotateSFrameKeyResponse',
  '2': [
    {
      '1': 'success',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.calls.RotateSFrameKeySuccess',
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

/// Descriptor for `RotateSFrameKeyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rotateSFrameKeyResponseDescriptor = $convert.base64Decode(
    'ChdSb3RhdGVTRnJhbWVLZXlSZXNwb25zZRJBCgdzdWNjZXNzGAEgASgLMiUuZ3VhcmR5bi5jYW'
    'xscy5Sb3RhdGVTRnJhbWVLZXlTdWNjZXNzSABSB3N1Y2Nlc3MSNQoFZXJyb3IYAiABKAsyHS5n'
    'dWFyZHluLmNvbW1vbi5FcnJvclJlc3BvbnNlSABSBWVycm9yQggKBnJlc3VsdA==');

@$core.Deprecated('Use rotateSFrameKeySuccessDescriptor instead')
const RotateSFrameKeySuccess$json = {
  '1': 'RotateSFrameKeySuccess',
  '2': [
    {'1': 'new_key_id', '3': 1, '4': 1, '5': 13, '10': 'newKeyId'},
    {'1': 'distributed', '3': 2, '4': 1, '5': 8, '10': 'distributed'},
  ],
};

/// Descriptor for `RotateSFrameKeySuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rotateSFrameKeySuccessDescriptor =
    $convert.base64Decode(
        'ChZSb3RhdGVTRnJhbWVLZXlTdWNjZXNzEhwKCm5ld19rZXlfaWQYASABKA1SCG5ld0tleUlkEi'
        'AKC2Rpc3RyaWJ1dGVkGAIgASgIUgtkaXN0cmlidXRlZA==');

@$core.Deprecated('Use healthRequestDescriptor instead')
const HealthRequest$json = {
  '1': 'HealthRequest',
};

/// Descriptor for `HealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthRequestDescriptor =
    $convert.base64Decode('Cg1IZWFsdGhSZXF1ZXN0');
