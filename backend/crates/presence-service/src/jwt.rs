/// JWT token validation and claims extraction
///
/// Validates JWT tokens issued by auth-service and extracts user claims

use anyhow::{anyhow, Result};
use jsonwebtoken::{decode, DecodingKey, Validation, Algorithm};
use serde::{Deserialize, Serialize};

/// JWT claims structure (must match auth-service)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String,       // User ID
    pub username: String,  // Username
    pub device_id: String, // Device ID
    pub exp: usize,        // Expiration time
    pub iat: usize,        // Issued at
}

/// Validate JWT token and extract claims
pub fn validate_token(token: &str, secret: &str) -> Result<Claims> {
    let validation = Validation::new(Algorithm::HS256);
    let key = DecodingKey::from_secret(secret.as_bytes());

    let token_data = decode::<Claims>(token, &key, &validation)
        .map_err(|e| anyhow!("Invalid token: {}", e))?;

    Ok(token_data.claims)
}

/// Extract user_id from token (convenience function)
pub fn get_user_id_from_token(token: &str, secret: &str) -> Result<String> {
    let claims = validate_token(token, secret)?;
    Ok(claims.sub)
}
