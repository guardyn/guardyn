//! Thumbnail Generation
//!
//! Generates thumbnails for images using the image crate

use crate::config::MediaConfig;
use anyhow::{anyhow, Result};
use bytes::Bytes;
use image::{GenericImageView, ImageFormat, imageops::FilterType};
use std::io::Cursor;

/// Thumbnail generator
pub struct ThumbnailGenerator {
    max_width: u32,
    max_height: u32,
    quality: u8,
}

impl ThumbnailGenerator {
    /// Create a new thumbnail generator with config
    pub fn new(config: &MediaConfig) -> Self {
        Self {
            max_width: config.thumbnail_max_width,
            max_height: config.thumbnail_max_height,
            quality: config.thumbnail_quality,
        }
    }

    /// Create with custom dimensions
    pub fn with_dimensions(max_width: u32, max_height: u32, quality: u8) -> Self {
        Self {
            max_width,
            max_height,
            quality,
        }
    }

    /// Generate a thumbnail from image bytes
    pub fn generate(&self, image_data: &[u8], format: &str) -> Result<Bytes> {
        // Load the image
        let img = image::load_from_memory(image_data)
            .map_err(|e| anyhow!("Failed to load image: {}", e))?;

        // Calculate new dimensions maintaining aspect ratio
        let (orig_width, orig_height) = img.dimensions();
        let (new_width, new_height) = self.calculate_dimensions(orig_width, orig_height);

        // Resize the image
        let thumbnail = img.resize_exact(new_width, new_height, FilterType::Lanczos3);

        // Encode to output format
        let output_format = self.parse_format(format)?;
        let mut output = Cursor::new(Vec::new());
        
        match output_format {
            ImageFormat::Jpeg => {
                let encoder = image::codecs::jpeg::JpegEncoder::new_with_quality(
                    &mut output,
                    self.quality,
                );
                thumbnail
                    .write_with_encoder(encoder)
                    .map_err(|e| anyhow!("Failed to encode JPEG: {}", e))?;
            }
            ImageFormat::Png => {
                thumbnail
                    .write_to(&mut output, ImageFormat::Png)
                    .map_err(|e| anyhow!("Failed to encode PNG: {}", e))?;
            }
            ImageFormat::WebP => {
                thumbnail
                    .write_to(&mut output, ImageFormat::WebP)
                    .map_err(|e| anyhow!("Failed to encode WebP: {}", e))?;
            }
            _ => {
                return Err(anyhow!("Unsupported output format: {}", format));
            }
        }

        Ok(Bytes::from(output.into_inner()))
    }

    /// Calculate thumbnail dimensions maintaining aspect ratio
    fn calculate_dimensions(&self, width: u32, height: u32) -> (u32, u32) {
        if width <= self.max_width && height <= self.max_height {
            return (width, height);
        }

        let width_ratio = self.max_width as f64 / width as f64;
        let height_ratio = self.max_height as f64 / height as f64;
        let ratio = width_ratio.min(height_ratio);

        let new_width = (width as f64 * ratio).round() as u32;
        let new_height = (height as f64 * ratio).round() as u32;

        (new_width.max(1), new_height.max(1))
    }

    /// Parse format string to ImageFormat
    fn parse_format(&self, format: &str) -> Result<ImageFormat> {
        match format.to_lowercase().as_str() {
            "jpeg" | "jpg" => Ok(ImageFormat::Jpeg),
            "png" => Ok(ImageFormat::Png),
            "webp" => Ok(ImageFormat::WebP),
            "" => Ok(ImageFormat::Jpeg), // Default
            _ => Err(anyhow!("Unsupported format: {}", format)),
        }
    }

    /// Get the MIME type for the output format
    pub fn format_to_mime(format: &str) -> &'static str {
        match format.to_lowercase().as_str() {
            "jpeg" | "jpg" | "" => "image/jpeg",
            "png" => "image/png",
            "webp" => "image/webp",
            _ => "image/jpeg",
        }
    }

    /// Check if a MIME type is supported for thumbnail generation
    pub fn is_supported_mime(mime_type: &str) -> bool {
        matches!(
            mime_type,
            "image/jpeg" | "image/jpg" | "image/png" | "image/gif" | "image/webp" | "image/bmp"
        )
    }
}

/// Extract image dimensions from image bytes
pub fn get_image_dimensions(image_data: &[u8]) -> Result<(u32, u32)> {
    let img = image::load_from_memory(image_data)
        .map_err(|e| anyhow!("Failed to load image: {}", e))?;
    Ok(img.dimensions())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculate_dimensions_no_resize() {
        let gen = ThumbnailGenerator::with_dimensions(256, 256, 80);
        let (w, h) = gen.calculate_dimensions(100, 100);
        assert_eq!((w, h), (100, 100));
    }

    #[test]
    fn test_calculate_dimensions_landscape() {
        let gen = ThumbnailGenerator::with_dimensions(256, 256, 80);
        let (w, h) = gen.calculate_dimensions(1920, 1080);
        assert_eq!(w, 256);
        assert!(h < 256);
    }

    #[test]
    fn test_calculate_dimensions_portrait() {
        let gen = ThumbnailGenerator::with_dimensions(256, 256, 80);
        let (w, h) = gen.calculate_dimensions(1080, 1920);
        assert!(w < 256);
        assert_eq!(h, 256);
    }

    #[test]
    fn test_is_supported_mime() {
        assert!(ThumbnailGenerator::is_supported_mime("image/jpeg"));
        assert!(ThumbnailGenerator::is_supported_mime("image/png"));
        assert!(ThumbnailGenerator::is_supported_mime("image/webp"));
        assert!(!ThumbnailGenerator::is_supported_mime("video/mp4"));
        assert!(!ThumbnailGenerator::is_supported_mime("application/pdf"));
    }
}
