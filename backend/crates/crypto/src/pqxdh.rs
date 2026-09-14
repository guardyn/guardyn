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
#![allow(unused_assignments)]

use crate::x3dh::{ed25519_public_to_x25519, ed25519_secret_to_x25519};
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
                    *byte = seq
                        .next_element()?
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
#[allow(unused_assignments)]
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
    #[allow(unused_assignments)]
    pq_decapsulation_key: Option<Vec<u8>>,
}

impl HybridPrivateKeys {
    /// Rebuild the private half of a hybrid bundle from keys held elsewhere.
    ///
    /// [`generate_hybrid_key_bundle`] is the only other constructor, and it mints fresh keys. A
    /// responder answering a handshake holds its published pre-keys in its own secure storage
    /// and must reconstruct the same value, so this is the seam between that storage and
    /// [`derive_recipient_shared_secret`].
    ///
    /// `identity_key` is the **Ed25519 signing key**, not its X25519 form: the bundle signs its
    /// pre-keys with it, and the classical half of the agreement converts it internally through
    /// `ed25519_secret_to_x25519`. An Ed25519 secret is not the X25519 secret of the same seed,
    /// and passing the converted form here derives a secret the initiator will not match - a
    /// failure that surfaces only as an AEAD tag rejection. See
    /// `docs/adr/ADR-0005-hybrid-pqxdh.md`.
    ///
    /// `signed_prekey` and `one_time_prekey` are X25519 secrets. `pq_decapsulation_key` is the
    /// 2400-byte ML-KEM-768 decapsulation key; `None` makes this a classical-only responder,
    /// which cannot answer a handshake that carries a ciphertext.
    pub fn from_parts(
        identity_key: [u8; 32],
        signed_prekey: [u8; 32],
        one_time_prekey: Option<[u8; 32]>,
        #[cfg(feature = "pq")] pq_decapsulation_key: Option<Vec<u8>>,
    ) -> Self {
        Self {
            identity_key,
            signed_prekey,
            one_time_prekey,
            #[cfg(feature = "pq")]
            pq_decapsulation_key,
        }
    }

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
#[allow(unused_assignments)]
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
    // Generate ML-KEM keys if requested
    #[cfg(feature = "pq")]
    let pq_result: Option<(Vec<u8>, Vec<u8>, SignatureBytes)> = if include_pq_key {
        let (dk, ek) = MlKem768::generate(&mut rng);
        let ek_bytes = ek.as_bytes().to_vec();
        let pq_signature = identity_signing_key.sign(&ek_bytes);
        Some((
            dk.as_bytes().to_vec(),
            ek_bytes,
            SignatureBytes(pq_signature.to_bytes()),
        ))
    } else {
        None
    };

    #[cfg(feature = "pq")]
    if let Some((_, ref ek_bytes, ref pq_sig)) = pq_result {
        bundle.pq_prekey = Some(ek_bytes.clone());
        bundle.pq_prekey_signature = Some(pq_sig.clone());
    }

    let private_keys = HybridPrivateKeys {
        identity_key: identity_signing_key.to_bytes(),
        signed_prekey: signed_prekey_secret.to_bytes(),
        one_time_prekey: one_time_secret,
        #[cfg(feature = "pq")]
        pq_decapsulation_key: pq_result.map(|(dk, _, _)| dk),
    };

    Ok((bundle, private_keys))
}

/// Verify a hybrid key bundle's signatures.
///
/// Both pre-keys are signed by the same Ed25519 identity key: one identity, one signer. The
/// signed pre-key is mandatory; the ML-KEM pre-key is optional, but its two fields are
/// **present together or absent together**.
///
/// A bundle carrying one half of that pair is rejected **in whole**, never degraded to the
/// classical-only exchange. Degrading is what an attacker wants - stripping one field is
/// cheaper than breaking either primitive, and a silent fallback converts a tampered bundle
/// into a session the post-quantum half no longer protects. `docs/spec/SRS.md` rule 4a is the
/// contract; `auth-service`'s `db::KeyBundle::validate_for_store` enforces the same shape on
/// the way into the store, but a bundle can reach a client from somewhere other than
/// `GetKeyBundle`, so the check has to exist on both sides.
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

    // Verify the ML-KEM pre-key. Exhaustive on purpose: this was an `if let (Some, Some)` with
    // no `else`, so a half pair fell through to `Ok(())` and read as a valid classical bundle.
    #[cfg(feature = "pq")]
    match (&bundle.pq_prekey, &bundle.pq_prekey_signature) {
        (Some(pq_prekey), Some(pq_sig_bytes)) => {
            let pq_signature = Signature::from_bytes(&pq_sig_bytes.0);
            identity_key.verify(pq_prekey, &pq_signature).map_err(|e| {
                CryptoError::InvalidSignature(format!("Invalid PQ signature: {}", e))
            })?;
        }
        // Classical-only. Classical strength is the floor, so this is a legitimate bundle.
        (None, None) => {}
        (Some(_), None) => {
            return Err(CryptoError::InvalidKey(
                "refusing an ML-KEM pre-key with no signature".to_string(),
            ))
        }
        (None, Some(_)) => {
            return Err(CryptoError::InvalidKey(
                "refusing an ML-KEM signature with no pre-key".to_string(),
            ))
        }
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
    // Classical X25519 DH operations (X3DH).
    // Identity keys are Ed25519 on both sides and must be mapped onto Curve25519 before any
    // Diffie-Hellman; the signed and one-time prekeys are already X25519.
    let sender_identity_secret = ed25519_secret_to_x25519(sender_identity_key);
    let sender_ephemeral = X25519Secret::from(*sender_ephemeral_secret);

    let recipient_identity = ed25519_public_to_x25519(&recipient_bundle.identity_key)?;
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
        let ek_bytes: &[u8; 1184] = pq_prekey
            .as_slice()
            .try_into()
            .map_err(|_| CryptoError::InvalidKey("Invalid PQ prekey size".to_string()))?;
        let ek =
            ml_kem::kem::EncapsulationKey::<ml_kem::MlKem768Params>::from_bytes(ek_bytes.into());
        // Reachable from a peer's published bundle as of PR-39b, so it propagates rather than
        // panicking: a Tauri command that unwinds takes the session with it and tells the user
        // nothing. RS-UNWRAP in `.claude/rules/20-code-style.md` is the standing rule.
        let (ciphertext, shared_secret) = ek
            .encapsulate(&mut rand::thread_rng())
            .map_err(|_| CryptoError::Encryption("ML-KEM encapsulation failed".to_string()))?;
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

    Ok((
        HybridSharedSecret {
            secret: shared_secret,
        },
        additional_data,
    ))
}

