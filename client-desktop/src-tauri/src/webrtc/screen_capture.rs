//! Screen Capture Module for Desktop
//!
//! Provides cross-platform screen capture for screen sharing.
//! Supports capturing displays and individual windows on Linux (X11/Wayland), macOS, and Windows.
//!
//! Uses the `xcap` crate for unified cross-platform screen capture.

use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::time::{Duration, Instant};

use image::codecs::png::PngEncoder;
use image::{ImageEncoder, RgbaImage};
use parking_lot::RwLock;
use tracing::{debug, info};
use xcap::{Monitor, Window};

/// Maximum thumbnail dimension (width or height)
const THUMBNAIL_MAX_SIZE: u32 = 256;

/// Screen source information
#[derive(Debug, Clone)]
pub struct ScreenSource {
    /// Unique identifier for this source
    pub id: String,
    /// Human-readable name
    pub name: String,
    /// Thumbnail image (PNG bytes)
    pub thumbnail: Vec<u8>,
    /// Type of source
    pub source_type: ScreenSourceType,
    /// Original width of the source
    pub width: u32,
    /// Original height of the source
    pub height: u32,
    /// Is this the primary display (for screens)
    pub is_primary: bool,
}

/// Type of screen source
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ScreenSourceType {
    /// Entire display/monitor
    Screen,
    /// Individual window
    Window,
}

/// Screen capture configuration
#[derive(Debug, Clone)]
pub struct CaptureConfig {
    /// Target frames per second
    pub fps: u32,
    /// Target width (0 for native)
    pub width: u32,
    /// Target height (0 for native)
    pub height: u32,
    /// Capture cursor
    pub capture_cursor: bool,
    /// Capture audio (system audio)
    pub capture_audio: bool,
}

impl Default for CaptureConfig {
    fn default() -> Self {
        Self {
            fps: 30,
            width: 0,
            height: 0,
            capture_cursor: true,
            capture_audio: false,
        }
    }
}

/// Internal source handle for capturing
enum SourceHandle {
    Monitor(Monitor),
    Window(Window),
}

/// Screen capturer for a single source
pub struct ScreenCapturer {
    source: ScreenSource,
    #[allow(dead_code)]
    config: CaptureConfig,
    handle: RwLock<Option<SourceHandle>>,
    is_capturing: AtomicBool,
    frame_count: AtomicU64,
    last_capture_time: RwLock<Instant>,
    frame_interval: Duration,
}

impl ScreenCapturer {
    /// Create a new screen capturer for a monitor
    pub fn from_monitor(monitor: Monitor, config: CaptureConfig) -> Result<Self, CaptureError> {
        let name = monitor.name().to_string();
        let width = monitor.width();
        let height = monitor.height();
        let is_primary = monitor.is_primary();
        let id = format!("monitor:{}", monitor.id());

        // Generate thumbnail
        let thumbnail = Self::generate_monitor_thumbnail(&monitor)?;

        let frame_interval = Duration::from_secs_f64(1.0 / config.fps as f64);

        Ok(Self {
            source: ScreenSource {
                id,
                name,
                thumbnail,
                source_type: ScreenSourceType::Screen,
                width,
                height,
                is_primary,
            },
            config,
            handle: RwLock::new(Some(SourceHandle::Monitor(monitor))),
            is_capturing: AtomicBool::new(false),
            frame_count: AtomicU64::new(0),
            last_capture_time: RwLock::new(Instant::now()),
            frame_interval,
        })
    }

    /// Create a new screen capturer for a window
    pub fn from_window(window: Window, config: CaptureConfig) -> Result<Self, CaptureError> {
        let title = window.title().to_string();
        let app_name = window.app_name().to_string();
        let name = if title.is_empty() {
            app_name.clone()
        } else {
            format!("{} - {}", title, app_name)
        };
        let width = window.width();
        let height = window.height();
        let id = format!("window:{}", window.id());

        // Generate thumbnail
        let thumbnail = Self::generate_window_thumbnail(&window)?;

        let frame_interval = Duration::from_secs_f64(1.0 / config.fps as f64);

        Ok(Self {
            source: ScreenSource {
                id,
                name,
                thumbnail,
                source_type: ScreenSourceType::Window,
                width,
                height,
                is_primary: false,
            },
            config,
            handle: RwLock::new(Some(SourceHandle::Window(window))),
            is_capturing: AtomicBool::new(false),
            frame_count: AtomicU64::new(0),
            last_capture_time: RwLock::new(Instant::now()),
            frame_interval,
        })
    }

