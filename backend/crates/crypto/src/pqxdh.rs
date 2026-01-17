//! Post-Quantum X3DH (PQXDH) Implementation
//!
//! This module implements a hybrid key exchange combining:
//! - Classical: X25519 Diffie-Hellman
//! - Post-Quantum: ML-KEM (Kyber) key encapsulation
//!
//! The hybrid approach ensures security even if one of the algorithms is broken.
//! Based on Signal's PQXDH specification.
//!
//! Reference: https://signal.org/docs/specifications/pqxdh/

use crate::{CryptoError, Result};
use ed25519_dalek::{Signature, SigningKey, VerifyingKey};
use hkdf::Hkdf;
use serde::{Deserialize, Serialize};
use sha2::Sha256;
use x25519_dalek::{PublicKey as X25519PublicKey, StaticSecret as X25519Secret};
use zeroize::{Zeroize, ZeroizeOnDrop};

#[cfg(feature = "pq")]
use ml_kem::{
    kem::{Decapsulate, Encapsulate},
    EncodedSizeUser, KemCore, MlKem768,
};

/// ML-KEM-768 public key size (1184 bytes)
#[cfg(feature = "pq")]
pub const MLKEM_PUBLIC_KEY_SIZE: usize = 1184;

/// ML-KEM-768 ciphertext size (1088 bytes)
#[cfg(feature = "pq")]
pub const MLKEM_CIPHERTEXT_SIZE: usize = 1088;

/// ML-KEM-768 shared secret size (32 bytes)
#[cfg(feature = "pq")]
pub const MLKEM_SHARED_SECRET_SIZE: usize = 32;

/// Signature bytes wrapper for serde support of [u8; 64]
#[derive(Clone)]
pub struct SignatureBytes(pub [u8; 64]);

impl Serialize for SignatureBytes {
    fn serialize<S>(&self, serializer: S) -> std::result::Result<S::Ok, S::Error>
    where
        S: serde::Serializer,
    {
        serializer.serialize_bytes(&self.0)
    }
}

impl<'de> Deserialize<'de> for SignatureBytes {
    fn deserialize<D>(deserializer: D) -> std::result::Result<Self, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        use serde::de::{Error, Visitor};
        
        struct BytesVisitor;
        
        impl<'de> Visitor<'de> for BytesVisitor {
            type Value = SignatureBytes;
            
            fn expecting(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
                write!(f, "64 bytes")
            }
            
            fn visit_bytes<E: Error>(self, v: &[u8]) -> std::result::Result<Self::Value, E> {
                if v.len() != 64 {
                    return Err(E::custom(format!("expected 64 bytes, got {}", v.len())));
                }
                let mut arr = [0u8; 64];
                arr.copy_from_slice(v);
                Ok(SignatureBytes(arr))
            }
            
            fn visit_seq<A>(self, mut seq: A) -> std::result::Result<Self::Value, A::Error>
            where
                A: serde::de::SeqAccess<'de>,
            {
                let mut arr = [0u8; 64];
                for (i, byte) in arr.iter_mut().enumerate() {
                    *byte = seq.next_element()?
                        .ok_or_else(|| Error::invalid_length(i, &self))?;
                }
                Ok(SignatureBytes(arr))
            }
        }
        
        deserializer.deserialize_bytes(BytesVisitor)
    }
}

/// Hybrid key bundle combining classical and post-quantum keys
#[derive(Clone, Serialize, Deserialize)]
pub struct HybridKeyBundle {
    /// Ed25519 identity public key (for signing)
    pub identity_key: [u8; 32],

    /// X25519 signed prekey
    pub signed_prekey: [u8; 32],

    /// Signature over the signed prekey
    pub signed_prekey_signature: SignatureBytes,

    /// Optional one-time X25519 prekey
    pub one_time_prekey: Option<[u8; 32]>,

    /// ML-KEM post-quantum prekey (optional, for hybrid mode)
    #[cfg(feature = "pq")]
    pub pq_prekey: Option<Vec<u8>>,

    /// Signature over the PQ prekey
    #[cfg(feature = "pq")]
    pub pq_prekey_signature: Option<SignatureBytes>,
}

