/// Database client for FoundationDB
///
/// Handles all database operations for the auth service:
/// - User profile storage
/// - Device management
/// - Session tracking
/// - Key bundle storage

use anyhow::{Result, Context};
use foundationdb::{Database, FdbError};
use serde::{Deserialize, Serialize};
use std::sync::Arc;

/// User profile stored in FoundationDB
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
    db: Arc<Database>,
}

impl DatabaseClient {
    /// Create new database client
    pub async fn new(cluster_file: &str) -> Result<Self> {
        let network = unsafe {
            foundationdb::boot().context("Failed to initialize FoundationDB")?
        };
        
        let db = Database::new(Some(cluster_file))
            .context("Failed to open FoundationDB")?;
        
        Ok(Self {
            db: Arc::new(db),
        })
    }

    /// Check if username exists
    pub async fn username_exists(&self, username: &str) -> Result<bool> {
        let trx = self.db.create_trx()?;
        let key = format!("/users/username/{}", username);
        
        match trx.get(key.as_bytes(), false).await {
            Ok(Some(_)) => Ok(true),
            Ok(None) => Ok(false),
            Err(e) => Err(e.into()),
        }
    }

    /// Create new user
    pub async fn create_user(&self, profile: &UserProfile) -> Result<()> {
        let trx = self.db.create_trx()?;
        
        // Store user profile
        let profile_key = format!("/users/{}/profile", profile.user_id);
        let profile_value = serde_json::to_vec(profile)?;
        trx.set(profile_key.as_bytes(), &profile_value);
        
        // Store username -> user_id mapping
        let username_key = format!("/users/username/{}", profile.username);
        trx.set(username_key.as_bytes(), profile.user_id.as_bytes());
        
        trx.commit().await?;
        Ok(())
    }

    /// Get user by username
    pub async fn get_user_by_username(&self, username: &str) -> Result<Option<UserProfile>> {
        let trx = self.db.create_trx()?;
        
        // Get user_id from username
        let username_key = format!("/users/username/{}", username);
        let user_id = match trx.get(username_key.as_bytes(), false).await? {
            Some(data) => String::from_utf8(data.to_vec())?,
            None => return Ok(None),
        };
        
        // Get user profile
        let profile_key = format!("/users/{}/profile", user_id);
        let profile_data = match trx.get(profile_key.as_bytes(), false).await? {
            Some(data) => data,
            None => return Ok(None),
        };
        
        let profile: UserProfile = serde_json::from_slice(&profile_data)?;
        Ok(Some(profile))
    }

    /// Get user by ID
    pub async fn get_user_by_id(&self, user_id: &str) -> Result<Option<UserProfile>> {
        let trx = self.db.create_trx()?;
        let profile_key = format!("/users/{}/profile", user_id);
        
        let profile_data = match trx.get(profile_key.as_bytes(), false).await? {
            Some(data) => data,
            None => return Ok(None),
        };
        
        let profile: UserProfile = serde_json::from_slice(&profile_data)?;
        Ok(Some(profile))
    }

    /// Store device
    pub async fn create_device(&self, device: &Device) -> Result<()> {
        let trx = self.db.create_trx()?;
        let key = format!("/devices/{}/{}", device.user_id, device.device_id);
        let value = serde_json::to_vec(device)?;
        trx.set(key.as_bytes(), &value);
        trx.commit().await?;
        Ok(())
    }

    /// Get device
    pub async fn get_device(&self, user_id: &str, device_id: &str) -> Result<Option<Device>> {
        let trx = self.db.create_trx()?;
        let key = format!("/devices/{}/{}", user_id, device_id);
        
        let device_data = match trx.get(key.as_bytes(), false).await? {
            Some(data) => data,
            None => return Ok(None),
        };
        
        let device: Device = serde_json::from_slice(&device_data)?;
        Ok(Some(device))
    }

    /// Create session
    pub async fn create_session(&self, session: &Session) -> Result<()> {
        let trx = self.db.create_trx()?;
        
        // Store session by token
        let token_key = format!("/sessions/{}", session.session_token);
        let session_value = serde_json::to_vec(session)?;
        trx.set(token_key.as_bytes(), &session_value);
        
        // Store session in user index
        let user_key = format!("/sessions/user/{}/{}", session.user_id, session.session_token);
        trx.set(user_key.as_bytes(), &session_value);
        
        trx.commit().await?;
        Ok(())
    }

    /// Get session by token
    pub async fn get_session(&self, token: &str) -> Result<Option<Session>> {
        let trx = self.db.create_trx()?;
        let key = format!("/sessions/{}", token);
        
        let session_data = match trx.get(key.as_bytes(), false).await? {
            Some(data) => data,
            None => return Ok(None),
        };
        
        let session: Session = serde_json::from_slice(&session_data)?;
        Ok(Some(session))
    }

    /// Delete session
    pub async fn delete_session(&self, token: &str) -> Result<()> {
        let trx = self.db.create_trx()?;
        
        // Get session to find user_id
        let session = match self.get_session(token).await? {
            Some(s) => s,
            None => return Ok(()), // Already deleted
        };
        
        // Delete from both indexes
        let token_key = format!("/sessions/{}", token);
        trx.clear(token_key.as_bytes());
        
        let user_key = format!("/sessions/user/{}/{}", session.user_id, token);
        trx.clear(user_key.as_bytes());
        
        trx.commit().await?;
        Ok(())
    }

    /// Store key bundle
    pub async fn store_key_bundle(
        &self,
        user_id: &str,
        device_id: &str,
        key_bundle: &KeyBundle,
    ) -> Result<()> {
        let trx = self.db.create_trx()?;
        
        // Store identity key
        let identity_key = format!("/users/{}/identity_key", user_id);
        trx.set(identity_key.as_bytes(), &key_bundle.identity_key);
        
        // Store signed pre-key
        let signed_pre_key_path = format!("/devices/{}/{}/signed_pre_key", user_id, device_id);
        trx.set(signed_pre_key_path.as_bytes(), &key_bundle.signed_pre_key);
        
        // Store signature
        let sig_path = format!("/devices/{}/{}/signed_pre_key_signature", user_id, device_id);
        trx.set(sig_path.as_bytes(), &key_bundle.signed_pre_key_signature);
        
        // Store one-time pre-keys
        for (i, otk) in key_bundle.one_time_pre_keys.iter().enumerate() {
            let otk_path = format!("/devices/{}/{}/one_time_keys/{}", user_id, device_id, i);
            trx.set(otk_path.as_bytes(), otk);
        }
        
        trx.commit().await?;
        Ok(())
    }

    /// Get key bundle
    pub async fn get_key_bundle(
        &self,
        user_id: &str,
        device_id: &str,
    ) -> Result<Option<KeyBundle>> {
        let trx = self.db.create_trx()?;
        
        // Get identity key
        let identity_key_path = format!("/users/{}/identity_key", user_id);
        let identity_key = match trx.get(identity_key_path.as_bytes(), false).await? {
            Some(data) => data.to_vec(),
            None => return Ok(None),
        };
        
        // Get signed pre-key
        let signed_pre_key_path = format!("/devices/{}/{}/signed_pre_key", user_id, device_id);
        let signed_pre_key = match trx.get(signed_pre_key_path.as_bytes(), false).await? {
            Some(data) => data.to_vec(),
            None => return Ok(None),
        };
        
        // Get signature
        let sig_path = format!("/devices/{}/{}/signed_pre_key_signature", user_id, device_id);
        let signature = match trx.get(sig_path.as_bytes(), false).await? {
            Some(data) => data.to_vec(),
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
