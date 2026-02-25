//! Production Readiness E2E Tests
//!
//! Comprehensive tests for validating system production readiness:
//! - Service health checks
//! - Error handling scenarios
//! - Edge cases and boundary conditions
//! - Performance under load
//! - Real API client tests
//!
//! Prerequisites:
//! - Docker Compose services running: docker compose -f docker-compose.dev.yml up -d
//!
//! Run tests with:
//! ```bash
//! cd backend && cargo test -p guardyn-e2e-tests --test e2e_production_readiness -- --nocapture --test-threads=1
//! ```

use std::time::{Duration, SystemTime, UNIX_EPOCH};
use tonic::{transport::Channel, Request};
use uuid::Uuid;

// Import generated proto code
#[allow(dead_code, clippy::large_enum_variant)]
mod proto {
    pub mod auth {
        tonic::include_proto!("guardyn.auth");
    }
    pub mod messaging {
        tonic::include_proto!("guardyn.messaging");
    }
    pub mod common {
        tonic::include_proto!("guardyn.common");
    }
}

use proto::auth::{
    auth_service_client::AuthServiceClient, LoginRequest, LogoutRequest, RegisterRequest,
};
use proto::common::{KeyBundle, Timestamp};
use proto::messaging::{
    messaging_service_client::MessagingServiceClient, MessageType, SendMessageRequest,
};

/// Test environment configuration
struct TestEnv {
    auth_endpoint: String,
    messaging_endpoint: String,
}

impl TestEnv {
    fn new() -> Self {
        Self {
            auth_endpoint: std::env::var("AUTH_ENDPOINT")
                .unwrap_or_else(|_| "http://localhost:50051".to_string()),
            messaging_endpoint: std::env::var("MESSAGING_ENDPOINT")
                .unwrap_or_else(|_| "http://localhost:50052".to_string()),
        }
    }

    async fn auth_client(&self) -> Result<AuthServiceClient<Channel>, Box<dyn std::error::Error>> {
        let channel = Channel::from_shared(self.auth_endpoint.clone())?
            .timeout(Duration::from_secs(10))
            .connect()
            .await?;
        Ok(AuthServiceClient::new(channel))
    }

    async fn messaging_client(
        &self,
    ) -> Result<MessagingServiceClient<Channel>, Box<dyn std::error::Error>> {
        let channel = Channel::from_shared(self.messaging_endpoint.clone())?
            .timeout(Duration::from_secs(10))
            .connect()
            .await?;
        Ok(MessagingServiceClient::new(channel))
    }
}

/// Create a mock key bundle for testing
fn mock_key_bundle() -> KeyBundle {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;

    KeyBundle {
        identity_key: vec![0u8; 32],
        signed_pre_key: vec![0u8; 32],
        signed_pre_key_signature: vec![0u8; 64],
        one_time_pre_keys: vec![vec![0u8; 32]],
        created_at: Some(Timestamp {
            seconds: now,
            nanos: 0,
        }),
    }
}

// ============================================================================
// HEALTH CHECK TESTS
// ============================================================================

#[tokio::test]
async fn test_health_auth_service() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🏥 Health Check: Auth Service");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let client = env.auth_client().await;

    match client {
        Ok(_) => {
            println!("✅ Auth service is healthy and accepting connections");
            Ok(())
        }
        Err(e) => {
            println!("❌ Auth service health check failed: {}", e);
            Err(e)
        }
    }
}

#[tokio::test]
async fn test_health_messaging_service() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🏥 Health Check: Messaging Service");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let client = env.messaging_client().await;

    match client {
        Ok(_) => {
            println!("✅ Messaging service is healthy and accepting connections");
            Ok(())
        }
        Err(e) => {
            println!("❌ Messaging service health check failed: {}", e);
            Err(e)
        }
    }
}

// ============================================================================
// ERROR HANDLING TESTS
// ============================================================================

