/// X3DH (Extended Triple Diffie-Hellman) key agreement protocol
///
/// Used for initial key exchange in 1-on-1 messaging
use crate::{CryptoError, Result};
use ed25519_dalek::{SigningKey, VerifyingKey, Signature, Signer, Verifier};
use x25519_dalek::{PublicKey as X25519PublicKey, StaticSecret, SharedSecret};
use rand::rngs::OsRng;
use serde::{Deserialize, Serialize};
use hkdf::Hkdf;
use sha2::Sha256;

/// Identity key pair (Ed25519 for signing)
#[derive(Debug, Clone)]
pub struct IdentityKeyPair {
    pub public: VerifyingKey,
    secret: SigningKey,
}

impl IdentityKeyPair {
    /// Generate a new identity key pair
    pub fn generate() -> Result<Self> {
        let secret = SigningKey::from_bytes(&rand::random::<[u8; 32]>());
        let public = secret.verifying_key();

        Ok(Self {
            public,
            secret,
        })
    }

    /// Sign data with identity key
    pub fn sign(&self, data: &[u8]) -> Result<Vec<u8>> {
        let signature = self.secret.sign(data);
        Ok(signature.to_bytes().to_vec())
    }

    /// Verify signature
    pub fn verify(public_key: &[u8], data: &[u8], signature: &[u8]) -> Result<()> {
        let public = VerifyingKey::from_bytes(
            public_key.try_into()
                .map_err(|_| CryptoError::InvalidKey("Invalid Ed25519 public key length".into()))?
        ).map_err(|e| CryptoError::InvalidKey(format!("Invalid Ed25519 public key: {}", e)))?;

        let sig = Signature::from_bytes(
            signature.try_into()
                .map_err(|_| CryptoError::InvalidSignature("Invalid signature length".into()))?
        );

        public.verify(data, &sig)
            .map_err(|e| CryptoError::InvalidSignature(format!("Signature verification failed: {}", e)))?;

        Ok(())
    }

    /// Export public key bytes
    pub fn public_bytes(&self) -> Vec<u8> {
        self.public.to_bytes().to_vec()
    }
}

/// Signed pre-key (X25519 for DH, signed with Ed25519)
#[derive(Debug, Clone)]
pub struct SignedPreKey {
    pub key_id: u32,
    pub public: X25519PublicKey,
    secret: StaticSecret,
    pub signature: Vec<u8>,
    pub timestamp: i64,
}

impl SignedPreKey {
    /// Generate a new signed pre-key
    pub fn generate(key_id: u32, identity_key: &IdentityKeyPair) -> Result<Self> {
        let secret = StaticSecret::random_from_rng(OsRng);
        let public = X25519PublicKey::from(&secret);

        // Sign the public key with identity key
        let signature = identity_key.sign(public.as_bytes())?;

        let timestamp = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64;

        Ok(Self {
            key_id,
            public,
            secret,
            signature,
            timestamp,
        })
    }

    /// Export public key bytes
    pub fn public_bytes(&self) -> Vec<u8> {
        self.public.as_bytes().to_vec()
    }

    /// Perform Diffie-Hellman with another X25519 public key
    pub fn dh(&self, other_public: &X25519PublicKey) -> Vec<u8> {
        let shared = self.secret.diffie_hellman(other_public);
        shared.as_bytes().to_vec()
    }
}

/// One-time pre-key (X25519)
#[derive(Debug, Clone)]
pub struct OneTimePreKey {
    pub key_id: u32,
    pub public: X25519PublicKey,
    secret: StaticSecret,
}

impl OneTimePreKey {
    /// Generate a new one-time pre-key
    pub fn generate(key_id: u32) -> Self {
        let secret = StaticSecret::random_from_rng(OsRng);
        let public = X25519PublicKey::from(&secret);

        Self {
            key_id,
            public,
            secret,
        }
    }

    /// Export public key bytes
    pub fn public_bytes(&self) -> Vec<u8> {
        self.public.as_bytes().to_vec()
    }

    /// Perform Diffie-Hellman
    pub fn dh(&self, other_public: &X25519PublicKey) -> Vec<u8> {
        let shared = self.secret.diffie_hellman(other_public);
        shared.as_bytes().to_vec()
    }
}

