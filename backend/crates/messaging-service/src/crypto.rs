/// E2EE Crypto Integration Module
///
/// Integrates X3DH and Double Ratchet protocols for secure messaging
use anyhow::{anyhow, Context, Result};
use guardyn_crypto::{
    double_ratchet::DoubleRatchet,
    x3dh::{IdentityKeyPair, X3DHKeyBundle, X3DHKeyMaterial, X3DHPrekeyMessage, X3DHProtocol},
    KeyStorage, KeyType,
};
use std::sync::Arc;

// Import generated proto types
use crate::proto::auth::{auth_service_client::AuthServiceClient, GetKeyBundleRequest};

/// Crypto manager for E2EE operations
///
/// Handles key storage and session management for end-to-end encryption.
/// In production, keys are loaded from secure storage; in development,
/// ephemeral keys may be generated.
#[allow(dead_code)]
pub struct CryptoManager {
    auth_service_url: String,
    /// Secure key storage for identity and session keys
    key_storage: Option<Arc<KeyStorage>>,
    /// User ID for key namespacing
    local_user_id: Option<String>,
    /// Device ID for key namespacing
    local_device_id: Option<String>,
}

impl CryptoManager {
    /// Create a new CryptoManager without key storage (development mode)
    pub fn new(auth_service_url: String) -> Self {
        Self {
            auth_service_url,
            key_storage: None,
            local_user_id: None,
            local_device_id: None,
        }
    }

    /// Create a new CryptoManager with secure key storage (production mode)
    pub fn with_storage(
        auth_service_url: String,
        key_storage: Arc<KeyStorage>,
        local_user_id: String,
        local_device_id: String,
    ) -> Self {
        Self {
            auth_service_url,
            key_storage: Some(key_storage),
            local_user_id: Some(local_user_id),
            local_device_id: Some(local_device_id),
        }
    }

    /// Get identity key ID for storage
    fn identity_key_id(&self) -> String {
        format!(
            "identity:{}:{}",
            self.local_user_id.as_deref().unwrap_or("unknown"),
            self.local_device_id.as_deref().unwrap_or("unknown")
        )
    }

    /// Load or generate identity key pair
    ///
    /// In production mode with key storage:
    /// - Tries to load existing identity key from storage
    /// - Generates and stores new key if not found
    ///
    /// In development mode without storage:
    /// - Generates ephemeral key (not persisted)
    fn load_or_generate_identity_key(&self) -> Result<IdentityKeyPair> {
        if let Some(ref storage) = self.key_storage {
            let key_id = self.identity_key_id();

            // Try to load existing key
            match storage.get_key(&key_id) {
                Ok(key_bytes) => {
                    // Deserialize identity key from storage
                    IdentityKeyPair::from_private_bytes(&key_bytes)
                        .map_err(|e| anyhow!("Failed to deserialize identity key: {}", e))
                }
                Err(_) => {
                    // Key not found, generate new one
                    let identity = IdentityKeyPair::generate()
                        .context("Failed to generate identity key pair")?;

                    // Store the private key
                    storage
                        .store_key_simple(
                            &key_id,
                            &identity.private_key_bytes(),
                            KeyType::Identity,
                            self.local_device_id.clone(),
                        )
                        .map_err(|e| anyhow!("Failed to store identity key: {}", e))?;

                    tracing::info!("Generated and stored new identity key for {}", key_id);
                    Ok(identity)
                }
            }
        } else {
            // Development mode: generate ephemeral key
            tracing::warn!("No key storage configured, generating ephemeral identity key");
            IdentityKeyPair::generate().context("Failed to generate identity key pair")
        }
    }

