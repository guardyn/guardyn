/// Database client for TiKV
///
/// Handles all database operations for the auth service:
/// - User profile storage
/// - Device management
/// - Session tracking
/// - Key bundle storage

use anyhow::{Result, Context};
use tikv_client::{RawClient, Error as TikvError};
use serde::{Deserialize, Serialize};
use std::sync::Arc;

/// User profile stored in TiKV
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserProfile {
    pub user_id: String,
    pub username: String,
    pub email: Option<String>,
    pub password_hash: String,
    pub created_at: i64,
    pub last_seen: i64,
}

/// Device information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Device {
    pub device_id: String,
    pub user_id: String,
    pub device_name: String,
    pub device_type: String,
    pub created_at: i64,
    pub last_seen: i64,
}

/// Session information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Session {
    pub session_token: String,
    pub user_id: String,
    pub device_id: String,
    pub created_at: i64,
    pub expires_at: i64,
}

/// Key bundle for E2EE
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KeyBundle {
    pub identity_key: Vec<u8>,
    pub signed_pre_key: Vec<u8>,
    pub signed_pre_key_signature: Vec<u8>,
    pub one_time_pre_keys: Vec<Vec<u8>>,
    pub created_at: i64,
}

/// Database client
#[derive(Clone)]
pub struct DatabaseClient {
    client: Arc<RawClient>,
}

impl DatabaseClient {
    /// Create new database client
    pub async fn new(pd_endpoints: Vec<String>) -> Result<Self> {
        let client = RawClient::new(pd_endpoints)
            .await
            .context("Failed to connect to TiKV")?;
        
        Ok(Self {
            client: Arc::new(client),
        })
    }

    /// Check if username exists
    pub async fn username_exists(&self, username: &str) -> Result<bool> {
        let key = format!("/users/username/{}", username).into_bytes();
        
        match self.client.get(key).await {
            Ok(Some(_)) => Ok(true),
            Ok(None) => Ok(false),
            Err(e) => Err(e.into()),
        }
    }

    /// Create new user
    pub async fn create_user(&self, profile: &UserProfile) -> Result<()> {
        // Store user profile
        let profile_key = format!("/users/{}/profile", profile.user_id).into_bytes();
        let profile_value = serde_json::to_vec(profile)?;
        self.client.put(profile_key.clone(), profile_value).await?;
        
        // Store username -> user_id mapping
        let username_key = format!("/users/username/{}", profile.username).into_bytes();
        self.client.put(username_key, profile.user_id.as_bytes().to_vec()).await?;
        
        Ok(())
    }

    /// Get user by username
    pub async fn get_user_by_username(&self, username: &str) -> Result<Option<UserProfile>> {
        // Get user_id from username
        let username_key = format!("/users/username/{}", username).into_bytes();
        let user_id = match self.client.get(username_key).await? {
            Some(data) => String::from_utf8(data)?,
            None => return Ok(None),
        };
        
        // Get user profile
        let profile_key = format!("/users/{}/profile", user_id).into_bytes();
        let profile_data = match self.client.get(profile_key).await? {
            Some(data) => data,
            None => return Ok(None),
        };
        
        let profile: UserProfile = serde_json::from_slice(&profile_data)?;
        Ok(Some(profile))
    }

    /// Get user by ID
    pub async fn get_user_by_id(&self, user_id: &str) -> Result<Option<UserProfile>> {
        let profile_key = format!("/users/{}/profile", user_id).into_bytes();
        
        let profile_data = match self.client.get(profile_key).await? {
            Some(data) => data,
            None => return Ok(None),
        };
        
        let profile: UserProfile = serde_json::from_slice(&profile_data)?;
        Ok(Some(profile))
    }

    /// Store device
    pub async fn create_device(&self, device: &Device) -> Result<()> {
        let key = format!("/devices/{}/{}", device.user_id, device.device_id).into_bytes();
        let value = serde_json::to_vec(device)?;
        self.client.put(key, value).await?;
        Ok(())
    }

