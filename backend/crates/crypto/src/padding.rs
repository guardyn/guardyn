//! PADMÉ Padding Implementation
//!
//! PADMÉ (Padding for Avoiding Detection of Message Encoding) is a padding scheme
//! that provides better traffic analysis protection than naive padding while
//! maintaining reasonable overhead.
//!
//! Reference: "PADMÉ Unpadded: Avoiding Metadata Leakage in Messaging Applications"
//! https://eprint.iacr.org/2019/1491

use zeroize::Zeroize;

/// Minimum padded length (prevents fingerprinting of very short messages)
const MIN_PADDED_LENGTH: usize = 32;

/// Maximum message length we support
const MAX_MESSAGE_LENGTH: usize = 16 * 1024 * 1024; // 16 MB

/// PADMÉ padding errors
#[derive(Debug, thiserror::Error)]
pub enum PaddingError {
    #[error("Message too large: {0} bytes (max: {1})")]
    MessageTooLarge(usize, usize),

    #[error("Invalid padding: {0}")]
    InvalidPadding(String),

    #[error("Padded message too short")]
    TooShort,
}

/// Pad a message using the PADMÉ scheme
///
/// The PADMÉ algorithm pads messages to lengths that follow a specific pattern,
/// providing a balance between privacy (hiding true message length) and efficiency
/// (not using excessive padding).
///
/// # Arguments
/// * `plaintext` - The message to pad
///
/// # Returns
/// * Padded message with ISO/IEC 7816-4 padding marker
///
/// # Example
/// ```ignore
/// let padded = pad_message(b"Hello, World!")?;
/// assert!(padded.len() >= 32);
/// ```
pub fn pad_message(plaintext: &[u8]) -> Result<Vec<u8>, PaddingError> {
    if plaintext.len() > MAX_MESSAGE_LENGTH {
        return Err(PaddingError::MessageTooLarge(plaintext.len(), MAX_MESSAGE_LENGTH));
    }

    let padded_len = next_padme_length(plaintext.len());
    let mut padded = vec![0u8; padded_len];

    // Copy plaintext
    padded[..plaintext.len()].copy_from_slice(plaintext);

    // ISO/IEC 7816-4 padding: 0x80 followed by zeros
    padded[plaintext.len()] = 0x80;

    Ok(padded)
}

/// Remove PADMÉ padding from a message
///
/// # Arguments
/// * `padded` - The padded message
///
/// # Returns
/// * Original plaintext with padding removed
pub fn unpad_message(padded: &[u8]) -> Result<Vec<u8>, PaddingError> {
    if padded.is_empty() {
        return Err(PaddingError::TooShort);
    }

    // Find the padding marker (0x80) from the end
    let mut padding_start = None;
    for i in (0..padded.len()).rev() {
        if padded[i] == 0x80 {
            padding_start = Some(i);
            break;
        } else if padded[i] != 0x00 {
            // Found non-zero byte that isn't the padding marker
            return Err(PaddingError::InvalidPadding(
                "Invalid padding bytes found".to_string(),
            ));
        }
    }

    match padding_start {
        Some(pos) => Ok(padded[..pos].to_vec()),
        None => Err(PaddingError::InvalidPadding(
            "Padding marker not found".to_string(),
        )),
    }
}

/// Calculate the next PADMÉ length for a given message size
///
/// For messages <= 256 bytes: round up to nearest 16 bytes
/// For larger messages: use PADMÉ exponential scheme
///
/// This provides:
/// - 16-byte granularity for small messages (acceptable overhead)
/// - Exponential buckets for larger messages (better privacy)
pub fn next_padme_length(len: usize) -> usize {
    // Ensure minimum length
    let len = len.max(1);
    let needed = len + 1; // +1 for padding marker

    if needed <= MIN_PADDED_LENGTH {
        return MIN_PADDED_LENGTH;
    }

    if needed <= 256 {
        // 16-byte alignment for small messages
        return ((needed + 15) / 16) * 16;
    }

    // PADMÉ algorithm for larger messages
    // L' = 2^(floor(log2(L)) - floor(log2(floor(log2(L))+1)))
    // Round L up to next multiple of L'

    let e = (needed as f64).log2().floor() as u32;
    let s = ((e as f64).log2().floor() as u32) + 1;

    if e <= s {
        // Fallback for edge cases
        return needed.next_power_of_two();
    }

    let granularity = 1usize << (e - s);
    let padded = ((needed + granularity - 1) / granularity) * granularity;

    // Ensure result is at least as large as input + padding marker
    padded.max(needed)
}

/// Securely zeroize a padded buffer after use
pub fn secure_zeroize(buffer: &mut [u8]) {
    buffer.zeroize();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_pad_small_message() {
        let msg = b"Hello";
        let padded = pad_message(msg).unwrap();
        assert_eq!(padded.len(), MIN_PADDED_LENGTH);
        assert_eq!(&padded[..5], msg);
        assert_eq!(padded[5], 0x80);
    }

    #[test]
    fn test_unpad_message() {
        let msg = b"Hello, World!";
        let padded = pad_message(msg).unwrap();
        let unpadded = unpad_message(&padded).unwrap();
        assert_eq!(unpadded, msg);
    }

    #[test]
    fn test_padme_lengths() {
        // Small messages get 16-byte alignment
        assert_eq!(next_padme_length(1), 32);
        assert_eq!(next_padme_length(15), 32);
        assert_eq!(next_padme_length(31), 32);
        assert_eq!(next_padme_length(32), 48);

        // Medium messages
        assert_eq!(next_padme_length(100), 112);
        assert_eq!(next_padme_length(200), 208);

        // Large messages use exponential buckets
        let len_1k = next_padme_length(1000);
        let len_2k = next_padme_length(2000);
        assert!(len_1k >= 1001);
        assert!(len_2k >= 2001);

        // Verify bucket sizes grow
        let bucket_1k = len_1k - 1000;
        let bucket_2k = len_2k - 2000;
        assert!(bucket_2k >= bucket_1k); // Larger messages have larger buckets
    }

    #[test]
    fn test_empty_message() {
        let padded = pad_message(b"").unwrap();
        assert_eq!(padded.len(), MIN_PADDED_LENGTH);
        assert_eq!(padded[0], 0x80);

        let unpadded = unpad_message(&padded).unwrap();
        assert!(unpadded.is_empty());
    }

    #[test]
    fn test_message_too_large() {
        let large_msg = vec![0u8; MAX_MESSAGE_LENGTH + 1];
        let result = pad_message(&large_msg);
        assert!(matches!(result, Err(PaddingError::MessageTooLarge(_, _))));
    }

    #[test]
    fn test_invalid_padding() {
        // Message with no padding marker
        let invalid = vec![0x41, 0x42, 0x43, 0x00, 0x00];
        let result = unpad_message(&invalid);
        assert!(matches!(result, Err(PaddingError::InvalidPadding(_))));
    }

    #[test]
    fn test_roundtrip_various_sizes() {
        for size in [0, 1, 15, 16, 17, 100, 256, 1000, 10000] {
            let msg: Vec<u8> = (0..size).map(|i| (i % 256) as u8).collect();
            let padded = pad_message(&msg).unwrap();
            let unpadded = unpad_message(&padded).unwrap();
            assert_eq!(unpadded, msg, "Failed for size {}", size);
        }
    }
}
