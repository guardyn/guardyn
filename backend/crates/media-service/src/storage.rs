//! S3/MinIO Storage Client
//!
//! Handles file storage operations using AWS SDK for S3-compatible storage

use crate::config::MediaConfig;
use anyhow::{anyhow, Result};
use aws_config::Region;
use aws_credential_types::Credentials;
use aws_sdk_s3::{
    config::Builder as S3ConfigBuilder,
    presigning::PresigningConfig,
    primitives::ByteStream,
    Client as S3Client,
};
use bytes::Bytes;
use std::time::Duration;

/// Storage client for S3/MinIO operations
#[derive(Clone)]
pub struct StorageClient {
    client: S3Client,
    bucket: String,
    presigned_expiry: Duration,
}

impl StorageClient {
    /// Create a new storage client
    pub async fn new(config: &MediaConfig) -> Result<Self> {
        let credentials = Credentials::new(
            &config.s3_access_key,
            &config.s3_secret_key,
            None,
            None,
            "guardyn-media",
        );

        let s3_config = S3ConfigBuilder::new()
            .region(Region::new(config.s3_region.clone()))
            .endpoint_url(&config.s3_endpoint)
            .credentials_provider(credentials)
            .force_path_style(true) // Required for MinIO
            .build();

        let client = S3Client::from_conf(s3_config);

        Ok(Self {
            client,
            bucket: config.bucket_name.clone(),
            presigned_expiry: Duration::from_secs(config.presigned_url_expiry_seconds),
        })
    }

    /// Ensure the bucket exists (create if not)
    pub async fn ensure_bucket_exists(&self, bucket_name: &str) -> Result<()> {
        match self.client.head_bucket().bucket(bucket_name).send().await {
            Ok(_) => {
                tracing::debug!(bucket = %bucket_name, "Bucket exists");
                Ok(())
            }
            Err(_) => {
                tracing::info!(bucket = %bucket_name, "Creating bucket");
                self.client
                    .create_bucket()
                    .bucket(bucket_name)
                    .send()
                    .await
                    .map_err(|e| anyhow!("Failed to create bucket: {}", e))?;
                Ok(())
            }
        }
    }

    /// Upload a file to storage
    pub async fn upload_file(
        &self,
        key: &str,
        data: Bytes,
        content_type: &str,
    ) -> Result<()> {
        self.client
            .put_object()
            .bucket(&self.bucket)
            .key(key)
            .body(ByteStream::from(data))
            .content_type(content_type)
            .send()
            .await
            .map_err(|e| anyhow!("Failed to upload file: {}", e))?;

        Ok(())
    }

    /// Upload a file from a stream
    pub async fn upload_stream(
        &self,
        key: &str,
        stream: ByteStream,
        content_type: &str,
        content_length: i64,
    ) -> Result<()> {
        self.client
            .put_object()
            .bucket(&self.bucket)
            .key(key)
            .body(stream)
            .content_type(content_type)
            .content_length(content_length)
            .send()
            .await
            .map_err(|e| anyhow!("Failed to upload stream: {}", e))?;

        Ok(())
    }

    /// Download a file from storage
    pub async fn download_file(&self, key: &str) -> Result<Bytes> {
        let response = self
            .client
            .get_object()
            .bucket(&self.bucket)
            .key(key)
            .send()
            .await
            .map_err(|e| anyhow!("Failed to download file: {}", e))?;

        let data = response
            .body
            .collect()
            .await
            .map_err(|e| anyhow!("Failed to read response body: {}", e))?;

        Ok(data.into_bytes())
    }

    /// Download a file with byte range (for resumable downloads)
    pub async fn download_range(
        &self,
        key: &str,
        offset: i64,
        length: i64,
    ) -> Result<Bytes> {
        let range = if length > 0 {
            format!("bytes={}-{}", offset, offset + length - 1)
        } else {
            format!("bytes={}-", offset)
        };

        let response = self
            .client
            .get_object()
            .bucket(&self.bucket)
            .key(key)
            .range(range)
            .send()
            .await
            .map_err(|e| anyhow!("Failed to download range: {}", e))?;

        let data = response
            .body
            .collect()
            .await
            .map_err(|e| anyhow!("Failed to read response body: {}", e))?;

        Ok(data.into_bytes())
    }

    /// Delete a file from storage
    pub async fn delete_file(&self, key: &str) -> Result<()> {
        self.client
            .delete_object()
            .bucket(&self.bucket)
            .key(key)
            .send()
            .await
            .map_err(|e| anyhow!("Failed to delete file: {}", e))?;

        Ok(())
    }

    /// Check if a file exists
    pub async fn file_exists(&self, key: &str) -> Result<bool> {
        match self.client.head_object().bucket(&self.bucket).key(key).send().await {
            Ok(_) => Ok(true),
            Err(e) => {
                // Check if it's a not found error
                if e.to_string().contains("NoSuchKey") || e.to_string().contains("NotFound") {
                    Ok(false)
                } else {
                    Err(anyhow!("Failed to check file existence: {}", e))
                }
            }
        }
    }

    /// Get file metadata (size, content type, etc.)
    pub async fn get_file_info(&self, key: &str) -> Result<(i64, String)> {
        let response = self
            .client
            .head_object()
            .bucket(&self.bucket)
            .key(key)
            .send()
            .await
            .map_err(|e| anyhow!("Failed to get file info: {}", e))?;

        let size = response.content_length().unwrap_or(0);
        let content_type = response
            .content_type()
            .unwrap_or("application/octet-stream")
            .to_string();

        Ok((size, content_type))
    }

    /// Generate a pre-signed URL for upload
    pub async fn generate_upload_url(
        &self,
        key: &str,
        content_type: &str,
        expiry: Option<Duration>,
    ) -> Result<String> {
        let expiry = expiry.unwrap_or(self.presigned_expiry);
        let presigning_config = PresigningConfig::builder()
            .expires_in(expiry)
            .build()
            .map_err(|e| anyhow!("Failed to build presigning config: {}", e))?;

        let presigned = self
            .client
            .put_object()
            .bucket(&self.bucket)
            .key(key)
            .content_type(content_type)
            .presigned(presigning_config)
            .await
            .map_err(|e| anyhow!("Failed to generate upload URL: {}", e))?;

        Ok(presigned.uri().to_string())
    }

    /// Generate a pre-signed URL for download
    pub async fn generate_download_url(
        &self,
        key: &str,
        expiry: Option<Duration>,
    ) -> Result<String> {
        let expiry = expiry.unwrap_or(self.presigned_expiry);
        let presigning_config = PresigningConfig::builder()
            .expires_in(expiry)
            .build()
            .map_err(|e| anyhow!("Failed to build presigning config: {}", e))?;

        let presigned = self
            .client
            .get_object()
            .bucket(&self.bucket)
            .key(key)
            .presigned(presigning_config)
            .await
            .map_err(|e| anyhow!("Failed to generate download URL: {}", e))?;

        Ok(presigned.uri().to_string())
    }

    /// Copy a file within storage (for thumbnails, etc.)
    pub async fn copy_file(&self, source_key: &str, dest_key: &str) -> Result<()> {
        let copy_source = format!("{}/{}", self.bucket, source_key);
        self.client
            .copy_object()
            .bucket(&self.bucket)
            .key(dest_key)
            .copy_source(copy_source)
            .send()
            .await
            .map_err(|e| anyhow!("Failed to copy file: {}", e))?;

        Ok(())
    }

    /// Get the bucket name
    pub fn bucket(&self) -> &str {
        &self.bucket
    }
}
