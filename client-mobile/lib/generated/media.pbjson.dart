// This is a generated file - do not edit.
//
// Generated from media.proto.

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

@$core.Deprecated('Use mediaTypeDescriptor instead')
const MediaType$json = {
  '1': 'MediaType',
  '2': [
    {'1': 'MEDIA_TYPE_UNKNOWN', '2': 0},
    {'1': 'MEDIA_TYPE_IMAGE', '2': 1},
    {'1': 'MEDIA_TYPE_VIDEO', '2': 2},
    {'1': 'MEDIA_TYPE_AUDIO', '2': 3},
    {'1': 'MEDIA_TYPE_DOCUMENT', '2': 4},
    {'1': 'MEDIA_TYPE_OTHER', '2': 5},
  ],
};

/// Descriptor for `MediaType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List mediaTypeDescriptor = $convert.base64Decode(
    'CglNZWRpYVR5cGUSFgoSTUVESUFfVFlQRV9VTktOT1dOEAASFAoQTUVESUFfVFlQRV9JTUFHRR'
    'ABEhQKEE1FRElBX1RZUEVfVklERU8QAhIUChBNRURJQV9UWVBFX0FVRElPEAMSFwoTTUVESUFf'
    'VFlQRV9ET0NVTUVOVBAEEhQKEE1FRElBX1RZUEVfT1RIRVIQBQ==');

@$core.Deprecated('Use uploadStatusDescriptor instead')
const UploadStatus$json = {
  '1': 'UploadStatus',
  '2': [
    {'1': 'UPLOAD_STATUS_UNKNOWN', '2': 0},
    {'1': 'UPLOAD_STATUS_PENDING', '2': 1},
    {'1': 'UPLOAD_STATUS_PROCESSING', '2': 2},
    {'1': 'UPLOAD_STATUS_COMPLETED', '2': 3},
    {'1': 'UPLOAD_STATUS_FAILED', '2': 4},
  ],
};

/// Descriptor for `UploadStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List uploadStatusDescriptor = $convert.base64Decode(
    'CgxVcGxvYWRTdGF0dXMSGQoVVVBMT0FEX1NUQVRVU19VTktOT1dOEAASGQoVVVBMT0FEX1NUQV'
    'RVU19QRU5ESU5HEAESHAoYVVBMT0FEX1NUQVRVU19QUk9DRVNTSU5HEAISGwoXVVBMT0FEX1NU'
    'QVRVU19DT01QTEVURUQQAxIYChRVUExPQURfU1RBVFVTX0ZBSUxFRBAE');

@$core.Deprecated('Use mediaMetadataDescriptor instead')
const MediaMetadata$json = {
  '1': 'MediaMetadata',
  '2': [
    {'1': 'media_id', '3': 1, '4': 1, '5': 9, '10': 'mediaId'},
    {'1': 'owner_user_id', '3': 2, '4': 1, '5': 9, '10': 'ownerUserId'},
    {'1': 'filename', '3': 3, '4': 1, '5': 9, '10': 'filename'},
    {
      '1': 'media_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.guardyn.media.MediaType',
      '10': 'mediaType'
    },
    {'1': 'mime_type', '3': 5, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'size_bytes', '3': 6, '4': 1, '5': 3, '10': 'sizeBytes'},
    {'1': 'checksum_sha256', '3': 7, '4': 1, '5': 9, '10': 'checksumSha256'},
    {'1': 'created_at', '3': 8, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'updated_at', '3': 9, '4': 1, '5': 3, '10': 'updatedAt'},
    {
      '1': 'status',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.guardyn.media.UploadStatus',
      '10': 'status'
    },
    {'1': 'width', '3': 11, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 12, '4': 1, '5': 5, '10': 'height'},
    {'1': 'duration_ms', '3': 13, '4': 1, '5': 5, '10': 'durationMs'},
    {'1': 'thumbnail_id', '3': 14, '4': 1, '5': 9, '10': 'thumbnailId'},
    {'1': 'is_encrypted', '3': 15, '4': 1, '5': 8, '10': 'isEncrypted'},
    {
      '1': 'encryption_key_id',
      '3': 16,
      '4': 1,
      '5': 12,
      '10': 'encryptionKeyId'
    },
    {'1': 'iv', '3': 17, '4': 1, '5': 12, '10': 'iv'},
    {'1': 'conversation_id', '3': 18, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'message_id', '3': 19, '4': 1, '5': 9, '10': 'messageId'},
    {'1': 'storage_path', '3': 20, '4': 1, '5': 9, '10': 'storagePath'},
  ],
};

