//! Secure Storage Module
//!
//! Provides secure, persistent storage for cryptographic keys using platform-native
//! credential managers:
//! - Linux: Secret Service API (GNOME Keyring, KWallet)
//! - macOS: Keychain
//! - Windows: Credential Manager
//!
//! All sensitive data is encrypted at rest by the OS credential manager.

use keyring::Entry;
use serde::{de::DeserializeOwned, Serialize};
use std::sync::LazyLock;
use thiserror::Error;
use tracing::{debug, error, info, warn};

/// Service name used in the system keyring
const SERVICE_NAME: &str = "com.guardyn.desktop";

/// Key names for different stored secrets
const KEY_IDENTITY_KEYPAIR: &str = "identity_keypair";
const KEY_SIGNED_PREKEY: &str = "signed_prekey";
const KEY_ONE_TIME_PREKEYS: &str = "one_time_prekeys";
const KEY_SESSIONS: &str = "sessions";

/// Errors that can occur during secure storage operations
#[derive(Error, Debug)]
pub enum SecureStorageError {
    #[error("Keyring error: {0}")]
    Keyring(#[from] keyring::Error),

    #[error("Serialization error: {0}")]
    Serialization(#[from] serde_json::Error),

    #[error("Key not found: {0}")]
    NotFound(String),

    #[error("Storage not available on this platform")]
    NotAvailable,
}

pub type Result<T> = std::result::Result<T, SecureStorageError>;

/// Secure storage manager using platform keyring
pub struct SecureStorage {
    service: String,
    user_id: String,
}

/// Global secure storage instance (default user)
static DEFAULT_STORAGE: LazyLock<SecureStorage> = LazyLock::new(|| {
    SecureStorage::new("default".to_string())
});

impl SecureStorage {
    /// Create a new secure storage instance for a specific user
    pub fn new(user_id: String) -> Self {
        Self {
            service: SERVICE_NAME.to_string(),
            user_id,
        }
    }

    /// Get the default storage instance
    pub fn default_instance() -> &'static SecureStorage {
        &DEFAULT_STORAGE
    }

    /// Generate the full key name including user context
    fn key_name(&self, key: &str) -> String {
        format!("{}:{}", self.user_id, key)
    }

    /// Create a keyring entry for a given key
    fn entry(&self, key: &str) -> Result<Entry> {
        let full_key = self.key_name(key);
        Entry::new(&self.service, &full_key).map_err(SecureStorageError::from)
    }

    /// Store a serializable value securely
    pub fn store<T: Serialize + ?Sized>(&self, key: &str, value: &T) -> Result<()> {
        let json = serde_json::to_string(value)?;
        let entry = self.entry(key)?;

        entry.set_password(&json).map_err(|e| {
            error!("Failed to store {} in keyring: {}", key, e);
            SecureStorageError::from(e)
        })?;

        debug!("Stored {} in secure storage", key);
        Ok(())
    }

    /// Retrieve a value from secure storage
    pub fn retrieve<T: DeserializeOwned>(&self, key: &str) -> Result<T> {
        let entry = self.entry(key)?;

        match entry.get_password() {
            Ok(json) => {
                let value = serde_json::from_str(&json)?;
                debug!("Retrieved {} from secure storage", key);
                Ok(value)
            }
            Err(keyring::Error::NoEntry) => {
                Err(SecureStorageError::NotFound(key.to_string()))
            }
            Err(e) => {
                error!("Failed to retrieve {} from keyring: {}", key, e);
                Err(SecureStorageError::from(e))
            }
        }
    }

    /// Delete a value from secure storage
    pub fn delete(&self, key: &str) -> Result<()> {
        let entry = self.entry(key)?;

        match entry.delete_credential() {
            Ok(()) => {
                debug!("Deleted {} from secure storage", key);
                Ok(())
            }
            Err(keyring::Error::NoEntry) => {
                // Already deleted, not an error
                Ok(())
            }
            Err(e) => {
                warn!("Failed to delete {} from keyring: {}", key, e);
                Err(SecureStorageError::from(e))
            }
        }
    }

    /// Check if a key exists in secure storage
    pub fn exists(&self, key: &str) -> bool {
        match self.entry(key) {
            Ok(entry) => entry.get_password().is_ok(),
            Err(_) => false,
        }
    }

    /// Clear all stored data for this user
    pub fn clear_all(&self) -> Result<()> {
        info!("Clearing all secure storage for user: {}", self.user_id);

        // List of all known keys to clear
        let keys = [
            KEY_IDENTITY_KEYPAIR,
            KEY_SIGNED_PREKEY,
            KEY_ONE_TIME_PREKEYS,
            KEY_SESSIONS,
        ];

        for key in keys {
            if let Err(e) = self.delete(key) {
                warn!("Failed to delete {}: {}", key, e);
                // Continue with other keys even if one fails
            }
        }

        info!("Secure storage cleared");
        Ok(())
    }
}

// =============================================================================
// SPECIALIZED STORAGE FUNCTIONS
// =============================================================================

use crate::commands::crypto::{IdentityKeyData, PreKeyData, SessionData};
use std::collections::HashMap;

impl SecureStorage {
    /// Store identity keypair
    pub fn store_identity_keypair(&self, keypair: &IdentityKeyData) -> Result<()> {
        self.store(KEY_IDENTITY_KEYPAIR, keypair)
    }

