//! Media Service gRPC Client
//!
//! Handles media uploads, downloads, thumbnails, and metadata operations.

use crate::grpc::{GrpcClient, GrpcError};
use crate::proto::media::{
    media_service_client::MediaServiceClient, DeleteMediaRequest, GenerateThumbnailRequest,
    GetDownloadUrlRequest, GetMediaMetadataRequest, GetUploadUrlRequest, ListMediaRequest,
    MediaType as ProtoMediaType,
};
use std::sync::Arc;
use tonic::metadata::MetadataValue;
use tonic::transport::Channel;
use tonic::Request;
use tracing::{debug, info, warn};

/// Media type enumeration
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MediaType {
    Unknown,
    Image,
    Video,
    Audio,
    Document,
    Other,
}

impl From<ProtoMediaType> for MediaType {
    fn from(proto: ProtoMediaType) -> Self {
        match proto {
            ProtoMediaType::Unknown => MediaType::Unknown,
            ProtoMediaType::Image => MediaType::Image,
            ProtoMediaType::Video => MediaType::Video,
            ProtoMediaType::Audio => MediaType::Audio,
            ProtoMediaType::Document => MediaType::Document,
            ProtoMediaType::Other => MediaType::Other,
        }
    }
}

impl From<MediaType> for ProtoMediaType {
    fn from(media_type: MediaType) -> Self {
        match media_type {
            MediaType::Unknown => ProtoMediaType::Unknown,
            MediaType::Image => ProtoMediaType::Image,
            MediaType::Video => ProtoMediaType::Video,
            MediaType::Audio => ProtoMediaType::Audio,
            MediaType::Document => ProtoMediaType::Document,
            MediaType::Other => ProtoMediaType::Other,
        }
    }
}

impl From<i32> for MediaType {
    fn from(value: i32) -> Self {
        match ProtoMediaType::try_from(value) {
            Ok(proto) => proto.into(),
            Err(_) => MediaType::Unknown,
        }
    }
}

/// Upload status enumeration
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UploadStatus {
    Unknown,
    Pending,
    Processing,
    Completed,
    Failed,
}

impl From<i32> for UploadStatus {
    fn from(value: i32) -> Self {
        match value {
            1 => UploadStatus::Pending,
            2 => UploadStatus::Processing,
            3 => UploadStatus::Completed,
            4 => UploadStatus::Failed,
            _ => UploadStatus::Unknown,
        }
    }
}

/// Media metadata
#[derive(Debug, Clone)]
pub struct MediaMetadata {
    pub media_id: String,
    pub owner_user_id: String,
    pub filename: String,
    pub media_type: MediaType,
    pub mime_type: String,
    pub size_bytes: i64,
    pub checksum_sha256: String,
    pub created_at: i64,
    pub updated_at: i64,
    pub status: UploadStatus,
    pub width: Option<i32>,
    pub height: Option<i32>,
    pub duration_ms: Option<i32>,
    pub thumbnail_id: Option<String>,
    pub is_encrypted: bool,
    pub conversation_id: Option<String>,
    pub message_id: Option<String>,
}

impl From<crate::proto::media::MediaMetadata> for MediaMetadata {
    fn from(proto: crate::proto::media::MediaMetadata) -> Self {
        Self {
            media_id: proto.media_id,
            owner_user_id: proto.owner_user_id,
            filename: proto.filename,
            media_type: proto.media_type.into(),
            mime_type: proto.mime_type,
            size_bytes: proto.size_bytes,
            checksum_sha256: proto.checksum_sha256,
            created_at: proto.created_at,
            updated_at: proto.updated_at,
            status: proto.status.into(),
            width: if proto.width > 0 {
                Some(proto.width)
            } else {
                None
            },
            height: if proto.height > 0 {
                Some(proto.height)
            } else {
                None
            },
            duration_ms: if proto.duration_ms > 0 {
                Some(proto.duration_ms)
            } else {
                None
            },
            thumbnail_id: if proto.thumbnail_id.is_empty() {
                None
            } else {
                Some(proto.thumbnail_id)
            },
            is_encrypted: proto.is_encrypted,
            conversation_id: if proto.conversation_id.is_empty() {
                None
            } else {
                Some(proto.conversation_id)
            },
            message_id: if proto.message_id.is_empty() {
                None
            } else {
                Some(proto.message_id)
            },
        }
    }
}

/// Upload URL result
#[derive(Debug, Clone)]
pub struct UploadUrlResult {
    pub upload_url: String,
    pub media_id: String,
    pub expires_at: i64,
    pub headers: std::collections::HashMap<String, String>,
}

/// Download URL result
#[derive(Debug, Clone)]
pub struct DownloadUrlResult {
    pub download_url: String,
    pub expires_at: i64,
    pub metadata: Option<MediaMetadata>,
}

/// Thumbnail result
#[derive(Debug, Clone)]
pub struct ThumbnailResult {
    pub thumbnail_id: String,
    pub metadata: Option<MediaMetadata>,
}

