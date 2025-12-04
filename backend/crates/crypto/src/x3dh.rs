/// X3DH (Extended Triple Diffie-Hellman) key agreement protocol
///
/// Used for initial key exchange in 1-on-1 messaging
///
/// Key conversion: Ed25519 identity keys are converted to X25519 for DH operations
/// using the birational equivalence between twisted Edwards curve (Ed25519) and
/// Montgomery curve (Curve25519/X25519). This is the same approach used by Signal Protocol.
use crate::{CryptoError, Result};
use curve25519_dalek::scalar::clamp_integer;
use ed25519_dalek::{SigningKey, VerifyingKey, Signature, Signer, Verifier};
use x25519_dalek::{PublicKey as X25519PublicKey, StaticSecret};
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

    /// Export public key bytes (Ed25519 format for signatures)
    pub fn public_bytes(&self) -> Vec<u8> {
        self.public.to_bytes().to_vec()
    }

    /// Convert Ed25519 public key to X25519 for Diffie-Hellman operations.
    ///
    /// Uses birational equivalence mapping between twisted Edwards curve (Ed25519)
    /// and Montgomery curve (X25519). This is the standard approach used by Signal Protocol.
    pub fn to_x25519_public(&self) -> X25519PublicKey {
        let montgomery = self.public.to_montgomery();
        X25519PublicKey::from(montgomery.to_bytes())
    }

    /// Convert Ed25519 signing key to X25519 StaticSecret for Diffie-Hellman operations.
    ///
    /// The conversion process (matching TweetNaCl's crypto_sign_ed25519_sk_to_x25519_sk):
    /// 1. Compute SHA512(seed)[0:32] via to_scalar_bytes()
    /// 2. Apply X25519 clamping:
    ///    - Clear bottom 3 bits of byte 0 (divisible by 8)
    ///    - Clear top bit of byte 31 (< 2^255)
    ///    - Set second-to-top bit of byte 31 (>= 2^254)
    ///
    /// Note: We use clamp_integer() which applies ONLY clamping without mod l reduction.
    /// This matches TweetNaCl exactly, unlike to_scalar() which also reduces mod l.
    pub fn to_x25519_secret(&self) -> StaticSecret {
        // Get raw SHA512(seed)[0:32] bytes
        let raw_scalar_bytes = self.secret.to_scalar_bytes();
        // Apply clamping (matches TweetNaCl's crypto_sign_ed25519_sk_to_x25519_sk)
        let clamped_bytes = clamp_integer(raw_scalar_bytes);
        StaticSecret::from(clamped_bytes)
    }
}