    /// Create capturer from a ScreenSource (reconnects to source by ID)
    pub fn new(source: ScreenSource, config: CaptureConfig) -> Result<Self, CaptureError> {
        let frame_interval = Duration::from_secs_f64(1.0 / config.fps as f64);

        // Find and reconnect to the source
        let handle = match source.source_type {
            ScreenSourceType::Screen => {
                let monitor_id: u32 = source
                    .id
                    .strip_prefix("monitor:")
                    .and_then(|s| s.parse().ok())
                    .ok_or(CaptureError::SourceNotFound)?;

                let monitors =
                    Monitor::all().map_err(|e| CaptureError::InitFailed(e.to_string()))?;
                let monitor = monitors
                    .into_iter()
                    .find(|m| m.id() == monitor_id)
                    .ok_or(CaptureError::SourceNotFound)?;

                SourceHandle::Monitor(monitor)
            }
            ScreenSourceType::Window => {
                let window_id: u32 = source
                    .id
                    .strip_prefix("window:")
                    .and_then(|s| s.parse().ok())
                    .ok_or(CaptureError::SourceNotFound)?;

                let windows =
                    Window::all().map_err(|e| CaptureError::InitFailed(e.to_string()))?;
                let window = windows
                    .into_iter()
                    .find(|w| w.id() == window_id)
                    .ok_or(CaptureError::SourceNotFound)?;

                SourceHandle::Window(window)
            }
        };

        Ok(Self {
            source,
            config,
            handle: RwLock::new(Some(handle)),
            is_capturing: AtomicBool::new(false),
            frame_count: AtomicU64::new(0),
            last_capture_time: RwLock::new(Instant::now()),
            frame_interval,
        })
    }

    /// Get source info
    pub fn source(&self) -> &ScreenSource {
        &self.source
    }

    /// Start capturing frames
    pub fn start(&self) -> Result<(), CaptureError> {
        info!("Starting screen capture for source: {}", self.source.name);

        // Verify we have a valid handle
        if self.handle.read().is_none() {
            return Err(CaptureError::SourceNotFound);
        }

        self.is_capturing.store(true, Ordering::SeqCst);
        self.frame_count.store(0, Ordering::SeqCst);
        *self.last_capture_time.write() = Instant::now();

        info!(
            "Screen capture started: {} ({}x{}) @ {} fps",
            self.source.name, self.source.width, self.source.height, self.config.fps
        );

        Ok(())
    }

    /// Stop capturing
    pub fn stop(&self) -> Result<(), CaptureError> {
        info!(
            "Stopping screen capture (captured {} frames)",
            self.frame_count.load(Ordering::SeqCst)
        );
        self.is_capturing.store(false, Ordering::SeqCst);
        Ok(())
    }

    /// Check if capturing
    pub fn is_capturing(&self) -> bool {
        self.is_capturing.load(Ordering::SeqCst)
    }

    /// Get frame count
    pub fn frame_count(&self) -> u64 {
        self.frame_count.load(Ordering::SeqCst)
    }

    /// Get the next captured frame (respects FPS limit)
    pub fn capture_frame(&self) -> Result<CapturedFrame, CaptureError> {
        if !self.is_capturing() {
            return Err(CaptureError::NotCapturing);
        }

        // Rate limiting
        let elapsed = self.last_capture_time.read().elapsed();
        if elapsed < self.frame_interval {
            std::thread::sleep(self.frame_interval - elapsed);
        }

        let handle_guard = self.handle.read();
        let handle = handle_guard.as_ref().ok_or(CaptureError::SourceNotFound)?;

        let frame = match handle {
            SourceHandle::Monitor(monitor) => self.capture_monitor_frame(monitor)?,
            SourceHandle::Window(window) => self.capture_window_frame(window)?,
        };

        self.frame_count.fetch_add(1, Ordering::SeqCst);
        *self.last_capture_time.write() = Instant::now();

        Ok(frame)
    }