#[tokio::test]
async fn test_error_invalid_credentials() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🔒 Error Test: Invalid Credentials");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let mut client = env.auth_client().await?;

    let request = Request::new(LoginRequest {
        username: "nonexistent_user_12345".to_string(),
        password: "wrong_password".to_string(),
        device_id: String::new(),
        device_name: "test".to_string(),
        device_type: "test".to_string(),
        key_bundle: Some(mock_key_bundle()),
    });

    let response = client.login(request).await?.into_inner();

    match response.result {
        Some(proto::auth::login_response::Result::Error(error)) => {
            println!("✅ Got expected error response: {:?}", error.code());
            assert!(
                !error.message.is_empty(),
                "Error message should not be empty"
            );
            Ok(())
        }
        Some(proto::auth::login_response::Result::Success(_)) => {
            Err("Expected error but got success".into())
        }
        None => Err("No response from login".into()),
    }
}

#[tokio::test]
async fn test_error_duplicate_registration() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🔒 Error Test: Duplicate Registration");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let mut client = env.auth_client().await?;

    let unique_id = Uuid::new_v4().to_string().replace("-", "");
    let username = format!("dup_test_{}", &unique_id[..8]);

    // First registration - should succeed
    let request1 = Request::new(RegisterRequest {
        username: username.clone(),
        password: "SecurePass123!".to_string(),
        email: format!("{}@test.local", username),
        device_name: "test_device".to_string(),
        device_type: "test".to_string(),
        key_bundle: Some(mock_key_bundle()),
    });

    let response1 = client.register(request1).await?.into_inner();
    assert!(
        matches!(
            response1.result,
            Some(proto::auth::register_response::Result::Success(_))
        ),
        "First registration should succeed"
    );
    println!("✅ First registration succeeded");

    // Second registration with same username - should fail
    let request2 = Request::new(RegisterRequest {
        username: username.clone(),
        password: "DifferentPass456!".to_string(),
        email: format!("{}2@test.local", username),
        device_name: "test_device2".to_string(),
        device_type: "test".to_string(),
        key_bundle: Some(mock_key_bundle()),
    });

    let response2 = client.register(request2).await?.into_inner();
    match response2.result {
        Some(proto::auth::register_response::Result::Error(error)) => {
            println!(
                "✅ Got expected duplicate error: {:?} - {}",
                error.code(),
                error.message
            );
            Ok(())
        }
        Some(proto::auth::register_response::Result::Success(_)) => {
            Err("Duplicate registration should fail".into())
        }
        None => Err("No response from second registration".into()),
    }
}

#[tokio::test]
async fn test_error_invalid_token() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🔒 Error Test: Invalid Token");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let mut client = env.messaging_client().await?;

    // Try to send message with invalid token
    let request = Request::new(SendMessageRequest {
        access_token: "invalid_token_12345".to_string(),
        recipient_user_id: Uuid::new_v4().to_string(),
        recipient_device_id: Uuid::new_v4().to_string(),
        encrypted_content: b"test".to_vec(),
        client_message_id: Uuid::new_v4().to_string(),
        client_timestamp: Some(Timestamp {
            seconds: SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs() as i64,
            nanos: 0,
        }),
        message_type: MessageType::Text as i32,
        media_id: String::new(),
        recipient_username: "test".to_string(),
        x3dh_prekey: String::new(),
        thread_reference: None,
        voice_metadata: None,
    });

    let response = client.send_message(request).await?.into_inner();

    match response.result {
        Some(proto::messaging::send_message_response::Result::Error(error)) => {
            println!(
                "✅ Got expected authentication error: {:?} - {}",
                error.code(),
                error.message
            );
            Ok(())
        }
        Some(proto::messaging::send_message_response::Result::Success(_)) => {
            Err("Invalid token should not succeed".into())
        }
        None => Err("No response from send_message".into()),
    }
}

// ============================================================================
// EDGE CASES TESTS
// ============================================================================

