//! JWT Token Validation
//!
//! Validates JWT tokens issued by auth-service

use jsonwebtoken::{decode, DecodingKey, Validation, Algorithm};
use serde::{Deserialize, Serialize};
use tonic::Status;

/// JWT Claims structure (must match auth-service)
#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    /// Subject (user_id)
    pub sub: String,
    /// Device ID
    pub device_id: String,
    /// Expiration time (Unix timestamp)
    pub exp: usize,
    /// Issued at (Unix timestamp)
    pub iat: usize,
}

/// Extract and validate JWT token from request metadata
pub fn validate_token(token: &str, jwt_secret: &str) -> Result<Claims, Status> {
    let decoding_key = DecodingKey::from_secret(jwt_secret.as_bytes());
    let validation = Validation::new(Algorithm::HS256);

    match decode::<Claims>(token, &decoding_key, &validation) {
        Ok(token_data) => Ok(token_data.claims),
        Err(e) => {
            tracing::warn!(error = %e, "JWT validation failed");
            Err(Status::unauthenticated("Invalid token"))
        }
    }
}

/// Extract token from Authorization header
pub fn extract_token_from_header(auth_header: Option<&str>) -> Result<&str, Status> {
    let header = auth_header.ok_or_else(|| Status::unauthenticated("Missing authorization header"))?;
    
    if let Some(token) = header.strip_prefix("Bearer ") {
        Ok(token)
    } else {
        Err(Status::unauthenticated("Invalid authorization header format"))
    }
}

/// Extract and validate token from gRPC request metadata
pub fn validate_request<T>(
    request: &tonic::Request<T>,
    jwt_secret: &str,
) -> Result<Claims, Status> {
    let auth_header = request
        .metadata()
        .get("authorization")
        .and_then(|v| v.to_str().ok());
    
    let token = extract_token_from_header(auth_header)?;
    validate_token(token, jwt_secret)
}

#[cfg(test)]
mod tests {
    use super::*;
    use jsonwebtoken::{encode, EncodingKey, Header};

    fn create_test_token(secret: &str, exp_offset: i64) -> String {
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as usize;
        
        let claims = Claims {
            sub: "user123".to_string(),
            device_id: "device456".to_string(),
            exp: (now as i64 + exp_offset) as usize,
            iat: now,
        };

        encode(
            &Header::default(),
            &claims,
            &EncodingKey::from_secret(secret.as_bytes()),
        )
        .unwrap()
    }

    #[test]
    fn test_validate_valid_token() {
        let secret = "test-secret";
        let token = create_test_token(secret, 3600); // Valid for 1 hour
        
        let result = validate_token(&token, secret);
        assert!(result.is_ok());
        
        let claims = result.unwrap();
        assert_eq!(claims.sub, "user123");
        assert_eq!(claims.device_id, "device456");
    }

    #[test]
    fn test_validate_expired_token() {
        let secret = "test-secret";
        let token = create_test_token(secret, -3600); // Expired 1 hour ago
        
        let result = validate_token(&token, secret);
        assert!(result.is_err());
    }

    #[test]
    fn test_validate_invalid_secret() {
        let token = create_test_token("secret1", 3600);
        let result = validate_token(&token, "secret2");
        assert!(result.is_err());
    }
}