    /// Capture a single frame from a monitor
    fn capture_monitor_frame(&self, monitor: &Monitor) -> Result<CapturedFrame, CaptureError> {
        let image = monitor
            .capture_image()
            .map_err(|e| CaptureError::CaptureFailed(e.to_string()))?;

        self.rgba_image_to_frame(image)
    }

    /// Capture a single frame from a window
    fn capture_window_frame(&self, window: &Window) -> Result<CapturedFrame, CaptureError> {
        let image = window
            .capture_image()
            .map_err(|e| CaptureError::CaptureFailed(e.to_string()))?;

        self.rgba_image_to_frame(image)
    }

    /// Convert RGBA image to CapturedFrame
    fn rgba_image_to_frame(&self, image: RgbaImage) -> Result<CapturedFrame, CaptureError> {
        let width = image.width();
        let height = image.height();

        // Optionally resize if config specifies dimensions
        let (final_width, final_height, data) =
            if self.config.width > 0 && self.config.height > 0 {
                let resized = image::imageops::resize(
                    &image,
                    self.config.width,
                    self.config.height,
                    image::imageops::FilterType::Triangle,
                );
                (self.config.width, self.config.height, resized.into_raw())
            } else {
                (width, height, image.into_raw())
            };

        let timestamp_ns = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_nanos() as u64;

        Ok(CapturedFrame {
            width: final_width,
            height: final_height,
            stride: final_width * 4,
            format: FrameFormat::Rgba,
            data,
            timestamp_ns,
        })
    }

    /// Generate thumbnail for a monitor
    fn generate_monitor_thumbnail(monitor: &Monitor) -> Result<Vec<u8>, CaptureError> {
        let image = monitor
            .capture_image()
            .map_err(|e| CaptureError::CaptureFailed(e.to_string()))?;

        Self::image_to_thumbnail(image)
    }

    /// Generate thumbnail for a window
    fn generate_window_thumbnail(window: &Window) -> Result<Vec<u8>, CaptureError> {
        let image = window
            .capture_image()
            .map_err(|e| CaptureError::CaptureFailed(e.to_string()))?;

        Self::image_to_thumbnail(image)
    }

    /// Convert image to thumbnail PNG bytes
    fn image_to_thumbnail(image: RgbaImage) -> Result<Vec<u8>, CaptureError> {
        let (width, height) = (image.width(), image.height());

        // Calculate thumbnail dimensions maintaining aspect ratio
        let (thumb_width, thumb_height) = if width > height {
            let ratio = THUMBNAIL_MAX_SIZE as f32 / width as f32;
            (THUMBNAIL_MAX_SIZE, (height as f32 * ratio) as u32)
        } else {
            let ratio = THUMBNAIL_MAX_SIZE as f32 / height as f32;
            ((width as f32 * ratio) as u32, THUMBNAIL_MAX_SIZE)
        };

        // Resize image
        let thumbnail = image::imageops::resize(
            &image,
            thumb_width,
            thumb_height,
            image::imageops::FilterType::Triangle,
        );

        // Encode to PNG
        let mut png_bytes = Vec::new();
        let encoder = PngEncoder::new(&mut png_bytes);
        encoder
            .write_image(
                &thumbnail,
                thumb_width,
                thumb_height,
                image::ExtendedColorType::Rgba8,
            )
            .map_err(|e| CaptureError::CaptureFailed(e.to_string()))?;

        Ok(png_bytes)
    }
}

/// Captured frame data
#[derive(Debug, Clone)]
pub struct CapturedFrame {
    /// Frame width in pixels
    pub width: u32,
    /// Frame height in pixels
    pub height: u32,
    /// Bytes per row (may include padding)
    pub stride: u32,
    /// Pixel format
    pub format: FrameFormat,
    /// Raw pixel data
    pub data: Vec<u8>,
    /// Capture timestamp in nanoseconds
    pub timestamp_ns: u64,
}

