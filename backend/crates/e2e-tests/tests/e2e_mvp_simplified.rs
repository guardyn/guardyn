//! Simplified E2E Tests for Auth + Messaging Services (MVP - Without Cryptography)
//!
//! This is a simplified version without X3DH/Double Ratchet/MLS cryptography.
//! Tests basic auth and messaging flow with mock key bundles.
//!
//! Prerequisites:
//! - k3d cluster running (guardyn-poc)
//! - Port-forwarding active:
//!   kubectl port-forward -n apps svc/auth-service 50051:50051 &
//!   kubectl port-forward -n apps svc/messaging-service 50052:50052 &
//!
//! Run tests with:
//! ```bash
//! cd /home/anry/projects/guardyn/guardyn
//! nix --extra-experimental-features 'nix-command flakes' develop --command bash -c \
//!   "cd backend && cargo test -p guardyn-e2e-tests -- --nocapture --test-threads=1"
//! ```

use std::time::{Duration, SystemTime, UNIX_EPOCH};
use tokio::time::sleep;
use tonic::{transport::Channel, Request};
use uuid::Uuid;

// Import generated proto code
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
    auth_service_client::AuthServiceClient,
    RegisterRequest, LoginRequest, LogoutRequest,
};
use proto::messaging::{
    messaging_service_client::MessagingServiceClient,
    SendMessageRequest, GetMessagesRequest, MessageType,
};
use proto::common::{KeyBundle, Timestamp};

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

    async fn messaging_client(&self) -> Result<MessagingServiceClient<Channel>, Box<dyn std::error::Error>> {
        let channel = Channel::from_shared(self.messaging_endpoint.clone())?
            .timeout(Duration::from_secs(10))
            .connect()
            .await?;
        Ok(MessagingServiceClient::new(channel))
    }
}

/// Create a mock key bundle for MVP testing (without real cryptography)
fn mock_key_bundle() -> KeyBundle {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;

    KeyBundle {
        identity_key: vec![0u8; 32], // Mock Ed25519 public key
        signed_pre_key: vec![0u8; 32], // Mock X25519 public key
        signed_pre_key_signature: vec![0u8; 64], // Mock Ed25519 signature
        one_time_pre_keys: vec![vec![0u8; 32]], // One mock X25519 pre-key
        created_at: Some(Timestamp {
            seconds: now,
            nanos: 0,
        }),
    }
}

/// Test user representation
struct TestUser {
    username: String,
    password: String,
    email: String,
    device_name: String,
    device_type: String,
    user_id: Option<String>,
    device_id: Option<String>,
    access_token: Option<String>,
}

impl TestUser {
    fn new(username: &str) -> Self {
        Self {
            username: username.to_string(),
            password: "SecurePassword123!".to_string(),
            email: format!("{}@test.guardyn.local", username),
            device_name: "E2E Test Device".to_string(),
            device_type: "test".to_string(),
            user_id: None,
            device_id: None,
            access_token: None,
        }
    }

    async fn register(&mut self, env: &TestEnv) -> Result<(), Box<dyn std::error::Error>> {
        let mut client = env.auth_client().await?;

        let request = Request::new(RegisterRequest {
            username: self.username.clone(),
            password: self.password.clone(),
            email: self.email.clone(),
            device_name: self.device_name.clone(),
            device_type: self.device_type.clone(),
            key_bundle: Some(mock_key_bundle()),
        });

        let response = client.register(request).await?.into_inner();

        match response.result {
            Some(proto::auth::register_response::Result::Success(success)) => {
                self.user_id = Some(success.user_id.clone());
                self.device_id = Some(success.device_id.clone());
                self.access_token = Some(success.access_token.clone());
                println!("✅ User '{}' registered (user_id: {}, device_id: {})",
                    self.username, success.user_id, success.device_id);
                Ok(())
            }
            Some(proto::auth::register_response::Result::Error(error)) => {
                Err(format!("Registration failed: {:?} - {}", error.code(), error.message).into())
            }
            None => Err("No response from registration".into()),
        }
    }

    fn token(&self) -> Result<String, Box<dyn std::error::Error>> {
        self.access_token.as_ref()
            .ok_or("User not authenticated".into())
            .map(|s| s.clone())
    }

    fn user_id(&self) -> Result<String, Box<dyn std::error::Error>> {
        self.user_id.as_ref()
            .ok_or("User ID not available".into())
            .map(|s| s.clone())
    }

    fn device_id(&self) -> Result<String, Box<dyn std::error::Error>> {
        self.device_id.as_ref()
            .ok_or("Device ID not available".into())
            .map(|s| s.clone())
    }
}

