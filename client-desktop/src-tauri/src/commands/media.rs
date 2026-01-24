//! Media Commands
//!
//! Handles media upload, download, and management operations.

use crate::state::AppState;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::PathBuf;
use tauri::{Manager, State};
use tokio::fs::File;
use tokio::io::AsyncReadExt;
use tracing::{debug, error, info};

/// Media type for serialization
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum MediaType {
    Unknown,
    Image,
    Video,
    Audio,
    Document,
    Other,
}

impl From<crate::services::MediaType> for MediaType {
    fn from(t: crate::services::MediaType) -> Self {
        match t {
            crate::services::MediaType::Unknown => MediaType::Unknown,
            crate::services::MediaType::Image => MediaType::Image,
            crate::services::MediaType::Video => MediaType::Video,
            crate::services::MediaType::Audio => MediaType::Audio,
            crate::services::MediaType::Document => MediaType::Document,
            crate::services::MediaType::Other => MediaType::Other,
        }
    }
}

/// Upload status for serialization
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum UploadStatus {
    Unknown,
    Pending,
    Processing,
    Completed,
    Failed,
}

impl From<crate::services::UploadStatus> for UploadStatus {
    fn from(s: crate::services::UploadStatus) -> Self {
        match s {
            crate::services::UploadStatus::Unknown => UploadStatus::Unknown,
            crate::services::UploadStatus::Pending => UploadStatus::Pending,
            crate::services::UploadStatus::Processing => UploadStatus::Processing,
            crate::services::UploadStatus::Completed => UploadStatus::Completed,
            crate::services::UploadStatus::Failed => UploadStatus::Failed,
        }
    }
}