/// Descriptor for `MediaMetadata`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mediaMetadataDescriptor = $convert.base64Decode(
    'Cg1NZWRpYU1ldGFkYXRhEhkKCG1lZGlhX2lkGAEgASgJUgdtZWRpYUlkEiIKDW93bmVyX3VzZX'
    'JfaWQYAiABKAlSC293bmVyVXNlcklkEhoKCGZpbGVuYW1lGAMgASgJUghmaWxlbmFtZRI3Cgpt'
    'ZWRpYV90eXBlGAQgASgOMhguZ3VhcmR5bi5tZWRpYS5NZWRpYVR5cGVSCW1lZGlhVHlwZRIbCg'
    'ltaW1lX3R5cGUYBSABKAlSCG1pbWVUeXBlEh0KCnNpemVfYnl0ZXMYBiABKANSCXNpemVCeXRl'
    'cxInCg9jaGVja3N1bV9zaGEyNTYYByABKAlSDmNoZWNrc3VtU2hhMjU2Eh0KCmNyZWF0ZWRfYX'
    'QYCCABKANSCWNyZWF0ZWRBdBIdCgp1cGRhdGVkX2F0GAkgASgDUgl1cGRhdGVkQXQSMwoGc3Rh'
    'dHVzGAogASgOMhsuZ3VhcmR5bi5tZWRpYS5VcGxvYWRTdGF0dXNSBnN0YXR1cxIUCgV3aWR0aB'
    'gLIAEoBVIFd2lkdGgSFgoGaGVpZ2h0GAwgASgFUgZoZWlnaHQSHwoLZHVyYXRpb25fbXMYDSAB'
    'KAVSCmR1cmF0aW9uTXMSIQoMdGh1bWJuYWlsX2lkGA4gASgJUgt0aHVtYm5haWxJZBIhCgxpc1'
    '9lbmNyeXB0ZWQYDyABKAhSC2lzRW5jcnlwdGVkEioKEWVuY3J5cHRpb25fa2V5X2lkGBAgASgM'
    'Ug9lbmNyeXB0aW9uS2V5SWQSDgoCaXYYESABKAxSAml2EicKD2NvbnZlcnNhdGlvbl9pZBgSIA'
    'EoCVIOY29udmVyc2F0aW9uSWQSHQoKbWVzc2FnZV9pZBgTIAEoCVIJbWVzc2FnZUlkEiEKDHN0'
    'b3JhZ2VfcGF0aBgUIAEoCVILc3RvcmFnZVBhdGg=');

@$core.Deprecated('Use uploadMediaRequestDescriptor instead')
const UploadMediaRequest$json = {
  '1': 'UploadMediaRequest',
  '2': [
    {
      '1': 'header',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.media.UploadMediaHeader',
      '9': 0,
      '10': 'header'
    },
    {'1': 'chunk', '3': 2, '4': 1, '5': 12, '9': 0, '10': 'chunk'},
  ],
  '8': [
    {'1': 'content'},
  ],
};

/// Descriptor for `UploadMediaRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadMediaRequestDescriptor = $convert.base64Decode(
    'ChJVcGxvYWRNZWRpYVJlcXVlc3QSOgoGaGVhZGVyGAEgASgLMiAuZ3VhcmR5bi5tZWRpYS5VcG'
    'xvYWRNZWRpYUhlYWRlckgAUgZoZWFkZXISFgoFY2h1bmsYAiABKAxIAFIFY2h1bmtCCQoHY29u'
    'dGVudA==');

@$core.Deprecated('Use uploadMediaHeaderDescriptor instead')
const UploadMediaHeader$json = {
  '1': 'UploadMediaHeader',
  '2': [
    {'1': 'filename', '3': 1, '4': 1, '5': 9, '10': 'filename'},
    {
      '1': 'media_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.media.MediaType',
      '10': 'mediaType'
    },
    {'1': 'mime_type', '3': 3, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'size_bytes', '3': 4, '4': 1, '5': 3, '10': 'sizeBytes'},
    {'1': 'checksum_sha256', '3': 5, '4': 1, '5': 9, '10': 'checksumSha256'},
    {'1': 'is_encrypted', '3': 6, '4': 1, '5': 8, '10': 'isEncrypted'},
    {
      '1': 'encryption_key_id',
      '3': 7,
      '4': 1,
      '5': 12,
      '10': 'encryptionKeyId'
    },
    {'1': 'iv', '3': 8, '4': 1, '5': 12, '10': 'iv'},
    {'1': 'conversation_id', '3': 9, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'message_id', '3': 10, '4': 1, '5': 9, '10': 'messageId'},
  ],
};