/// Key bundle for publishing to server
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct X3DHKeyBundle {
    pub identity_key: Vec<u8>,           // Ed25519 public key
    pub signed_pre_key: Vec<u8>,         // X25519 public key
    pub signed_pre_key_id: u32,
    pub signed_pre_key_signature: Vec<u8>,
    pub one_time_pre_keys: Vec<OneTimePreKeyPublic>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OneTimePreKeyPublic {
    pub key_id: u32,
    pub public_key: Vec<u8>,
}

/// Complete key material for a device
pub struct X3DHKeyMaterial {
    pub identity_key: IdentityKeyPair,
    pub signed_pre_key: SignedPreKey,
    pub one_time_pre_keys: Vec<OneTimePreKey>,
}

impl X3DHKeyMaterial {
    /// Generate complete key material (identity + signed pre-key + one-time keys)
    pub fn generate(num_one_time_keys: usize) -> Result<Self> {
        let identity_key = IdentityKeyPair::generate()?;
        let signed_pre_key = SignedPreKey::generate(1, &identity_key)?;

        let mut one_time_pre_keys = Vec::with_capacity(num_one_time_keys);
        for i in 0..num_one_time_keys {
            one_time_pre_keys.push(OneTimePreKey::generate(i as u32));
        }

        Ok(Self {
            identity_key,
            signed_pre_key,
            one_time_pre_keys,
        })
    }

    /// Export public key bundle for publishing
    pub fn export_bundle(&self) -> X3DHKeyBundle {
        X3DHKeyBundle {
            identity_key: self.identity_key.public_bytes(),
            signed_pre_key: self.signed_pre_key.public_bytes(),
            signed_pre_key_id: self.signed_pre_key.key_id,
            signed_pre_key_signature: self.signed_pre_key.signature.clone(),
            one_time_pre_keys: self.one_time_pre_keys.iter().map(|key| {
                OneTimePreKeyPublic {
                    key_id: key.key_id,
                    public_key: key.public_bytes(),
                }
            }).collect(),
        }
    }
}

/// X3DH Protocol implementation
pub struct X3DHProtocol;

impl X3DHProtocol {
    /// Generate a new key bundle for publishing
    pub fn generate_key_bundle() -> Result<X3DHKeyBundle> {
        let key_material = X3DHKeyMaterial::generate(100)?;
        Ok(key_material.export_bundle())
    }

    /// Perform 4-DH key agreement as initiator (Alice)
    /// 
    /// Inputs:
    /// - local_identity_key: Alice's long-term identity key
    /// - local_ephemeral_key: Alice's ephemeral key (generated for this exchange)
    /// - peer_bundle: Bob's public key bundle
    /// - one_time_key_id: ID of the one-time pre-key to use (if available)
    /// 
    /// Returns: 32-byte shared secret
    pub fn initiate_key_agreement(
        local_identity_secret: &StaticSecret,
        peer_bundle: &X3DHKeyBundle,
        use_one_time_key: bool,
    ) -> Result<(Vec<u8>, X25519PublicKey)> {
        // Parse peer's keys
        let peer_identity = x25519_public_from_bytes(&peer_bundle.identity_key)?;
        let peer_signed_pre_key = x25519_public_from_bytes(&peer_bundle.signed_pre_key)?;
        
        // Verify signed pre-key signature
        IdentityKeyPair::verify(
            &peer_bundle.identity_key,
            &peer_bundle.signed_pre_key,
            &peer_bundle.signed_pre_key_signature,
        )?;
        
        // Generate ephemeral key for this exchange
        let ephemeral_secret = StaticSecret::random_from_rng(OsRng);
        let ephemeral_public = X25519PublicKey::from(&ephemeral_secret);        // Perform 4-DH:
        // DH1 = DH(IK_A, SPK_B)
        let dh1 = local_identity_secret.diffie_hellman(&peer_signed_pre_key);

        // DH2 = DH(EK_A, IK_B)
        let dh2 = ephemeral_secret.diffie_hellman(&peer_identity);

        // DH3 = DH(EK_A, SPK_B)
        let dh3 = ephemeral_secret.diffie_hellman(&peer_signed_pre_key);

        // Optional DH4 = DH(EK_A, OPK_B)
        let mut dh_outputs = vec![
            dh1.as_bytes(),
            dh2.as_bytes(),
            dh3.as_bytes(),
        ];

        if use_one_time_key && !peer_bundle.one_time_pre_keys.is_empty() {
            let peer_one_time_key = x25519_public_from_bytes(
                &peer_bundle.one_time_pre_keys[0].public_key
            )?;
            let dh4 = ephemeral_secret.diffie_hellman(&peer_one_time_key);
            dh_outputs.push(dh4.as_bytes());
        }

        // Derive shared secret using HKDF-SHA256
        let shared_secret = derive_shared_secret(&dh_outputs)?;

        Ok((shared_secret, ephemeral_public))
    }

    /// Perform 4-DH key agreement as responder (Bob)
    ///
    /// Inputs:
    /// - key_material: Bob's key material (identity, signed pre-key, one-time keys)
    /// - peer_identity_public: Alice's identity public key
    /// - peer_ephemeral_public: Alice's ephemeral public key
    /// - one_time_key_id: Which one-time key was used (if any)
    ///
    /// Returns: 32-byte shared secret
    pub fn respond_key_agreement(
        key_material: &X3DHKeyMaterial,
        peer_identity_bytes: &[u8],
        peer_ephemeral_bytes: &[u8],
        one_time_key_id: Option<u32>,
    ) -> Result<Vec<u8>> {
        let peer_identity = x25519_public_from_bytes(peer_identity_bytes)?;
        let peer_ephemeral = x25519_public_from_bytes(peer_ephemeral_bytes)?;

        // Perform 4-DH (same as initiator):
        // DH1 = DH(SPK_B, IK_A)
        let dh1 = key_material.signed_pre_key.dh(&peer_identity);

        // DH2 = DH(IK_B, EK_A) - need to convert identity key to X25519
        // Note: In real implementation, identity keys should be X25519, not Ed25519
        // For now, we assume conversion or separate X25519 identity key
        // This is a simplification - in production, use proper key conversion
        let identity_x25519_secret = StaticSecret::random_from_rng(OsRng); // TODO: Derive from Ed25519
        let dh2_bytes = identity_x25519_secret.diffie_hellman(&peer_ephemeral).as_bytes().to_vec();

        // DH3 = DH(SPK_B, EK_A)
        let dh3 = key_material.signed_pre_key.dh(&peer_ephemeral);

        let mut dh_outputs = vec![
            dh1.as_slice(),
            dh2_bytes.as_slice(),
            dh3.as_slice(),
        ];

        // Optional DH4 with one-time key
        if let Some(key_id) = one_time_key_id {
            if let Some(otk) = key_material.one_time_pre_keys.iter().find(|k| k.key_id == key_id) {
                let dh4 = otk.dh(&peer_ephemeral);
                dh_outputs.push(dh4.as_slice());
            }
        }

        derive_shared_secret(&dh_outputs)
    }
}

/// Helper: Convert bytes to X25519 public key
fn x25519_public_from_bytes(bytes: &[u8]) -> Result<X25519PublicKey> {
    if bytes.len() != 32 {
        return Err(CryptoError::InvalidKey("X25519 public key must be 32 bytes".into()));
    }
    let mut key_bytes = [0u8; 32];
    key_bytes.copy_from_slice(bytes);
    Ok(X25519PublicKey::from(key_bytes))
}

/// Helper: Derive shared secret from DH outputs using HKDF
fn derive_shared_secret(dh_outputs: &[&[u8]]) -> Result<Vec<u8>> {
    // Concatenate all DH outputs
    let mut concat = Vec::new();
    for output in dh_outputs {
        concat.extend_from_slice(output);
    }

    // Use HKDF-SHA256 to derive 32-byte shared secret
    let hk = Hkdf::<Sha256>::new(None, &concat);
    let mut okm = [0u8; 32];
    hk.expand(b"X3DH", &mut okm)
        .map_err(|e| CryptoError::Protocol(format!("HKDF expansion failed: {}", e)))?;

    Ok(okm.to_vec())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_identity_key_generation() {
        let key = IdentityKeyPair::generate().expect("Failed to generate identity key");
        assert_eq!(key.public_bytes().len(), 32);
    }

    #[test]
    fn test_signed_pre_key_generation() {
        let identity = IdentityKeyPair::generate().unwrap();
        let spk = SignedPreKey::generate(1, &identity).unwrap();

        assert_eq!(spk.key_id, 1);
        assert_eq!(spk.public_bytes().len(), 32);
        assert!(!spk.signature.is_empty());
    }

    #[test]
    fn test_one_time_key_generation() {
        let otk = OneTimePreKey::generate(42);
        assert_eq!(otk.key_id, 42);
        assert_eq!(otk.public_bytes().len(), 32);
    }

    #[test]
    fn test_key_bundle_generation() {
        let bundle = X3DHProtocol::generate_key_bundle().unwrap();

        assert_eq!(bundle.identity_key.len(), 32);
        assert_eq!(bundle.signed_pre_key.len(), 32);
        assert!(!bundle.signed_pre_key_signature.is_empty());
        assert_eq!(bundle.one_time_pre_keys.len(), 100);
    }

    #[test]
    fn test_signature_verification() {
        let identity = IdentityKeyPair::generate().unwrap();
        let data = b"test data";

        let signature = identity.sign(data).unwrap();
        let result = IdentityKeyPair::verify(&identity.public_bytes(), data, &signature);

        assert!(result.is_ok());
    }

    #[test]
    fn test_x3dh_key_agreement() {
        // Bob generates key material
        let bob_material = X3DHKeyMaterial::generate(10).unwrap();
        let bob_bundle = bob_material.export_bundle();
        
        // Alice initiates key agreement
        let alice_identity_secret = StaticSecret::random_from_rng(OsRng);
        let (alice_shared_secret, _alice_ephemeral) = X3DHProtocol::initiate_key_agreement(
            &alice_identity_secret,
            &bob_bundle,
            true,
        ).unwrap();
        
        assert_eq!(alice_shared_secret.len(), 32);
        
        // Note: Full responder test requires proper key conversion
        // This is a basic test of the initiator side
    }
}
