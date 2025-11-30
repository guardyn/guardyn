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
    RegisterRequest,
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

    let send_request = Request::new(SendMessageRequest {
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
        recipient_username: user2.username.clone(),
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

#[tokio::test]
async fn test_03_mark_messages_as_read() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 3: Mark Messages As Read");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user1 = TestUser::new(&format!("sender_{}", &user1_id[..8]));
    let mut user2 = TestUser::new(&format!("reader_{}", &user2_id[..8]));

    // Register both users
    user1.register(&env).await?;
    user2.register(&env).await?;

    // User 1 sends 3 messages to User 2
    let mut messaging_client = env.messaging_client().await?;
    let mut message_ids = Vec::new();

    for i in 1..=3 {
        let message_content = format!("Test message {}", i).into_bytes();
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)?
            .as_secs() as i64;

        let send_request = Request::new(SendMessageRequest {
            access_token: user1.token()?,
            recipient_user_id: user2.user_id()?,
            recipient_device_id: user2.device_id()?,
            encrypted_content: message_content,
            client_message_id: Uuid::new_v4().to_string(),
            client_timestamp: Some(Timestamp {
                seconds: now,
                nanos: 0,
            }),
            message_type: MessageType::Text as i32,
            media_id: String::new(),
            recipient_username: user2.username.clone(),
        });

        let send_response = messaging_client.send_message(send_request).await?.into_inner();

        if let Some(proto::messaging::send_message_response::Result::Success(success)) = send_response.result {
            message_ids.push(success.message_id.clone());
            println!("✅ Message {} sent: {}", i, success.message_id);
        }
    }

    // Wait for message propagation
    sleep(Duration::from_secs(2)).await;

    // User 2 marks messages as read
    let _conversation_id = generate_conversation_id(&user1.user_id()?, &user2.user_id()?);

    let mark_read_request = Request::new(proto::messaging::MarkAsReadRequest {
        access_token: user2.token()?,
        message_ids: message_ids.clone(),
    });

    let mark_read_response = messaging_client.mark_as_read(mark_read_request).await?.into_inner();

    match mark_read_response.result {
        Some(proto::messaging::mark_as_read_response::Result::Success(success)) => {
            assert_eq!(success.marked_count, message_ids.len() as i32, "Should mark all messages");
            println!("✅ Marked {} messages as read", success.marked_count);
        }
        Some(proto::messaging::mark_as_read_response::Result::Error(error)) => {
            return Err(format!("Mark as read failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from mark_as_read".into()),
    }

    Ok(())
}

#[tokio::test]
async fn test_04_delete_message() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 4: Delete Message");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user1 = TestUser::new(&format!("sender_{}", &user1_id[..8]));
    let mut user2 = TestUser::new(&format!("deleter_{}", &user2_id[..8]));

    // Register both users
    user1.register(&env).await?;
    user2.register(&env).await?;

    // User 1 sends 2 messages
    let mut messaging_client = env.messaging_client().await?;
    let mut message_ids = Vec::new();

    for i in 1..=2 {
        let message_content = format!("Message to delete {}", i).into_bytes();
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)?
            .as_secs() as i64;

        let send_request = Request::new(SendMessageRequest {
            access_token: user1.token()?,
            recipient_user_id: user2.user_id()?,
            recipient_device_id: user2.device_id()?,
            encrypted_content: message_content,
            client_message_id: Uuid::new_v4().to_string(),
            client_timestamp: Some(Timestamp {
                seconds: now,
                nanos: 0,
            }),
            message_type: MessageType::Text as i32,
            media_id: String::new(),
            recipient_username: user2.username.clone(),
        });

        let send_response = messaging_client.send_message(send_request).await?.into_inner();

        if let Some(proto::messaging::send_message_response::Result::Success(success)) = send_response.result {
            message_ids.push(success.message_id.clone());
            println!("✅ Message {} sent: {}", i, success.message_id);
        }
    }

    sleep(Duration::from_secs(2)).await;

    // User 2 deletes the first message
    let conversation_id = generate_conversation_id(&user1.user_id()?, &user2.user_id()?);

    let delete_request = Request::new(proto::messaging::DeleteMessageRequest {
        access_token: user2.token()?,
        message_id: message_ids[0].clone(),
        conversation_id: conversation_id.clone(),
        delete_for_everyone: false,
    });

    let delete_response = messaging_client.delete_message(delete_request).await?.into_inner();

    match delete_response.result {
        Some(proto::messaging::delete_message_response::Result::Success(_)) => {
            println!("✅ Message deleted successfully");
        }
        Some(proto::messaging::delete_message_response::Result::Error(error)) => {
            return Err(format!("Delete failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from delete_message".into()),
    }

    // Verify message is marked as deleted (or not returned)
    sleep(Duration::from_secs(1)).await;

    let get_request = Request::new(GetMessagesRequest {
        access_token: user2.token()?,
        conversation_user_id: String::new(),
        conversation_id: conversation_id.clone(),
        start_time: None,
        end_time: None,
        pagination: None,
        limit: 10,
    });

    let get_response = messaging_client.get_messages(get_request).await?.into_inner();

    if let Some(proto::messaging::get_messages_response::Result::Success(success)) = get_response.result {
        let deleted_msg = success.messages.iter()
            .find(|m| m.message_id == message_ids[0]);

        // Message should either not exist or have is_deleted=true
        if let Some(msg) = deleted_msg {
            assert!(msg.is_deleted, "Deleted message should have is_deleted=true");
            println!("✅ Message marked as deleted (is_deleted=true)");
        } else {
            println!("✅ Deleted message not returned in query");
        }
    }

    Ok(())
}

#[tokio::test]
async fn test_05_group_chat_flow() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 5: Group Chat Flow");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let user3_id = Uuid::new_v4().to_string().replace("-", "");

    let mut user1 = TestUser::new(&format!("group_admin_{}", &user1_id[..8]));
    let mut user2 = TestUser::new(&format!("group_mem1_{}", &user2_id[..8]));
    let mut user3 = TestUser::new(&format!("group_mem2_{}", &user3_id[..8]));

    // Register all users
    user1.register(&env).await?;
    user2.register(&env).await?;
    user3.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // User 1 creates a group
    let create_group_request = Request::new(proto::messaging::CreateGroupRequest {
        access_token: user1.token()?,
        group_name: "E2E Test Group".to_string(),
        member_user_ids: vec![user2.user_id()?, user3.user_id()?],
        mls_group_state: vec![], // Mock MLS state for MVP
    });

    let create_response = messaging_client.create_group(create_group_request).await?.into_inner();

    let group_id = match create_response.result {
        Some(proto::messaging::create_group_response::Result::Success(success)) => {
            println!("✅ Group created: {}", success.group_id);
            success.group_id
        }
        Some(proto::messaging::create_group_response::Result::Error(error)) => {
            return Err(format!("Create group failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from create_group".into()),
    };

    sleep(Duration::from_secs(1)).await;

    // User 1 sends a group message
    let group_message = b"Hello, group members!".to_vec();

    let send_group_request = Request::new(proto::messaging::SendGroupMessageRequest {
        access_token: user1.token()?,
        group_id: group_id.clone(),
        encrypted_content: group_message.clone(),
        message_type: MessageType::Text as i32,
        client_message_id: Uuid::new_v4().to_string(),
        client_timestamp: Some(Timestamp {
            seconds: SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs() as i64,
            nanos: 0,
        }),
        media_id: String::new(),
    });

    let send_group_response = messaging_client.send_group_message(send_group_request).await?.into_inner();

    let message_id = match send_group_response.result {
        Some(proto::messaging::send_group_message_response::Result::Success(success)) => {
            println!("✅ Group message sent: {}", success.message_id);
            success.message_id
        }
        Some(proto::messaging::send_group_message_response::Result::Error(error)) => {
            return Err(format!("Send group message failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from send_group_message".into()),
    };

    sleep(Duration::from_secs(2)).await;

    // User 2 retrieves group messages
    let get_group_request = Request::new(proto::messaging::GetGroupMessagesRequest {
        access_token: user2.token()?,
        group_id: group_id.clone(),
        start_time: None,
        end_time: None,
        pagination: None,
        limit: 10,
    });

    let get_group_response = messaging_client.get_group_messages(get_group_request).await?.into_inner();

    match get_group_response.result {
        Some(proto::messaging::get_group_messages_response::Result::Success(success)) => {
            assert!(!success.messages.is_empty(), "Should have at least one group message");

            let received_msg = success.messages.iter()
                .find(|m| m.message_id == message_id)
                .expect("Should find the sent group message");

            assert_eq!(received_msg.encrypted_content, group_message, "Message content should match");
            assert_eq!(received_msg.sender_user_id, user1.user_id()?, "Sender should match");

            println!("✅ Group message retrieved successfully");
        }
        Some(proto::messaging::get_group_messages_response::Result::Error(error)) => {
            return Err(format!("Get group messages failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from get_group_messages".into()),
    }

    Ok(())
}

#[tokio::test]
async fn test_06_offline_message_delivery() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 6: Offline Message Delivery");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user1 = TestUser::new(&format!("online_{}", &user1_id[..8]));
    let mut user2 = TestUser::new(&format!("offline_{}", &user2_id[..8]));

    // Register both users
    user1.register(&env).await?;
    user2.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // User 1 sends message to User 2 (who is "offline" - not listening)
    let message_content = b"Message while offline".to_vec();
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)?
        .as_secs() as i64;

    let send_request = Request::new(SendMessageRequest {
        access_token: user1.token()?,
        recipient_user_id: user2.user_id()?,
        recipient_device_id: user2.device_id()?,
        encrypted_content: message_content.clone(),
        client_message_id: Uuid::new_v4().to_string(),
        client_timestamp: Some(Timestamp {
            seconds: now,
            nanos: 0,
        }),
        message_type: MessageType::Text as i32,
        media_id: String::new(),
        recipient_username: user2.username.clone(),
    });

    let send_response = messaging_client.send_message(send_request).await?.into_inner();

    if let Some(proto::messaging::send_message_response::Result::Success(success)) = send_response.result {
        println!("✅ Message sent to offline user: {}", success.message_id);
    }

    // Simulate User 2 coming online and fetching messages
    sleep(Duration::from_secs(2)).await;

    let conversation_id = generate_conversation_id(&user1.user_id()?, &user2.user_id()?);

    let get_request = Request::new(GetMessagesRequest {
        access_token: user2.token()?,
        conversation_user_id: String::new(),
        conversation_id: conversation_id.clone(),
        start_time: None,
        end_time: None,
        pagination: None,
        limit: 10,
    });

    let get_response = messaging_client.get_messages(get_request).await?.into_inner();

    match get_response.result {
        Some(proto::messaging::get_messages_response::Result::Success(success)) => {
            assert!(!success.messages.is_empty(), "Should have offline messages");

            let offline_msg = success.messages.iter()
                .find(|m| m.encrypted_content == message_content)
                .expect("Should find the offline message");

            println!("✅ Offline message retrieved successfully");
            println!("✅ Delivery status: {} (0=SENT, 1=DELIVERED)", offline_msg.delivery_status);
        }
        Some(proto::messaging::get_messages_response::Result::Error(error)) => {
            return Err(format!("Get messages failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from get_messages".into()),
    }

    Ok(())
}

#[tokio::test]
async fn test_07_group_member_management() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 7: Group Member Management");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let user3_id = Uuid::new_v4().to_string().replace("-", "");
    let user4_id = Uuid::new_v4().to_string().replace("-", "");

    let mut user1 = TestUser::new(&format!("admin_{}", &user1_id[..8]));
    let mut user2 = TestUser::new(&format!("member1_{}", &user2_id[..8]));
    let mut user3 = TestUser::new(&format!("member2_{}", &user3_id[..8]));
    let mut user4 = TestUser::new(&format!("new_member_{}", &user4_id[..8]));

    // Register all users
    user1.register(&env).await?;
    user2.register(&env).await?;
    user3.register(&env).await?;
    user4.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // User 1 creates a group with user2 and user3
    let create_group_request = Request::new(proto::messaging::CreateGroupRequest {
        access_token: user1.token()?,
        group_name: "Member Management Test".to_string(),
        member_user_ids: vec![user2.user_id()?, user3.user_id()?],
        mls_group_state: vec![], // Mock MLS state
    });

    let create_response = messaging_client.create_group(create_group_request).await?.into_inner();

    let group_id = match create_response.result {
        Some(proto::messaging::create_group_response::Result::Success(success)) => {
            println!("✅ Group created: {}", success.group_id);
            success.group_id
        }
        _ => return Err("Failed to create group".into()),
    };

    sleep(Duration::from_secs(1)).await;

    // User 1 adds user4 to the group
    let add_member_request = Request::new(proto::messaging::AddGroupMemberRequest {
        access_token: user1.token()?,
        group_id: group_id.clone(),
        member_user_id: user4.user_id()?,
        member_device_id: user4.device_id()?,
        mls_group_state: vec![], // Mock MLS state
    });

    let add_response = messaging_client.add_group_member(add_member_request).await?.into_inner();

    match add_response.result {
        Some(proto::messaging::add_group_member_response::Result::Success(_)) => {
            println!("✅ User 4 added to group");
        }
        Some(proto::messaging::add_group_member_response::Result::Error(error)) => {
            return Err(format!("Add member failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from add_group_member".into()),
    }

    sleep(Duration::from_secs(1)).await;

    // User 1 removes user3 from the group
    let remove_member_request = Request::new(proto::messaging::RemoveGroupMemberRequest {
        access_token: user1.token()?,
        group_id: group_id.clone(),
        member_user_id: user3.user_id()?,
        mls_group_state: vec![], // Mock MLS state
    });

    let remove_response = messaging_client.remove_group_member(remove_member_request).await?.into_inner();

    match remove_response.result {
        Some(proto::messaging::remove_group_member_response::Result::Success(_)) => {
            println!("✅ User 3 removed from group");
        }
        Some(proto::messaging::remove_group_member_response::Result::Error(error)) => {
            return Err(format!("Remove member failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from remove_group_member".into()),
    }

    sleep(Duration::from_secs(1)).await;

    // Verify user3 cannot access group messages
    let get_group_request = Request::new(proto::messaging::GetGroupMessagesRequest {
        access_token: user3.token()?,
        group_id: group_id.clone(),
        start_time: None,
        end_time: None,
        pagination: None,
        limit: 10,
    });

    let get_group_response = messaging_client.get_group_messages(get_group_request).await?.into_inner();

    match get_group_response.result {
        Some(proto::messaging::get_group_messages_response::Result::Error(error)) => {
            println!("✅ Removed user cannot access group (expected error: {:?})", error.code());
        }
        Some(proto::messaging::get_group_messages_response::Result::Success(_)) => {
            return Err("Removed user should not have access to group messages".into());
        }
        None => return Err("No response from get_group_messages".into()),
    }

    // Verify user4 CAN access group
    let get_group_request_user4 = Request::new(proto::messaging::GetGroupMessagesRequest {
        access_token: user4.token()?,
        group_id: group_id.clone(),
        start_time: None,
        end_time: None,
        pagination: None,
        limit: 10,
    });

    let get_group_response_user4 = messaging_client.get_group_messages(get_group_request_user4).await?.into_inner();

    match get_group_response_user4.result {
        Some(proto::messaging::get_group_messages_response::Result::Success(_)) => {
            println!("✅ New member can access group messages");
        }
        _ => return Err("New member should have access to group".into()),
    }

    Ok(())
}
