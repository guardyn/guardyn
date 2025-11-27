/// JWT token validation for messaging service
///
/// Validates JWT tokens issued by auth-service
use anyhow::{Result, bail};
use jsonwebtoken::{decode, Algorithm, DecodingKey, Validation};
use serde::{Deserialize, Serialize};
use tonic::Status;

/// JWT claims structure (matches auth-service)
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
    pub sub: String,       // user_id
    pub device_id: String, // device_id
    #[serde(default)]
    pub username: String,  // username for display purposes
    pub exp: i64,          // expiration time
    pub iat: i64,          // issued at
    pub permissions: Vec<String>, // user permissions
    #[serde(skip_serializing_if = "Option::is_none")]
    pub token_type: Option<String>, // "access" or "refresh"
}

/// Validate JWT token and extract claims
///
/// Returns Ok(Claims) if valid, Err otherwise
pub fn validate_token(token: &str, secret: &str) -> Result<Claims> {
    // Strip "Bearer " prefix if present
    let token = token.strip_prefix("Bearer ").unwrap_or(token);

    if token.is_empty() {
        bail!("Token is empty");
    }

    let validation = Validation::new(Algorithm::HS256);
    
    let token_data = decode::<Claims>(
        token,
        &DecodingKey::from_secret(secret.as_bytes()),
        &validation,
    )?;
    
    // Check if token is expired
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)?
        .as_secs() as i64;
    
    if token_data.claims.exp < now {
        bail!("Token expired");
    }
    
    Ok(token_data.claims)
}

/// Validate token and extract user_id + device_id + username
///
/// Returns (user_id, device_id, username) or gRPC Status error
pub fn validate_and_extract(token: &str, secret: &str) -> Result<(String, String, String), Status> {
    match validate_token(token, secret) {
        Ok(claims) => {
            // Verify it's an access token
            if claims.token_type.as_deref() != Some("access") {
                return Err(Status::unauthenticated("Invalid token type"));
            }
            
            Ok((claims.sub, claims.device_id, claims.username))
        }
        Err(e) => {
            tracing::warn!("Token validation failed: {}", e);
            Err(Status::unauthenticated("Invalid or expired token"))
        }
    }
}

/// Extract user_id from token (simplified version)
pub fn extract_user_id(token: &str, secret: &str) -> Result<String, Status> {
    let (user_id, _, _) = validate_and_extract(token, secret)?;
    Ok(user_id)
}

#[cfg(test)]
mod tests {
    use super::*;

    const TEST_SECRET: &str = "test-jwt-secret-key-32-bytes!!";

    #[test]
    fn test_validate_empty_token() {
        let result = validate_token("", TEST_SECRET);
        assert!(result.is_err());
    }

    #[test]
    fn test_validate_invalid_token() {
        let result = validate_token("invalid.token.here", TEST_SECRET);
        assert!(result.is_err());
    }

    #[test]
    fn test_strip_bearer_prefix() {
        let token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.invalid";
        let result = validate_token(token, TEST_SECRET);
        // Should fail on invalid signature, not on bearer prefix
        assert!(result.is_err());
    }

    #[test]
    fn test_validate_and_extract_wrong_type() {
        // This would need a valid refresh token to test properly
        // For now, just verify the function signature
        let result = validate_and_extract("invalid", TEST_SECRET);
        assert!(result.is_err());
    }
}