impl CapturedFrame {
    /// Convert frame to PNG bytes
    pub fn to_png(&self) -> Result<Vec<u8>, CaptureError> {
        if self.format != FrameFormat::Rgba {
            return Err(CaptureError::CaptureFailed(
                "Only RGBA format supported for PNG conversion".to_string(),
            ));
        }

        let mut png_bytes = Vec::new();
        let encoder = PngEncoder::new(&mut png_bytes);
        encoder
            .write_image(
                &self.data,
                self.width,
                self.height,
                image::ExtendedColorType::Rgba8,
            )
            .map_err(|e| CaptureError::CaptureFailed(e.to_string()))?;

        Ok(png_bytes)
    }

    /// Convert RGBA to BGRA (common format for video encoding)
    pub fn to_bgra(&self) -> Vec<u8> {
        if self.format == FrameFormat::Bgra {
            return self.data.clone();
        }

        let mut bgra = self.data.clone();
        for chunk in bgra.chunks_exact_mut(4) {
            chunk.swap(0, 2); // Swap R and B
        }
        bgra
    }

    /// Convert to I420 (YUV 4:2:0) for video encoding
    pub fn to_i420(&self) -> Vec<u8> {
        let width = self.width as usize;
        let height = self.height as usize;

        // I420 layout: Y plane (full), U plane (quarter), V plane (quarter)
        let y_size = width * height;
        let uv_size = (width / 2) * (height / 2);
        let mut yuv = vec![0u8; y_size + 2 * uv_size];

        let (y_plane, uv_planes) = yuv.split_at_mut(y_size);
        let (u_plane, v_plane) = uv_planes.split_at_mut(uv_size);

        // Convert RGBA to YUV
        for y in 0..height {
            for x in 0..width {
                let idx = (y * width + x) * 4;
                let r = self.data[idx] as f32;
                let g = self.data[idx + 1] as f32;
                let b = self.data[idx + 2] as f32;

                // BT.601 conversion
                let y_val = 16.0 + 65.481 * r / 255.0 + 128.553 * g / 255.0 + 24.966 * b / 255.0;
                y_plane[y * width + x] = y_val.clamp(0.0, 255.0) as u8;

                // Subsample U and V (average 2x2 blocks)
                if y % 2 == 0 && x % 2 == 0 {
                    let u_idx = (y / 2) * (width / 2) + (x / 2);
                    let v_idx = u_idx;

                    let u_val =
                        128.0 - 37.797 * r / 255.0 - 74.203 * g / 255.0 + 112.0 * b / 255.0;
                    let v_val =
                        128.0 + 112.0 * r / 255.0 - 93.786 * g / 255.0 - 18.214 * b / 255.0;

                    u_plane[u_idx] = u_val.clamp(0.0, 255.0) as u8;
                    v_plane[v_idx] = v_val.clamp(0.0, 255.0) as u8;
                }
            }
        }

        yuv
    }
}

/// Pixel formats for captured frames
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum FrameFormat {
    /// Blue-Green-Red-Alpha (common on Windows)
    Bgra,
    /// Red-Green-Blue-Alpha (xcap native format)
    Rgba,
    /// YUV 4:2:0 (for video encoding)
    I420,
    /// NV12 (common hardware encoder format)
    Nv12,
}

/// Screen capture errors
#[derive(Debug, thiserror::Error)]
pub enum CaptureError {
    #[error("Screen capture is not supported on this platform")]
    UnsupportedPlatform,

    #[error("No display server detected")]
    NoDisplayServer,

    #[error("Permission denied for screen capture")]
    PermissionDenied,

    #[error("Source not found")]
    SourceNotFound,

    #[error("Capture not started")]
    NotCapturing,

    #[error("Capture failed: {0}")]
    CaptureFailed(String),

    #[error("Initialization failed: {0}")]
    InitFailed(String),
}

