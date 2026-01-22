// This is a generated file - do not edit.
//
// Generated from media.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'media.pb.dart' as $0;

export 'media.pb.dart';

/// Media Service - handles file uploads, downloads, thumbnails, and encryption
@$pb.GrpcServiceName('guardyn.media.MediaService')
class MediaServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  MediaServiceClient(super.channel, {super.options, super.interceptors});

  /// Upload a media file (images, videos, audio, documents)
  $grpc.ResponseFuture<$0.UploadMediaResponse> uploadMedia(
    $async.Stream<$0.UploadMediaRequest> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$uploadMedia, request, options: options)
        .single;
  }

  /// Download a media file
  $grpc.ResponseStream<$0.DownloadMediaResponse> downloadMedia(
    $0.DownloadMediaRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$downloadMedia, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Get media metadata without downloading the file
  $grpc.ResponseFuture<$0.GetMediaMetadataResponse> getMediaMetadata(
    $0.GetMediaMetadataRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMediaMetadata, request, options: options);
  }

  /// Delete a media file
  $grpc.ResponseFuture<$0.DeleteMediaResponse> deleteMedia(
    $0.DeleteMediaRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteMedia, request, options: options);
  }

  /// Get a pre-signed URL for direct upload (bypassing gRPC for large files)
  $grpc.ResponseFuture<$0.GetUploadUrlResponse> getUploadUrl(
    $0.GetUploadUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getUploadUrl, request, options: options);
  }

  /// Get a pre-signed URL for direct download
  $grpc.ResponseFuture<$0.GetDownloadUrlResponse> getDownloadUrl(
    $0.GetDownloadUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDownloadUrl, request, options: options);
  }

  /// Generate thumbnail for image/video
  $grpc.ResponseFuture<$0.GenerateThumbnailResponse> generateThumbnail(
    $0.GenerateThumbnailRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$generateThumbnail, request, options: options);
  }

  /// List media files for a user or conversation
  $grpc.ResponseFuture<$0.ListMediaResponse> listMedia(
    $0.ListMediaRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listMedia, request, options: options);
  }

  // method descriptors

  static final _$uploadMedia =
      $grpc.ClientMethod<$0.UploadMediaRequest, $0.UploadMediaResponse>(
          '/guardyn.media.MediaService/UploadMedia',
          ($0.UploadMediaRequest value) => value.writeToBuffer(),
          $0.UploadMediaResponse.fromBuffer);
  static final _$downloadMedia =
      $grpc.ClientMethod<$0.DownloadMediaRequest, $0.DownloadMediaResponse>(
          '/guardyn.media.MediaService/DownloadMedia',
          ($0.DownloadMediaRequest value) => value.writeToBuffer(),
          $0.DownloadMediaResponse.fromBuffer);
  static final _$getMediaMetadata = $grpc.ClientMethod<
          $0.GetMediaMetadataRequest, $0.GetMediaMetadataResponse>(
      '/guardyn.media.MediaService/GetMediaMetadata',
      ($0.GetMediaMetadataRequest value) => value.writeToBuffer(),
      $0.GetMediaMetadataResponse.fromBuffer);
  static final _$deleteMedia =
      $grpc.ClientMethod<$0.DeleteMediaRequest, $0.DeleteMediaResponse>(
          '/guardyn.media.MediaService/DeleteMedia',
          ($0.DeleteMediaRequest value) => value.writeToBuffer(),
          $0.DeleteMediaResponse.fromBuffer);
  static final _$getUploadUrl =
      $grpc.ClientMethod<$0.GetUploadUrlRequest, $0.GetUploadUrlResponse>(
          '/guardyn.media.MediaService/GetUploadUrl',
          ($0.GetUploadUrlRequest value) => value.writeToBuffer(),
          $0.GetUploadUrlResponse.fromBuffer);
  static final _$getDownloadUrl =
      $grpc.ClientMethod<$0.GetDownloadUrlRequest, $0.GetDownloadUrlResponse>(
          '/guardyn.media.MediaService/GetDownloadUrl',
          ($0.GetDownloadUrlRequest value) => value.writeToBuffer(),
          $0.GetDownloadUrlResponse.fromBuffer);
  static final _$generateThumbnail = $grpc.ClientMethod<
          $0.GenerateThumbnailRequest, $0.GenerateThumbnailResponse>(
      '/guardyn.media.MediaService/GenerateThumbnail',
      ($0.GenerateThumbnailRequest value) => value.writeToBuffer(),
      $0.GenerateThumbnailResponse.fromBuffer);
  static final _$listMedia =
      $grpc.ClientMethod<$0.ListMediaRequest, $0.ListMediaResponse>(
          '/guardyn.media.MediaService/ListMedia',
          ($0.ListMediaRequest value) => value.writeToBuffer(),
          $0.ListMediaResponse.fromBuffer);
}