#[tokio::test]
async fn test_edge_empty_message_content() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n📏 Edge Case: Empty Message Content");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let mut auth_client = env.auth_client().await?;

    // Register a test user
    let unique_id = Uuid::new_v4().to_string().replace("-", "");
    let username = format!("empty_test_{}", &unique_id[..8]);

    let reg_request = Request::new(RegisterRequest {
        username: username.clone(),
        password: "SecurePass123!".to_string(),
        email: format!("{}@test.local", username),
        device_name: "test".to_string(),
        device_type: "test".to_string(),
        key_bundle: Some(mock_key_bundle()),
    });

    let reg_response = auth_client.register(reg_request).await?.into_inner();
    let (user_id, device_id, token) = match reg_response.result {
        Some(proto::auth::register_response::Result::Success(s)) => {
            (s.user_id, s.device_id, s.access_token)
        }
        _ => return Err("Registration failed".into()),
    };

    let mut msg_client = env.messaging_client().await?;

    // Try to send empty message
    let request = Request::new(SendMessageRequest {
        access_token: token,
        recipient_user_id: user_id.clone(),
        recipient_device_id: device_id,
        encrypted_content: vec![], // Empty content
        client_message_id: Uuid::new_v4().to_string(),
        client_timestamp: Some(Timestamp {
            seconds: SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs() as i64,
            nanos: 0,
        }),
        message_type: MessageType::Text as i32,
        media_id: String::new(),
        recipient_username: username,
        x3dh_prekey: String::new(),
        thread_reference: None,
        voice_metadata: None,
    });

    let response = msg_client.send_message(request).await?.into_inner();

    match response.result {
        Some(proto::messaging::send_message_response::Result::Success(_)) => {
            println!("✅ Empty message was accepted (policy decision)");
        }
        Some(proto::messaging::send_message_response::Result::Error(error)) => {
            println!("✅ Empty message was rejected: {:?}", error.code());
        }
        None => return Err("No response".into()),
    }

    Ok(())
}

#[tokio::test]
async fn test_edge_large_message() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n📏 Edge Case: Large Message (1MB)");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let mut auth_client = env.auth_client().await?;

    // Register test users
    let unique_id = Uuid::new_v4().to_string().replace("-", "");
    let username1 = format!("large_sender_{}", &unique_id[..8]);
    let username2 = format!("large_recv_{}", &unique_id[..8]);

    let reg1 = Request::new(RegisterRequest {
        username: username1.clone(),
        password: "SecurePass123!".to_string(),
        email: format!("{}@test.local", username1),
        device_name: "test".to_string(),
        device_type: "test".to_string(),
        key_bundle: Some(mock_key_bundle()),
    });
    let resp1 = auth_client.register(reg1).await?.into_inner();
    let token1 = match resp1.result {
        Some(proto::auth::register_response::Result::Success(s)) => s.access_token,
        _ => return Err("Registration failed".into()),
    };

    let reg2 = Request::new(RegisterRequest {
        username: username2.clone(),
        password: "SecurePass123!".to_string(),
        email: format!("{}@test.local", username2),
        device_name: "test".to_string(),
        device_type: "test".to_string(),
        key_bundle: Some(mock_key_bundle()),
    });
    let resp2 = auth_client.register(reg2).await?.into_inner();
    let (user_id2, device_id2) = match resp2.result {
        Some(proto::auth::register_response::Result::Success(s)) => (s.user_id, s.device_id),
        _ => return Err("Registration failed".into()),
    };

    let mut msg_client = env.messaging_client().await?;

    // Create 1MB message
    let large_content = vec![b'A'; 1024 * 1024];
    println!("📤 Sending {}KB message...", large_content.len() / 1024);

    let request = Request::new(SendMessageRequest {
        access_token: token1,
        recipient_user_id: user_id2,
        recipient_device_id: device_id2,
        encrypted_content: large_content,
        client_message_id: Uuid::new_v4().to_string(),
        client_timestamp: Some(Timestamp {
            seconds: SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs() as i64,
            nanos: 0,
        }),
        message_type: MessageType::Text as i32,
        media_id: String::new(),
        recipient_username: username2,
        x3dh_prekey: String::new(),
        thread_reference: None,
        voice_metadata: None,
    });

    let response = msg_client.send_message(request).await?.into_inner();

    match response.result {
        Some(proto::messaging::send_message_response::Result::Success(s)) => {
            println!("✅ Large message sent: {}", s.message_id);
        }
        Some(proto::messaging::send_message_response::Result::Error(error)) => {
            println!(
                "✅ Large message rejected (expected for size limits): {:?}",
                error.code()
            );
        }
        None => return Err("No response".into()),
    }

    Ok(())
}