/// Descriptor for `UploadMediaHeader`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadMediaHeaderDescriptor = $convert.base64Decode(
    'ChFVcGxvYWRNZWRpYUhlYWRlchIaCghmaWxlbmFtZRgBIAEoCVIIZmlsZW5hbWUSNwoKbWVkaW'
    'FfdHlwZRgCIAEoDjIYLmd1YXJkeW4ubWVkaWEuTWVkaWFUeXBlUgltZWRpYVR5cGUSGwoJbWlt'
    'ZV90eXBlGAMgASgJUghtaW1lVHlwZRIdCgpzaXplX2J5dGVzGAQgASgDUglzaXplQnl0ZXMSJw'
    'oPY2hlY2tzdW1fc2hhMjU2GAUgASgJUg5jaGVja3N1bVNoYTI1NhIhCgxpc19lbmNyeXB0ZWQY'
    'BiABKAhSC2lzRW5jcnlwdGVkEioKEWVuY3J5cHRpb25fa2V5X2lkGAcgASgMUg9lbmNyeXB0aW'
    '9uS2V5SWQSDgoCaXYYCCABKAxSAml2EicKD2NvbnZlcnNhdGlvbl9pZBgJIAEoCVIOY29udmVy'
    'c2F0aW9uSWQSHQoKbWVzc2FnZV9pZBgKIAEoCVIJbWVzc2FnZUlk');

@$core.Deprecated('Use uploadMediaResponseDescriptor instead')
const UploadMediaResponse$json = {
  '1': 'UploadMediaResponse',
  '2': [
    {'1': 'media_id', '3': 1, '4': 1, '5': 9, '10': 'mediaId'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.guardyn.media.UploadStatus',
      '10': 'status'
    },
    {
      '1': 'metadata',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.media.MediaMetadata',
      '10': 'metadata'
    },
    {'1': 'error_message', '3': 4, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `UploadMediaResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadMediaResponseDescriptor = $convert.base64Decode(
    'ChNVcGxvYWRNZWRpYVJlc3BvbnNlEhkKCG1lZGlhX2lkGAEgASgJUgdtZWRpYUlkEjMKBnN0YX'
    'R1cxgCIAEoDjIbLmd1YXJkeW4ubWVkaWEuVXBsb2FkU3RhdHVzUgZzdGF0dXMSOAoIbWV0YWRh'
    'dGEYAyABKAsyHC5ndWFyZHluLm1lZGlhLk1lZGlhTWV0YWRhdGFSCG1ldGFkYXRhEiMKDWVycm'
    '9yX21lc3NhZ2UYBCABKAlSDGVycm9yTWVzc2FnZQ==');

@$core.Deprecated('Use downloadMediaRequestDescriptor instead')
const DownloadMediaRequest$json = {
  '1': 'DownloadMediaRequest',
  '2': [
    {'1': 'media_id', '3': 1, '4': 1, '5': 9, '10': 'mediaId'},
    {'1': 'offset', '3': 2, '4': 1, '5': 3, '10': 'offset'},
    {'1': 'length', '3': 3, '4': 1, '5': 3, '10': 'length'},
  ],
};

/// Descriptor for `DownloadMediaRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadMediaRequestDescriptor = $convert.base64Decode(
    'ChREb3dubG9hZE1lZGlhUmVxdWVzdBIZCghtZWRpYV9pZBgBIAEoCVIHbWVkaWFJZBIWCgZvZm'
    'ZzZXQYAiABKANSBm9mZnNldBIWCgZsZW5ndGgYAyABKANSBmxlbmd0aA==');

@$core.Deprecated('Use downloadMediaResponseDescriptor instead')
const DownloadMediaResponse$json = {
  '1': 'DownloadMediaResponse',
  '2': [
    {
      '1': 'metadata',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.media.MediaMetadata',
      '9': 0,
      '10': 'metadata'
    },
    {'1': 'chunk', '3': 2, '4': 1, '5': 12, '9': 0, '10': 'chunk'},
  ],
  '8': [
    {'1': 'content'},
  ],
};

/// Descriptor for `DownloadMediaResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadMediaResponseDescriptor = $convert.base64Decode(
    'ChVEb3dubG9hZE1lZGlhUmVzcG9uc2USOgoIbWV0YWRhdGEYASABKAsyHC5ndWFyZHluLm1lZG'
    'lhLk1lZGlhTWV0YWRhdGFIAFIIbWV0YWRhdGESFgoFY2h1bmsYAiABKAxIAFIFY2h1bmtCCQoH'
    'Y29udGVudA==');

@$core.Deprecated('Use getMediaMetadataRequestDescriptor instead')
const GetMediaMetadataRequest$json = {
  '1': 'GetMediaMetadataRequest',
  '2': [
    {'1': 'media_id', '3': 1, '4': 1, '5': 9, '10': 'mediaId'},
  ],
};

/// Descriptor for `GetMediaMetadataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMediaMetadataRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRNZWRpYU1ldGFkYXRhUmVxdWVzdBIZCghtZWRpYV9pZBgBIAEoCVIHbWVkaWFJZA==');

@$core.Deprecated('Use getMediaMetadataResponseDescriptor instead')
const GetMediaMetadataResponse$json = {
  '1': 'GetMediaMetadataResponse',
  '2': [
    {
      '1': 'metadata',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.guardyn.media.MediaMetadata',
      '10': 'metadata'
    },
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '10': 'error'
    },
  ],
};

/// Descriptor for `GetMediaMetadataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMediaMetadataResponseDescriptor = $convert.base64Decode(
    'ChhHZXRNZWRpYU1ldGFkYXRhUmVzcG9uc2USOAoIbWV0YWRhdGEYASABKAsyHC5ndWFyZHluLm'
    '1lZGlhLk1lZGlhTWV0YWRhdGFSCG1ldGFkYXRhEjMKBWVycm9yGAIgASgLMh0uZ3VhcmR5bi5j'
    'b21tb24uRXJyb3JSZXNwb25zZVIFZXJyb3I=');

