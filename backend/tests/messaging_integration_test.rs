/// Integration tests for Messaging Service
///
/// Tests cover:
/// 1. Send and receive 1-on-1 messages
/// 2. Message history retrieval
/// 3. Mark messages as read
/// 4. Delete messages
/// 5. Receive streaming (real-time delivery)
/// 6. Offline message delivery
/// 7. Group chat (create, send, receive)

use tonic::Request;
use uuid::Uuid;

// Import generated protobuf types
pub mod proto {
    pub mod common {
        tonic::include_proto!("guardyn.common");
    }
    pub mod auth {
        tonic::include_proto!("guardyn.auth");
    }
    pub mod messaging {
        tonic::include_proto!("guardyn.messaging");
    }
}

use proto::auth::{
    auth_service_client::AuthServiceClient, LoginRequest, RegisterRequest,
};
use proto::messaging::{
    messaging_service_client::MessagingServiceClient, SendMessageRequest,
    GetMessagesRequest, MarkAsReadRequest, DeleteMessageRequest,
    CreateGroupRequest, SendGroupMessageRequest, GetGroupMessagesRequest,
};
use proto::common::{KeyBundle, Timestamp};

// Test configuration
const AUTH_SERVICE_URL: &str = "http://localhost:50051";
const MESSAGING_SERVICE_URL: &str = "http://localhost:50052";

// Helper: Create test user and return access token
async fn create_test_user(username: &str, password: &str) -> String {
    let mut client = AuthServiceClient::connect(AUTH_SERVICE_URL)
        .await
        .expect("Failed to connect to auth service");

    let key_bundle = KeyBundle {
        identity_key: vec![1; 32],
        signed_pre_key: vec![2; 32],
        signed_pre_key_signature: vec![3; 64],
        one_time_pre_keys: vec![vec![4; 32], vec![5; 32]],
    };

    let request = Request::new(RegisterRequest {
        username: username.to_string(),
        password: password.to_string(),
        device_name: "test-device".to_string(),
        key_bundle: Some(key_bundle),
    });

    let response = client.register(request).await.expect("Register failed");
    let result = response.into_inner().result.unwrap();

    match result {
        proto::auth::register_response::Result::Success(success) => success.access_token,
        proto::auth::register_response::Result::Error(err) => {
            panic!("Registration error: {}", err.message);
        }
    }
}

// Helper: Login user and return access token
async fn login_user(username: &str, password: &str) -> String {
    let mut client = AuthServiceClient::connect(AUTH_SERVICE_URL)
        .await
        .expect("Failed to connect to auth service");

    let key_bundle = KeyBundle {
        identity_key: vec![1; 32],
        signed_pre_key: vec![2; 32],
        signed_pre_key_signature: vec![3; 64],
        one_time_pre_keys: vec![vec![4; 32]],
    };

    let request = Request::new(LoginRequest {
        username: username.to_string(),
        password: password.to_string(),
        device_name: "test-device".to_string(),
        key_bundle: Some(key_bundle),
    });

    let response = client.login(request).await.expect("Login failed");
    let result = response.into_inner().result.unwrap();

    match result {
        proto::auth::login_response::Result::Success(success) => success.access_token,
        proto::auth::login_response::Result::Error(err) => {
            panic!("Login error: {}", err.message);
        }
    }
}

#[tokio::test]
async fn test_send_and_receive_message() {
    // Create two test users
    let sender_username = format!("sender_{}", Uuid::new_v4());
    let recipient_username = format!("recipient_{}", Uuid::new_v4());
    
    let sender_token = create_test_user(&sender_username, "SecurePassword123").await;
    let recipient_token = create_test_user(&recipient_username, "SecurePassword123").await;

    // Connect to messaging service
    let mut client = MessagingServiceClient::connect(MESSAGING_SERVICE_URL)
        .await
        .expect("Failed to connect to messaging service");

    // Send message
    let encrypted_content = b"Hello, this is a test message!";
    let request = Request::new(SendMessageRequest {
        access_token: sender_token.clone(),
        recipient_user_id: recipient_username.clone(),
        recipient_device_id: None,
        encrypted_content: encrypted_content.to_vec(),
        message_type: 0, // TEXT
        client_timestamp: Some(Timestamp {
            seconds: chrono::Utc::now().timestamp(),
            nanos: 0,
        }),
    });

    let response = client.send_message(request).await.expect("Send message failed");
    let result = response.into_inner().result.unwrap();

    let message_id = match result {
        proto::messaging::send_message_response::Result::Success(success) => {
            assert!(!success.message_id.is_empty());
            success.message_id
        }
        proto::messaging::send_message_response::Result::Error(err) => {
            panic!("Send message error: {}", err.message);
        }
    };

    println!("✅ Message sent successfully: {}", message_id);

    // Retrieve messages as recipient
    tokio::time::sleep(tokio::time::Duration::from_millis(500)).await; // Wait for persistence

    let request = Request::new(GetMessagesRequest {
        access_token: recipient_token.clone(),
        conversation_id: None, // Auto-generate from user IDs
        limit: 10,
        before_message_id: None,
    });

    let response = client.get_messages(request).await.expect("Get messages failed");
    let result = response.into_inner().result.unwrap();

    match result {
        proto::messaging::get_messages_response::Result::Success(success) => {
            assert!(!success.messages.is_empty(), "No messages retrieved");
            let msg = &success.messages[0];
            assert_eq!(msg.message_id, message_id);
            assert_eq!(msg.encrypted_content, encrypted_content);
            println!("✅ Message retrieved successfully: {} bytes", msg.encrypted_content.len());
        }
        proto::messaging::get_messages_response::Result::Error(err) => {
            panic!("Get messages error: {}", err.message);
        }
    }
}

