// This is a generated file - do not edit.
//
// Generated from common.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use timestampDescriptor instead')
const Timestamp$json = {
  '1': 'Timestamp',
  '2': [
    {'1': 'seconds', '3': 1, '4': 1, '5': 3, '10': 'seconds'},
    {'1': 'nanos', '3': 2, '4': 1, '5': 5, '10': 'nanos'},
  ],
};

/// Descriptor for `Timestamp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timestampDescriptor = $convert.base64Decode(
    'CglUaW1lc3RhbXASGAoHc2Vjb25kcxgBIAEoA1IHc2Vjb25kcxIUCgVuYW5vcxgCIAEoBVIFbm'
    'Fub3M=');

@$core.Deprecated('Use userIdDescriptor instead')
const UserId$json = {
  '1': 'UserId',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `UserId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userIdDescriptor =
    $convert.base64Decode('CgZVc2VySWQSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use deviceIdDescriptor instead')
const DeviceId$json = {
  '1': 'DeviceId',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `DeviceId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceIdDescriptor = $convert.base64Decode(
    'CghEZXZpY2VJZBIXCgd1c2VyX2lkGAEgASgJUgZ1c2VySWQSGwoJZGV2aWNlX2lkGAIgASgJUg'
    'hkZXZpY2VJZA==');

@$core.Deprecated('Use keyBundleDescriptor instead')
const KeyBundle$json = {
  '1': 'KeyBundle',
  '2': [
    {'1': 'identity_key', '3': 1, '4': 1, '5': 12, '10': 'identityKey'},
    {'1': 'signed_pre_key', '3': 2, '4': 1, '5': 12, '10': 'signedPreKey'},
    {
      '1': 'signed_pre_key_signature',
      '3': 3,
      '4': 1,
      '5': 12,
      '10': 'signedPreKeySignature'
    },
    {'1': 'one_time_pre_keys', '3': 4, '4': 3, '5': 12, '10': 'oneTimePreKeys'},
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

/// Descriptor for `KeyBundle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List keyBundleDescriptor = $convert.base64Decode(
    'CglLZXlCdW5kbGUSIQoMaWRlbnRpdHlfa2V5GAEgASgMUgtpZGVudGl0eUtleRIkCg5zaWduZW'
    'RfcHJlX2tleRgCIAEoDFIMc2lnbmVkUHJlS2V5EjcKGHNpZ25lZF9wcmVfa2V5X3NpZ25hdHVy'
    'ZRgDIAEoDFIVc2lnbmVkUHJlS2V5U2lnbmF0dXJlEikKEW9uZV90aW1lX3ByZV9rZXlzGAQgAy'
    'gMUg5vbmVUaW1lUHJlS2V5cxI4CgpjcmVhdGVkX2F0GAUgASgLMhkuZ3VhcmR5bi5jb21tb24u'
    'VGltZXN0YW1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use errorResponseDescriptor instead')
const ErrorResponse$json = {
  '1': 'ErrorResponse',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.guardyn.common.ErrorResponse.ErrorCode',
      '10': 'code'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'details',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse.DetailsEntry',
      '10': 'details'
    },
  ],
  '3': [ErrorResponse_DetailsEntry$json],
  '4': [ErrorResponse_ErrorCode$json],
};

@$core.Deprecated('Use errorResponseDescriptor instead')
const ErrorResponse_DetailsEntry$json = {
  '1': 'DetailsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use errorResponseDescriptor instead')
const ErrorResponse_ErrorCode$json = {
  '1': 'ErrorCode',
  '2': [
    {'1': 'UNKNOWN', '2': 0},
    {'1': 'INVALID_REQUEST', '2': 1},
    {'1': 'UNAUTHORIZED', '2': 2},
    {'1': 'FORBIDDEN', '2': 3},
    {'1': 'NOT_FOUND', '2': 4},
    {'1': 'CONFLICT', '2': 5},
    {'1': 'INTERNAL_ERROR', '2': 6},
    {'1': 'SERVICE_UNAVAILABLE', '2': 7},
    {'1': 'RATE_LIMITED', '2': 8},
  ],
};