/// Media list result
#[derive(Debug, Clone)]
pub struct MediaListResult {
    pub items: Vec<MediaMetadata>,
    pub next_cursor: Option<String>,
    pub total_count: i32,
}

/// Media service gRPC client
pub struct MediaClient {
    grpc: Arc<GrpcClient>,
}

impl MediaClient {
    /// Create a new media client with the given gRPC connection manager
    pub fn new(grpc: Arc<GrpcClient>) -> Self {
        Self { grpc }
    }

    /// Create a gRPC client
    async fn client(&self) -> Result<MediaServiceClient<Channel>, GrpcError> {
        let channel = self.grpc.get_channel().await?;
        Ok(MediaServiceClient::new(channel))
    }

    /// Add auth token to request
    fn with_auth<T>(&self, mut request: Request<T>) -> Result<Request<T>, GrpcError> {
        if let Some(token) = self.grpc.get_auth_token() {
            let value = MetadataValue::try_from(format!("Bearer {}", token)).map_err(|_| {
                GrpcError::RequestFailed("Invalid auth token format".to_string())
            })?;
            request.metadata_mut().insert("authorization", value);
        }
        Ok(request)
    }

    /// Get a presigned URL for uploading media
    pub async fn get_upload_url(
        &self,
        filename: String,
        mime_type: String,
        size_bytes: i64,
        conversation_id: Option<String>,
    ) -> Result<UploadUrlResult, GrpcError> {
        info!("Getting upload URL for file: {}", filename);

        let request = GetUploadUrlRequest {
            filename,
            mime_type,
            size_bytes,
            conversation_id: conversation_id.unwrap_or_default(),
        };

        let mut client = self.client().await?;
        let response = client
            .get_upload_url(self.with_auth(Request::new(request))?)
            .await
            .map_err(|e| {
                warn!("GetUploadUrl request failed: {:?}", e);
                GrpcError::RequestFailed(e.to_string())
            })?;

        let result = response.into_inner();

        if let Some(error) = result.error {
            return Err(GrpcError::RequestFailed(error.message));
        }

        debug!("Got upload URL for media_id: {}", result.media_id);
        Ok(UploadUrlResult {
            upload_url: result.upload_url,
            media_id: result.media_id,
            expires_at: result.expires_at,
            headers: result.headers,
        })
    }

    /// Get a presigned URL for downloading media
    pub async fn get_download_url(&self, media_id: String) -> Result<DownloadUrlResult, GrpcError> {
        info!("Getting download URL for media: {}", media_id);

        let request = GetDownloadUrlRequest { media_id };

        let mut client = self.client().await?;
        let response = client
            .get_download_url(self.with_auth(Request::new(request))?)
            .await
            .map_err(|e| {
                warn!("GetDownloadUrl request failed: {:?}", e);
                GrpcError::RequestFailed(e.to_string())
            })?;

        let result = response.into_inner();

        if let Some(error) = result.error {
            return Err(GrpcError::RequestFailed(error.message));
        }

        debug!("Got download URL, expires at: {}", result.expires_at);
        Ok(DownloadUrlResult {
            download_url: result.download_url,
            expires_at: result.expires_at,
            metadata: result.metadata.map(|m| m.into()),
        })
    }

    /// Get media metadata
    pub async fn get_metadata(&self, media_id: String) -> Result<MediaMetadata, GrpcError> {
        info!("Getting metadata for media: {}", media_id);

        let request = GetMediaMetadataRequest { media_id };

        let mut client = self.client().await?;
        let response = client
            .get_media_metadata(self.with_auth(Request::new(request))?)
            .await
            .map_err(|e| {
                warn!("GetMediaMetadata request failed: {:?}", e);
                GrpcError::RequestFailed(e.to_string())
            })?;

        let result = response.into_inner();

        if let Some(error) = result.error {
            return Err(GrpcError::RequestFailed(error.message));
        }

        result
            .metadata
            .map(|m| m.into())
            .ok_or_else(|| GrpcError::RequestFailed("No metadata in response".to_string()))
    }

    /// Delete media
    pub async fn delete_media(&self, media_id: String) -> Result<(), GrpcError> {
        info!("Deleting media: {}", media_id);

        let request = DeleteMediaRequest { media_id };

        let mut client = self.client().await?;
        let response = client
            .delete_media(self.with_auth(Request::new(request))?)
            .await
            .map_err(|e| {
                warn!("DeleteMedia request failed: {:?}", e);
                GrpcError::RequestFailed(e.to_string())
            })?;

        let result = response.into_inner();

        if let Some(error) = result.error {
            return Err(GrpcError::RequestFailed(error.message));
        }

        if !result.success {
            return Err(GrpcError::RequestFailed("Delete operation failed".to_string()));
        }

        debug!("Media deleted successfully");
        Ok(())
    }