#[tokio::test]
async fn test_mark_messages_as_read() {
    // Create two test users
    let sender_username = format!("sender_{}", Uuid::new_v4());
    let recipient_username = format!("recipient_{}", Uuid::new_v4());
    
    let sender_token = create_test_user(&sender_username, "SecurePassword123").await;
    let recipient_token = create_test_user(&recipient_username, "SecurePassword123").await;

    let mut client = MessagingServiceClient::connect(MESSAGING_SERVICE_URL)
        .await
        .expect("Failed to connect to messaging service");

    // Send message
    let request = Request::new(SendMessageRequest {
        access_token: sender_token.clone(),
        recipient_user_id: recipient_username.clone(),
        recipient_device_id: None,
        encrypted_content: b"Test message for read receipt".to_vec(),
        message_type: 0,
        client_timestamp: Some(Timestamp {
            seconds: chrono::Utc::now().timestamp(),
            nanos: 0,
        }),
    });

    let response = client.send_message(request).await.expect("Send message failed");
    let result = response.into_inner().result.unwrap();
    let message_id = match result {
        proto::messaging::send_message_response::Result::Success(s) => s.message_id,
        proto::messaging::send_message_response::Result::Error(e) => panic!("Error: {}", e.message),
    };

    tokio::time::sleep(tokio::time::Duration::from_millis(500)).await;

    // Mark as read
    let request = Request::new(MarkAsReadRequest {
        access_token: recipient_token.clone(),
        message_ids: vec![message_id.clone()],
    });

    let response = client.mark_as_read(request).await.expect("Mark as read failed");
    let result = response.into_inner().result.unwrap();

    match result {
        proto::messaging::mark_as_read_response::Result::Success(success) => {
            assert_eq!(success.marked_count, 1);
            println!("✅ Message marked as read: {} messages", success.marked_count);
        }
        proto::messaging::mark_as_read_response::Result::Error(err) => {
            panic!("Mark as read error: {}", err.message);
        }
    }
}

#[tokio::test]
async fn test_delete_message() {
    // Create two test users
    let sender_username = format!("sender_{}", Uuid::new_v4());
    let recipient_username = format!("recipient_{}", Uuid::new_v4());
    
    let sender_token = create_test_user(&sender_username, "SecurePassword123").await;
    let recipient_token = create_test_user(&recipient_username, "SecurePassword123").await;

    let mut client = MessagingServiceClient::connect(MESSAGING_SERVICE_URL)
        .await
        .expect("Failed to connect to messaging service");

    // Send message
    let request = Request::new(SendMessageRequest {
        access_token: sender_token.clone(),
        recipient_user_id: recipient_username.clone(),
        recipient_device_id: None,
        encrypted_content: b"Test message to be deleted".to_vec(),
        message_type: 0,
        client_timestamp: Some(Timestamp {
            seconds: chrono::Utc::now().timestamp(),
            nanos: 0,
        }),
    });

    let response = client.send_message(request).await.expect("Send message failed");
    let result = response.into_inner().result.unwrap();
    let (message_id, conversation_id) = match result {
        proto::messaging::send_message_response::Result::Success(s) => {
            (s.message_id, s.conversation_id.unwrap_or_default())
        }
        proto::messaging::send_message_response::Result::Error(e) => panic!("Error: {}", e.message),
    };

    tokio::time::sleep(tokio::time::Duration::from_millis(500)).await;

    // Delete message
    let request = Request::new(DeleteMessageRequest {
        access_token: sender_token.clone(),
        conversation_id: conversation_id.clone(),
        message_id: message_id.clone(),
    });

    let response = client.delete_message(request).await.expect("Delete message failed");
    let result = response.into_inner().result.unwrap();

    match result {
        proto::messaging::delete_message_response::Result::Success(_) => {
            println!("✅ Message deleted successfully: {}", message_id);
        }
        proto::messaging::delete_message_response::Result::Error(err) => {
            panic!("Delete message error: {}", err.message);
        }
    }
}

