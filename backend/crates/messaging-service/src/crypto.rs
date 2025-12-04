/// E2EE Crypto Integration Module
///
/// Integrates X3DH and Double Ratchet protocols for secure messaging

use anyhow::{Context, Result, anyhow};
use guardyn_crypto::{
    x3dh::{X3DHProtocol, X3DHKeyBundle, IdentityKeyPair},
    double_ratchet::DoubleRatchet,
};
use crate::models::RatchetSession;
use std::sync::Arc;

// Import generated proto types
use crate::proto::auth::{
    auth_service_client::AuthServiceClient,
    GetKeyBundleRequest,
};

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
        // Fetch remote key bundle from auth-service
        let key_bundle = self.fetch_key_bundle(remote_user_id, remote_device_id).await
            .context("Failed to fetch recipient's key bundle")?;

        // Parse key bundle into X3DH types
        let x3dh_bundle = self.parse_key_bundle(&key_bundle)?;

        // Generate or use local identity key for X3DH
        // Per ENCRYPTION_ARCHITECTURE.md: Identity Keys are Ed25519, converted to X25519 for DH operations
        // TODO: In production, load from secure storage instead of generating new key
        let local_identity = IdentityKeyPair::generate()
            .context("Failed to generate identity key pair")?;

        // Perform X3DH key agreement (Alice side)
        let (shared_secret, ephemeral_public) = X3DHProtocol::initiate_key_agreement(
            &local_identity,
            &x3dh_bundle,
            false, // Don't use one-time keys for MVP
        ).context("X3DH key agreement failed")?;

        // Initialize Double Ratchet with shared secret
        let remote_signed_prekey_pub = x25519_dalek::PublicKey::from(
            <[u8; 32]>::try_from(key_bundle.signed_pre_key.as_slice())
                .context("Invalid signed pre-key length")?
        );

        let ratchet = DoubleRatchet::init_alice(&shared_secret, remote_signed_prekey_pub)
            .context("Failed to initialize Double Ratchet")?;

        // Return ratchet and ephemeral key for initial message
        Ok((ratchet, ephemeral_public.as_bytes().to_vec()))
    }

    /// Fetch key bundle from auth-service via gRPC
    async fn fetch_key_bundle(
        &self,
        user_id: &str,
        device_id: &str,
    ) -> Result<crate::proto::common::KeyBundle> {
        let mut client = AuthServiceClient::connect(self.auth_service_url.clone())
            .await
            .context("Failed to connect to auth-service")?;

        let request = tonic::Request::new(GetKeyBundleRequest {
            user_id: user_id.to_string(),
            device_id: device_id.to_string(),
        });

        let response = client.get_key_bundle(request)
            .await
            .context("GetKeyBundle RPC failed")?
            .into_inner();

        match response.result {
            Some(crate::proto::auth::get_key_bundle_response::Result::Success(success)) => {
                success.key_bundle.ok_or_else(|| anyhow!("Key bundle missing in response"))
            }
            Some(crate::proto::auth::get_key_bundle_response::Result::Error(err)) => {
                Err(anyhow!("Auth service error: {} (code: {:?})", err.message, err.code))
            }
            None => Err(anyhow!("Empty response from auth-service"))
        }
    }

    /// Parse proto KeyBundle into X3DH KeyBundle
    fn parse_key_bundle(&self, bundle: &crate::proto::common::KeyBundle) -> Result<X3DHKeyBundle> {
        use ed25519_dalek::VerifyingKey;
        use x25519_dalek::PublicKey as X25519PublicKey;

        // Parse identity key (Ed25519)
        let identity_key = VerifyingKey::from_bytes(
            <&[u8; 32]>::try_from(bundle.identity_key.as_slice())
                .context("Invalid identity key length")?
        ).context("Invalid Ed25519 identity key")?;

        // Parse signed pre-key (X25519)
        let signed_pre_key = X25519PublicKey::from(
            <[u8; 32]>::try_from(bundle.signed_pre_key.as_slice())
                .context("Invalid signed pre-key length")?
        );

        // Parse signature
        let signature = ed25519_dalek::Signature::from_bytes(
            <&[u8; 64]>::try_from(bundle.signed_pre_key_signature.as_slice())
                .context("Invalid signature length")?
        );

        // Convert one-time pre-keys to the format expected by crypto crate
        let one_time_pre_keys: Vec<guardyn_crypto::x3dh::OneTimePreKeyPublic> = bundle.one_time_pre_keys
            .iter()
            .enumerate()
            .map(|(idx, key_bytes)| {
                guardyn_crypto::x3dh::OneTimePreKeyPublic {
                    key_id: idx as u32,
                    public_key: key_bytes.clone(),
                }
            })
            .collect();

        Ok(X3DHKeyBundle {
            identity_key: identity_key.to_bytes().to_vec(),
            signed_pre_key: signed_pre_key.as_bytes().to_vec(),
            signed_pre_key_id: 1, // Default ID for MVP
            signed_pre_key_signature: signature.to_bytes().to_vec(),
            one_time_pre_keys,
        })
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
        Ok(ratchet.serialize())
    }

    /// Deserialize Double Ratchet state from storage
    pub fn deserialize_ratchet(data: &[u8]) -> Result<DoubleRatchet> {
        DoubleRatchet::deserialize(data)
            .map_err(|e| anyhow!("Failed to deserialize ratchet: {}", e))
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