    /// Generate thumbnail for media
    pub async fn generate_thumbnail(
        &self,
        media_id: String,
        max_width: Option<i32>,
        max_height: Option<i32>,
        format: Option<String>,
        quality: Option<i32>,
    ) -> Result<ThumbnailResult, GrpcError> {
        info!("Generating thumbnail for media: {}", media_id);

        let request = GenerateThumbnailRequest {
            media_id,
            max_width: max_width.unwrap_or(256),
            max_height: max_height.unwrap_or(256),
            format: format.unwrap_or_else(|| "jpeg".to_string()),
            quality: quality.unwrap_or(80),
        };

        let mut client = self.client().await?;
        let response = client
            .generate_thumbnail(self.with_auth(Request::new(request))?)
            .await
            .map_err(|e| {
                warn!("GenerateThumbnail request failed: {:?}", e);
                GrpcError::RequestFailed(e.to_string())
            })?;

        let result = response.into_inner();

        if let Some(error) = result.error {
            return Err(GrpcError::RequestFailed(error.message));
        }

        debug!("Thumbnail generated: {}", result.thumbnail_id);
        Ok(ThumbnailResult {
            thumbnail_id: result.thumbnail_id,
            metadata: result.metadata.map(|m| m.into()),
        })
    }

    /// List media with filters and pagination
    pub async fn list_media(
        &self,
        user_id: Option<String>,
        conversation_id: Option<String>,
        media_types: Option<Vec<MediaType>>,
        limit: Option<i32>,
        cursor: Option<String>,
        sort_by: Option<String>,
        ascending: Option<bool>,
    ) -> Result<MediaListResult, GrpcError> {
        info!(
            "Listing media for conversation: {:?}",
            conversation_id.as_deref().unwrap_or("all")
        );

        let request = ListMediaRequest {
            user_id: user_id.unwrap_or_default(),
            conversation_id: conversation_id.unwrap_or_default(),
            media_types: media_types
                .map(|types| types.into_iter().map(|t| ProtoMediaType::from(t) as i32).collect())
                .unwrap_or_default(),
            limit: limit.unwrap_or(50),
            cursor: cursor.unwrap_or_default(),
            sort_by: sort_by.unwrap_or_else(|| "created_at".to_string()),
            ascending: ascending.unwrap_or(false),
        };

        let mut client = self.client().await?;
        let response = client
            .list_media(self.with_auth(Request::new(request))?)
            .await
            .map_err(|e| {
                warn!("ListMedia request failed: {:?}", e);
                GrpcError::RequestFailed(e.to_string())
            })?;

        let result = response.into_inner();

        if let Some(error) = result.error {
            return Err(GrpcError::RequestFailed(error.message));
        }

        debug!("Listed {} media items", result.items.len());
        Ok(MediaListResult {
            items: result.items.into_iter().map(|m| m.into()).collect(),
            next_cursor: if result.next_cursor.is_empty() {
                None
            } else {
                Some(result.next_cursor)
            },
            total_count: result.total_count,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_media_type_from_proto() {
        assert_eq!(MediaType::from(ProtoMediaType::Image), MediaType::Image);
        assert_eq!(MediaType::from(ProtoMediaType::Video), MediaType::Video);
        assert_eq!(MediaType::from(ProtoMediaType::Audio), MediaType::Audio);
        assert_eq!(MediaType::from(ProtoMediaType::Document), MediaType::Document);
        assert_eq!(MediaType::from(ProtoMediaType::Other), MediaType::Other);
        assert_eq!(MediaType::from(ProtoMediaType::Unknown), MediaType::Unknown);
    }

    #[test]
    fn test_media_type_to_proto() {
        assert_eq!(ProtoMediaType::from(MediaType::Image), ProtoMediaType::Image);
        assert_eq!(ProtoMediaType::from(MediaType::Video), ProtoMediaType::Video);
        assert_eq!(ProtoMediaType::from(MediaType::Audio), ProtoMediaType::Audio);
        assert_eq!(ProtoMediaType::from(MediaType::Document), ProtoMediaType::Document);
        assert_eq!(ProtoMediaType::from(MediaType::Other), ProtoMediaType::Other);
        assert_eq!(ProtoMediaType::from(MediaType::Unknown), ProtoMediaType::Unknown);
    }

    #[test]
    fn test_media_type_from_i32() {
        assert_eq!(MediaType::from(0), MediaType::Unknown);
        assert_eq!(MediaType::from(1), MediaType::Image);
        assert_eq!(MediaType::from(2), MediaType::Video);
        assert_eq!(MediaType::from(3), MediaType::Audio);
        assert_eq!(MediaType::from(4), MediaType::Document);
        assert_eq!(MediaType::from(5), MediaType::Other);
        assert_eq!(MediaType::from(99), MediaType::Unknown);
    }

    #[test]
    fn test_upload_status_from_i32() {
        assert_eq!(UploadStatus::from(0), UploadStatus::Unknown);
        assert_eq!(UploadStatus::from(1), UploadStatus::Pending);
        assert_eq!(UploadStatus::from(2), UploadStatus::Processing);
        assert_eq!(UploadStatus::from(3), UploadStatus::Completed);
        assert_eq!(UploadStatus::from(4), UploadStatus::Failed);
        assert_eq!(UploadStatus::from(99), UploadStatus::Unknown);
    }
}