@$core.Deprecated('Use deleteMediaRequestDescriptor instead')
const DeleteMediaRequest$json = {
  '1': 'DeleteMediaRequest',
  '2': [
    {'1': 'media_id', '3': 1, '4': 1, '5': 9, '10': 'mediaId'},
  ],
};

/// Descriptor for `DeleteMediaRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteMediaRequestDescriptor =
    $convert.base64Decode(
        'ChJEZWxldGVNZWRpYVJlcXVlc3QSGQoIbWVkaWFfaWQYASABKAlSB21lZGlhSWQ=');

@$core.Deprecated('Use deleteMediaResponseDescriptor instead')
const DeleteMediaResponse$json = {
  '1': 'DeleteMediaResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {
      '1': 'error',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '10': 'error'
    },
  ],
};

/// Descriptor for `DeleteMediaResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteMediaResponseDescriptor = $convert.base64Decode(
    'ChNEZWxldGVNZWRpYVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSMwoFZXJyb3'
    'IYAiABKAsyHS5ndWFyZHluLmNvbW1vbi5FcnJvclJlc3BvbnNlUgVlcnJvcg==');

@$core.Deprecated('Use getUploadUrlRequestDescriptor instead')
const GetUploadUrlRequest$json = {
  '1': 'GetUploadUrlRequest',
  '2': [
    {'1': 'filename', '3': 1, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'mime_type', '3': 2, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'size_bytes', '3': 3, '4': 1, '5': 3, '10': 'sizeBytes'},
    {'1': 'conversation_id', '3': 4, '4': 1, '5': 9, '10': 'conversationId'},
  ],
};

/// Descriptor for `GetUploadUrlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUploadUrlRequestDescriptor = $convert.base64Decode(
    'ChNHZXRVcGxvYWRVcmxSZXF1ZXN0EhoKCGZpbGVuYW1lGAEgASgJUghmaWxlbmFtZRIbCgltaW'
    '1lX3R5cGUYAiABKAlSCG1pbWVUeXBlEh0KCnNpemVfYnl0ZXMYAyABKANSCXNpemVCeXRlcxIn'
    'Cg9jb252ZXJzYXRpb25faWQYBCABKAlSDmNvbnZlcnNhdGlvbklk');

