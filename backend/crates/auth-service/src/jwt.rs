/// JWT token generation and validation
///
/// Handles:
/// - Access token generation (15 min expiry)
/// - Refresh token generation (30 days expiry)
/// - Token validation
/// - Claims extraction

use anyhow::{Result, bail};
use jsonwebtoken::{decode, encode, Algorithm, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};

/// JWT token type
#[derive(Debug, Clone, PartialEq)]
pub enum TokenType {
    Access,
    Refresh,
}

/// JWT claims for access tokens
#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String,       // user_id
    pub device_id: String, // device_id
    pub username: String,  // username for display purposes
    pub exp: i64,          // expiration time
    pub iat: i64,          // issued at
    pub permissions: Vec<String>, // user permissions
    #[serde(skip_serializing_if = "Option::is_none")]
    pub token_type: Option<String>, // "access" or "refresh"
}

/// Generate access token (15 minutes)
pub fn generate_access_token(
    user_id: &str,
    device_id: &str,
    username: &str,
    secret: &str,
) -> Result<String> {
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)?
        .as_secs() as i64;
    
    let claims = Claims {
        sub: user_id.to_string(),
        device_id: device_id.to_string(),
        username: username.to_string(),
        exp: now + 15 * 60, // 15 minutes
        iat: now,
        permissions: vec!["read".to_string(), "write".to_string()],
        token_type: Some("access".to_string()),
    };
    
    let header = Header::new(Algorithm::HS256);
    let token = encode(
        &header,
        &claims,
        &EncodingKey::from_secret(secret.as_bytes()),
    )?;
    
    Ok(token)
}

/// Generate refresh token (30 days)
pub fn generate_refresh_token(
    user_id: &str,
    device_id: &str,
    username: &str,
    secret: &str,
) -> Result<String> {
    let now = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)?
        .as_secs() as i64;
    
    let claims = Claims {
        sub: user_id.to_string(),
        device_id: device_id.to_string(),
        username: username.to_string(),
        exp: now + 30 * 24 * 60 * 60, // 30 days
        iat: now,
        permissions: vec![],
        token_type: Some("refresh".to_string()),
    };
    
    let header = Header::new(Algorithm::HS256);
    let token = encode(
        &header,
        &claims,
        &EncodingKey::from_secret(secret.as_bytes()),
    )?;
    
    Ok(token)
}

/// Validate token and extract claims
pub fn validate_token(token: &str, secret: &str) -> Result<Claims> {
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

/// Extract token type from claims
pub fn get_token_type(claims: &Claims) -> TokenType {
    match claims.token_type.as_deref() {
        Some("refresh") => TokenType::Refresh,
        _ => TokenType::Access,
    }
}

/// Verify a JWT token and return user ID
pub fn verify_jwt(token: &str, secret: &str) -> Result<String, tonic::Status> {
    match validate_token(token, secret) {
        Ok(claims) => Ok(claims.sub),
        Err(_) => Err(tonic::Status::unauthenticated("Invalid token")),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const TEST_SECRET: &str = "test-secret-key";

    #[test]
    fn test_generate_access_token() {
        let token = generate_access_token("user123", "device456", "testuser", TEST_SECRET).unwrap();
        assert!(!token.is_empty());
        
        let claims = validate_token(&token, TEST_SECRET).unwrap();
        assert_eq!(claims.sub, "user123");
        assert_eq!(claims.device_id, "device456");
        assert_eq!(claims.username, "testuser");
        assert_eq!(get_token_type(&claims), TokenType::Access);
    }

    #[test]
    fn test_generate_refresh_token() {
        let token = generate_refresh_token("user123", "device456", "testuser", TEST_SECRET).unwrap();
        assert!(!token.is_empty());
        
        let claims = validate_token(&token, TEST_SECRET).unwrap();
        assert_eq!(claims.sub, "user123");
        assert_eq!(claims.device_id, "device456");
        assert_eq!(claims.username, "testuser");
        assert_eq!(get_token_type(&claims), TokenType::Refresh);
    }

    #[test]
    fn test_invalid_secret() {
        let token = generate_access_token("user123", "device456", "testuser", TEST_SECRET).unwrap();
        let result = validate_token(&token, "wrong-secret");
        assert!(result.is_err());
    }

    #[test]
    fn test_token_expiry() {
        // This test would need to mock time or use a very short expiry
        // For now, we just verify the expiry time is set correctly
        let token = generate_access_token("user123", "device456", "testuser", TEST_SECRET).unwrap();
        let claims = validate_token(&token, TEST_SECRET).unwrap();
        
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64;
        
        // Access token should expire in ~15 minutes
        assert!(claims.exp > now);
        assert!(claims.exp <= now + 16 * 60); // Allow 1 minute slack
    }
}