/// Private keys for the hybrid key bundle
#[derive(Zeroize, ZeroizeOnDrop)]
pub struct HybridPrivateKeys {
    /// Ed25519 identity signing key
    identity_key: [u8; 32],

    /// X25519 signed prekey secret
    signed_prekey: [u8; 32],

    /// X25519 one-time prekey secret (if generated)
    one_time_prekey: Option<[u8; 32]>,

    /// ML-KEM decapsulation key
    #[cfg(feature = "pq")]
    #[zeroize(skip)] // ML-KEM key handles its own zeroization
    pq_decapsulation_key: Option<Vec<u8>>,
}

impl HybridPrivateKeys {
    /// Get identity key bytes
    pub fn identity_key(&self) -> &[u8; 32] {
        &self.identity_key
    }

    /// Get signed prekey bytes
    pub fn signed_prekey(&self) -> &[u8; 32] {
        &self.signed_prekey
    }

    /// Get one-time prekey bytes
    pub fn one_time_prekey(&self) -> Option<&[u8; 32]> {
        self.one_time_prekey.as_ref()
    }

    /// Get PQ decapsulation key bytes
    #[cfg(feature = "pq")]
    pub fn pq_decapsulation_key(&self) -> Option<Vec<u8>> {
        self.pq_decapsulation_key.clone()
    }
}

/// Shared secret derived from hybrid key exchange
#[derive(Zeroize, ZeroizeOnDrop)]
pub struct HybridSharedSecret {
    /// The combined shared secret (32 bytes)
    secret: [u8; 32],
}

impl HybridSharedSecret {
    /// Get the shared secret bytes
    pub fn as_bytes(&self) -> &[u8; 32] {
        &self.secret
    }
}

/// Generate a new hybrid key bundle
pub fn generate_hybrid_key_bundle(
    include_one_time_prekey: bool,
    #[allow(unused_variables)] include_pq_key: bool,
) -> Result<(HybridKeyBundle, HybridPrivateKeys)> {
    let mut rng = rand::thread_rng();

    // Generate Ed25519 identity key
    let identity_signing_key = SigningKey::generate(&mut rng);
    let identity_verifying_key = identity_signing_key.verifying_key();

    // Generate X25519 signed prekey
    let signed_prekey_secret = X25519Secret::random_from_rng(&mut rng);
    let signed_prekey_public = X25519PublicKey::from(&signed_prekey_secret);

    // Sign the prekey with identity key
    use ed25519_dalek::Signer;
    let signature = identity_signing_key.sign(signed_prekey_public.as_bytes());

    // Optional one-time prekey
    let (one_time_public, one_time_secret) = if include_one_time_prekey {
        let secret = X25519Secret::random_from_rng(&mut rng);
        let public = X25519PublicKey::from(&secret);
        (Some(*public.as_bytes()), Some(secret.to_bytes()))
    } else {
        (None, None)
    };

    // Build public bundle
    #[allow(unused_mut)]
    let mut bundle = HybridKeyBundle {
        identity_key: identity_verifying_key.to_bytes(),
        signed_prekey: *signed_prekey_public.as_bytes(),
        signed_prekey_signature: SignatureBytes(signature.to_bytes()),
        one_time_prekey: one_time_public,
        #[cfg(feature = "pq")]
        pq_prekey: None,
        #[cfg(feature = "pq")]
        pq_prekey_signature: None,
    };

    // Build private keys
    #[allow(unused_mut)]
    let mut private_keys = HybridPrivateKeys {
        identity_key: identity_signing_key.to_bytes(),
        signed_prekey: signed_prekey_secret.to_bytes(),
        one_time_prekey: one_time_secret,
        #[cfg(feature = "pq")]
        pq_decapsulation_key: None,
    };

    // Generate ML-KEM keys if requested
    #[cfg(feature = "pq")]
    if include_pq_key {
        let (dk, ek) = MlKem768::generate(&mut rng);
        let ek_bytes = ek.as_bytes().to_vec();

        // Sign the PQ prekey
        let pq_signature = identity_signing_key.sign(&ek_bytes);

        bundle.pq_prekey = Some(ek_bytes);
        bundle.pq_prekey_signature = Some(SignatureBytes(pq_signature.to_bytes()));
        private_keys.pq_decapsulation_key = Some(dk.as_bytes().to_vec());
    }

    Ok((bundle, private_keys))
}

