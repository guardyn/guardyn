//! Media Service Configuration

use serde::{Deserialize, Serialize};

/// Media service configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MediaConfig {
    /// S3/MinIO endpoint URL
    pub s3_endpoint: String,
    /// S3 region (us-east-1 for MinIO)
    pub s3_region: String,
    /// S3 access key
    pub s3_access_key: String,
    /// S3 secret key
    pub s3_secret_key: String,
    /// Bucket name for media storage
    pub bucket_name: String,
    /// Maximum file size in bytes (default: 100MB)
    pub max_file_size_bytes: u64,
    /// Chunk size for streaming uploads/downloads (default: 1MB)
    pub chunk_size_bytes: usize,
    /// Pre-signed URL expiration in seconds (default: 3600 = 1 hour)
    pub presigned_url_expiry_seconds: u64,
    /// Thumbnail max width
    pub thumbnail_max_width: u32,
    /// Thumbnail max height
    pub thumbnail_max_height: u32,
    /// Thumbnail JPEG quality (1-100)
    pub thumbnail_quality: u8,
    /// Enable thumbnail generation
    pub thumbnails_enabled: bool,
}

impl Default for MediaConfig {
    fn default() -> Self {
        Self {
            s3_endpoint: "http://minio.data.svc.cluster.local:9000".to_string(),
            s3_region: "us-east-1".to_string(),
            s3_access_key: "minioadmin".to_string(),
            s3_secret_key: "minioadmin".to_string(),
            bucket_name: "guardyn-media".to_string(),
            max_file_size_bytes: 100 * 1024 * 1024, // 100 MB
            chunk_size_bytes: 1024 * 1024, // 1 MB
            presigned_url_expiry_seconds: 3600, // 1 hour
            thumbnail_max_width: 256,
            thumbnail_max_height: 256,
            thumbnail_quality: 80,
            thumbnails_enabled: true,
        }
    }
}

impl MediaConfig {
    /// Load configuration from environment variables
    pub fn from_env() -> Self {
        let mut config = Self::default();
        
        if let Ok(val) = std::env::var("S3_ENDPOINT") {
            config.s3_endpoint = val;
        }
        if let Ok(val) = std::env::var("S3_REGION") {
            config.s3_region = val;
        }
        if let Ok(val) = std::env::var("S3_ACCESS_KEY") {
            config.s3_access_key = val;
        }
        if let Ok(val) = std::env::var("S3_SECRET_KEY") {
            config.s3_secret_key = val;
        }
        if let Ok(val) = std::env::var("S3_BUCKET_NAME") {
            config.bucket_name = val;
        }
        if let Ok(val) = std::env::var("MAX_FILE_SIZE_BYTES") {
            if let Ok(size) = val.parse() {
                config.max_file_size_bytes = size;
            }
        }
        if let Ok(val) = std::env::var("CHUNK_SIZE_BYTES") {
            if let Ok(size) = val.parse() {
                config.chunk_size_bytes = size;
            }
        }
        if let Ok(val) = std::env::var("PRESIGNED_URL_EXPIRY_SECONDS") {
            if let Ok(expiry) = val.parse() {
                config.presigned_url_expiry_seconds = expiry;
            }
        }
        if let Ok(val) = std::env::var("THUMBNAIL_MAX_WIDTH") {
            if let Ok(width) = val.parse() {
                config.thumbnail_max_width = width;
            }
        }
        if let Ok(val) = std::env::var("THUMBNAIL_MAX_HEIGHT") {
            if let Ok(height) = val.parse() {
                config.thumbnail_max_height = height;
            }
        }
        if let Ok(val) = std::env::var("THUMBNAIL_QUALITY") {
            if let Ok(quality) = val.parse() {
                config.thumbnail_quality = quality;
            }
        }
        if let Ok(val) = std::env::var("THUMBNAILS_ENABLED") {
            config.thumbnails_enabled = val.to_lowercase() == "true" || val == "1";
        }
        
        config
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_config() {
        let config = MediaConfig::default();
        assert_eq!(config.max_file_size_bytes, 100 * 1024 * 1024);
        assert_eq!(config.chunk_size_bytes, 1024 * 1024);
        assert_eq!(config.presigned_url_expiry_seconds, 3600);
        assert!(config.thumbnails_enabled);
    }
}
