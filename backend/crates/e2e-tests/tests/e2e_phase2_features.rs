//! E2E Tests for Phase 2 Features
//!
//! This module contains integration tests for messenger features implemented in Phase 2:
//! - Message reactions (add/remove/get)
//! - Enhanced read receipts
//! - Message forwarding
//! - Message editing
//! - Disappearing messages configuration
//!
//! Prerequisites:
//! - Docker Compose services running (`docker compose -f docker-compose.dev.yml up -d`)
//! - OR k3d cluster running with port-forwarding:
//!   kubectl port-forward -n apps svc/auth-service 50051:50051 &
//!   kubectl port-forward -n apps svc/messaging-service 50052:50052 &
//!
//! Run tests with:
//! ```bash
//! cd /home/anry/projects/guardyn/guardyn
//! nix --extra-experimental-features 'nix-command flakes' develop --command bash -c \
//!   "cd backend && cargo test -p guardyn-e2e-tests e2e_phase2 -- --nocapture --test-threads=1"
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

use proto::auth::{auth_service_client::AuthServiceClient, RegisterRequest};
use proto::common::{KeyBundle, Timestamp};
use proto::messaging::{
    messaging_service_client::MessagingServiceClient, GetMessagesRequest, MessageType,
    SendMessageRequest,
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

/// Create a mock key bundle for MVP testing (without real cryptography)
fn mock_key_bundle() -> KeyBundle {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64;

    KeyBundle {
        identity_key: vec![0u8; 32],           // Mock Ed25519 public key
        signed_pre_key: vec![0u8; 32],         // Mock X25519 public key
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
    device_id: Option<String>,
    user_id: Option<String>,
    token: Option<String>,
}

impl TestUser {
    fn new(username: &str) -> Self {
        Self {
            username: username.to_string(),
            password: "SecurePassword123!".to_string(),
            device_id: None,
            user_id: None,
            token: None,
        }
    }

    async fn register(&mut self, env: &TestEnv) -> Result<(), Box<dyn std::error::Error>> {
        let mut client = env.auth_client().await?;

        let request = Request::new(RegisterRequest {
            username: self.username.clone(),
            password: self.password.clone(),
            email: format!("{}@test.guardyn.local", self.username),
            device_name: "E2E Test Device".to_string(),
            device_type: "desktop".to_string(),
            key_bundle: Some(mock_key_bundle()),
        });

        let response = client.register(request).await?.into_inner();

        match response.result {
            Some(proto::auth::register_response::Result::Success(success)) => {
                self.user_id = Some(success.user_id.clone());
                self.device_id = Some(success.device_id.clone());
                self.token = Some(success.access_token.clone());
                Ok(())
            }
            Some(proto::auth::register_response::Result::Error(error)) => {
                Err(format!("Registration failed: {:?} - {}", error.code(), error.message).into())
            }
            None => Err("No response from registration".into()),
        }
    }

    fn token(&self) -> Result<String, Box<dyn std::error::Error>> {
        self.token
            .clone()
            .ok_or_else(|| "User not authenticated".into())
    }

    fn user_id(&self) -> Result<String, Box<dyn std::error::Error>> {
        self.user_id
            .clone()
            .ok_or_else(|| "User not registered".into())
    }

    fn device_id(&self) -> Result<String, Box<dyn std::error::Error>> {
        self.device_id
            .clone()
            .ok_or_else(|| "User not registered".into())
    }
}

/// Generate deterministic conversation ID from two user IDs
fn generate_conversation_id(user_id1: &str, user_id2: &str) -> String {
    let mut ids = [user_id1, user_id2];
    ids.sort();
    format!("conv_{}_{}", ids[0], ids[1])
}

// ============================================================================
// Test: Message Reactions
// ============================================================================

#[tokio::test]
async fn test_phase2_01_add_and_remove_reaction() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Phase 2 Test 1: Add and Remove Reaction");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user1 = TestUser::new(&format!("reactor1_{}", &user1_id[..8]));
    let mut user2 = TestUser::new(&format!("reactor2_{}", &user2_id[..8]));

    // Register both users
    user1.register(&env).await?;
    user2.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;
    let conversation_id = generate_conversation_id(&user1.user_id()?, &user2.user_id()?);

    // User 1 sends a message to User 2
    let message_content = b"React to this message!".to_vec();
    let now = SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs() as i64;

    let send_request = Request::new(SendMessageRequest {
        access_token: user1.token()?,
        recipient_user_id: user2.user_id()?,
        recipient_device_id: user2.device_id()?,
        encrypted_content: message_content,
        client_message_id: Uuid::new_v4().to_string(),
        client_timestamp: Some(Timestamp { seconds: now, nanos: 0 }),
        message_type: MessageType::Text as i32,
        media_id: String::new(),
        recipient_username: user2.username.clone(),
        x3dh_prekey: String::new(),
        thread_reference: None,
        voice_metadata: None,
    });

    let send_response = messaging_client.send_message(send_request).await?.into_inner();
    let message_id = match send_response.result {
        Some(proto::messaging::send_message_response::Result::Success(success)) => {
            println!("✅ Message sent: {}", success.message_id);
            success.message_id
        }
        _ => return Err("Failed to send message".into()),
    };

    sleep(Duration::from_secs(1)).await;

    // User 2 adds a reaction
    let add_reaction_request = Request::new(proto::messaging::AddReactionRequest {
        access_token: user2.token()?,
        message_id: message_id.clone(),
        conversation_id: conversation_id.clone(),
        emoji: "👍".to_string(),
        is_group: false,
    });

    let add_response = messaging_client
        .add_reaction(add_reaction_request)
        .await?
        .into_inner();

    match add_response.result {
        Some(proto::messaging::add_reaction_response::Result::Success(success)) => {
            println!("✅ Reaction added: {} by user", success.reaction.as_ref().map(|r| r.emoji.as_str()).unwrap_or("?"));
            assert!(success.reaction.is_some());
            let reaction = success.reaction.unwrap();
            assert_eq!(reaction.emoji, "👍");
            assert_eq!(reaction.message_id, message_id);
        }
        Some(proto::messaging::add_reaction_response::Result::Error(error)) => {
            return Err(format!("Add reaction failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from add_reaction".into()),
    }

    // Get reactions for the message
    let get_reactions_request = Request::new(proto::messaging::GetReactionsRequest {
        access_token: user1.token()?,
        message_id: message_id.clone(),
        conversation_id: conversation_id.clone(),
        is_group: false,
    });

    let get_response = messaging_client
        .get_reactions(get_reactions_request)
        .await?
        .into_inner();

    match get_response.result {
        Some(proto::messaging::get_reactions_response::Result::Success(success)) => {
            assert!(!success.reactions.is_empty(), "Should have at least one reaction");
            let reaction = success.reactions.iter().find(|r| r.emoji == "👍");
            assert!(reaction.is_some(), "Should find the thumbs up reaction");
            println!("✅ Got {} reaction(s) for message", success.reactions.len());
        }
        Some(proto::messaging::get_reactions_response::Result::Error(error)) => {
            return Err(format!("Get reactions failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from get_reactions".into()),
    }

    // User 2 removes the reaction
    let remove_reaction_request = Request::new(proto::messaging::RemoveReactionRequest {
        access_token: user2.token()?,
        message_id: message_id.clone(),
        conversation_id: conversation_id.clone(),
        emoji: "👍".to_string(),
        is_group: false,
    });

    let remove_response = messaging_client
        .remove_reaction(remove_reaction_request)
        .await?
        .into_inner();

    match remove_response.result {
        Some(proto::messaging::remove_reaction_response::Result::Success(success)) => {
            assert!(success.removed, "Reaction should be removed");
            println!("✅ Reaction removed successfully");
        }
        Some(proto::messaging::remove_reaction_response::Result::Error(error)) => {
            return Err(format!("Remove reaction failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from remove_reaction".into()),
    }

    // Verify reaction is gone
    let verify_request = Request::new(proto::messaging::GetReactionsRequest {
        access_token: user1.token()?,
        message_id: message_id.clone(),
        conversation_id: conversation_id.clone(),
        is_group: false,
    });

    let verify_response = messaging_client
        .get_reactions(verify_request)
        .await?
        .into_inner();

    match verify_response.result {
        Some(proto::messaging::get_reactions_response::Result::Success(success)) => {
            let thumbs_up = success.reactions.iter().find(|r| r.emoji == "👍" && r.user_id == user2.user_id().unwrap());
            assert!(thumbs_up.is_none(), "Reaction should be removed");
            println!("✅ Verified reaction was removed");
        }
        _ => {}
    }

    Ok(())
}

// ============================================================================
// Test: Enhanced Read Receipts
// ============================================================================

#[tokio::test]
async fn test_phase2_02_read_receipts() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Phase 2 Test 2: Enhanced Read Receipts");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user1 = TestUser::new(&format!("sender_rr_{}", &user1_id[..8]));
    let mut user2 = TestUser::new(&format!("reader_rr_{}", &user2_id[..8]));

    // Register both users
    user1.register(&env).await?;
    user2.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;
    let conversation_id = generate_conversation_id(&user1.user_id()?, &user2.user_id()?);

    // User 1 sends multiple messages
    let mut message_ids = Vec::new();
    for i in 1..=3 {
        let message_content = format!("Message {} for read receipt test", i).into_bytes();
        let now = SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs() as i64;

        let send_request = Request::new(SendMessageRequest {
            access_token: user1.token()?,
            recipient_user_id: user2.user_id()?,
            recipient_device_id: user2.device_id()?,
            encrypted_content: message_content,
            client_message_id: Uuid::new_v4().to_string(),
            client_timestamp: Some(Timestamp { seconds: now, nanos: 0 }),
            message_type: MessageType::Text as i32,
            media_id: String::new(),
            recipient_username: user2.username.clone(),
            x3dh_prekey: String::new(),
            thread_reference: None,
            voice_metadata: None,
        });

        let send_response = messaging_client.send_message(send_request).await?.into_inner();
        if let Some(proto::messaging::send_message_response::Result::Success(success)) = send_response.result {
            message_ids.push(success.message_id);
        }
        sleep(Duration::from_millis(100)).await;
    }
    println!("✅ Sent {} messages", message_ids.len());

    sleep(Duration::from_secs(1)).await;

    // User 2 sends read receipt for the last message
    let last_message_id = message_ids.last().cloned().unwrap_or_default();

    let send_receipt_request = Request::new(proto::messaging::SendReadReceiptRequest {
        access_token: user2.token()?,
        conversation_id: conversation_id.clone(),
        last_read_message_id: last_message_id.clone(),
        is_group: false,
    });

    let send_receipt_response = messaging_client
        .send_read_receipt(send_receipt_request)
        .await?
        .into_inner();

    match send_receipt_response.result {
        Some(proto::messaging::send_read_receipt_response::Result::Success(success)) => {
            println!("✅ Read receipt sent at {:?}", success.timestamp);
        }
        Some(proto::messaging::send_read_receipt_response::Result::Error(error)) => {
            return Err(format!("Send read receipt failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from send_read_receipt".into()),
    }

    sleep(Duration::from_secs(1)).await;

    // User 1 gets read receipts for the conversation
    let get_receipts_request = Request::new(proto::messaging::GetReadReceiptsRequest {
        access_token: user1.token()?,
        conversation_id: conversation_id.clone(),
        is_group: false,
    });

    let get_receipts_response = messaging_client
        .get_read_receipts(get_receipts_request)
        .await?
        .into_inner();

    match get_receipts_response.result {
        Some(proto::messaging::get_read_receipts_response::Result::Success(success)) => {
            let user2_receipt = success.receipts.iter()
                .find(|r| r.user_id == user2.user_id().unwrap());

            assert!(user2_receipt.is_some(), "Should have read receipt from User 2");
            let receipt = user2_receipt.unwrap();
            assert_eq!(receipt.last_read_message_id, last_message_id, "Last read message should match");
            println!("✅ Got read receipt: User 2 read up to message {}", receipt.last_read_message_id);
        }
        Some(proto::messaging::get_read_receipts_response::Result::Error(error)) => {
            return Err(format!("Get read receipts failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from get_read_receipts".into()),
    }

    Ok(())
}

// ============================================================================
// Test: Forward Message
// ============================================================================

#[tokio::test]
async fn test_phase2_03_forward_message() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Phase 2 Test 3: Forward Message");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let user3_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user1 = TestUser::new(&format!("fwd_sender_{}", &user1_id[..8]));
    let mut user2 = TestUser::new(&format!("fwd_rcv_{}", &user2_id[..8]));
    let mut user3 = TestUser::new(&format!("fwd_target_{}", &user3_id[..8]));

    // Register all users
    user1.register(&env).await?;
    user2.register(&env).await?;
    user3.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;
    let conversation_id_1_2 = generate_conversation_id(&user1.user_id()?, &user2.user_id()?);
    let conversation_id_2_3 = generate_conversation_id(&user2.user_id()?, &user3.user_id()?);

    // User 1 sends a message to User 2
    let original_content = b"This is the original message to forward!".to_vec();
    let now = SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs() as i64;

    let send_request = Request::new(SendMessageRequest {
        access_token: user1.token()?,
        recipient_user_id: user2.user_id()?,
        recipient_device_id: user2.device_id()?,
        encrypted_content: original_content.clone(),
        client_message_id: Uuid::new_v4().to_string(),
        client_timestamp: Some(Timestamp { seconds: now, nanos: 0 }),
        message_type: MessageType::Text as i32,
        media_id: String::new(),
        recipient_username: user2.username.clone(),
        x3dh_prekey: String::new(),
        thread_reference: None,
        voice_metadata: None,
    });

    let send_response = messaging_client.send_message(send_request).await?.into_inner();
    let source_message_id = match send_response.result {
        Some(proto::messaging::send_message_response::Result::Success(success)) => {
            println!("✅ Original message sent: {}", success.message_id);
            success.message_id
        }
        _ => return Err("Failed to send original message".into()),
    };

    sleep(Duration::from_secs(1)).await;

    // User 2 forwards the message to User 3
    let forward_request = Request::new(proto::messaging::ForwardMessageRequest {
        access_token: user2.token()?,
        source_message_id: source_message_id.clone(),
        source_conversation_id: conversation_id_1_2.clone(),
        source_is_group: false,
        target_conversation_id: conversation_id_2_3.clone(),
        target_is_group: false,
        target_user_id: user3.user_id()?,
        encrypted_content: original_content.clone(), // Re-encrypted for User 3
        client_message_id: Uuid::new_v4().to_string(),
    });

    let forward_response = messaging_client
        .forward_message(forward_request)
        .await?
        .into_inner();

    let forwarded_message_id = match forward_response.result {
        Some(proto::messaging::forward_message_response::Result::Success(success)) => {
            println!("✅ Message forwarded: {}", success.message_id);
            success.message_id
        }
        Some(proto::messaging::forward_message_response::Result::Error(error)) => {
            return Err(format!("Forward failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from forward_message".into()),
    };

    sleep(Duration::from_secs(1)).await;

    // User 3 retrieves messages and verifies forwarded message
    let get_request = Request::new(GetMessagesRequest {
        access_token: user3.token()?,
        conversation_user_id: String::new(),
        conversation_id: conversation_id_2_3.clone(),
        start_time: None,
        end_time: None,
        pagination: None,
        limit: 10,
    });

    let get_response = messaging_client.get_messages(get_request).await?.into_inner();

    match get_response.result {
        Some(proto::messaging::get_messages_response::Result::Success(success)) => {
            let forwarded_msg = success.messages.iter()
                .find(|m| m.message_id == forwarded_message_id);

            assert!(forwarded_msg.is_some(), "Should find forwarded message");
            let msg = forwarded_msg.unwrap();
            assert_eq!(msg.encrypted_content, original_content, "Content should match");
            assert!(msg.forward_info.is_some(), "Should have forward_info");

            let forward_info = msg.forward_info.as_ref().unwrap();
            assert_eq!(forward_info.original_message_id, source_message_id, "Original message ID should match");
            println!("✅ User 3 received forwarded message with forward_info");
        }
        Some(proto::messaging::get_messages_response::Result::Error(error)) => {
            return Err(format!("Get messages failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from get_messages".into()),
    }

    Ok(())
}

// ============================================================================
// Test: Edit Message
// ============================================================================

#[tokio::test]
async fn test_phase2_04_edit_message() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Phase 2 Test 4: Edit Message");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user1 = TestUser::new(&format!("editor_{}", &user1_id[..8]));
    let mut user2 = TestUser::new(&format!("viewer_{}", &user2_id[..8]));

    // Register both users
    user1.register(&env).await?;
    user2.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;
    let conversation_id = generate_conversation_id(&user1.user_id()?, &user2.user_id()?);

    // User 1 sends a message
    let original_content = b"Original message with typo".to_vec();
    let now = SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs() as i64;

    let send_request = Request::new(SendMessageRequest {
        access_token: user1.token()?,
        recipient_user_id: user2.user_id()?,
        recipient_device_id: user2.device_id()?,
        encrypted_content: original_content,
        client_message_id: Uuid::new_v4().to_string(),
        client_timestamp: Some(Timestamp { seconds: now, nanos: 0 }),
        message_type: MessageType::Text as i32,
        media_id: String::new(),
        recipient_username: user2.username.clone(),
        x3dh_prekey: String::new(),
        thread_reference: None,
        voice_metadata: None,
    });

    let send_response = messaging_client.send_message(send_request).await?.into_inner();
    let message_id = match send_response.result {
        Some(proto::messaging::send_message_response::Result::Success(success)) => {
            println!("✅ Original message sent: {}", success.message_id);
            success.message_id
        }
        _ => return Err("Failed to send original message".into()),
    };

    sleep(Duration::from_secs(1)).await;

    // User 1 edits the message
    let edited_content = b"Edited message without typo".to_vec();
    let edit_now = SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs() as i64;

    let edit_request = Request::new(proto::messaging::EditMessageRequest {
        access_token: user1.token()?,
        message_id: message_id.clone(),
        conversation_id: conversation_id.clone(),
        is_group: false,
        encrypted_content: edited_content.clone(),
        client_timestamp: Some(Timestamp { seconds: edit_now, nanos: 0 }),
    });

    let edit_response = messaging_client.edit_message(edit_request).await?.into_inner();

    match edit_response.result {
        Some(proto::messaging::edit_message_response::Result::Success(success)) => {
            println!("✅ Message edited, version: {}", success.edit_version);
            assert!(success.edit_version >= 1, "Edit version should be >= 1");
        }
        Some(proto::messaging::edit_message_response::Result::Error(error)) => {
            return Err(format!("Edit failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from edit_message".into()),
    }

    sleep(Duration::from_secs(1)).await;

    // User 2 retrieves messages and verifies edited content
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
            let edited_msg = success.messages.iter().find(|m| m.message_id == message_id);

            assert!(edited_msg.is_some(), "Should find the message");
            let msg = edited_msg.unwrap();
            assert_eq!(msg.encrypted_content, edited_content, "Content should be edited");
            assert!(msg.edit_version >= 1, "Edit version should be >= 1");
            assert!(msg.last_edited_at.is_some(), "Should have last_edited_at timestamp");
            println!("✅ User 2 sees edited content, version: {}", msg.edit_version);
        }
        Some(proto::messaging::get_messages_response::Result::Error(error)) => {
            return Err(format!("Get messages failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from get_messages".into()),
    }

    Ok(())
}

// ============================================================================
// Test: Disappearing Messages
// ============================================================================

#[tokio::test]
async fn test_phase2_05_disappearing_messages() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Phase 2 Test 5: Disappearing Messages");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user1 = TestUser::new(&format!("disappear1_{}", &user1_id[..8]));
    let mut user2 = TestUser::new(&format!("disappear2_{}", &user2_id[..8]));

    // Register both users
    user1.register(&env).await?;
    user2.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;
    let conversation_id = generate_conversation_id(&user1.user_id()?, &user2.user_id()?);

    // User 1 enables disappearing messages (1 day TTL)
    let ttl_seconds = 86400; // 1 day

    let set_disappearing_request = Request::new(proto::messaging::SetDisappearingMessagesRequest {
        access_token: user1.token()?,
        conversation_id: conversation_id.clone(),
        is_group: false,
        ttl_seconds,
    });

    let set_response = messaging_client
        .set_disappearing_messages(set_disappearing_request)
        .await?
        .into_inner();

    match set_response.result {
        Some(proto::messaging::set_disappearing_messages_response::Result::Success(success)) => {
            let config = success.config.unwrap();
            assert_eq!(config.ttl_seconds, ttl_seconds, "TTL should match");
            assert_eq!(config.set_by_user_id, user1.user_id()?, "Set by should be User 1");
            println!("✅ Disappearing messages enabled: {} seconds TTL", config.ttl_seconds);
        }
        Some(proto::messaging::set_disappearing_messages_response::Result::Error(error)) => {
            return Err(format!("Set disappearing failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from set_disappearing_messages".into()),
    }

    // User 2 gets the disappearing config
    let get_config_request = Request::new(proto::messaging::GetDisappearingConfigRequest {
        access_token: user2.token()?,
        conversation_id: conversation_id.clone(),
        is_group: false,
    });

    let get_config_response = messaging_client
        .get_disappearing_config(get_config_request)
        .await?
        .into_inner();

    match get_config_response.result {
        Some(proto::messaging::get_disappearing_config_response::Result::Success(success)) => {
            let config = success.config.unwrap();
            assert_eq!(config.ttl_seconds, ttl_seconds, "TTL should match for User 2");
            println!("✅ User 2 sees disappearing config: {} seconds", config.ttl_seconds);
        }
        Some(proto::messaging::get_disappearing_config_response::Result::Error(error)) => {
            return Err(format!("Get config failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from get_disappearing_config".into()),
    }

    // User 1 disables disappearing messages
    let disable_request = Request::new(proto::messaging::SetDisappearingMessagesRequest {
        access_token: user1.token()?,
        conversation_id: conversation_id.clone(),
        is_group: false,
        ttl_seconds: 0, // 0 = disabled
    });

    let disable_response = messaging_client
        .set_disappearing_messages(disable_request)
        .await?
        .into_inner();

    match disable_response.result {
        Some(proto::messaging::set_disappearing_messages_response::Result::Success(success)) => {
            let config = success.config.unwrap();
            assert_eq!(config.ttl_seconds, 0, "TTL should be 0 (disabled)");
            println!("✅ Disappearing messages disabled");
        }
        Some(proto::messaging::set_disappearing_messages_response::Result::Error(error)) => {
            return Err(format!("Disable disappearing failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from set_disappearing_messages".into()),
    }

    Ok(())
}

// ============================================================================
// Test: Multiple Reactions from Multiple Users
// ============================================================================

#[tokio::test]
async fn test_phase2_06_multiple_reactions() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Phase 2 Test 6: Multiple Reactions from Multiple Users");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let user1_id = Uuid::new_v4().to_string().replace("-", "");
    let user2_id = Uuid::new_v4().to_string().replace("-", "");
    let user3_id = Uuid::new_v4().to_string().replace("-", "");

    let mut user1 = TestUser::new(&format!("multi_r1_{}", &user1_id[..8]));
    let mut user2 = TestUser::new(&format!("multi_r2_{}", &user2_id[..8]));
    let mut user3 = TestUser::new(&format!("multi_r3_{}", &user3_id[..8]));

    // Register all users
    user1.register(&env).await?;
    user2.register(&env).await?;
    user3.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // Create a group with all users
    let create_group_request = Request::new(proto::messaging::CreateGroupRequest {
        access_token: user1.token()?,
        group_name: "Reaction Test Group".to_string(),
        member_user_ids: vec![user2.user_id()?, user3.user_id()?],
        mls_group_state: vec![],
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

    // User 1 sends a group message
    let message_content = b"React to this group message!".to_vec();
    let now = SystemTime::now().duration_since(UNIX_EPOCH)?.as_secs() as i64;

    let send_group_request = Request::new(proto::messaging::SendGroupMessageRequest {
        access_token: user1.token()?,
        group_id: group_id.clone(),
        encrypted_content: message_content,
        message_type: MessageType::Text as i32,
        client_message_id: Uuid::new_v4().to_string(),
        client_timestamp: Some(Timestamp { seconds: now, nanos: 0 }),
        media_id: String::new(),
        thread_reference: None,
        voice_metadata: None,
    });

    let send_response = messaging_client.send_group_message(send_group_request).await?.into_inner();
    let message_id = match send_response.result {
        Some(proto::messaging::send_group_message_response::Result::Success(success)) => {
            println!("✅ Group message sent: {}", success.message_id);
            success.message_id
        }
        _ => return Err("Failed to send group message".into()),
    };

    sleep(Duration::from_secs(1)).await;

    // All users add different reactions
    let reactions = vec![
        (&user1, "👍"),
        (&user2, "❤️"),
        (&user3, "😂"),
        (&user2, "👍"), // User 2 also adds thumbs up
    ];

    for (user, emoji) in reactions {
        let add_request = Request::new(proto::messaging::AddReactionRequest {
            access_token: user.token()?,
            message_id: message_id.clone(),
            conversation_id: group_id.clone(),
            emoji: emoji.to_string(),
            is_group: true,
        });

        let _ = messaging_client.add_reaction(add_request).await?;
        println!("✅ {} added {} reaction", user.username, emoji);
    }

    sleep(Duration::from_secs(1)).await;

    // Get all reactions and verify counts
    let get_reactions_request = Request::new(proto::messaging::GetReactionsRequest {
        access_token: user1.token()?,
        message_id: message_id.clone(),
        conversation_id: group_id.clone(),
        is_group: true,
    });

    let get_response = messaging_client.get_reactions(get_reactions_request).await?.into_inner();

    match get_response.result {
        Some(proto::messaging::get_reactions_response::Result::Success(success)) => {
            assert!(success.reactions.len() >= 3, "Should have at least 3 reactions");

            // Count unique emojis
            let thumbs_up = success.reactions.iter().filter(|r| r.emoji == "👍").count();
            let hearts = success.reactions.iter().filter(|r| r.emoji == "❤️").count();
            let laughs = success.reactions.iter().filter(|r| r.emoji == "😂").count();

            println!("✅ Reactions: 👍={}, ❤️={}, 😂={}", thumbs_up, hearts, laughs);

            assert!(thumbs_up >= 2, "Should have 2 thumbs up reactions");
            assert!(hearts >= 1, "Should have 1 heart reaction");
            assert!(laughs >= 1, "Should have 1 laugh reaction");
        }
        Some(proto::messaging::get_reactions_response::Result::Error(error)) => {
            return Err(format!("Get reactions failed: {:?} - {}", error.code(), error.message).into());
        }
        None => return Err("No response from get_reactions".into()),
    }

    Ok(())
}
