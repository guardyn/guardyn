//! Download Commands
//!
//! Handles file downloads with progress tracking and system integration.

use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use tauri::{AppHandle, Emitter, State};
use tokio::io::AsyncWriteExt;

use crate::state::AppState;

/// Result of a completed download
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DownloadResult {
    pub file_size: u64,
    pub saved_path: String,
}

/// Progress update for an active download
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DownloadProgress {
    pub download_id: String,
    pub bytes_downloaded: u64,
    pub total_bytes: u64,
}

/// Download a file from a URL with progress tracking
#[tauri::command]
pub async fn download_file(
    url: String,
    destination_path: Option<String>,
    file_name: String,
    app: AppHandle,
    _state: State<'_, AppState>,
) -> Result<DownloadResult, String> {
    // Determine the save path
    let save_path = if let Some(dest) = destination_path {
        PathBuf::from(dest)
    } else {
        // Default to downloads directory
        let downloads_dir = dirs::download_dir()
            .ok_or_else(|| "Could not determine downloads directory".to_string())?;
        downloads_dir.join(&file_name)
    };

    // Ensure parent directory exists
    if let Some(parent) = save_path.parent() {
        tokio::fs::create_dir_all(parent)
            .await
            .map_err(|e| format!("Failed to create directory: {}", e))?;
    }

    // Generate a download ID for progress tracking
    let download_id = uuid::Uuid::new_v4().to_string();

    // Start the download
    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .send()
        .await
        .map_err(|e| format!("Failed to start download: {}", e))?;

    // Check if the request was successful
    if !response.status().is_success() {
        return Err(format!("Download failed with status: {}", response.status()));
    }

    // Get content length if available
    let total_bytes = response.content_length().unwrap_or(0);

    // Create the file
    let mut file = tokio::fs::File::create(&save_path)
        .await
        .map_err(|e| format!("Failed to create file: {}", e))?;

    // Stream the download with progress updates
    let mut bytes_downloaded: u64 = 0;
    let mut stream = response.bytes_stream();

    use futures_util::StreamExt;

    while let Some(chunk_result) = stream.next().await {
        let chunk = chunk_result.map_err(|e| format!("Download stream error: {}", e))?;

        file.write_all(&chunk)
            .await
            .map_err(|e| format!("Failed to write to file: {}", e))?;

        bytes_downloaded += chunk.len() as u64;

        // Emit progress event
        let _ = app.emit(
            "download-progress",
            DownloadProgress {
                download_id: download_id.clone(),
                bytes_downloaded,
                total_bytes,
            },
        );
    }

    // Ensure all data is flushed
    file.flush()
        .await
        .map_err(|e| format!("Failed to flush file: {}", e))?;

    Ok(DownloadResult {
        file_size: bytes_downloaded,
        saved_path: save_path.to_string_lossy().to_string(),
    })
}

/// Cancel an active download
/// Note: This is a placeholder - actual cancellation would require
/// storing download handles in the app state
#[tauri::command]
pub async fn cancel_download(_download_id: String) -> Result<(), String> {
    // In a full implementation, we would:
    // 1. Store download handles in AppState
    // 2. Look up the handle by download_id
    // 3. Cancel the download task
    Ok(())
}

/// Open a file with the system's default application
#[tauri::command]
pub async fn open_file_with_default_app(file_path: String) -> Result<(), String> {
    let path = PathBuf::from(&file_path);

    if !path.exists() {
        return Err("File does not exist".to_string());
    }

    #[cfg(target_os = "windows")]
    {
        std::process::Command::new("cmd")
            .args(["/C", "start", "", &file_path])
            .spawn()
            .map_err(|e| format!("Failed to open file: {}", e))?;
    }

    #[cfg(target_os = "macos")]
    {
        std::process::Command::new("open")
            .arg(&file_path)
            .spawn()
            .map_err(|e| format!("Failed to open file: {}", e))?;
    }

    #[cfg(target_os = "linux")]
    {
        std::process::Command::new("xdg-open")
            .arg(&file_path)
            .spawn()
            .map_err(|e| format!("Failed to open file: {}", e))?;
    }

    Ok(())
}

/// Show a file in the system file manager
#[tauri::command]
pub async fn show_in_folder(file_path: String) -> Result<(), String> {
    let path = PathBuf::from(&file_path);

    if !path.exists() {
        return Err("File does not exist".to_string());
    }

    #[cfg(target_os = "windows")]
    {
        std::process::Command::new("explorer")
            .args(["/select,", &file_path])
            .spawn()
            .map_err(|e| format!("Failed to show in folder: {}", e))?;
    }

    #[cfg(target_os = "macos")]
    {
        std::process::Command::new("open")
            .args(["-R", &file_path])
            .spawn()
            .map_err(|e| format!("Failed to show in folder: {}", e))?;
    }

    #[cfg(target_os = "linux")]
    {
        // Try to select the file in the file manager
        // This works with most file managers that support DBus
        if let Some(parent) = path.parent() {
            std::process::Command::new("xdg-open")
                .arg(parent)
                .spawn()
                .map_err(|e| format!("Failed to show in folder: {}", e))?;
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_download_result_serialization() {
        let result = DownloadResult {
            file_size: 1024,
            saved_path: "/tmp/test.txt".to_string(),
        };

        let json = serde_json::to_string(&result).unwrap();
        assert!(json.contains("file_size"));
        assert!(json.contains("saved_path"));
    }

    #[test]
    fn test_download_progress_serialization() {
        let progress = DownloadProgress {
            download_id: "test-123".to_string(),
            bytes_downloaded: 512,
            total_bytes: 1024,
        };

        let json = serde_json::to_string(&progress).unwrap();
        assert!(json.contains("download_id"));
        assert!(json.contains("bytes_downloaded"));
    }
}