    /// Initialize Double Ratchet session as sender (Alice)
    ///
    /// Steps:
    /// 1. Fetch recipient's key bundle from auth-service
    /// 2. Load or generate local identity key
    /// 3. Perform X3DH key agreement
    /// 4. Initialize Double Ratchet with shared secret
    pub async fn init_sender_session(
        &self,
        local_user_id: &str,
        local_device_id: &str,
        remote_user_id: &str,
        remote_device_id: &str,
        _local_identity_key: &[u8], // Deprecated: now loaded from storage
    ) -> Result<(DoubleRatchet, Vec<u8>)> {
        // Fetch remote key bundle from auth-service
        let key_bundle = self
            .fetch_key_bundle(remote_user_id, remote_device_id)
            .await
            .context("Failed to fetch recipient's key bundle")?;

        // Parse key bundle into X3DH types
        let x3dh_bundle = self.parse_key_bundle(&key_bundle)?;

        // Load or generate local identity key from secure storage
        // Per ENCRYPTION_ARCHITECTURE.md: Identity Keys are Ed25519, converted to X25519 for DH operations
        let local_identity = self.load_or_generate_identity_key()?;

        // Perform X3DH key agreement (Alice side)
        let (shared_secret, ephemeral_public) = X3DHProtocol::initiate_key_agreement(
            &local_identity,
            &x3dh_bundle,
            false, // Don't use one-time keys for MVP
        )
        .context("X3DH key agreement failed")?;

        // Initialize Double Ratchet with shared secret
        let remote_signed_prekey_pub = x25519_dalek::PublicKey::from(
            <[u8; 32]>::try_from(key_bundle.signed_pre_key.as_slice())
                .context("Invalid signed pre-key length")?,
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

        let response = client
            .get_key_bundle(request)
            .await
            .context("GetKeyBundle RPC failed")?
            .into_inner();

        match response.result {
            Some(crate::proto::auth::get_key_bundle_response::Result::Success(success)) => success
                .key_bundle
                .ok_or_else(|| anyhow!("Key bundle missing in response")),
            Some(crate::proto::auth::get_key_bundle_response::Result::Error(err)) => Err(anyhow!(
                "Auth service error: {} (code: {:?})",
                err.message,
                err.code
            )),
            None => Err(anyhow!("Empty response from auth-service")),
        }
    }

    /// Parse proto KeyBundle into X3DH KeyBundle
    fn parse_key_bundle(&self, bundle: &crate::proto::common::KeyBundle) -> Result<X3DHKeyBundle> {
        use ed25519_dalek::VerifyingKey;
        use x25519_dalek::PublicKey as X25519PublicKey;

        // Parse identity key (Ed25519)
        let identity_key = VerifyingKey::from_bytes(
            <&[u8; 32]>::try_from(bundle.identity_key.as_slice())
                .context("Invalid identity key length")?,
        )
        .context("Invalid Ed25519 identity key")?;

        // Parse signed pre-key (X25519)
        let signed_pre_key = X25519PublicKey::from(
            <[u8; 32]>::try_from(bundle.signed_pre_key.as_slice())
                .context("Invalid signed pre-key length")?,
        );

        // Parse signature
        let signature = ed25519_dalek::Signature::from_bytes(
            <&[u8; 64]>::try_from(bundle.signed_pre_key_signature.as_slice())
                .context("Invalid signature length")?,
        );

        // Convert one-time pre-keys to the format expected by crypto crate
        let one_time_pre_keys: Vec<guardyn_crypto::x3dh::OneTimePreKeyPublic> = bundle
            .one_time_pre_keys
            .iter()
            .enumerate()
            .map(
                |(idx, key_bytes)| guardyn_crypto::x3dh::OneTimePreKeyPublic {
                    key_id: idx as u32,
                    public_key: key_bytes.clone(),
                },
            )
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
    /// This is called when receiving the first message from a new sender.
    /// The message contains X3DH prekey data that allows Bob to complete
    /// the key agreement and establish a Double Ratchet session.
    ///
    /// Steps:
    /// 1. Parse X3DHPrekeyMessage from received data
    /// 2. Perform X3DH key agreement (responder side)
    /// 3. Initialize Double Ratchet with shared secret
    ///
    /// # Arguments
    /// * `x3dh_prekey_base64` - Base64-encoded X3DHPrekeyMessage from the first message
    /// * `local_key_material` - Bob's key material (identity, signed pre-key, one-time keys)
    ///
    /// # Returns
    /// A tuple of (DoubleRatchet session, session_id for storage)
    pub fn init_receiver_session(
        &self,
        local_user_id: &str,
        local_device_id: &str,
        remote_user_id: &str,
        remote_device_id: &str,
        x3dh_prekey_base64: &str,
        local_key_material: &X3DHKeyMaterial,
    ) -> Result<DoubleRatchet> {
        // Parse X3DH prekey message from base64
        let prekey_msg = X3DHPrekeyMessage::from_base64(x3dh_prekey_base64)
            .map_err(|e| anyhow!("Failed to parse X3DH prekey message: {}", e))?;

        tracing::debug!(
            "Received X3DH prekey from {} (OTK used: {:?})",
            remote_user_id,
            prekey_msg.used_one_time_key_id
        );

        // Perform X3DH key agreement as responder (Bob)
        let shared_secret = X3DHProtocol::respond_key_agreement(
            local_key_material,
            &prekey_msg.sender_identity_key,
            &prekey_msg.ephemeral_key,
            prekey_msg.used_one_time_key_id,
        )
        .map_err(|e| anyhow!("X3DH responder key agreement failed: {}", e))?;

        tracing::debug!(
            "X3DH responder completed, shared secret derived ({} bytes)",
            shared_secret.len()
        );

        // Initialize Double Ratchet as Bob (receiver of first message)
        let ratchet = DoubleRatchet::init_bob(&shared_secret)
            .context("Failed to initialize Double Ratchet as receiver")?;

        tracing::info!(
            "E2EE session established: {} -> {} (receiver)",
            remote_user_id,
            local_user_id
        );

        Ok(ratchet)
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
        let encrypted_msg = ratchet
            .encrypt(plaintext, associated_data)
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

        let plaintext = ratchet
            .decrypt(&encrypted_msg, associated_data)
            .context("Failed to decrypt message with Double Ratchet")?;

        Ok(plaintext)
    }
}

/// Session manager for Double Ratchet sessions
#[allow(dead_code)]
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
        if let Some(session) = self
            .db
            .get_ratchet_session_by_devices(
                local_user_id,
                local_device_id,
                remote_user_id,
                remote_device_id,
            )
            .await?
        {
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
    pub async fn save_session(&self, session_id: &str, ratchet: &DoubleRatchet) -> Result<()> {
        let new_state = CryptoManager::serialize_ratchet(ratchet)?;
        self.db
            .update_ratchet_session_state(session_id, new_state)
            .await?;
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