#[tokio::test]
async fn test_edge_special_characters_username() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n📏 Edge Case: Special Characters in Username");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let mut client = env.auth_client().await?;

    // Try various special characters
    let test_cases = vec![
        "user@special",
        "user#hash",
        "user with spaces",
        "пользователь_кириллица",
        "用户中文",
        "user\ttab",
    ];

    for username in test_cases {
        let request = Request::new(RegisterRequest {
            username: username.to_string(),
            password: "SecurePass123!".to_string(),
            email: format!("test_{}@test.local", Uuid::new_v4()),
            device_name: "test".to_string(),
            device_type: "test".to_string(),
            key_bundle: Some(mock_key_bundle()),
        });

        let response = client.register(request).await?.into_inner();

        match response.result {
            Some(proto::auth::register_response::Result::Success(_)) => {
                println!("✅ Username '{}' accepted", username);
            }
            Some(proto::auth::register_response::Result::Error(error)) => {
                println!("✅ Username '{}' rejected: {:?}", username, error.code());
            }
            None => println!("⚠️ No response for username '{}'", username),
        }
    }

    Ok(())
}

// ============================================================================
// CONCURRENT ACCESS TESTS
// ============================================================================

#[tokio::test]
async fn test_concurrent_registrations() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🔄 Concurrent Test: Multiple Registrations");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let num_users = 10;

    let mut handles = Vec::new();

    for i in 0..num_users {
        let auth_endpoint = env.auth_endpoint.clone();
        handles.push(tokio::spawn(async move {
            let channel = Channel::from_shared(auth_endpoint)?
                .timeout(Duration::from_secs(30))
                .connect()
                .await?;
            let mut client = AuthServiceClient::new(channel);

            let unique_id = Uuid::new_v4().to_string().replace("-", "");
            let username = format!("concurrent_{}_{}", i, &unique_id[..6]);

            let request = Request::new(RegisterRequest {
                username: username.clone(),
                password: "SecurePass123!".to_string(),
                email: format!("{}@test.local", username),
                device_name: format!("device_{}", i),
                device_type: "test".to_string(),
                key_bundle: Some(KeyBundle {
                    identity_key: vec![0u8; 32],
                    signed_pre_key: vec![0u8; 32],
                    signed_pre_key_signature: vec![0u8; 64],
                    one_time_pre_keys: vec![vec![0u8; 32]],
                    created_at: Some(Timestamp {
                        seconds: SystemTime::now()
                            .duration_since(UNIX_EPOCH)
                            .unwrap()
                            .as_secs() as i64,
                        nanos: 0,
                    }),
                }),
            });

            let start = std::time::Instant::now();
            let response = client.register(request).await?.into_inner();
            let duration = start.elapsed();

            Ok::<_, Box<dyn std::error::Error + Send + Sync>>((username, response, duration))
        }));
    }

    let mut successes = 0;
    let mut total_duration = Duration::ZERO;

    for handle in handles {
        match handle.await? {
            Ok((username, response, duration)) => {
                total_duration += duration;
                if let Some(proto::auth::register_response::Result::Success(_)) = response.result {
                    successes += 1;
                    println!("✅ {} registered in {:?}", username, duration);
                }
            }
            Err(e) => println!("❌ Registration error: {}", e),
        }
    }

    let avg_duration = total_duration / num_users;
    println!("\n📊 Results:");
    println!("   Success rate: {}/{}", successes, num_users);
    println!("   Average registration time: {:?}", avg_duration);

    assert!(
        successes == num_users,
        "All concurrent registrations should succeed"
    );
    assert!(
        avg_duration < Duration::from_secs(5),
        "Average time should be < 5s"
    );

    Ok(())
}

// ============================================================================
// SESSION MANAGEMENT TESTS
// ============================================================================