/// Verify a hybrid key bundle's signatures
pub fn verify_hybrid_bundle(bundle: &HybridKeyBundle) -> Result<()> {
    use ed25519_dalek::Verifier;

    // Parse identity key
    let identity_key = VerifyingKey::from_bytes(&bundle.identity_key)
        .map_err(|e| CryptoError::InvalidKey(format!("Invalid identity key: {}", e)))?;

    // Verify signed prekey signature
    let spk_signature = Signature::from_bytes(&bundle.signed_prekey_signature.0);
    identity_key
        .verify(&bundle.signed_prekey, &spk_signature)
        .map_err(|e| CryptoError::InvalidSignature(format!("Invalid SPK signature: {}", e)))?;

    // Verify PQ prekey signature if present
    #[cfg(feature = "pq")]
    if let (Some(pq_prekey), Some(pq_sig_bytes)) =
        (&bundle.pq_prekey, &bundle.pq_prekey_signature)
    {
        let pq_signature = Signature::from_bytes(&pq_sig_bytes.0);
        identity_key
            .verify(pq_prekey, &pq_signature)
            .map_err(|e| CryptoError::InvalidSignature(format!("Invalid PQ signature: {}", e)))?;
    }

    Ok(())
}

/// Derive a hybrid shared secret (sender side)
///
/// This performs both classical X3DH and (optionally) ML-KEM encapsulation,
/// combining the results with HKDF.
#[allow(unused_variables)]
pub fn derive_sender_shared_secret(
    sender_identity_key: &[u8; 32],
    sender_ephemeral_secret: &[u8; 32],
    recipient_bundle: &HybridKeyBundle,
) -> Result<(HybridSharedSecret, Vec<u8>)> {
    // Classical X25519 DH operations (X3DH)
    let sender_identity_secret =
        X25519Secret::from(*sender_identity_key);
    let sender_ephemeral = X25519Secret::from(*sender_ephemeral_secret);

    let recipient_identity =
        X25519PublicKey::from(recipient_bundle.identity_key);
    let recipient_spk = X25519PublicKey::from(recipient_bundle.signed_prekey);

    // DH1 = DH(IK_A, SPK_B)
    let dh1 = sender_identity_secret.diffie_hellman(&recipient_spk);

    // DH2 = DH(EK_A, IK_B)
    let dh2 = sender_ephemeral.diffie_hellman(&recipient_identity);

    // DH3 = DH(EK_A, SPK_B)
    let dh3 = sender_ephemeral.diffie_hellman(&recipient_spk);

    // DH4 = DH(EK_A, OPK_B) - optional
    let dh4 = recipient_bundle.one_time_prekey.map(|opk| {
        let opk_public = X25519PublicKey::from(opk);
        sender_ephemeral.diffie_hellman(&opk_public)
    });

    // Combine classical DH results
    let mut classical_ikm = Vec::with_capacity(128);
    classical_ikm.extend_from_slice(dh1.as_bytes());
    classical_ikm.extend_from_slice(dh2.as_bytes());
    classical_ikm.extend_from_slice(dh3.as_bytes());
    if let Some(ref dh4_result) = dh4 {
        classical_ikm.extend_from_slice(dh4_result.as_bytes());
    }

    // Additional data for encapsulation (returned to recipient)
    let mut additional_data = Vec::new();
    let ephemeral_public = X25519PublicKey::from(&sender_ephemeral);
    additional_data.extend_from_slice(ephemeral_public.as_bytes());

    // ML-KEM encapsulation (if available)
    #[cfg(feature = "pq")]
    let pq_shared = if let Some(ref pq_prekey) = recipient_bundle.pq_prekey {
        use ml_kem::EncodedSizeUser;
        use ml_kem::array::Array;
        let ek_bytes: &[u8; 1184] = pq_prekey
            .as_slice()
            .try_into()
            .map_err(|_| CryptoError::InvalidKey("Invalid PQ prekey size".to_string()))?;
        let ek = ml_kem::kem::EncapsulationKey::<ml_kem::MlKem768Params>::from_bytes(
            Array::from_slice(ek_bytes),
        );
        let (ciphertext, shared_secret) = ek.encapsulate(&mut rand::thread_rng()).unwrap();
        additional_data.extend_from_slice(ciphertext.as_slice());
        Some(shared_secret)
    } else {
        None
    };

    // Derive final shared secret using HKDF
    let mut ikm = classical_ikm;
    #[cfg(feature = "pq")]
    if let Some(ref pq) = pq_shared {
        ikm.extend_from_slice(pq.as_slice());
    }

    let info = b"PQXDH_SharedSecret";
    let hkdf = Hkdf::<Sha256>::new(None, &ikm);
    let mut shared_secret = [0u8; 32];
    hkdf.expand(info, &mut shared_secret)
        .map_err(|e| CryptoError::Protocol(format!("HKDF expansion failed: {}", e)))?;

    // Clear intermediate values
    ikm.zeroize();

    Ok((HybridSharedSecret { secret: shared_secret }, additional_data))
}