@$core.Deprecated('Use getUploadUrlResponseDescriptor instead')
const GetUploadUrlResponse$json = {
  '1': 'GetUploadUrlResponse',
  '2': [
    {'1': 'upload_url', '3': 1, '4': 1, '5': 9, '10': 'uploadUrl'},
    {'1': 'media_id', '3': 2, '4': 1, '5': 9, '10': 'mediaId'},
    {'1': 'expires_at', '3': 3, '4': 1, '5': 3, '10': 'expiresAt'},
    {
      '1': 'headers',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.guardyn.media.GetUploadUrlResponse.HeadersEntry',
      '10': 'headers'
    },
    {
      '1': 'error',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '10': 'error'
    },
  ],
  '3': [GetUploadUrlResponse_HeadersEntry$json],
};

@$core.Deprecated('Use getUploadUrlResponseDescriptor instead')
const GetUploadUrlResponse_HeadersEntry$json = {
  '1': 'HeadersEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `GetUploadUrlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUploadUrlResponseDescriptor = $convert.base64Decode(
    'ChRHZXRVcGxvYWRVcmxSZXNwb25zZRIdCgp1cGxvYWRfdXJsGAEgASgJUgl1cGxvYWRVcmwSGQ'
    'oIbWVkaWFfaWQYAiABKAlSB21lZGlhSWQSHQoKZXhwaXJlc19hdBgDIAEoA1IJZXhwaXJlc0F0'
    'EkoKB2hlYWRlcnMYBCADKAsyMC5ndWFyZHluLm1lZGlhLkdldFVwbG9hZFVybFJlc3BvbnNlLk'
    'hlYWRlcnNFbnRyeVIHaGVhZGVycxIzCgVlcnJvchgFIAEoCzIdLmd1YXJkeW4uY29tbW9uLkVy'
    'cm9yUmVzcG9uc2VSBWVycm9yGjoKDEhlYWRlcnNFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCg'
    'V2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use getDownloadUrlRequestDescriptor instead')
const GetDownloadUrlRequest$json = {
  '1': 'GetDownloadUrlRequest',
  '2': [
    {'1': 'media_id', '3': 1, '4': 1, '5': 9, '10': 'mediaId'},
  ],
};

/// Descriptor for `GetDownloadUrlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDownloadUrlRequestDescriptor =
    $convert.base64Decode(
        'ChVHZXREb3dubG9hZFVybFJlcXVlc3QSGQoIbWVkaWFfaWQYASABKAlSB21lZGlhSWQ=');

@$core.Deprecated('Use getDownloadUrlResponseDescriptor instead')
const GetDownloadUrlResponse$json = {
  '1': 'GetDownloadUrlResponse',
  '2': [
    {'1': 'download_url', '3': 1, '4': 1, '5': 9, '10': 'downloadUrl'},
    {'1': 'expires_at', '3': 2, '4': 1, '5': 3, '10': 'expiresAt'},
    {
      '1': 'metadata',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.media.MediaMetadata',
      '10': 'metadata'
    },
    {
      '1': 'error',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '10': 'error'
    },
  ],
};

/// Descriptor for `GetDownloadUrlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDownloadUrlResponseDescriptor = $convert.base64Decode(
    'ChZHZXREb3dubG9hZFVybFJlc3BvbnNlEiEKDGRvd25sb2FkX3VybBgBIAEoCVILZG93bmxvYW'
    'RVcmwSHQoKZXhwaXJlc19hdBgCIAEoA1IJZXhwaXJlc0F0EjgKCG1ldGFkYXRhGAMgASgLMhwu'
    'Z3VhcmR5bi5tZWRpYS5NZWRpYU1ldGFkYXRhUghtZXRhZGF0YRIzCgVlcnJvchgEIAEoCzIdLm'
    'd1YXJkeW4uY29tbW9uLkVycm9yUmVzcG9uc2VSBWVycm9y');

@$core.Deprecated('Use generateThumbnailRequestDescriptor instead')
const GenerateThumbnailRequest$json = {
  '1': 'GenerateThumbnailRequest',
  '2': [
    {'1': 'media_id', '3': 1, '4': 1, '5': 9, '10': 'mediaId'},
    {'1': 'max_width', '3': 2, '4': 1, '5': 5, '10': 'maxWidth'},
    {'1': 'max_height', '3': 3, '4': 1, '5': 5, '10': 'maxHeight'},
    {'1': 'format', '3': 4, '4': 1, '5': 9, '10': 'format'},
    {'1': 'quality', '3': 5, '4': 1, '5': 5, '10': 'quality'},
  ],
};