/// Generate deterministic conversation ID from two user IDs (same logic as messaging service)
fn generate_conversation_id(user1: &str, user2: &str) -> String {
    let mut users = vec![user1, user2];
    users.sort();
    let namespace = Uuid::parse_str("00000000-0000-0000-0000-000000000000").unwrap();
    let data = format!("{}:{}", users[0], users[1]);
    Uuid::new_v5(&namespace, data.as_bytes()).to_string()
}

//
// TEST SUITE
//

#[tokio::test]
async fn test_00_service_health_check() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 0: Service Health Check");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();

    // Check Auth Service
    match env.auth_client().await {
        Ok(_) => println!("✅ Auth Service is reachable at {}", env.auth_endpoint),
        Err(e) => return Err(format!("❌ Auth Service unreachable: {}", e).into()),
    }

    // Check Messaging Service
    match env.messaging_client().await {
        Ok(_) => println!("✅ Messaging Service is reachable at {}", env.messaging_endpoint),
        Err(e) => return Err(format!("❌ Messaging Service unreachable: {}", e).into()),
    }

    Ok(())
}

#[tokio::test]
async fn test_01_user_registration() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 1: User Registration");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    // Remove hyphens from UUID to pass username validation (alphanumeric + underscore only)
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user1 = TestUser::new(&format!("test_{}", &user1_id[..8])); // Use first 8 chars
    let mut user2 = TestUser::new(&format!("test_{}", &user2_id[..8]));

    // Register user 1
    user1.register(&env).await?;
    assert!(user1.user_id.is_some(), "User 1 should have user_id");
    assert!(user1.access_token.is_some(), "User 1 should have access_token");

    // Register user 2
    user2.register(&env).await?;
    assert!(user2.user_id.is_some(), "User 2 should have user_id");
    assert!(user2.access_token.is_some(), "User 2 should have access_token");

    println!("✅ Both users registered successfully");
    Ok(())
}

#[tokio::test]
async fn test_02_send_and_receive_message() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 2: Send and Receive 1-on-1 Message");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user1 = TestUser::new(&format!("sender_{}", &user1_id[..8]));
    let mut user2 = TestUser::new(&format!("recv_{}", &user2_id[..8]));

    // Register both users
    user1.register(&env).await?;
    user2.register(&env).await?;

    // User 1 sends message to User 2
    let mut messaging_client = env.messaging_client().await?;

    let message_content = b"Hello from MVP E2E test!".to_vec();
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)?
        .as_secs() as i64;

    let mut send_request = Request::new(SendMessageRequest {
        access_token: user1.token()?,
        recipient_user_id: user2.user_id()?,
        recipient_device_id: user2.device_id()?,
        encrypted_content: message_content.clone(),
        client_message_id: Uuid::new_v4().to_string(),
        client_timestamp: Some(Timestamp {
            seconds: now,
            nanos: 0,
        }),
        message_type: MessageType::Text as i32, // TEXT = 0
        media_id: String::new(),
    });

    let send_response = messaging_client.send_message(send_request).await?.into_inner();

    let message_id = match send_response.result {
        Some(proto::messaging::send_message_response::Result::Success(success)) => {
            println!("✅ Message sent: {}", success.message_id);
            success.message_id
        }
        Some(proto::messaging::send_message_response::Result::Error(error)) => {
            return Err(format!("Send failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from send_message".into()),
    };

    // Wait for message propagation
    sleep(Duration::from_secs(2)).await;

    // Generate conversation ID (same as server-side logic)
    let conversation_id = generate_conversation_id(&user1.user_id()?, &user2.user_id()?);
    println!("🔍 Generated conversation_id: {}", conversation_id);
    println!("🔍 Requesting messages for user2 ({})", user2.user_id()?);

    // User 2 retrieves messages
    let get_request = Request::new(GetMessagesRequest {
        access_token: user2.token()?,
        conversation_user_id: String::new(), // Leave empty when using conversation_id
        conversation_id: conversation_id.clone(), // Use generated conversation_id
        start_time: None,
        end_time: None,
        pagination: None,
        limit: 10,
    });

    println!("🔍 Calling GetMessages...");
    let get_response = messaging_client.get_messages(get_request).await?.into_inner();
    println!("✅ GetMessages response received");

    match get_response.result {
        Some(proto::messaging::get_messages_response::Result::Success(success)) => {
            assert!(!success.messages.is_empty(), "Should have at least one message");

            let received_msg = success.messages.iter()
                .find(|m| m.message_id == message_id)
                .expect("Should find the sent message");

            assert_eq!(received_msg.encrypted_content, message_content, "Message content should match");
            assert_eq!(received_msg.sender_user_id, user1.user_id()?, "Sender should match");

            println!("✅ Message retrieved successfully by recipient");
        }
        Some(proto::messaging::get_messages_response::Result::Error(error)) => {
            return Err(format!("Get messages failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from get_messages".into()),
    }

    Ok(())
}