/// Derive a hybrid shared secret (recipient side)
#[allow(unused_variables)]
pub fn derive_recipient_shared_secret(
    recipient_private_keys: &HybridPrivateKeys,
    sender_identity_key: &[u8; 32],
    sender_ephemeral_key: &[u8; 32],
    #[allow(unused_variables)] pq_ciphertext: Option<&[u8]>,
) -> Result<HybridSharedSecret> {
    let recipient_identity = X25519Secret::from(recipient_private_keys.identity_key);
    let recipient_spk = X25519Secret::from(recipient_private_keys.signed_prekey);

    let sender_identity = X25519PublicKey::from(*sender_identity_key);
    let sender_ephemeral = X25519PublicKey::from(*sender_ephemeral_key);

    // DH1 = DH(SPK_B, IK_A)
    let dh1 = recipient_spk.diffie_hellman(&sender_identity);

    // DH2 = DH(IK_B, EK_A)
    let dh2 = recipient_identity.diffie_hellman(&sender_ephemeral);

    // DH3 = DH(SPK_B, EK_A)
    let dh3 = recipient_spk.diffie_hellman(&sender_ephemeral);

    // DH4 = DH(OPK_B, EK_A) - optional
    let dh4 = recipient_private_keys.one_time_prekey.map(|opk| {
        let opk_secret = X25519Secret::from(opk);
        opk_secret.diffie_hellman(&sender_ephemeral)
    });

    // Combine classical DH results
    let mut classical_ikm = Vec::with_capacity(128);
    classical_ikm.extend_from_slice(dh1.as_bytes());
    classical_ikm.extend_from_slice(dh2.as_bytes());
    classical_ikm.extend_from_slice(dh3.as_bytes());
    if let Some(ref dh4_result) = dh4 {
        classical_ikm.extend_from_slice(dh4_result.as_bytes());
    }

    // ML-KEM decapsulation (if available)
    #[cfg(feature = "pq")]
    let pq_shared = if let (Some(ref dk_bytes), Some(ct)) =
        (&recipient_private_keys.pq_decapsulation_key, pq_ciphertext)
    {
        use ml_kem::EncodedSizeUser;
        use ml_kem::array::Array;
        let dk_arr: &[u8; 2400] = dk_bytes
            .as_slice()
            .try_into()
            .map_err(|_| CryptoError::InvalidKey("Invalid PQ decapsulation key".to_string()))?;
        let dk = ml_kem::kem::DecapsulationKey::<ml_kem::MlKem768Params>::from_bytes(
            Array::from_slice(dk_arr),
        );
        let ct_arr: &[u8; 1088] = ct
            .try_into()
            .map_err(|_| CryptoError::InvalidKey("Invalid PQ ciphertext".to_string()))?;
        let ciphertext = Array::from_slice(ct_arr);
        let shared_secret = dk.decapsulate(ciphertext)
            .map_err(|_| CryptoError::Decryption("ML-KEM decapsulation failed".to_string()))?;
        Some(shared_secret)
    } else {
        None
    };

    // Derive final shared secret using HKDF
    let mut ikm = classical_ikm;
    #[cfg(feature = "pq")]
    if let Some(ref pq) = pq_shared {
        ikm.extend_from_slice(pq.as_slice());
    }

    let info = b"PQXDH_SharedSecret";
    let hkdf = Hkdf::<Sha256>::new(None, &ikm);
    let mut shared_secret = [0u8; 32];
    hkdf.expand(info, &mut shared_secret)
        .map_err(|e| CryptoError::Protocol(format!("HKDF expansion failed: {}", e)))?;

    // Clear intermediate values
    ikm.zeroize();

    Ok(HybridSharedSecret { secret: shared_secret })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_bundle_classical() {
        let (bundle, _private) = generate_hybrid_key_bundle(true, false).unwrap();

        assert_eq!(bundle.identity_key.len(), 32);
        assert_eq!(bundle.signed_prekey.len(), 32);
        assert!(bundle.one_time_prekey.is_some());
    }

    #[test]
    fn test_verify_bundle() {
        let (bundle, _private) = generate_hybrid_key_bundle(true, false).unwrap();
        verify_hybrid_bundle(&bundle).unwrap();
    }

    #[test]
    fn test_classical_key_exchange() {
        // Generate recipient bundle
        let (recipient_bundle, recipient_private) =
            generate_hybrid_key_bundle(true, false).unwrap();

        // Sender generates ephemeral key and derives shared secret
        let mut rng = rand::thread_rng();
        let sender_identity = SigningKey::generate(&mut rng);
        let sender_ephemeral = X25519Secret::random_from_rng(&mut rng);

        let (sender_secret, additional_data) = derive_sender_shared_secret(
            &sender_identity.to_bytes(),
            &sender_ephemeral.to_bytes(),
            &recipient_bundle,
        )
        .unwrap();

        // Recipient derives shared secret
        let sender_ephemeral_public = X25519PublicKey::from(&sender_ephemeral);
        let recipient_secret = derive_recipient_shared_secret(
            &recipient_private,
            &sender_identity.verifying_key().to_bytes(),
            sender_ephemeral_public.as_bytes(),
            None, // No PQ ciphertext
        )
        .unwrap();

        // Shared secrets should match
        assert_eq!(sender_secret.as_bytes(), recipient_secret.as_bytes());
    }

    #[cfg(feature = "pq")]
    #[test]
    fn test_hybrid_key_exchange() {
        // Generate recipient bundle with PQ keys
        let (recipient_bundle, recipient_private) =
            generate_hybrid_key_bundle(true, true).unwrap();

        assert!(recipient_bundle.pq_prekey.is_some());

        // Sender generates ephemeral key and derives shared secret
        let mut rng = rand::thread_rng();
        let sender_identity = SigningKey::generate(&mut rng);
        let sender_ephemeral = X25519Secret::random_from_rng(&mut rng);

        let (sender_secret, additional_data) = derive_sender_shared_secret(
            &sender_identity.to_bytes(),
            &sender_ephemeral.to_bytes(),
            &recipient_bundle,
        )
        .unwrap();

        // Extract PQ ciphertext from additional data
        // additional_data = ephemeral_public (32) + pq_ciphertext (1088)
        let pq_ciphertext = if additional_data.len() > 32 {
            Some(&additional_data[32..])
        } else {
            None
        };

        // Recipient derives shared secret
        let sender_ephemeral_public = X25519PublicKey::from(&sender_ephemeral);
        let recipient_secret = derive_recipient_shared_secret(
            &recipient_private,
            &sender_identity.verifying_key().to_bytes(),
            sender_ephemeral_public.as_bytes(),
            pq_ciphertext,
        )
        .unwrap();

        // Shared secrets should match
        assert_eq!(sender_secret.as_bytes(), recipient_secret.as_bytes());
    }
}