/// Descriptor for `GenerateThumbnailRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateThumbnailRequestDescriptor = $convert.base64Decode(
    'ChhHZW5lcmF0ZVRodW1ibmFpbFJlcXVlc3QSGQoIbWVkaWFfaWQYASABKAlSB21lZGlhSWQSGw'
    'oJbWF4X3dpZHRoGAIgASgFUghtYXhXaWR0aBIdCgptYXhfaGVpZ2h0GAMgASgFUgltYXhIZWln'
    'aHQSFgoGZm9ybWF0GAQgASgJUgZmb3JtYXQSGAoHcXVhbGl0eRgFIAEoBVIHcXVhbGl0eQ==');

@$core.Deprecated('Use generateThumbnailResponseDescriptor instead')
const GenerateThumbnailResponse$json = {
  '1': 'GenerateThumbnailResponse',
  '2': [
    {'1': 'thumbnail_id', '3': 1, '4': 1, '5': 9, '10': 'thumbnailId'},
    {
      '1': 'metadata',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.guardyn.media.MediaMetadata',
      '10': 'metadata'
    },
    {
      '1': 'error',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '10': 'error'
    },
  ],
};

/// Descriptor for `GenerateThumbnailResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateThumbnailResponseDescriptor = $convert.base64Decode(
    'ChlHZW5lcmF0ZVRodW1ibmFpbFJlc3BvbnNlEiEKDHRodW1ibmFpbF9pZBgBIAEoCVILdGh1bW'
    'JuYWlsSWQSOAoIbWV0YWRhdGEYAiABKAsyHC5ndWFyZHluLm1lZGlhLk1lZGlhTWV0YWRhdGFS'
    'CG1ldGFkYXRhEjMKBWVycm9yGAMgASgLMh0uZ3VhcmR5bi5jb21tb24uRXJyb3JSZXNwb25zZV'
    'IFZXJyb3I=');

@$core.Deprecated('Use listMediaRequestDescriptor instead')
const ListMediaRequest$json = {
  '1': 'ListMediaRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'media_types',
      '3': 3,
      '4': 3,
      '5': 14,
      '6': '.guardyn.media.MediaType',
      '10': 'mediaTypes'
    },
    {'1': 'limit', '3': 4, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'cursor', '3': 5, '4': 1, '5': 9, '10': 'cursor'},
    {'1': 'sort_by', '3': 6, '4': 1, '5': 9, '10': 'sortBy'},
    {'1': 'ascending', '3': 7, '4': 1, '5': 8, '10': 'ascending'},
  ],
};

/// Descriptor for `ListMediaRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMediaRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0TWVkaWFSZXF1ZXN0EhcKB3VzZXJfaWQYASABKAlSBnVzZXJJZBInCg9jb252ZXJzYX'
    'Rpb25faWQYAiABKAlSDmNvbnZlcnNhdGlvbklkEjkKC21lZGlhX3R5cGVzGAMgAygOMhguZ3Vh'
    'cmR5bi5tZWRpYS5NZWRpYVR5cGVSCm1lZGlhVHlwZXMSFAoFbGltaXQYBCABKAVSBWxpbWl0Eh'
    'YKBmN1cnNvchgFIAEoCVIGY3Vyc29yEhcKB3NvcnRfYnkYBiABKAlSBnNvcnRCeRIcCglhc2Nl'
    'bmRpbmcYByABKAhSCWFzY2VuZGluZw==');

@$core.Deprecated('Use listMediaResponseDescriptor instead')
const ListMediaResponse$json = {
  '1': 'ListMediaResponse',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.guardyn.media.MediaMetadata',
      '10': 'items'
    },
    {'1': 'next_cursor', '3': 2, '4': 1, '5': 9, '10': 'nextCursor'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
    {
      '1': 'error',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.guardyn.common.ErrorResponse',
      '10': 'error'
    },
  ],
};

/// Descriptor for `ListMediaResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMediaResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0TWVkaWFSZXNwb25zZRIyCgVpdGVtcxgBIAMoCzIcLmd1YXJkeW4ubWVkaWEuTWVkaW'
    'FNZXRhZGF0YVIFaXRlbXMSHwoLbmV4dF9jdXJzb3IYAiABKAlSCm5leHRDdXJzb3ISHwoLdG90'
    'YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQSMwoFZXJyb3IYBCABKAsyHS5ndWFyZHluLmNvbW'
    '1vbi5FcnJvclJlc3BvbnNlUgVlcnJvcg==');