@$pb.GrpcServiceName('guardyn.media.MediaService')
abstract class MediaServiceBase extends $grpc.Service {
  $core.String get $name => 'guardyn.media.MediaService';

  MediaServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.UploadMediaRequest, $0.UploadMediaResponse>(
            'UploadMedia',
            uploadMedia,
            true,
            false,
            ($core.List<$core.int> value) =>
                $0.UploadMediaRequest.fromBuffer(value),
            ($0.UploadMediaResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DownloadMediaRequest, $0.DownloadMediaResponse>(
            'DownloadMedia',
            downloadMedia_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.DownloadMediaRequest.fromBuffer(value),
            ($0.DownloadMediaResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetMediaMetadataRequest,
            $0.GetMediaMetadataResponse>(
        'GetMediaMetadata',
        getMediaMetadata_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetMediaMetadataRequest.fromBuffer(value),
        ($0.GetMediaMetadataResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.DeleteMediaRequest, $0.DeleteMediaResponse>(
            'DeleteMedia',
            deleteMedia_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.DeleteMediaRequest.fromBuffer(value),
            ($0.DeleteMediaResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetUploadUrlRequest, $0.GetUploadUrlResponse>(
            'GetUploadUrl',
            getUploadUrl_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetUploadUrlRequest.fromBuffer(value),
            ($0.GetUploadUrlResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetDownloadUrlRequest,
            $0.GetDownloadUrlResponse>(
        'GetDownloadUrl',
        getDownloadUrl_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetDownloadUrlRequest.fromBuffer(value),
        ($0.GetDownloadUrlResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GenerateThumbnailRequest,
            $0.GenerateThumbnailResponse>(
        'GenerateThumbnail',
        generateThumbnail_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GenerateThumbnailRequest.fromBuffer(value),
        ($0.GenerateThumbnailResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListMediaRequest, $0.ListMediaResponse>(
        'ListMedia',
        listMedia_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListMediaRequest.fromBuffer(value),
        ($0.ListMediaResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.UploadMediaResponse> uploadMedia(
      $grpc.ServiceCall call, $async.Stream<$0.UploadMediaRequest> request);

  $async.Stream<$0.DownloadMediaResponse> downloadMedia_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DownloadMediaRequest> $request) async* {
    yield* downloadMedia($call, await $request);
  }

  $async.Stream<$0.DownloadMediaResponse> downloadMedia(
      $grpc.ServiceCall call, $0.DownloadMediaRequest request);

  $async.Future<$0.GetMediaMetadataResponse> getMediaMetadata_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetMediaMetadataRequest> $request) async {
    return getMediaMetadata($call, await $request);
  }

  $async.Future<$0.GetMediaMetadataResponse> getMediaMetadata(
      $grpc.ServiceCall call, $0.GetMediaMetadataRequest request);

  $async.Future<$0.DeleteMediaResponse> deleteMedia_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteMediaRequest> $request) async {
    return deleteMedia($call, await $request);
  }

  $async.Future<$0.DeleteMediaResponse> deleteMedia(
      $grpc.ServiceCall call, $0.DeleteMediaRequest request);

  $async.Future<$0.GetUploadUrlResponse> getUploadUrl_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetUploadUrlRequest> $request) async {
    return getUploadUrl($call, await $request);
  }

  $async.Future<$0.GetUploadUrlResponse> getUploadUrl(
      $grpc.ServiceCall call, $0.GetUploadUrlRequest request);

  $async.Future<$0.GetDownloadUrlResponse> getDownloadUrl_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetDownloadUrlRequest> $request) async {
    return getDownloadUrl($call, await $request);
  }

  $async.Future<$0.GetDownloadUrlResponse> getDownloadUrl(
      $grpc.ServiceCall call, $0.GetDownloadUrlRequest request);

  $async.Future<$0.GenerateThumbnailResponse> generateThumbnail_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GenerateThumbnailRequest> $request) async {
    return generateThumbnail($call, await $request);
  }

  $async.Future<$0.GenerateThumbnailResponse> generateThumbnail(
      $grpc.ServiceCall call, $0.GenerateThumbnailRequest request);

  $async.Future<$0.ListMediaResponse> listMedia_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListMediaRequest> $request) async {
    return listMedia($call, await $request);
  }

  $async.Future<$0.ListMediaResponse> listMedia(
      $grpc.ServiceCall call, $0.ListMediaRequest request);
}
