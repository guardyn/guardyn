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

#[cfg(test)]
mod tests {
    use super::*;
    use jsonwebtoken::{encode, EncodingKey, Header};

    const TEST_JWT_SECRET: &str = "test-jwt-secret-key-32-bytes!!";

    fn create_test_token(user_id: &str) -> String {
        let claims = Claims {
            sub: user_id.to_string(),
            username: format!("user_{}", user_id),
            device_id: "test-device-001".to_string(),
            exp: (chrono::Utc::now() + chrono::Duration::hours(1)).timestamp() as usize,
            iat: chrono::Utc::now().timestamp() as usize,
        };

        encode(
            &Header::default(),
            &claims,
            &EncodingKey::from_secret(TEST_JWT_SECRET.as_bytes()),
        )
        .unwrap()
    }

    fn create_expired_token(user_id: &str) -> String {
        let claims = Claims {
            sub: user_id.to_string(),
            username: format!("user_{}", user_id),
            device_id: "test-device-001".to_string(),
            exp: (chrono::Utc::now() - chrono::Duration::hours(1)).timestamp() as usize,
            iat: (chrono::Utc::now() - chrono::Duration::hours(2)).timestamp() as usize,
        };

        encode(
            &Header::default(),
            &claims,
            &EncodingKey::from_secret(TEST_JWT_SECRET.as_bytes()),
        )
        .unwrap()
    }

    #[test]
    fn test_validate_valid_token() {
        let token = create_test_token("user-123");
        let result = validate_token(&token, TEST_JWT_SECRET);
        
        assert!(result.is_ok());
        let claims = result.unwrap();
        assert_eq!(claims.sub, "user-123");
        assert_eq!(claims.username, "user_user-123");
        assert_eq!(claims.device_id, "test-device-001");
    }

    #[test]
    fn test_validate_expired_token() {
        let token = create_expired_token("user-expired");
        let result = validate_token(&token, TEST_JWT_SECRET);
        
        assert!(result.is_err());
        let err_msg = result.unwrap_err().to_string();
        assert!(err_msg.contains("Invalid token") || err_msg.contains("ExpiredSignature"));
    }

    #[test]
    fn test_validate_wrong_secret() {
        let token = create_test_token("user-wrong-secret");
        let result = validate_token(&token, "wrong-secret-key!!");
        
        assert!(result.is_err());
    }

    #[test]
    fn test_validate_empty_token() {
        let result = validate_token("", TEST_JWT_SECRET);
        assert!(result.is_err());
    }

    #[test]
    fn test_validate_invalid_token_format() {
        let result = validate_token("not.a.valid.token", TEST_JWT_SECRET);
        assert!(result.is_err());
    }

    #[test]
    fn test_get_user_id_from_token() {
        let token = create_test_token("user-456");
        let result = get_user_id_from_token(&token, TEST_JWT_SECRET);
        
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), "user-456");
    }
}