/// Media metadata response
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct MediaMetadataResponse {
    pub id: String,
    pub owner_user_id: String,
    pub filename: String,
    #[serde(rename = "type")]
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

impl From<crate::services::MediaMetadata> for MediaMetadataResponse {
    fn from(m: crate::services::MediaMetadata) -> Self {
        Self {
            id: m.media_id,
            owner_user_id: m.owner_user_id,
            filename: m.filename,
            media_type: m.media_type.into(),
            mime_type: m.mime_type,
            size_bytes: m.size_bytes,
            checksum_sha256: m.checksum_sha256,
            created_at: m.created_at,
            updated_at: m.updated_at,
            status: m.status.into(),
            width: m.width,
            height: m.height,
            duration_ms: m.duration_ms,
            thumbnail_id: m.thumbnail_id,
            is_encrypted: m.is_encrypted,
            conversation_id: m.conversation_id,
            message_id: m.message_id,
        }
    }
}

/// Upload URL result
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UploadUrlResponse {
    pub media_id: String,
    pub upload_url: String,
    pub expires_at: i64,
    pub headers: HashMap<String, String>,
}

/// Download URL result
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct DownloadUrlResponse {
    pub download_url: String,
    pub expires_at: i64,
    pub metadata: Option<MediaMetadataResponse>,
}

/// Media list result
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct MediaListResponse {
    pub items: Vec<MediaMetadataResponse>,
    pub next_cursor: Option<String>,
    pub total_count: i32,
}

/// Thumbnail result
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ThumbnailResponse {
    pub thumbnail_id: String,
    pub metadata: Option<MediaMetadataResponse>,
}

/// Get presigned upload URL
#[tauri::command]
pub async fn get_media_upload_url(
    filename: String,
    mime_type: String,
    size_bytes: i64,
    conversation_id: Option<String>,
    state: State<'_, AppState>,
) -> Result<UploadUrlResponse, String> {
    info!("Getting upload URL for file: {}", filename);

    let result = state
        .media()
        .get_upload_url(filename, mime_type, size_bytes, conversation_id)
        .await
        .map_err(|e| {
            error!("Failed to get upload URL: {:?}", e);
            e.to_string()
        })?;

    Ok(UploadUrlResponse {
        media_id: result.media_id,
        upload_url: result.upload_url,
        expires_at: result.expires_at,
        headers: result.headers,
    })
}

/// Upload file to presigned URL
#[tauri::command]
pub async fn upload_media_file(
    file_path: String,
    presigned_url: String,
    mime_type: String,
) -> Result<(), String> {
    info!("Uploading file: {}", file_path);

    let path = PathBuf::from(&file_path);
    
    // Check if file exists
    if !path.exists() {
        return Err(format!("File not found: {}", file_path));
    }

    // Read file contents
    let mut file = File::open(&path).await.map_err(|e| {
        error!("Failed to open file: {:?}", e);
        format!("Failed to open file: {}", e)
    })?;

    let mut buffer = Vec::new();
    file.read_to_end(&mut buffer).await.map_err(|e| {
        error!("Failed to read file: {:?}", e);
        format!("Failed to read file: {}", e)
    })?;

    debug!("Read {} bytes from file", buffer.len());

    // Upload to presigned URL using HTTP PUT
    let client = reqwest::Client::new();
    let response = client
        .put(&presigned_url)
        .header("Content-Type", &mime_type)
        .header("Content-Length", buffer.len())
        .body(buffer)
        .send()
        .await
        .map_err(|e| {
            error!("Failed to upload file: {:?}", e);
            format!("Failed to upload file: {}", e)
        })?;

    if !response.status().is_success() {
        let status = response.status();
        let body = response.text().await.unwrap_or_default();
        error!("Upload failed with status {}: {}", status, body);
        return Err(format!("Upload failed with status {}: {}", status, body));
    }

    info!("File uploaded successfully");
    Ok(())
}

/// Get presigned download URL
#[tauri::command]
pub async fn get_media_download_url(
    media_id: String,
    state: State<'_, AppState>,
) -> Result<DownloadUrlResponse, String> {
    info!("Getting download URL for media: {}", media_id);

    let result = state
        .media()
        .get_download_url(media_id)
        .await
        .map_err(|e| {
            error!("Failed to get download URL: {:?}", e);
            e.to_string()
        })?;

    Ok(DownloadUrlResponse {
        download_url: result.download_url,
        expires_at: result.expires_at,
        metadata: result.metadata.map(|m| m.into()),
    })
}

/// Download file from presigned URL and save to disk
#[tauri::command]
pub async fn download_media_file(
    download_url: String,
    save_path: String,
) -> Result<String, String> {
    info!("Downloading file to: {}", save_path);

    // Download file using HTTP GET
    let client = reqwest::Client::new();
    let response = client
        .get(&download_url)
        .send()
        .await
        .map_err(|e| {
            error!("Failed to download file: {:?}", e);
            format!("Failed to download file: {}", e)
        })?;

    if !response.status().is_success() {
        let status = response.status();
        let body = response.text().await.unwrap_or_default();
        error!("Download failed with status {}: {}", status, body);
        return Err(format!("Download failed with status {}: {}", status, body));
    }

    let bytes = response.bytes().await.map_err(|e| {
        error!("Failed to read response body: {:?}", e);
        format!("Failed to read response body: {}", e)
    })?;

    debug!("Downloaded {} bytes", bytes.len());

    // Ensure parent directory exists
    let save_path = PathBuf::from(&save_path);
    if let Some(parent) = save_path.parent() {
        tokio::fs::create_dir_all(parent).await.map_err(|e| {
            error!("Failed to create directory: {:?}", e);
            format!("Failed to create directory: {}", e)
        })?;
    }

    // Write to file
    tokio::fs::write(&save_path, &bytes).await.map_err(|e| {
        error!("Failed to write file: {:?}", e);
        format!("Failed to write file: {}", e)
    })?;

    info!("File downloaded successfully to: {:?}", save_path);
    Ok(save_path.to_string_lossy().to_string())
}

/// Get media metadata
#[tauri::command]
pub async fn get_media_metadata(
    media_id: String,
    state: State<'_, AppState>,
) -> Result<MediaMetadataResponse, String> {
    info!("Getting metadata for media: {}", media_id);

    let result = state
        .media()
        .get_metadata(media_id)
        .await
        .map_err(|e| {
            error!("Failed to get metadata: {:?}", e);
            e.to_string()
        })?;

    Ok(result.into())
}

/// Delete media
#[tauri::command]
pub async fn delete_media(
    media_id: String,
    state: State<'_, AppState>,
) -> Result<(), String> {
    info!("Deleting media: {}", media_id);

    state
        .media()
        .delete_media(media_id)
        .await
        .map_err(|e| {
            error!("Failed to delete media: {:?}", e);
            e.to_string()
        })?;

    info!("Media deleted successfully");
    Ok(())
}

/// Generate thumbnail
#[tauri::command]
pub async fn generate_thumbnail(
    media_id: String,
    max_width: Option<i32>,
    max_height: Option<i32>,
    format: Option<String>,
    quality: Option<i32>,
    state: State<'_, AppState>,
) -> Result<ThumbnailResponse, String> {
    info!("Generating thumbnail for media: {}", media_id);

    let result = state
        .media()
        .generate_thumbnail(media_id, max_width, max_height, format, quality)
        .await
        .map_err(|e| {
            error!("Failed to generate thumbnail: {:?}", e);
            e.to_string()
        })?;

    Ok(ThumbnailResponse {
        thumbnail_id: result.thumbnail_id,
        metadata: result.metadata.map(|m| m.into()),
    })
}

/// List media with filters and pagination
#[tauri::command]
pub async fn list_media(
    user_id: Option<String>,
    conversation_id: Option<String>,
    media_types: Option<Vec<String>>,
    limit: Option<i32>,
    cursor: Option<String>,
    sort_by: Option<String>,
    ascending: Option<bool>,
    state: State<'_, AppState>,
) -> Result<MediaListResponse, String> {
    info!("Listing media for conversation: {:?}", conversation_id);

    // Convert string media types to enum
    let media_types = media_types.map(|types| {
        types
            .into_iter()
            .map(|t| match t.to_lowercase().as_str() {
                "image" => crate::services::MediaType::Image,
                "video" => crate::services::MediaType::Video,
                "audio" => crate::services::MediaType::Audio,
                "document" => crate::services::MediaType::Document,
                "other" => crate::services::MediaType::Other,
                _ => crate::services::MediaType::Unknown,
            })
            .collect()
    });

    let result = state
        .media()
        .list_media(
            user_id,
            conversation_id,
            media_types,
            limit,
            cursor,
            sort_by,
            ascending,
        )
        .await
        .map_err(|e| {
            error!("Failed to list media: {:?}", e);
            e.to_string()
        })?;

    Ok(MediaListResponse {
        items: result.items.into_iter().map(|m| m.into()).collect(),
        next_cursor: result.next_cursor,
        total_count: result.total_count,
    })
}

/// Get cache directory for media files
#[tauri::command]
pub async fn get_media_cache_dir(app: tauri::AppHandle) -> Result<String, String> {
    let cache_dir = app
        .path()
        .app_cache_dir()
        .map_err(|e| format!("Failed to get cache directory: {}", e))?
        .join("media");

    // Create directory if it doesn't exist
    tokio::fs::create_dir_all(&cache_dir)
        .await
        .map_err(|e| format!("Failed to create cache directory: {}", e))?;

    Ok(cache_dir.to_string_lossy().to_string())
}

/// Clear media cache
#[tauri::command]
pub async fn clear_media_cache(app: tauri::AppHandle) -> Result<(), String> {
    let cache_dir = app
        .path()
        .app_cache_dir()
        .map_err(|e| format!("Failed to get cache directory: {}", e))?
        .join("media");

    if cache_dir.exists() {
        tokio::fs::remove_dir_all(&cache_dir)
            .await
            .map_err(|e| format!("Failed to clear cache directory: {}", e))?;

        // Recreate empty directory
        tokio::fs::create_dir_all(&cache_dir)
            .await
            .map_err(|e| format!("Failed to recreate cache directory: {}", e))?;
    }

    info!("Media cache cleared");
    Ok(())
}

/// Get cached file path if exists
#[tauri::command]
pub async fn get_cached_media_path(
    media_id: String,
    app: tauri::AppHandle,
) -> Result<Option<String>, String> {
    let cache_dir = app
        .path()
        .app_cache_dir()
        .map_err(|e| format!("Failed to get cache directory: {}", e))?
        .join("media");

    // Look for any file with the media_id prefix
    let pattern = format!("{}*", media_id);
    
    if cache_dir.exists() {
        let mut entries = tokio::fs::read_dir(&cache_dir)
            .await
            .map_err(|e| format!("Failed to read cache directory: {}", e))?;

        while let Some(entry) = entries.next_entry().await.map_err(|e| e.to_string())? {
            let filename = entry.file_name().to_string_lossy().to_string();
            if filename.starts_with(&media_id) {
                return Ok(Some(entry.path().to_string_lossy().to_string()));
            }
        }
    }

    Ok(None)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_media_type_serialization() {
        let media_type = MediaType::Image;
        let json = serde_json::to_string(&media_type).unwrap();
        assert_eq!(json, "\"image\"");

        let deserialized: MediaType = serde_json::from_str(&json).unwrap();
        assert!(matches!(deserialized, MediaType::Image));
    }

    #[test]
    fn test_upload_status_serialization() {
        let status = UploadStatus::Completed;
        let json = serde_json::to_string(&status).unwrap();
        assert_eq!(json, "\"completed\"");

        let deserialized: UploadStatus = serde_json::from_str(&json).unwrap();
        assert!(matches!(deserialized, UploadStatus::Completed));
    }

    #[test]
    fn test_media_metadata_response_serialization() {
        let metadata = MediaMetadataResponse {
            id: "test-id".to_string(),
            owner_user_id: "user-123".to_string(),
            filename: "test.jpg".to_string(),
            media_type: MediaType::Image,
            mime_type: "image/jpeg".to_string(),
            size_bytes: 1024,
            checksum_sha256: "abc123".to_string(),
            created_at: 1234567890,
            updated_at: 1234567890,
            status: UploadStatus::Completed,
            width: Some(800),
            height: Some(600),
            duration_ms: None,
            thumbnail_id: Some("thumb-id".to_string()),
            is_encrypted: false,
            conversation_id: Some("conv-123".to_string()),
            message_id: None,
        };

        let json = serde_json::to_string(&metadata).unwrap();
        assert!(json.contains("\"id\":\"test-id\""));
        assert!(json.contains("\"type\":\"image\""));
        assert!(json.contains("\"mimeType\":\"image/jpeg\""));
    }
}
