/// E2EE Crypto Integration Module
///
/// Integrates X3DH and Double Ratchet protocols for secure messaging

use anyhow::{Context, Result, anyhow};
use guardyn_crypto::{
    x3dh::{X3DHProtocol, KeyBundle as X3DHKeyBundle},
    double_ratchet::DoubleRatchet,
};
use crate::models::RatchetSession;
use std::sync::Arc;

/// Crypto manager for E2EE operations
pub struct CryptoManager {
    auth_service_url: String,
}

impl CryptoManager {
    pub fn new(auth_service_url: String) -> Self {
        Self { auth_service_url }
    }

    /// Initialize Double Ratchet session as sender (Alice)
    /// 
    /// Steps:
    /// 1. Fetch recipient's key bundle from auth-service
    /// 2. Perform X3DH key agreement
    /// 3. Initialize Double Ratchet with shared secret
    pub async fn init_sender_session(
        &self,
        local_user_id: &str,
        local_device_id: &str,
        remote_user_id: &str,
        remote_device_id: &str,
        local_identity_key: &[u8],
    ) -> Result<(DoubleRatchet, Vec<u8>)> {
        // TODO: Fetch remote key bundle from auth-service via gRPC
        // For now, return error indicating implementation needed
        Err(anyhow!("Key bundle fetch not yet implemented - need to call auth-service GetKeyBundle RPC"))
    }

    /// Initialize Double Ratchet session as receiver (Bob)
    /// 
    /// Steps:
    /// 1. Use received X3DH key agreement data
    /// 2. Perform X3DH key agreement (responder side)
    /// 3. Initialize Double Ratchet with shared secret
    pub fn init_receiver_session(
        &self,
        local_user_id: &str,
        local_device_id: &str,
        remote_user_id: &str,
        remote_device_id: &str,
        x3dh_data: &[u8],
        local_key_bundle: &X3DHKeyBundle,
    ) -> Result<DoubleRatchet> {
        // Parse X3DH ephemeral key from message
        // TODO: Implement X3DH responder side
        Err(anyhow!("X3DH responder not yet implemented"))
    }

    /// Serialize Double Ratchet state for storage
    pub fn serialize_ratchet(ratchet: &DoubleRatchet) -> Result<Vec<u8>> {
        // TODO: Implement serialization
        // For now, return placeholder
        Err(anyhow!("Ratchet serialization not yet implemented"))
    }

    /// Deserialize Double Ratchet state from storage
    pub fn deserialize_ratchet(data: &[u8]) -> Result<DoubleRatchet> {
        // TODO: Implement deserialization
        // For now, return error
        Err(anyhow!("Ratchet deserialization not yet implemented"))
    }

    /// Encrypt message with Double Ratchet
    pub fn encrypt_message(
        ratchet: &mut DoubleRatchet,
        plaintext: &[u8],
        associated_data: &[u8],
    ) -> Result<Vec<u8>> {
        let encrypted_msg = ratchet.encrypt(plaintext, associated_data)
            .context("Failed to encrypt message with Double Ratchet")?;
        
        Ok(encrypted_msg.to_bytes())
    }

    /// Decrypt message with Double Ratchet
    pub fn decrypt_message(
        ratchet: &mut DoubleRatchet,
        ciphertext: &[u8],
        associated_data: &[u8],
    ) -> Result<Vec<u8>> {
        use guardyn_crypto::double_ratchet::EncryptedMessage;

        let encrypted_msg = EncryptedMessage::from_bytes(ciphertext)
            .context("Failed to parse encrypted message")?;
        
        let plaintext = ratchet.decrypt(&encrypted_msg, associated_data)
            .context("Failed to decrypt message with Double Ratchet")?;
        
        Ok(plaintext)
    }
}

/// Session manager for Double Ratchet sessions
pub struct SessionManager {
    db: Arc<crate::db::DatabaseClient>,
    crypto: CryptoManager,
}

impl SessionManager {
    pub fn new(db: Arc<crate::db::DatabaseClient>, auth_service_url: String) -> Self {
        Self {
            db,
            crypto: CryptoManager::new(auth_service_url),
        }
    }

    /// Get or create Double Ratchet session for a device pair
    pub async fn get_or_create_session(
        &self,
        local_user_id: &str,
        local_device_id: &str,
        remote_user_id: &str,
        remote_device_id: &str,
    ) -> Result<DoubleRatchet> {
        // Try to load existing session
        if let Some(session) = self.db.get_ratchet_session_by_devices(
            local_user_id,
            local_device_id,
            remote_user_id,
            remote_device_id,
        ).await? {
            // Deserialize ratchet state
            return CryptoManager::deserialize_ratchet(&session.ratchet_state);
        }

        // No session exists - need to initialize new one
        // This requires X3DH key exchange with auth-service
        Err(anyhow!(
            "No existing session found. New session initialization requires X3DH key exchange."
        ))
    }

    /// Save Double Ratchet session after encryption/decryption
    pub async fn save_session(
        &self,
        session_id: &str,
        ratchet: &DoubleRatchet,
    ) -> Result<()> {
        let new_state = CryptoManager::serialize_ratchet(ratchet)?;
        self.db.update_ratchet_session_state(session_id, new_state).await?;
        Ok(())
    }

    /// Encrypt message and update session
    pub async fn encrypt_and_save(
        &self,
        session_id: &str,
        mut ratchet: DoubleRatchet,
        plaintext: &[u8],
        associated_data: &[u8],
    ) -> Result<Vec<u8>> {
        let ciphertext = CryptoManager::encrypt_message(&mut ratchet, plaintext, associated_data)?;
        self.save_session(session_id, &ratchet).await?;
        Ok(ciphertext)
    }

    /// Decrypt message and update session
    pub async fn decrypt_and_save(
        &self,
        session_id: &str,
        mut ratchet: DoubleRatchet,
        ciphertext: &[u8],
        associated_data: &[u8],
    ) -> Result<Vec<u8>> {
        let plaintext = CryptoManager::decrypt_message(&mut ratchet, ciphertext, associated_data)?;
        self.save_session(session_id, &ratchet).await?;
        Ok(plaintext)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_crypto_manager_creation() {
        let manager = CryptoManager::new("http://auth-service:50051".to_string());
        // Basic smoke test - manager should be created without errors
        assert_eq!(manager.auth_service_url, "http://auth-service:50051");
    }

    #[test]
    fn test_session_id_generation() {
        use crate::models::RatchetSession;

        let id1 = RatchetSession::session_id("user1", "dev1", "user2", "dev2");
        let id2 = RatchetSession::session_id("user2", "dev2", "user1", "dev1");
        
        // Session IDs should be identical regardless of order (canonical form)
        assert_eq!(id1, id2);
        assert_eq!(id1, "user1:dev1:user2:dev2");
    }
}
