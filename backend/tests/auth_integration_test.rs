/// Integration tests for Auth Service
/// 
/// Tests:
/// 1. User registration flow
/// 2. User login flow
/// 3. Token refresh flow
/// 4. Token validation
/// 5. Key bundle storage and retrieval

use tonic::Request;

// Import generated protobuf types
mod proto {
    pub mod common {
        tonic::include_proto!("guardyn.common");
    }
    pub mod auth {
        tonic::include_proto!("guardyn.auth");
    }
}

use proto::auth::{
    auth_service_client::AuthServiceClient,
    RegisterRequest, LoginRequest, RefreshTokenRequest,
    ValidateTokenRequest, GetKeyBundleRequest,
};
use proto::common::KeyBundle;

/// Test configuration
const AUTH_SERVICE_URL: &str = "http://127.0.0.1:50051";
const TEST_USERNAME: &str = "test_user_integration";
const TEST_PASSWORD: &str = "TestPassword123!";
const TEST_DEVICE_ID: &str = "test_device_001";

#[tokio::test]
async fn test_user_registration() {
    // Connect to auth service
    let mut client = AuthServiceClient::connect(AUTH_SERVICE_URL)
        .await
        .expect("Failed to connect to auth service");
    
    // Create key bundle for E2EE
    let key_bundle = KeyBundle {
        identity_key: vec![1; 32], // Mock Ed25519 key
        signed_pre_key: vec![2; 32], // Mock X25519 key
        signed_pre_key_signature: vec![3; 64], // Mock signature
        one_time_pre_keys: vec![vec![4; 32], vec![5; 32]], // Mock OTKs
        created_at: Some(proto::common::Timestamp {
            seconds: std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_secs() as i64,
            nanos: 0,
        }),
    };
    
    // Register new user
    let request = Request::new(RegisterRequest {
        username: TEST_USERNAME.to_string(),
        password: TEST_PASSWORD.to_string(),
        email: "test@example.com".to_string(),
        device_id: TEST_DEVICE_ID.to_string(),
        device_name: "Test Device".to_string(),
        device_type: "integration_test".to_string(),
        key_bundle: Some(key_bundle),
    });
    
    let response = client.register(request)
        .await
        .expect("Registration failed");
    
    let register_response = response.into_inner();
    
    // Verify success response
    match register_response.result {
        Some(proto::auth::register_response::Result::Success(success)) => {
            assert!(!success.user_id.is_empty(), "User ID should not be empty");
            assert!(!success.access_token.is_empty(), "Access token should not be empty");
            assert!(!success.refresh_token.is_empty(), "Refresh token should not be empty");
            assert_eq!(success.access_token_expires_in, 15 * 60, "Access token expiry should be 15 minutes");
            assert_eq!(success.refresh_token_expires_in, 30 * 24 * 60 * 60, "Refresh token expiry should be 30 days");
            
            println!("✅ User registration successful");
            println!("   User ID: {}", success.user_id);
            println!("   Access Token: {}...", &success.access_token[..20]);
        }
        Some(proto::auth::register_response::Result::Error(error)) => {
            panic!("Registration error: {} (code: {})", error.message, error.code);
        }
        None => {
            panic!("No response from registration");
        }
    }
}

#[tokio::test]
async fn test_user_login() {
    // First, register a user (or ensure one exists)
    // For this test, we assume the user from previous test exists
    
    let mut client = AuthServiceClient::connect(AUTH_SERVICE_URL)
        .await
        .expect("Failed to connect to auth service");
    
    // Login
    let request = Request::new(LoginRequest {
        username: TEST_USERNAME.to_string(),
        password: TEST_PASSWORD.to_string(),
        device_id: TEST_DEVICE_ID.to_string(),
        device_name: "Test Device".to_string(),
        device_type: "integration_test".to_string(),
        key_bundle: None, // No new key bundle for existing device
    });
    
    let response = client.login(request)
        .await
        .expect("Login failed");
    
    let login_response = response.into_inner();
    
    match login_response.result {
        Some(proto::auth::login_response::Result::Success(success)) => {
            assert!(!success.user_id.is_empty());
            assert!(!success.access_token.is_empty());
            assert!(!success.refresh_token.is_empty());
            assert!(!success.devices.is_empty(), "Should return device list");
            
            println!("✅ User login successful");
            println!("   User ID: {}", success.user_id);
            println!("   Devices: {}", success.devices.len());
        }
        Some(proto::auth::login_response::Result::Error(error)) => {
            panic!("Login error: {} (code: {})", error.message, error.code);
        }
        None => {
            panic!("No response from login");
        }
    }
}

