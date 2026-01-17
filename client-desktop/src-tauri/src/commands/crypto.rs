//! Cryptography Commands
//!
//! Exposes guardyn-crypto functionality to the frontend.

use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct KeyBundle {
    pub identity_key: String,
    pub signed_prekey: String,
    pub prekey_signature: String,
    pub one_time_prekey: Option<String>,
    #[cfg(feature = "pq")]
    pub pq_prekey: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct EncryptedMessage {
    pub ciphertext: String,
    pub nonce: String,
    pub header: String,
}

/// Generate a new key bundle for E2EE
#[tauri::command]
pub async fn generate_key_bundle(include_pq: bool) -> Result<KeyBundle, String> {
    tracing::debug!("Generating key bundle (PQ: {})", include_pq);

    // Use guardyn-crypto to generate keys
    #[cfg(feature = "pq")]
    if include_pq {
        match guardyn_crypto::pqxdh::generate_hybrid_key_bundle(true, true) {
            Ok((bundle, _private_keys)) => {
                return Ok(KeyBundle {
                    identity_key: hex::encode(&bundle.identity_key),
                    signed_prekey: hex::encode(&bundle.signed_prekey),
                    prekey_signature: hex::encode(&bundle.signed_prekey_signature.0),
                    one_time_prekey: bundle.one_time_prekey.map(|k| hex::encode(&k)),
                    pq_prekey: bundle.pq_prekey.map(|k| hex::encode(&k)),
                });
            }
            Err(e) => return Err(format!("Failed to generate key bundle: {}", e)),
        }
    }

    // Classical key bundle (without PQ)
    match guardyn_crypto::pqxdh::generate_hybrid_key_bundle(true, false) {
        Ok((bundle, _private_keys)) => Ok(KeyBundle {
            identity_key: hex::encode(&bundle.identity_key),
            signed_prekey: hex::encode(&bundle.signed_prekey),
            prekey_signature: hex::encode(&bundle.signed_prekey_signature.0),
            one_time_prekey: bundle.one_time_prekey.map(|k| hex::encode(&k)),
            #[cfg(feature = "pq")]
            pq_prekey: None,
        }),
        Err(e) => Err(format!("Failed to generate key bundle: {}", e)),
    }
}

/// Encrypt a message using the appropriate protocol
#[tauri::command]
pub async fn encrypt_message(
    plaintext: String,
    _recipient_id: String,
) -> Result<EncryptedMessage, String> {
    tracing::debug!("Encrypting message ({} bytes)", plaintext.len());

    // First, apply PADMÉ padding
    let padded = guardyn_crypto::pad_message(plaintext.as_bytes())
        .map_err(|e| format!("Padding failed: {}", e))?;

    // TODO: Encrypt with Double Ratchet using recipient's session
    // For now, return a placeholder

    Ok(EncryptedMessage {
        ciphertext: hex::encode(&padded),
        nonce: hex::encode([0u8; 12]),
        header: "placeholder".to_string(),
    })
}

/// Decrypt a message
#[tauri::command]
pub async fn decrypt_message(
    ciphertext: String,
    nonce: String,
    _sender_id: String,
) -> Result<String, String> {
    tracing::debug!("Decrypting message");

    // TODO: Decrypt with Double Ratchet using sender's session
    // For now, just decode and unpad

    let padded =
        hex::decode(&ciphertext).map_err(|e| format!("Invalid ciphertext hex: {}", e))?;

    let _nonce_bytes = hex::decode(&nonce).map_err(|e| format!("Invalid nonce hex: {}", e))?;

    // Remove PADMÉ padding
    let plaintext = guardyn_crypto::unpad_message(&padded)
        .map_err(|e| format!("Unpadding failed: {}", e))?;

    String::from_utf8(plaintext).map_err(|e| format!("Invalid UTF-8: {}", e))
}