/// Enumerate available screen sources (monitors)
pub fn enumerate_monitors() -> Result<Vec<ScreenSource>, CaptureError> {
    info!("Enumerating available monitors");

    let monitors = Monitor::all().map_err(|e| CaptureError::InitFailed(e.to_string()))?;

    let mut sources = Vec::with_capacity(monitors.len());

    for monitor in monitors {
        let name = monitor.name().to_string();
        let width = monitor.width();
        let height = monitor.height();
        let is_primary = monitor.is_primary();
        let id = format!("monitor:{}", monitor.id());

        // Try to generate thumbnail, use empty if fails
        let thumbnail = ScreenCapturer::generate_monitor_thumbnail(&monitor).unwrap_or_default();

        debug!(
            "Found monitor: {} ({}x{}) primary={}",
            name, width, height, is_primary
        );

        sources.push(ScreenSource {
            id,
            name,
            thumbnail,
            source_type: ScreenSourceType::Screen,
            width,
            height,
            is_primary,
        });
    }

    info!("Found {} monitors", sources.len());
    Ok(sources)
}

/// Enumerate available windows
pub fn enumerate_windows() -> Result<Vec<ScreenSource>, CaptureError> {
    info!("Enumerating available windows");

    let windows = Window::all().map_err(|e| CaptureError::InitFailed(e.to_string()))?;

    let mut sources = Vec::with_capacity(windows.len());

    for window in windows {
        let title = window.title().to_string();
        let app_name = window.app_name().to_string();

        // Skip windows with no title or very small windows
        if title.is_empty() && app_name.is_empty() {
            continue;
        }

        let width = window.width();
        let height = window.height();

        // Skip very small or hidden windows
        if width < 100 || height < 100 {
            continue;
        }

        let name = if title.is_empty() {
            app_name.clone()
        } else {
            format!("{} - {}", title, app_name)
        };

        let id = format!("window:{}", window.id());

        // Try to generate thumbnail, use empty if fails
        let thumbnail = ScreenCapturer::generate_window_thumbnail(&window).unwrap_or_default();

        debug!("Found window: {} ({}x{})", name, width, height);

        sources.push(ScreenSource {
            id,
            name,
            thumbnail,
            source_type: ScreenSourceType::Window,
            width,
            height,
            is_primary: false,
        });
    }

    info!("Found {} windows", sources.len());
    Ok(sources)
}

/// Enumerate all available sources (monitors + windows)
pub fn enumerate_sources() -> Result<Vec<ScreenSource>, CaptureError> {
    let mut sources = enumerate_monitors()?;
    match enumerate_windows() {
        Ok(windows) => sources.extend(windows),
        Err(e) => {
            // Log warning but continue with just monitors
            info!("Could not enumerate windows (continuing with monitors only): {}", e);
        }
    }
    Ok(sources)
}

/// Get the primary monitor
pub fn get_primary_monitor() -> Result<ScreenSource, CaptureError> {
    let monitors = enumerate_monitors()?;
    monitors
        .into_iter()
        .find(|m| m.is_primary)
        .ok_or(CaptureError::SourceNotFound)
}

/// Create a capturer for a specific source ID
pub fn create_capturer(
    source_id: &str,
    config: CaptureConfig,
) -> Result<ScreenCapturer, CaptureError> {
    info!("Creating capturer for source: {}", source_id);

    if source_id.starts_with("monitor:") {
        let monitor_id: u32 = source_id
            .strip_prefix("monitor:")
            .and_then(|s| s.parse().ok())
            .ok_or(CaptureError::SourceNotFound)?;

        let monitors = Monitor::all().map_err(|e| CaptureError::InitFailed(e.to_string()))?;
        let monitor = monitors
            .into_iter()
            .find(|m| m.id() == monitor_id)
            .ok_or(CaptureError::SourceNotFound)?;

        ScreenCapturer::from_monitor(monitor, config)
    } else if source_id.starts_with("window:") {
        let window_id: u32 = source_id
            .strip_prefix("window:")
            .and_then(|s| s.parse().ok())
            .ok_or(CaptureError::SourceNotFound)?;

        let windows = Window::all().map_err(|e| CaptureError::InitFailed(e.to_string()))?;
        let window = windows
            .into_iter()
            .find(|w| w.id() == window_id)
            .ok_or(CaptureError::SourceNotFound)?;

        ScreenCapturer::from_window(window, config)
    } else {
        Err(CaptureError::SourceNotFound)
    }
}