/// Signed pre-key (X25519 for DH, signed with Ed25519)
#[derive(Clone)]
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
#[derive(Clone)]
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
    /// - local_identity: Alice's long-term identity key pair (Ed25519, converted to X25519 for DH)
    /// - peer_bundle: Bob's public key bundle
    /// - use_one_time_key: Whether to use a one-time pre-key (if available)
    ///
    /// Returns: (32-byte shared secret, ephemeral public key to send to peer)
    pub fn initiate_key_agreement(
        local_identity: &IdentityKeyPair,
        peer_bundle: &X3DHKeyBundle,
        use_one_time_key: bool,
    ) -> Result<(Vec<u8>, X25519PublicKey)> {
        // Convert peer's Ed25519 identity key to X25519 for DH
        let peer_identity = ed25519_public_to_x25519(&peer_bundle.identity_key)?;
        let peer_signed_pre_key = x25519_public_from_bytes(&peer_bundle.signed_pre_key)?;

        // Verify signed pre-key signature (using Ed25519)
        IdentityKeyPair::verify(
            &peer_bundle.identity_key,
            &peer_bundle.signed_pre_key,
            &peer_bundle.signed_pre_key_signature,
        )?;

        // Convert local Ed25519 identity key to X25519 for DH operations
        let local_identity_x25519 = local_identity.to_x25519_secret();

        // Generate ephemeral key for this exchange
        let ephemeral_secret = StaticSecret::random_from_rng(OsRng);
        let ephemeral_public = X25519PublicKey::from(&ephemeral_secret);

        // Perform 4-DH:
        // DH1 = DH(IK_A, SPK_B) - Alice's identity (converted to X25519) with Bob's signed prekey
        let dh1 = local_identity_x25519.diffie_hellman(&peer_signed_pre_key);

        // DH2 = DH(EK_A, IK_B) - Alice's ephemeral with Bob's identity (converted to X25519)
        let dh2 = ephemeral_secret.diffie_hellman(&peer_identity);

        // DH3 = DH(EK_A, SPK_B)
        let dh3 = ephemeral_secret.diffie_hellman(&peer_signed_pre_key);

        // Optional DH4 = DH(EK_A, OPK_B)
        let mut dh_outputs: Vec<Vec<u8>> = vec![
            dh1.as_bytes().to_vec(),
            dh2.as_bytes().to_vec(),
            dh3.as_bytes().to_vec(),
        ];

        if use_one_time_key && !peer_bundle.one_time_pre_keys.is_empty() {
            let peer_one_time_key = x25519_public_from_bytes(
                &peer_bundle.one_time_pre_keys[0].public_key
            )?;
            let dh4 = ephemeral_secret.diffie_hellman(&peer_one_time_key);
            dh_outputs.push(dh4.as_bytes().to_vec());
        }

        // Derive shared secret using HKDF-SHA256
        let shared_secret = derive_shared_secret(&dh_outputs)?;

        Ok((shared_secret, ephemeral_public))
    }

    /// Perform 4-DH key agreement as responder (Bob)
    ///
    /// Inputs:
    /// - key_material: Bob's key material (identity, signed pre-key, one-time keys)
    /// - peer_identity_bytes: Alice's identity public key (Ed25519 format)
    /// - peer_ephemeral_bytes: Alice's ephemeral public key (X25519 format)
    /// - one_time_key_id: Which one-time key was used (if any)
    ///
    /// Returns: 32-byte shared secret
    pub fn respond_key_agreement(
        key_material: &X3DHKeyMaterial,
        peer_identity_bytes: &[u8],
        peer_ephemeral_bytes: &[u8],
        one_time_key_id: Option<u32>,
    ) -> Result<Vec<u8>> {
        // Convert peer's Ed25519 identity key to X25519 for DH
        let peer_identity_x25519 = ed25519_public_to_x25519(peer_identity_bytes)?;
        let peer_ephemeral = x25519_public_from_bytes(peer_ephemeral_bytes)?;

        // Convert local Ed25519 identity key to X25519 for DH operations
        let local_identity_x25519 = key_material.identity_key.to_x25519_secret();

        // Perform 4-DH (symmetric with initiator):
        // DH1 = DH(SPK_B, IK_A) - Bob's signed prekey with Alice's identity (converted to X25519)
        let dh1 = key_material.signed_pre_key.dh(&peer_identity_x25519);

        // DH2 = DH(IK_B, EK_A) - Bob's identity (converted to X25519) with Alice's ephemeral
        let dh2_bytes = local_identity_x25519.diffie_hellman(&peer_ephemeral).as_bytes().to_vec();

        // DH3 = DH(SPK_B, EK_A)
        let dh3 = key_material.signed_pre_key.dh(&peer_ephemeral);

        let mut dh_outputs: Vec<Vec<u8>> = vec![
            dh1,
            dh2_bytes,
            dh3,
        ];

        // Optional DH4 with one-time key
        if let Some(key_id) = one_time_key_id {
            if let Some(otk) = key_material.one_time_pre_keys.iter().find(|k| k.key_id == key_id) {
                let dh4 = otk.dh(&peer_ephemeral);
                dh_outputs.push(dh4);
            }
        }

        derive_shared_secret(&dh_outputs)
    }
}