    /// Retrieve identity keypair
    pub fn get_identity_keypair(&self) -> Result<IdentityKeyData> {
        self.retrieve(KEY_IDENTITY_KEYPAIR)
    }

    /// Delete identity keypair
    pub fn delete_identity_keypair(&self) -> Result<()> {
        self.delete(KEY_IDENTITY_KEYPAIR)
    }

    /// Check if identity keypair exists
    pub fn has_identity_keypair(&self) -> bool {
        self.exists(KEY_IDENTITY_KEYPAIR)
    }

    /// Store signed prekey
    pub fn store_signed_prekey(&self, prekey: &PreKeyData) -> Result<()> {
        self.store(KEY_SIGNED_PREKEY, prekey)
    }

    /// Retrieve signed prekey
    pub fn get_signed_prekey(&self) -> Result<PreKeyData> {
        self.retrieve(KEY_SIGNED_PREKEY)
    }

    /// Delete signed prekey
    pub fn delete_signed_prekey(&self) -> Result<()> {
        self.delete(KEY_SIGNED_PREKEY)
    }

    /// Store one-time prekeys
    pub fn store_one_time_prekeys(&self, prekeys: &[PreKeyData]) -> Result<()> {
        self.store(KEY_ONE_TIME_PREKEYS, prekeys)
    }

    /// Retrieve one-time prekeys
    pub fn get_one_time_prekeys(&self) -> Result<Vec<PreKeyData>> {
        self.retrieve(KEY_ONE_TIME_PREKEYS)
    }

    /// Delete one-time prekeys
    pub fn delete_one_time_prekeys(&self) -> Result<()> {
        self.delete(KEY_ONE_TIME_PREKEYS)
    }

    /// Store sessions
    pub fn store_sessions(&self, sessions: &HashMap<String, SessionData>) -> Result<()> {
        self.store(KEY_SESSIONS, sessions)
    }

    /// Retrieve sessions
    pub fn get_sessions(&self) -> Result<HashMap<String, SessionData>> {
        self.retrieve(KEY_SESSIONS)
    }

    /// Delete sessions
    pub fn delete_sessions(&self) -> Result<()> {
        self.delete(KEY_SESSIONS)
    }
}

// =============================================================================
// TESTS
// =============================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_key_name_generation() {
        let storage = SecureStorage::new("test_user".to_string());
        assert_eq!(storage.key_name("test_key"), "test_user:test_key");
    }

    #[test]
    fn test_store_and_retrieve() {
        let storage = SecureStorage::new("test_store_retrieve".to_string());

        // Store a simple value
        let test_data = serde_json::json!({
            "public_key": "abc123",
            "private_key": "secret456"
        });

        // This test may fail on CI without a keyring service
        // Skip if keyring is not available
        if storage.store("test_key", &test_data).is_ok() {
            // Retrieve may also fail in some environments (e.g., headless CI)
            if let Ok(retrieved) = storage.retrieve::<serde_json::Value>("test_key") {
                assert_eq!(retrieved["public_key"], "abc123");
            }

            // Cleanup (ignore errors)
            let _ = storage.delete("test_key");
        }
    }

    #[test]
    fn test_not_found() {
        let storage = SecureStorage::new("test_not_found".to_string());

        let result: Result<String> = storage.retrieve("nonexistent_key_12345");
        assert!(matches!(result, Err(SecureStorageError::NotFound(_))));
    }
}