#[tokio::test]
async fn test_token_refresh() {
    let mut client = AuthServiceClient::connect(AUTH_SERVICE_URL)
        .await
        .expect("Failed to connect to auth service");
    
    // First login to get tokens
    let login_request = Request::new(LoginRequest {
        username: TEST_USERNAME.to_string(),
        password: TEST_PASSWORD.to_string(),
        device_id: TEST_DEVICE_ID.to_string(),
        device_name: "Test Device".to_string(),
        device_type: "integration_test".to_string(),
        key_bundle: None,
    });
    
    let login_response = client.login(login_request)
        .await
        .expect("Login failed")
        .into_inner();
    
    let refresh_token = match login_response.result {
        Some(proto::auth::login_response::Result::Success(s)) => s.refresh_token,
        _ => panic!("Login failed"),
    };
    
    // Now refresh the token
    let refresh_request = Request::new(RefreshTokenRequest {
        refresh_token,
    });
    
    let refresh_response = client.refresh_token(refresh_request)
        .await
        .expect("Token refresh failed")
        .into_inner();
    
    match refresh_response.result {
        Some(proto::auth::refresh_token_response::Result::Success(success)) => {
            assert!(!success.access_token.is_empty());
            assert_eq!(success.access_token_expires_in, 15 * 60);
            
            println!("✅ Token refresh successful");
            println!("   New Access Token: {}...", &success.access_token[..20]);
        }
        Some(proto::auth::refresh_token_response::Result::Error(error)) => {
            panic!("Token refresh error: {} (code: {})", error.message, error.code);
        }
        None => {
            panic!("No response from token refresh");
        }
    }
}

#[tokio::test]
async fn test_token_validation() {
    let mut client = AuthServiceClient::connect(AUTH_SERVICE_URL)
        .await
        .expect("Failed to connect to auth service");
    
    // Login to get access token
    let login_request = Request::new(LoginRequest {
        username: TEST_USERNAME.to_string(),
        password: TEST_PASSWORD.to_string(),
        device_id: TEST_DEVICE_ID.to_string(),
        device_name: "Test Device".to_string(),
        device_type: "integration_test".to_string(),
        key_bundle: None,
    });
    
    let login_response = client.login(login_request)
        .await
        .expect("Login failed")
        .into_inner();
    
    let access_token = match login_response.result {
        Some(proto::auth::login_response::Result::Success(s)) => s.access_token,
        _ => panic!("Login failed"),
    };
    
    // Validate token
    let validate_request = Request::new(ValidateTokenRequest {
        access_token,
    });
    
    let validate_response = client.validate_token(validate_request)
        .await
        .expect("Token validation failed")
        .into_inner();
    
    match validate_response.result {
        Some(proto::auth::validate_token_response::Result::Success(success)) => {
            assert!(!success.user_id.is_empty());
            assert_eq!(success.device_id, TEST_DEVICE_ID);
            assert!(!success.permissions.is_empty());
            
            println!("✅ Token validation successful");
            println!("   User ID: {}", success.user_id);
            println!("   Permissions: {:?}", success.permissions);
        }
        Some(proto::auth::validate_token_response::Result::Error(error)) => {
            panic!("Token validation error: {} (code: {})", error.message, error.code);
        }
        None => {
            panic!("No response from token validation");
        }
    }
}

// Helper function to clean up test data
#[allow(dead_code)]
async fn cleanup_test_user() {
    // TODO: Implement cleanup if needed
    // For now, test data will accumulate
    println!("⚠️  Test cleanup not implemented - test data may accumulate");
}