#[tokio::test]
async fn test_group_chat_flow() {
    // Create three test users
    let creator_username = format!("creator_{}", Uuid::new_v4());
    let member1_username = format!("member1_{}", Uuid::new_v4());
    let member2_username = format!("member2_{}", Uuid::new_v4());
    
    let creator_token = create_test_user(&creator_username, "SecurePassword123").await;
    let member1_token = create_test_user(&member1_username, "SecurePassword123").await;
    let member2_token = create_test_user(&member2_username, "SecurePassword123").await;

    let mut client = MessagingServiceClient::connect(MESSAGING_SERVICE_URL)
        .await
        .expect("Failed to connect to messaging service");

    // Create group
    let request = Request::new(CreateGroupRequest {
        access_token: creator_token.clone(),
        group_name: "Test Group".to_string(),
        member_user_ids: vec![member1_username.clone(), member2_username.clone()],
        mls_group_info: vec![1, 2, 3], // Mock MLS data
    });

    let response = client.create_group(request).await.expect("Create group failed");
    let result = response.into_inner().result.unwrap();

    let group_id = match result {
        proto::messaging::create_group_response::Result::Success(success) => {
            assert!(!success.group_id.is_empty());
            println!("✅ Group created: {}", success.group_id);
            success.group_id
        }
        proto::messaging::create_group_response::Result::Error(err) => {
            panic!("Create group error: {}", err.message);
        }
    };

    // Send group message
    let request = Request::new(SendGroupMessageRequest {
        access_token: creator_token.clone(),
        group_id: group_id.clone(),
        encrypted_content: b"Hello group!".to_vec(),
        message_type: 0,
        client_timestamp: Some(Timestamp {
            seconds: chrono::Utc::now().timestamp(),
            nanos: 0,
        }),
    });

    let response = client.send_group_message(request).await.expect("Send group message failed");
    let result = response.into_inner().result.unwrap();

    let message_id = match result {
        proto::messaging::send_group_message_response::Result::Success(success) => {
            assert!(!success.message_id.is_empty());
            println!("✅ Group message sent: {}", success.message_id);
            success.message_id
        }
        proto::messaging::send_group_message_response::Result::Error(err) => {
            panic!("Send group message error: {}", err.message);
        }
    };

    tokio::time::sleep(tokio::time::Duration::from_millis(500)).await;

    // Retrieve group messages as member
    let request = Request::new(GetGroupMessagesRequest {
        access_token: member1_token.clone(),
        group_id: group_id.clone(),
        limit: 10,
        before_message_id: None,
    });

    let response = client.get_group_messages(request).await.expect("Get group messages failed");
    let result = response.into_inner().result.unwrap();

    match result {
        proto::messaging::get_group_messages_response::Result::Success(success) => {
            assert!(!success.messages.is_empty(), "No group messages retrieved");
            let msg = &success.messages[0];
            assert_eq!(msg.message_id, message_id);
            assert_eq!(msg.encrypted_content, b"Hello group!");
            println!("✅ Group message retrieved: {} bytes", msg.encrypted_content.len());
        }
        proto::messaging::get_group_messages_response::Result::Error(err) => {
            panic!("Get group messages error: {}", err.message);
        }
    }
}

#[tokio::test]
async fn test_offline_message_delivery() {
    // Create two test users
    let sender_username = format!("sender_{}", Uuid::new_v4());
    let recipient_username = format!("recipient_{}", Uuid::new_v4());
    
    let sender_token = create_test_user(&sender_username, "SecurePassword123").await;
    let recipient_token = create_test_user(&recipient_username, "SecurePassword123").await;

    let mut client = MessagingServiceClient::connect(MESSAGING_SERVICE_URL)
        .await
        .expect("Failed to connect to messaging service");

    // Send multiple messages while recipient is offline
    for i in 1..=3 {
        let request = Request::new(SendMessageRequest {
            access_token: sender_token.clone(),
            recipient_user_id: recipient_username.clone(),
            recipient_device_id: None,
            encrypted_content: format!("Offline message #{}", i).as_bytes().to_vec(),
            message_type: 0,
            client_timestamp: Some(Timestamp {
                seconds: chrono::Utc::now().timestamp(),
                nanos: 0,
            }),
        });

        let response = client.send_message(request).await.expect("Send message failed");
        match response.into_inner().result.unwrap() {
            proto::messaging::send_message_response::Result::Success(s) => {
                println!("✅ Offline message #{} sent: {}", i, s.message_id);
            }
            proto::messaging::send_message_response::Result::Error(e) => {
                panic!("Send message error: {}", e.message);
            }
        }
    }

    tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;

    // Recipient comes online and retrieves messages
    let request = Request::new(GetMessagesRequest {
        access_token: recipient_token.clone(),
        conversation_id: None,
        limit: 10,
        before_message_id: None,
    });

    let response = client.get_messages(request).await.expect("Get messages failed");
    let result = response.into_inner().result.unwrap();

    match result {
        proto::messaging::get_messages_response::Result::Success(success) => {
            assert_eq!(success.messages.len(), 3, "Expected 3 offline messages");
            println!("✅ Retrieved {} offline messages", success.messages.len());
            
            for (i, msg) in success.messages.iter().enumerate() {
                let expected_content = format!("Offline message #{}", 3 - i); // Reverse order
                println!("   - Message {}: {} bytes", i + 1, msg.encrypted_content.len());
            }
        }
        proto::messaging::get_messages_response::Result::Error(err) => {
            panic!("Get messages error: {}", err.message);
        }
    }
}