/// Derive a hybrid shared secret (recipient side)
#[allow(unused_variables)]
pub fn derive_recipient_shared_secret(
    recipient_private_keys: &HybridPrivateKeys,
    sender_identity_key: &[u8; 32],
    sender_ephemeral_key: &[u8; 32],
    #[allow(unused_variables)] pq_ciphertext: Option<&[u8]>,
) -> Result<HybridSharedSecret> {
    // Mirror of the sender: the Ed25519 identity keys on both sides are mapped onto
    // Curve25519 before any Diffie-Hellman.
    let recipient_identity = ed25519_secret_to_x25519(&recipient_private_keys.identity_key);
    let recipient_spk = X25519Secret::from(recipient_private_keys.signed_prekey);

    let sender_identity = ed25519_public_to_x25519(sender_identity_key)?;
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
        let dk_arr: &[u8; 2400] = dk_bytes
            .as_slice()
            .try_into()
            .map_err(|_| CryptoError::InvalidKey("Invalid PQ decapsulation key".to_string()))?;
        let dk = ml_kem::kem::DecapsulationKey::<ml_kem::MlKem768Params>::from_bytes(dk_arr.into());
        let ct_arr: &[u8; 1088] = ct
            .try_into()
            .map_err(|_| CryptoError::InvalidKey("Invalid PQ ciphertext".to_string()))?;
        let ciphertext = ct_arr.into();
        let shared_secret = dk
            .decapsulate(ciphertext)
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

    Ok(HybridSharedSecret {
        secret: shared_secret,
    })
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

        let (sender_secret, _additional_data) = derive_sender_shared_secret(
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
        let (recipient_bundle, recipient_private) = generate_hybrid_key_bundle(true, true).unwrap();

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

    /// A bundle with neither ML-KEM field is a classical-only device, which is legal.
    ///
    /// This is the case the half-pair rejection must not catch: classical strength is the
    /// floor, and absence of post-quantum material is not a tampered bundle.
    #[test]
    fn verify_accepts_a_classical_bundle() {
        let (bundle, _private) = generate_hybrid_key_bundle(true, false).unwrap();
        verify_hybrid_bundle(&bundle).expect("a classical-only bundle is legitimate");
    }

    /// Regression for the half-pair defect: the ML-KEM key with its signature stripped.
    ///
    /// Before the fix `verify_hybrid_bundle` checked the pair under `if let (Some, Some)` with
    /// no `else`, so this bundle returned `Ok(())` and was indistinguishable from a classical
    /// one - which is exactly the downgrade `docs/spec/SRS.md` rule 4a forbids. Stripping a
    /// field is cheaper than breaking a primitive, so this must fail.
    #[cfg(feature = "pq")]
    #[test]
    fn verify_rejects_a_pq_key_with_no_signature() {
        let (mut bundle, _private) = generate_hybrid_key_bundle(true, true).unwrap();
        assert!(bundle.pq_prekey.is_some());

        bundle.pq_prekey_signature = None;

        let err = verify_hybrid_bundle(&bundle)
            .expect_err("an ML-KEM pre-key with no signature must be rejected in whole");
        assert!(
            matches!(err, CryptoError::InvalidKey(_)),
            "expected InvalidKey, got {:?}",
            err
        );
    }

    /// The mirror of the case above: a signature with no key to verify it against.
    ///
    /// Rejected for the same reason and with the same force - the pair is present together or
    /// absent together, and neither orphan is a classical bundle.
    #[cfg(feature = "pq")]
    #[test]
    fn verify_rejects_a_pq_signature_with_no_key() {
        let (mut bundle, _private) = generate_hybrid_key_bundle(true, true).unwrap();
        assert!(bundle.pq_prekey_signature.is_some());

        bundle.pq_prekey = None;

        let err = verify_hybrid_bundle(&bundle)
            .expect_err("an ML-KEM signature with no pre-key must be rejected in whole");
        assert!(
            matches!(err, CryptoError::InvalidKey(_)),
            "expected InvalidKey, got {:?}",
            err
        );
    }

    /// A whole pair still verifies once the match is exhaustive.
    #[cfg(feature = "pq")]
    #[test]
    fn verify_accepts_a_whole_pq_pair() {
        let (bundle, _private) = generate_hybrid_key_bundle(true, true).unwrap();
        verify_hybrid_bundle(&bundle).expect("a whole ML-KEM pair is legitimate");
    }

    /// A tampered ML-KEM pre-key fails its signature rather than being silently accepted.
    #[cfg(feature = "pq")]
    #[test]
    fn verify_rejects_a_tampered_pq_prekey() {
        let (mut bundle, _private) = generate_hybrid_key_bundle(true, true).unwrap();
        bundle.pq_prekey.as_mut().unwrap()[0] ^= 0xff;

        let err = verify_hybrid_bundle(&bundle).expect_err("a tampered ML-KEM pre-key must fail");
        assert!(
            matches!(err, CryptoError::InvalidSignature(_)),
            "expected InvalidSignature, got {:?}",
            err
        );
    }

    /// [`HybridPrivateKeys::from_parts`] reconstructs a private half that agrees with the
    /// initiator.
    ///
    /// This is what the desktop responder does: its pre-key secrets live in the OS keyring, not
    /// in a [`HybridPrivateKeys`] returned by [`generate_hybrid_key_bundle`], so it has to
    /// rebuild the value. Round-tripping a real handshake through the rebuilt keys is the only
    /// thing that proves the reconstruction is faithful - in particular that `identity_key` is
    /// the Ed25519 secret and not its X25519 form, a confusion that still derives *a* secret,
    /// just not the same one.
    #[cfg(feature = "pq")]
    #[test]
    fn from_parts_reproduces_the_sender_secret() {
        let (recipient_bundle, generated) = generate_hybrid_key_bundle(true, true).unwrap();

        let mut rng = rand::thread_rng();
        let sender_identity = SigningKey::generate(&mut rng);
        let sender_ephemeral = X25519Secret::random_from_rng(&mut rng);

        let (sender_secret, additional_data) = derive_sender_shared_secret(
            &sender_identity.to_bytes(),
            &sender_ephemeral.to_bytes(),
            &recipient_bundle,
        )
        .unwrap();

        // `additional_data` is `ephemeral_public(32) || ciphertext`; only the ciphertext travels
        // in the prekey message, because the ephemeral key is already carried there.
        let pq_ciphertext = &additional_data[32..];

        // Rebuild the private half from its parts, as a responder loading them from storage
        // would.
        let rebuilt = HybridPrivateKeys::from_parts(
            *generated.identity_key(),
            *generated.signed_prekey(),
            generated.one_time_prekey().copied(),
            generated.pq_decapsulation_key(),
        );

        let sender_ephemeral_public = X25519PublicKey::from(&sender_ephemeral);
        let recipient_secret = derive_recipient_shared_secret(
            &rebuilt,
            &sender_identity.verifying_key().to_bytes(),
            sender_ephemeral_public.as_bytes(),
            Some(pq_ciphertext),
        )
        .unwrap();

        assert_eq!(sender_secret.as_bytes(), recipient_secret.as_bytes());
    }

    /// Without the decapsulation key the rebuilt responder cannot reach the initiator's secret.
    ///
    /// It does not error - the classical halves still agree - so the mismatch would surface only
    /// as an AEAD tag rejection. Pinning it here documents why the responder must treat a
    /// missing decapsulation key as a hard failure rather than deriving anyway.
    #[cfg(feature = "pq")]
    #[test]
    fn from_parts_without_the_decapsulation_key_diverges() {
        let (recipient_bundle, generated) = generate_hybrid_key_bundle(true, true).unwrap();

        let mut rng = rand::thread_rng();
        let sender_identity = SigningKey::generate(&mut rng);
        let sender_ephemeral = X25519Secret::random_from_rng(&mut rng);

        let (sender_secret, additional_data) = derive_sender_shared_secret(
            &sender_identity.to_bytes(),
            &sender_ephemeral.to_bytes(),
            &recipient_bundle,
        )
        .unwrap();

        let classical_only = HybridPrivateKeys::from_parts(
            *generated.identity_key(),
            *generated.signed_prekey(),
            generated.one_time_prekey().copied(),
            None,
        );

        let sender_ephemeral_public = X25519PublicKey::from(&sender_ephemeral);
        let recipient_secret = derive_recipient_shared_secret(
            &classical_only,
            &sender_identity.verifying_key().to_bytes(),
            sender_ephemeral_public.as_bytes(),
            Some(&additional_data[32..]),
        )
        .unwrap();

        assert_ne!(sender_secret.as_bytes(), recipient_secret.as_bytes());
    }
}