/// Helper: Convert Ed25519 public key bytes to X25519 public key
///
/// Uses birational equivalence mapping between twisted Edwards curve (Ed25519)
/// and Montgomery curve (X25519). This is the standard approach used by Signal Protocol.
fn ed25519_public_to_x25519(ed25519_bytes: &[u8]) -> Result<X25519PublicKey> {
    if ed25519_bytes.len() != 32 {
        return Err(CryptoError::InvalidKey("Ed25519 public key must be 32 bytes".into()));
    }

    let verifying_key = VerifyingKey::from_bytes(
        ed25519_bytes.try_into()
            .map_err(|_| CryptoError::InvalidKey("Invalid Ed25519 public key length".into()))?
    ).map_err(|e| CryptoError::InvalidKey(format!("Invalid Ed25519 public key: {}", e)))?;

    let montgomery = verifying_key.to_montgomery();
    Ok(X25519PublicKey::from(montgomery.to_bytes()))
}

/// Helper: Convert bytes to X25519 public key (for already X25519 formatted keys)
fn x25519_public_from_bytes(bytes: &[u8]) -> Result<X25519PublicKey> {
    if bytes.len() != 32 {
        return Err(CryptoError::InvalidKey("X25519 public key must be 32 bytes".into()));
    }
    let mut key_bytes = [0u8; 32];
    key_bytes.copy_from_slice(bytes);
    Ok(X25519PublicKey::from(key_bytes))
}

/// Helper: Derive shared secret from DH outputs using HKDF
fn derive_shared_secret(dh_outputs: &[Vec<u8>]) -> Result<Vec<u8>> {
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
        // Alice and Bob generate key material
        let alice_material = X3DHKeyMaterial::generate(10).unwrap();
        let bob_material = X3DHKeyMaterial::generate(10).unwrap();
        let bob_bundle = bob_material.export_bundle();

        // Alice initiates key agreement with Bob's bundle
        let (alice_shared_secret, alice_ephemeral) = X3DHProtocol::initiate_key_agreement(
            &alice_material.identity_key,
            &bob_bundle,
            true,
        ).unwrap();

        assert_eq!(alice_shared_secret.len(), 32);

        // Bob responds to complete the key agreement
        let bob_shared_secret = X3DHProtocol::respond_key_agreement(
            &bob_material,
            &alice_material.identity_key.public_bytes(),
            alice_ephemeral.as_bytes(),
            Some(0), // Using first one-time prekey
        ).unwrap();

        assert_eq!(bob_shared_secret.len(), 32);

        // Both sides should derive the same shared secret
        assert_eq!(alice_shared_secret, bob_shared_secret,
            "Alice and Bob should derive identical shared secrets");
    }

    #[test]
    fn test_ed25519_to_x25519_conversion() {
        let identity = IdentityKeyPair::generate().unwrap();

        // Convert to X25519 keys
        let x25519_public = identity.to_x25519_public();
        let x25519_secret = identity.to_x25519_secret();

        // Verify the conversion is consistent
        let derived_public = X25519PublicKey::from(&x25519_secret);
        assert_eq!(x25519_public.as_bytes(), derived_public.as_bytes(),
            "X25519 public key derived from secret should match converted public key");
    }

    #[test]
    fn test_x3dh_without_one_time_key() {
        let alice_material = X3DHKeyMaterial::generate(0).unwrap(); // No OTKs
        let bob_material = X3DHKeyMaterial::generate(0).unwrap();
        let bob_bundle = bob_material.export_bundle();

        // Alice initiates without one-time key
        let (alice_shared_secret, alice_ephemeral) = X3DHProtocol::initiate_key_agreement(
            &alice_material.identity_key,
            &bob_bundle,
            false, // No one-time key
        ).unwrap();

        // Bob responds
        let bob_shared_secret = X3DHProtocol::respond_key_agreement(
            &bob_material,
            &alice_material.identity_key.public_bytes(),
            alice_ephemeral.as_bytes(),
            None, // No one-time key
        ).unwrap();

        assert_eq!(alice_shared_secret, bob_shared_secret);
    }
}