    /// Get device
    pub async fn get_device(&self, user_id: &str, device_id: &str) -> Result<Option<Device>> {
        let key = format!("/devices/{}/{}", user_id, device_id).into_bytes();
        
        let device_data = match self.client.get(key).await? {
            Some(data) => data,
            None => return Ok(None),
        };
        
        let device: Device = serde_json::from_slice(&device_data)?;
        Ok(Some(device))
    }

    /// Create session
    pub async fn create_session(&self, session: &Session) -> Result<()> {
        // Store session by token
        let token_key = format!("/sessions/{}", session.session_token).into_bytes();
        let session_value = serde_json::to_vec(session)?;
        self.client.put(token_key, session_value.clone()).await?;
        
        // Store session in user index
        let user_key = format!("/sessions/user/{}/{}", session.user_id, session.session_token).into_bytes();
        self.client.put(user_key, session_value).await?;
        
        Ok(())
    }

    /// Get session by token
    pub async fn get_session(&self, token: &str) -> Result<Option<Session>> {
        let key = format!("/sessions/{}", token).into_bytes();
        
        let session_data = match self.client.get(key).await? {
            Some(data) => data,
            None => return Ok(None),
        };
        
        let session: Session = serde_json::from_slice(&session_data)?;
        Ok(Some(session))
    }

    /// Delete session
    pub async fn delete_session(&self, token: &str) -> Result<()> {
        // Get session to find user_id
        let session = match self.get_session(token).await? {
            Some(s) => s,
            None => return Ok(()), // Already deleted
        };
        
        // Delete from both indexes
        let token_key = format!("/sessions/{}", token).into_bytes();
        self.client.delete(token_key).await?;
        
        let user_key = format!("/sessions/user/{}/{}", session.user_id, token).into_bytes();
        self.client.delete(user_key).await?;
        
        Ok(())
    }

    /// Store key bundle
    pub async fn store_key_bundle(
        &self,
        user_id: &str,
        device_id: &str,
        key_bundle: &KeyBundle,
    ) -> Result<()> {
        // Store identity key
        let identity_key = format!("/users/{}/identity_key", user_id).into_bytes();
        self.client.put(identity_key, key_bundle.identity_key.clone()).await?;
        
        // Store signed pre-key
        let signed_pre_key_path = format!("/devices/{}/{}/signed_pre_key", user_id, device_id).into_bytes();
        self.client.put(signed_pre_key_path, key_bundle.signed_pre_key.clone()).await?;
        
        // Store signature
        let sig_path = format!("/devices/{}/{}/signed_pre_key_signature", user_id, device_id).into_bytes();
        self.client.put(sig_path, key_bundle.signed_pre_key_signature.clone()).await?;
        
        // Store one-time pre-keys
        for (i, otk) in key_bundle.one_time_pre_keys.iter().enumerate() {
            let otk_path = format!("/devices/{}/{}/one_time_keys/{}", user_id, device_id, i).into_bytes();
            self.client.put(otk_path, otk.clone()).await?;
        }
        
        Ok(())
    }

    /// Get key bundle
    pub async fn get_key_bundle(
        &self,
        user_id: &str,
        device_id: &str,
    ) -> Result<Option<KeyBundle>> {
        // Get identity key
        let identity_key_path = format!("/users/{}/identity_key", user_id).into_bytes();
        let identity_key = match self.client.get(identity_key_path).await? {
            Some(data) => data,
            None => return Ok(None),
        };
        
        // Get signed pre-key
        let signed_pre_key_path = format!("/devices/{}/{}/signed_pre_key", user_id, device_id).into_bytes();
        let signed_pre_key = match self.client.get(signed_pre_key_path).await? {
            Some(data) => data,
            None => return Ok(None),
        };
        
        // Get signature
        let sig_path = format!("/devices/{}/{}/signed_pre_key_signature", user_id, device_id).into_bytes();
        let signature = match self.client.get(sig_path).await? {
            Some(data) => data,
            None => return Ok(None),
        };
        
        // TODO: Get one-time pre-keys (implement range scan)
        let one_time_pre_keys = vec![];
        
        Ok(Some(KeyBundle {
            identity_key,
            signed_pre_key,
            signed_pre_key_signature: signature,
            one_time_pre_keys,
            created_at: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs() as i64,
        }))
    }
}