/// Descriptor for `ErrorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errorResponseDescriptor = $convert.base64Decode(
    'Cg1FcnJvclJlc3BvbnNlEjsKBGNvZGUYASABKA4yJy5ndWFyZHluLmNvbW1vbi5FcnJvclJlc3'
    'BvbnNlLkVycm9yQ29kZVIEY29kZRIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlEkQKB2RldGFp'
    'bHMYAyADKAsyKi5ndWFyZHluLmNvbW1vbi5FcnJvclJlc3BvbnNlLkRldGFpbHNFbnRyeVIHZG'
    'V0YWlscxo6CgxEZXRhaWxzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlS'
    'BXZhbHVlOgI4ASKqAQoJRXJyb3JDb2RlEgsKB1VOS05PV04QABITCg9JTlZBTElEX1JFUVVFU1'
    'QQARIQCgxVTkFVVEhPUklaRUQQAhINCglGT1JCSURERU4QAxINCglOT1RfRk9VTkQQBBIMCghD'
    'T05GTElDVBAFEhIKDklOVEVSTkFMX0VSUk9SEAYSFwoTU0VSVklDRV9VTkFWQUlMQUJMRRAHEh'
    'AKDFJBVEVfTElNSVRFRBAI');

@$core.Deprecated('Use paginationRequestDescriptor instead')
const PaginationRequest$json = {
  '1': 'PaginationRequest',
  '2': [
    {'1': 'page', '3': 1, '4': 1, '5': 13, '10': 'page'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 13, '10': 'pageSize'},
  ],
};

/// Descriptor for `PaginationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paginationRequestDescriptor = $convert.base64Decode(
    'ChFQYWdpbmF0aW9uUmVxdWVzdBISCgRwYWdlGAEgASgNUgRwYWdlEhsKCXBhZ2Vfc2l6ZRgCIA'
    'EoDVIIcGFnZVNpemU=');

@$core.Deprecated('Use paginationResponseDescriptor instead')
const PaginationResponse$json = {
  '1': 'PaginationResponse',
  '2': [
    {'1': 'total_items', '3': 1, '4': 1, '5': 13, '10': 'totalItems'},
    {'1': 'total_pages', '3': 2, '4': 1, '5': 13, '10': 'totalPages'},
    {'1': 'current_page', '3': 3, '4': 1, '5': 13, '10': 'currentPage'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 13, '10': 'pageSize'},
  ],
};

/// Descriptor for `PaginationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List paginationResponseDescriptor = $convert.base64Decode(
    'ChJQYWdpbmF0aW9uUmVzcG9uc2USHwoLdG90YWxfaXRlbXMYASABKA1SCnRvdGFsSXRlbXMSHw'
    'oLdG90YWxfcGFnZXMYAiABKA1SCnRvdGFsUGFnZXMSIQoMY3VycmVudF9wYWdlGAMgASgNUgtj'
    'dXJyZW50UGFnZRIbCglwYWdlX3NpemUYBCABKA1SCHBhZ2VTaXpl');

@$core.Deprecated('Use healthStatusDescriptor instead')
const HealthStatus$json = {
  '1': 'HealthStatus',
  '2': [
    {
      '1': 'status',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.guardyn.common.HealthStatus.Status',
      '10': 'status'
    },
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
    {
      '1': 'timestamp',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'components',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.guardyn.common.HealthStatus.ComponentsEntry',
      '10': 'components'
    },
  ],
  '3': [HealthStatus_ComponentsEntry$json],
  '4': [HealthStatus_Status$json],
};

@$core.Deprecated('Use healthStatusDescriptor instead')
const HealthStatus_ComponentsEntry$json = {
  '1': 'ComponentsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

@$core.Deprecated('Use healthStatusDescriptor instead')
const HealthStatus_Status$json = {
  '1': 'Status',
  '2': [
    {'1': 'UNKNOWN', '2': 0},
    {'1': 'HEALTHY', '2': 1},
    {'1': 'DEGRADED', '2': 2},
    {'1': 'UNHEALTHY', '2': 3},
  ],
};

/// Descriptor for `HealthStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthStatusDescriptor = $convert.base64Decode(
    'CgxIZWFsdGhTdGF0dXMSOwoGc3RhdHVzGAEgASgOMiMuZ3VhcmR5bi5jb21tb24uSGVhbHRoU3'
    'RhdHVzLlN0YXR1c1IGc3RhdHVzEhgKB3ZlcnNpb24YAiABKAlSB3ZlcnNpb24SNwoJdGltZXN0'
    'YW1wGAMgASgLMhkuZ3VhcmR5bi5jb21tb24uVGltZXN0YW1wUgl0aW1lc3RhbXASTAoKY29tcG'
    '9uZW50cxgEIAMoCzIsLmd1YXJkeW4uY29tbW9uLkhlYWx0aFN0YXR1cy5Db21wb25lbnRzRW50'
    'cnlSCmNvbXBvbmVudHMaPQoPQ29tcG9uZW50c0VudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBX'
    'ZhbHVlGAIgASgJUgV2YWx1ZToCOAEiPwoGU3RhdHVzEgsKB1VOS05PV04QABILCgdIRUFMVEhZ'
    'EAESDAoIREVHUkFERUQQAhINCglVTkhFQUxUSFkQAw==');