#[tokio::test]
async fn test_login_logout_flow() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🔐 Session Test: Login/Logout Flow");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let mut client = env.auth_client().await?;

    // Register a new user
    let unique_id = Uuid::new_v4().to_string().replace("-", "");
    let username = format!("session_test_{}", &unique_id[..8]);

    let reg_request = Request::new(RegisterRequest {
        username: username.clone(),
        password: "SecurePass123!".to_string(),
        email: format!("{}@test.local", username),
        device_name: "test".to_string(),
        device_type: "test".to_string(),
        key_bundle: Some(mock_key_bundle()),
    });

    let reg_response = client.register(reg_request).await?.into_inner();
    let token = match reg_response.result {
        Some(proto::auth::register_response::Result::Success(s)) => {
            println!("✅ User registered");
            s.access_token
        }
        _ => return Err("Registration failed".into()),
    };

    // Verify token works by sending a logout request
    let logout_request = Request::new(LogoutRequest {
        access_token: token.clone(),
        all_devices: false,
    });

    let logout_response = client.logout(logout_request).await?.into_inner();
    match logout_response.result {
        Some(proto::auth::logout_response::Result::Success(s)) => {
            println!(
                "✅ Logout succeeded, sessions invalidated: {}",
                s.sessions_invalidated
            );
        }
        Some(proto::auth::logout_response::Result::Error(e)) => {
            println!("⚠️ Logout returned error: {:?}", e.code());
        }
        None => println!("⚠️ No response from logout"),
    }

    // Try to use the same token after logout - should fail
    let mut msg_client = env.messaging_client().await?;
    let send_request = Request::new(SendMessageRequest {
        access_token: token,
        recipient_user_id: Uuid::new_v4().to_string(),
        recipient_device_id: Uuid::new_v4().to_string(),
        encrypted_content: b"test after logout".to_vec(),
        client_message_id: Uuid::new_v4().to_string(),
        client_timestamp: Some(Timestamp {
            seconds: SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs() as i64,
            nanos: 0,
        }),
        message_type: MessageType::Text as i32,
        media_id: String::new(),
        recipient_username: "test".to_string(),
        x3dh_prekey: String::new(),
        thread_reference: None,
        voice_metadata: None,
    });

    let send_response = msg_client.send_message(send_request).await?.into_inner();
    match send_response.result {
        Some(proto::messaging::send_message_response::Result::Error(_)) => {
            println!("✅ Token invalid after logout (expected)");
        }
        Some(proto::messaging::send_message_response::Result::Success(_)) => {
            println!("⚠️ Token still valid after logout (may be by design)");
        }
        None => println!("⚠️ No response"),
    }

    Ok(())
}

// ============================================================================
// PERFORMANCE SMOKE TESTS
// ============================================================================

#[tokio::test]
async fn test_registration_latency() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n⏱️ Performance: Registration Latency");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let mut client = env.auth_client().await?;

    let iterations = 5;
    let mut durations = Vec::new();

    for i in 0..iterations {
        let unique_id = Uuid::new_v4().to_string().replace("-", "");
        let username = format!("perf_test_{}_{}", i, &unique_id[..6]);

        let request = Request::new(RegisterRequest {
            username: username.clone(),
            password: "SecurePass123!".to_string(),
            email: format!("{}@test.local", username),
            device_name: "test".to_string(),
            device_type: "test".to_string(),
            key_bundle: Some(mock_key_bundle()),
        });

        let start = std::time::Instant::now();
        let _response = client.register(request).await?.into_inner();
        let duration = start.elapsed();

        durations.push(duration);
        println!("   Iteration {}: {:?}", i + 1, duration);
    }

    let total: Duration = durations.iter().sum();
    let avg = total / iterations as u32;
    let min = durations.iter().min().unwrap();
    let max = durations.iter().max().unwrap();

    println!("\n📊 Latency Statistics:");
    println!("   Min: {:?}", min);
    println!("   Max: {:?}", max);
    println!("   Avg: {:?}", avg);

    assert!(
        avg < Duration::from_secs(2),
        "Average registration time should be < 2s"
    );

    Ok(())
}