/// Check if screen capture is available on this platform
pub fn is_available() -> bool {
    // Try to enumerate monitors
    Monitor::all().is_ok()
}

/// Get platform-specific permissions info
pub fn get_permissions_info() -> &'static str {
    #[cfg(target_os = "macos")]
    {
        "Screen Recording permission required. Go to System Preferences > Security & Privacy > Privacy > Screen Recording and enable for this app."
    }

    #[cfg(target_os = "linux")]
    {
        "Screen capture uses PipeWire on Wayland or X11. On Wayland, you may see a system dialog to select a screen to share."
    }

    #[cfg(target_os = "windows")]
    {
        "Screen capture uses DXGI Desktop Duplication API. No additional permissions required."
    }

    #[cfg(not(any(target_os = "linux", target_os = "macos", target_os = "windows")))]
    {
        "Screen capture is not supported on this platform."
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_capture_config() {
        let config = CaptureConfig::default();
        assert_eq!(config.fps, 30);
        assert_eq!(config.width, 0);
        assert_eq!(config.height, 0);
        assert!(config.capture_cursor);
        assert!(!config.capture_audio);
    }

    #[test]
    fn test_frame_format_equality() {
        assert_eq!(FrameFormat::Rgba, FrameFormat::Rgba);
        assert_ne!(FrameFormat::Rgba, FrameFormat::Bgra);
    }

    #[test]
    fn test_screen_source_type() {
        assert_eq!(ScreenSourceType::Screen, ScreenSourceType::Screen);
        assert_ne!(ScreenSourceType::Screen, ScreenSourceType::Window);
    }

    #[test]
    fn test_is_available() {
        // Should not panic
        let _ = is_available();
    }

    #[test]
    fn test_get_permissions_info() {
        let info = get_permissions_info();
        assert!(!info.is_empty());
    }

    #[test]
    fn test_enumerate_monitors() {
        // May fail in CI without display, but should not panic
        let result = enumerate_monitors();
        match result {
            Ok(monitors) => {
                println!("Found {} monitors", monitors.len());
                for m in &monitors {
                    println!(
                        "  - {} ({}x{}) primary={}",
                        m.name, m.width, m.height, m.is_primary
                    );
                }
            }
            Err(e) => {
                println!("Could not enumerate monitors: {}", e);
                // This is OK in CI environment
            }
        }
    }

    #[test]
    fn test_enumerate_sources() {
        let result = enumerate_sources();
        match result {
            Ok(sources) => {
                println!("Found {} sources", sources.len());
            }
            Err(e) => {
                println!("Could not enumerate sources: {}", e);
            }
        }
    }

    #[test]
    fn test_captured_frame_to_bgra() {
        let frame = CapturedFrame {
            width: 2,
            height: 2,
            stride: 8,
            format: FrameFormat::Rgba,
            data: vec![
                255, 0, 0, 255, // Red pixel
                0, 255, 0, 255, // Green pixel
                0, 0, 255, 255, // Blue pixel
                255, 255, 255, 255, // White pixel
            ],
            timestamp_ns: 0,
        };

        let bgra = frame.to_bgra();

        // Check first pixel (was RGBA Red, now BGRA)
        assert_eq!(bgra[0], 0); // B (was R)
        assert_eq!(bgra[1], 0); // G (unchanged)
        assert_eq!(bgra[2], 255); // R (was B)
        assert_eq!(bgra[3], 255); // A (unchanged)
    }

    #[test]
    fn test_captured_frame_to_i420() {
        let frame = CapturedFrame {
            width: 4,
            height: 4,
            stride: 16,
            format: FrameFormat::Rgba,
            data: vec![128u8; 4 * 4 * 4], // 4x4 gray image
            timestamp_ns: 0,
        };

        let yuv = frame.to_i420();

        // I420 size: Y (16) + U (4) + V (4) = 24
        assert_eq!(yuv.len(), 24);
    }
}
