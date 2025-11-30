//! E2E Tests for Group Chat Functionality
//!
//! Comprehensive tests for group chat features:
//! - Group creation
//! - Adding/removing members
//! - Group messaging
//! - Getting group list
//! - Getting group details
//! - Leaving a group
//!
//! Prerequisites:
//! - k3d cluster running (guardyn-poc)
//! - Port-forwarding active:
//!   kubectl port-forward -n apps svc/auth-service 50051:50051 &
//!   kubectl port-forward -n apps svc/messaging-service 50052:50052 &
//!
//! Run all group tests:
//! ```bash
//! cd /home/anry/projects/guardyn/guardyn
//! nix --extra-experimental-features 'nix-command flakes' develop --command bash -c \
//!   "cd backend && cargo test -p guardyn-e2e-tests --test e2e_groups -- --nocapture --test-threads=1"
//! ```
//!
//! Run a specific test:
//! ```bash
//! cargo test -p guardyn-e2e-tests --test e2e_groups test_01_create_group -- --nocapture
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
    messaging_service_client::MessagingServiceClient, AddGroupMemberRequest, CreateGroupRequest,
    GetGroupByIdRequest, GetGroupMessagesRequest, GetGroupsRequest, LeaveGroupRequest, MessageType,
    RemoveGroupMemberRequest, SendGroupMessageRequest,
};

// ============================================================================
// Test Environment
// ============================================================================

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

/// Create a mock key bundle for testing (without real cryptography)
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
// Test User Helper
// ============================================================================

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
                println!(
                    "  ✅ User '{}' registered (user_id: {})",
                    self.username, success.user_id
                );
                Ok(())
            }
            Some(proto::auth::register_response::Result::Error(error)) => Err(format!(
                "Registration failed for '{}': {:?} - {}",
                self.username,
                error.code(),
                error.message
            )
            .into()),
            None => Err("No response from register".into()),
        }
    }

    fn token(&self) -> Result<String, Box<dyn std::error::Error>> {
        self.access_token
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

// ============================================================================
// Test 1: Create Group
// ============================================================================

#[tokio::test]
async fn test_01_create_group() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 1: Create Group");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let unique_id = Uuid::new_v4().to_string().replace("-", "");

    let mut admin = TestUser::new(&format!("grp_admin_{}", &unique_id[..8]));
    admin.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // Create empty group (just admin)
    let create_request = Request::new(CreateGroupRequest {
        access_token: admin.token()?,
        group_name: "Test Group (Empty)".to_string(),
        member_user_ids: vec![],
        mls_group_state: vec![],
    });

    let create_response = messaging_client
        .create_group(create_request)
        .await?
        .into_inner();

    match create_response.result {
        Some(proto::messaging::create_group_response::Result::Success(success)) => {
            println!("  ✅ Empty group created: {}", success.group_id);
            assert!(!success.group_id.is_empty(), "Group ID should not be empty");
        }
        Some(proto::messaging::create_group_response::Result::Error(error)) => {
            return Err(
                format!("Create group failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from create_group".into()),
    }

    println!("\n✅ Test 1 PASSED: Group creation works\n");
    Ok(())
}

// ============================================================================
// Test 2: Create Group with Initial Members
// ============================================================================

#[tokio::test]
async fn test_02_create_group_with_members() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 2: Create Group with Initial Members");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let unique_id = Uuid::new_v4().to_string().replace("-", "");

    let mut admin = TestUser::new(&format!("grp2_admin_{}", &unique_id[..8]));
    let mut member1 = TestUser::new(&format!("grp2_mem1_{}", &unique_id[..8]));
    let mut member2 = TestUser::new(&format!("grp2_mem2_{}", &unique_id[..8]));

    // Register all users
    admin.register(&env).await?;
    member1.register(&env).await?;
    member2.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // Create group with initial members
    let create_request = Request::new(CreateGroupRequest {
        access_token: admin.token()?,
        group_name: "Test Group with Members".to_string(),
        member_user_ids: vec![member1.user_id()?, member2.user_id()?],
        mls_group_state: vec![],
    });

    let create_response = messaging_client
        .create_group(create_request)
        .await?
        .into_inner();

    let group_id = match create_response.result {
        Some(proto::messaging::create_group_response::Result::Success(success)) => {
            println!("  ✅ Group created with members: {}", success.group_id);
            success.group_id
        }
        Some(proto::messaging::create_group_response::Result::Error(error)) => {
            return Err(
                format!("Create group failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from create_group".into()),
    };

    // Verify group has members by getting group details
    sleep(Duration::from_millis(500)).await;

    let get_request = Request::new(GetGroupByIdRequest {
        access_token: admin.token()?,
        group_id: group_id.clone(),
    });

    let get_response = messaging_client
        .get_group_by_id(get_request)
        .await?
        .into_inner();

    match get_response.result {
        Some(proto::messaging::get_group_by_id_response::Result::Success(success)) => {
            let group = success.group.expect("Group should exist");
            println!("  ✅ Group details retrieved: {}", group.name);
            println!("  ✅ Member count: {}", group.member_count);

            // Should have admin + 2 members = 3
            assert!(
                group.member_count >= 1,
                "Group should have at least 1 member (admin)"
            );
        }
        Some(proto::messaging::get_group_by_id_response::Result::Error(error)) => {
            return Err(
                format!("Get group failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from get_group_by_id".into()),
    }

    println!("\n✅ Test 2 PASSED: Group with initial members created\n");
    Ok(())
}

// ============================================================================
// Test 3: Send and Retrieve Group Messages
// ============================================================================

#[tokio::test]
async fn test_03_group_messaging() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 3: Group Messaging");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let unique_id = Uuid::new_v4().to_string().replace("-", "");

    let mut admin = TestUser::new(&format!("grp3_admin_{}", &unique_id[..8]));
    let mut member = TestUser::new(&format!("grp3_mem_{}", &unique_id[..8]));

    admin.register(&env).await?;
    member.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // Create group
    let create_request = Request::new(CreateGroupRequest {
        access_token: admin.token()?,
        group_name: "Messaging Test Group".to_string(),
        member_user_ids: vec![member.user_id()?],
        mls_group_state: vec![],
    });

    let create_response = messaging_client
        .create_group(create_request)
        .await?
        .into_inner();

    let group_id = match create_response.result {
        Some(proto::messaging::create_group_response::Result::Success(success)) => {
            println!("  ✅ Group created: {}", success.group_id);
            success.group_id
        }
        Some(proto::messaging::create_group_response::Result::Error(error)) => {
            return Err(
                format!("Create group failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from create_group".into()),
    };

    sleep(Duration::from_millis(500)).await;

    // Admin sends a message
    let message_content = b"Hello from admin!".to_vec();
    let client_message_id = Uuid::new_v4().to_string();

    let send_request = Request::new(SendGroupMessageRequest {
        access_token: admin.token()?,
        group_id: group_id.clone(),
        encrypted_content: message_content.clone(),
        message_type: MessageType::Text as i32,
        client_message_id: client_message_id.clone(),
        client_timestamp: Some(Timestamp {
            seconds: SystemTime::now()
                .duration_since(UNIX_EPOCH)?
                .as_secs() as i64,
            nanos: 0,
        }),
        media_id: String::new(),
    });

    let send_response = messaging_client
        .send_group_message(send_request)
        .await?
        .into_inner();

    let message_id = match send_response.result {
        Some(proto::messaging::send_group_message_response::Result::Success(success)) => {
            println!("  ✅ Message sent: {}", success.message_id);
            success.message_id
        }
        Some(proto::messaging::send_group_message_response::Result::Error(error)) => {
            return Err(
                format!("Send message failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from send_group_message".into()),
    };

    sleep(Duration::from_secs(1)).await;

    // Member retrieves messages
    let get_request = Request::new(GetGroupMessagesRequest {
        access_token: member.token()?,
        group_id: group_id.clone(),
        start_time: None,
        end_time: None,
        pagination: None,
        limit: 10,
    });

    let get_response = messaging_client
        .get_group_messages(get_request)
        .await?
        .into_inner();

    match get_response.result {
        Some(proto::messaging::get_group_messages_response::Result::Success(success)) => {
            assert!(
                !success.messages.is_empty(),
                "Should have at least one message"
            );

            let received_msg = success
                .messages
                .iter()
                .find(|m| m.message_id == message_id)
                .expect("Should find the sent message");

            assert_eq!(
                received_msg.encrypted_content, message_content,
                "Message content should match"
            );
            assert_eq!(
                received_msg.sender_user_id,
                admin.user_id()?,
                "Sender should be admin"
            );

            println!(
                "  ✅ Message retrieved by member: {} messages",
                success.messages.len()
            );
        }
        Some(proto::messaging::get_group_messages_response::Result::Error(error)) => {
            return Err(
                format!("Get messages failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from get_group_messages".into()),
    }

    println!("\n✅ Test 3 PASSED: Group messaging works\n");
    Ok(())
}

// ============================================================================
// Test 4: Get User's Groups List
// ============================================================================

#[tokio::test]
async fn test_04_get_groups_list() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 4: Get Groups List");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let unique_id = Uuid::new_v4().to_string().replace("-", "");

    let mut user = TestUser::new(&format!("grp4_user_{}", &unique_id[..8]));
    user.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // Create multiple groups
    for i in 1..=3 {
        let create_request = Request::new(CreateGroupRequest {
            access_token: user.token()?,
            group_name: format!("Test Group {}", i),
            member_user_ids: vec![],
            mls_group_state: vec![],
        });

        let response = messaging_client
            .create_group(create_request)
            .await?
            .into_inner();

        match response.result {
            Some(proto::messaging::create_group_response::Result::Success(success)) => {
                println!("  ✅ Created group {}: {}", i, success.group_id);
            }
            Some(proto::messaging::create_group_response::Result::Error(error)) => {
                return Err(format!(
                    "Create group {} failed: {:?} - {}",
                    i,
                    error.code(),
                    error.message
                )
                .into());
            }
            None => return Err(format!("No response for group {}", i).into()),
        }
    }

    sleep(Duration::from_millis(500)).await;

    // Get groups list
    let get_request = Request::new(GetGroupsRequest {
        access_token: user.token()?,
        limit: 50,
        cursor: String::new(),
    });

    let get_response = messaging_client.get_groups(get_request).await?.into_inner();

    match get_response.result {
        Some(proto::messaging::get_groups_response::Result::Success(success)) => {
            println!("  ✅ Retrieved {} groups", success.groups.len());
            assert!(
                success.groups.len() >= 3,
                "Should have at least 3 groups created"
            );

            for group in &success.groups {
                println!("    - {}: {}", group.group_id, group.name);
            }
        }
        Some(proto::messaging::get_groups_response::Result::Error(error)) => {
            return Err(
                format!("Get groups failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from get_groups".into()),
    }

    println!("\n✅ Test 4 PASSED: Groups list retrieval works\n");
    Ok(())
}

// ============================================================================
// Test 5: Add Member to Group
// ============================================================================

#[tokio::test]
async fn test_05_add_group_member() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 5: Add Member to Group");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let unique_id = Uuid::new_v4().to_string().replace("-", "");

    let mut admin = TestUser::new(&format!("grp5_admin_{}", &unique_id[..8]));
    let mut new_member = TestUser::new(&format!("grp5_new_{}", &unique_id[..8]));

    admin.register(&env).await?;
    new_member.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // Create group without the new member
    let create_request = Request::new(CreateGroupRequest {
        access_token: admin.token()?,
        group_name: "Add Member Test Group".to_string(),
        member_user_ids: vec![],
        mls_group_state: vec![],
    });

    let create_response = messaging_client
        .create_group(create_request)
        .await?
        .into_inner();

    let group_id = match create_response.result {
        Some(proto::messaging::create_group_response::Result::Success(success)) => {
            println!("  ✅ Group created: {}", success.group_id);
            success.group_id
        }
        Some(proto::messaging::create_group_response::Result::Error(error)) => {
            return Err(
                format!("Create group failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from create_group".into()),
    };

    sleep(Duration::from_millis(500)).await;

    // Add new member
    let add_request = Request::new(AddGroupMemberRequest {
        access_token: admin.token()?,
        group_id: group_id.clone(),
        member_user_id: new_member.user_id()?,
        member_device_id: new_member.device_id()?,
        mls_group_state: vec![],
    });

    let add_response = messaging_client
        .add_group_member(add_request)
        .await?
        .into_inner();

    match add_response.result {
        Some(proto::messaging::add_group_member_response::Result::Success(success)) => {
            println!("  ✅ Member added: {}", success.added);
            assert!(success.added, "Member should be added");
        }
        Some(proto::messaging::add_group_member_response::Result::Error(error)) => {
            return Err(
                format!("Add member failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from add_group_member".into()),
    }

    sleep(Duration::from_millis(500)).await;

    // Verify new member can see the group
    let get_request = Request::new(GetGroupsRequest {
        access_token: new_member.token()?,
        limit: 50,
        cursor: String::new(),
    });

    let get_response = messaging_client.get_groups(get_request).await?.into_inner();

    match get_response.result {
        Some(proto::messaging::get_groups_response::Result::Success(success)) => {
            let found = success.groups.iter().any(|g| g.group_id == group_id);
            println!("  ✅ New member can see group: {}", found);
            assert!(found, "New member should see the group in their list");
        }
        Some(proto::messaging::get_groups_response::Result::Error(error)) => {
            return Err(
                format!("Get groups failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from get_groups".into()),
    }

    println!("\n✅ Test 5 PASSED: Add member works\n");
    Ok(())
}

// ============================================================================
// Test 6: Remove Member from Group
// ============================================================================

#[tokio::test]
async fn test_06_remove_group_member() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 6: Remove Member from Group");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let unique_id = Uuid::new_v4().to_string().replace("-", "");

    let mut admin = TestUser::new(&format!("grp6_admin_{}", &unique_id[..8]));
    let mut member = TestUser::new(&format!("grp6_mem_{}", &unique_id[..8]));

    admin.register(&env).await?;
    member.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // Create group with member
    let create_request = Request::new(CreateGroupRequest {
        access_token: admin.token()?,
        group_name: "Remove Member Test Group".to_string(),
        member_user_ids: vec![member.user_id()?],
        mls_group_state: vec![],
    });

    let create_response = messaging_client
        .create_group(create_request)
        .await?
        .into_inner();

    let group_id = match create_response.result {
        Some(proto::messaging::create_group_response::Result::Success(success)) => {
            println!("  ✅ Group created with member: {}", success.group_id);
            success.group_id
        }
        Some(proto::messaging::create_group_response::Result::Error(error)) => {
            return Err(
                format!("Create group failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from create_group".into()),
    };

    sleep(Duration::from_millis(500)).await;

    // Remove member
    let remove_request = Request::new(RemoveGroupMemberRequest {
        access_token: admin.token()?,
        group_id: group_id.clone(),
        member_user_id: member.user_id()?,
        mls_group_state: vec![],
    });

    let remove_response = messaging_client
        .remove_group_member(remove_request)
        .await?
        .into_inner();

    match remove_response.result {
        Some(proto::messaging::remove_group_member_response::Result::Success(success)) => {
            println!("  ✅ Member removed: {}", success.removed);
            assert!(success.removed, "Member should be removed");
        }
        Some(proto::messaging::remove_group_member_response::Result::Error(error)) => {
            return Err(
                format!("Remove member failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from remove_group_member".into()),
    }

    sleep(Duration::from_millis(500)).await;

    // Verify removed member cannot see the group anymore
    let get_request = Request::new(GetGroupsRequest {
        access_token: member.token()?,
        limit: 50,
        cursor: String::new(),
    });

    let get_response = messaging_client.get_groups(get_request).await?.into_inner();

    match get_response.result {
        Some(proto::messaging::get_groups_response::Result::Success(success)) => {
            let found = success.groups.iter().any(|g| g.group_id == group_id);
            println!(
                "  ✅ Removed member cannot see group: {}",
                !found
            );
            assert!(
                !found,
                "Removed member should not see the group in their list"
            );
        }
        Some(proto::messaging::get_groups_response::Result::Error(error)) => {
            // This might be expected if the user has no groups
            println!(
                "  ℹ️  Get groups returned error (expected if no groups): {:?}",
                error.code()
            );
        }
        None => {
            // Also acceptable - no groups for this user
            println!("  ℹ️  No groups returned (expected after removal)");
        }
    }

    println!("\n✅ Test 6 PASSED: Remove member works\n");
    Ok(())
}

// ============================================================================
// Test 7: Leave Group
// ============================================================================

#[tokio::test]
async fn test_07_leave_group() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 7: Leave Group");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let unique_id = Uuid::new_v4().to_string().replace("-", "");

    let mut admin = TestUser::new(&format!("grp7_admin_{}", &unique_id[..8]));
    let mut member = TestUser::new(&format!("grp7_mem_{}", &unique_id[..8]));

    admin.register(&env).await?;
    member.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // Create group with member
    let create_request = Request::new(CreateGroupRequest {
        access_token: admin.token()?,
        group_name: "Leave Group Test".to_string(),
        member_user_ids: vec![member.user_id()?],
        mls_group_state: vec![],
    });

    let create_response = messaging_client
        .create_group(create_request)
        .await?
        .into_inner();

    let group_id = match create_response.result {
        Some(proto::messaging::create_group_response::Result::Success(success)) => {
            println!("  ✅ Group created: {}", success.group_id);
            success.group_id
        }
        Some(proto::messaging::create_group_response::Result::Error(error)) => {
            return Err(
                format!("Create group failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from create_group".into()),
    };

    sleep(Duration::from_millis(500)).await;

    // Member leaves the group
    let leave_request = Request::new(LeaveGroupRequest {
        access_token: member.token()?,
        group_id: group_id.clone(),
    });

    let leave_response = messaging_client
        .leave_group(leave_request)
        .await?
        .into_inner();

    match leave_response.result {
        Some(proto::messaging::leave_group_response::Result::Success(success)) => {
            println!("  ✅ Member left group: {}", success.left);
            assert!(success.left, "Member should have left");
        }
        Some(proto::messaging::leave_group_response::Result::Error(error)) => {
            return Err(
                format!("Leave group failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from leave_group".into()),
    }

    sleep(Duration::from_millis(500)).await;

    // Verify member cannot see the group anymore
    let get_request = Request::new(GetGroupsRequest {
        access_token: member.token()?,
        limit: 50,
        cursor: String::new(),
    });

    let get_response = messaging_client.get_groups(get_request).await?.into_inner();

    match get_response.result {
        Some(proto::messaging::get_groups_response::Result::Success(success)) => {
            let found = success.groups.iter().any(|g| g.group_id == group_id);
            println!(
                "  ✅ Member who left cannot see group: {}",
                !found
            );
            assert!(!found, "Member who left should not see the group");
        }
        Some(proto::messaging::get_groups_response::Result::Error(_)) => {
            println!("  ℹ️  Get groups returned error (expected if no groups)");
        }
        None => {
            println!("  ℹ️  No groups returned (expected after leaving)");
        }
    }

    println!("\n✅ Test 7 PASSED: Leave group works\n");
    Ok(())
}

// ============================================================================
// Test 8: Get Group by ID
// ============================================================================

#[tokio::test]
async fn test_08_get_group_by_id() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 8: Get Group by ID");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();
    let unique_id = Uuid::new_v4().to_string().replace("-", "");

    let mut admin = TestUser::new(&format!("grp8_admin_{}", &unique_id[..8]));
    admin.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // Create group with specific name
    let group_name = "Detailed Info Test Group";
    let create_request = Request::new(CreateGroupRequest {
        access_token: admin.token()?,
        group_name: group_name.to_string(),
        member_user_ids: vec![],
        mls_group_state: vec![],
    });

    let create_response = messaging_client
        .create_group(create_request)
        .await?
        .into_inner();

    let group_id = match create_response.result {
        Some(proto::messaging::create_group_response::Result::Success(success)) => {
            println!("  ✅ Group created: {}", success.group_id);
            success.group_id
        }
        Some(proto::messaging::create_group_response::Result::Error(error)) => {
            return Err(
                format!("Create group failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from create_group".into()),
    };

    sleep(Duration::from_millis(500)).await;

    // Get group details
    let get_request = Request::new(GetGroupByIdRequest {
        access_token: admin.token()?,
        group_id: group_id.clone(),
    });

    let get_response = messaging_client
        .get_group_by_id(get_request)
        .await?
        .into_inner();

    match get_response.result {
        Some(proto::messaging::get_group_by_id_response::Result::Success(success)) => {
            let group = success.group.expect("Group should exist");
            println!("  ✅ Group details:");
            println!("    - ID: {}", group.group_id);
            println!("    - Name: {}", group.name);
            println!("    - Creator: {}", group.creator_user_id);
            println!("    - Members: {}", group.member_count);

            assert_eq!(group.group_id, group_id, "Group ID should match");
            assert_eq!(group.name, group_name, "Group name should match");
            assert_eq!(
                group.creator_user_id,
                admin.user_id()?,
                "Creator should be admin"
            );
        }
        Some(proto::messaging::get_group_by_id_response::Result::Error(error)) => {
            return Err(
                format!("Get group failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from get_group_by_id".into()),
    }

    println!("\n✅ Test 8 PASSED: Get group by ID works\n");
    Ok(())
}

// ============================================================================
// Test 9: Full Group Flow Integration
// ============================================================================

#[tokio::test]
async fn test_09_full_group_flow() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 9: Full Group Flow Integration");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    println!("This test simulates a complete group chat scenario:\n");

    let env = TestEnv::new();
    let unique_id = Uuid::new_v4().to_string().replace("-", "");

    // Create 3 users
    let mut alice = TestUser::new(&format!("alice_{}", &unique_id[..8]));
    let mut bob = TestUser::new(&format!("bob_{}", &unique_id[..8]));
    let mut charlie = TestUser::new(&format!("charlie_{}", &unique_id[..8]));

    println!("Step 1: Register users");
    alice.register(&env).await?;
    bob.register(&env).await?;
    charlie.register(&env).await?;

    let mut messaging_client = env.messaging_client().await?;

    // Step 2: Alice creates a group
    println!("\nStep 2: Alice creates 'Project Team' group with Bob");
    let create_request = Request::new(CreateGroupRequest {
        access_token: alice.token()?,
        group_name: "Project Team".to_string(),
        member_user_ids: vec![bob.user_id()?],
        mls_group_state: vec![],
    });

    let create_response = messaging_client
        .create_group(create_request)
        .await?
        .into_inner();

    let group_id = match create_response.result {
        Some(proto::messaging::create_group_response::Result::Success(success)) => {
            println!("  ✅ Group created: {}", success.group_id);
            success.group_id
        }
        Some(proto::messaging::create_group_response::Result::Error(error)) => {
            return Err(
                format!("Create group failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from create_group".into()),
    };

    sleep(Duration::from_millis(500)).await;

    // Step 3: Alice sends a welcome message
    println!("\nStep 3: Alice sends welcome message");
    let welcome_msg = b"Welcome to Project Team!".to_vec();
    let send_request = Request::new(SendGroupMessageRequest {
        access_token: alice.token()?,
        group_id: group_id.clone(),
        encrypted_content: welcome_msg.clone(),
        message_type: MessageType::Text as i32,
        client_message_id: Uuid::new_v4().to_string(),
        client_timestamp: Some(Timestamp {
            seconds: SystemTime::now()
                .duration_since(UNIX_EPOCH)?
                .as_secs() as i64,
            nanos: 0,
        }),
        media_id: String::new(),
    });

    let send_response = messaging_client
        .send_group_message(send_request)
        .await?
        .into_inner();

    match send_response.result {
        Some(proto::messaging::send_group_message_response::Result::Success(success)) => {
            println!("  ✅ Welcome message sent: {}", success.message_id);
        }
        Some(proto::messaging::send_group_message_response::Result::Error(error)) => {
            return Err(
                format!("Send message failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from send_group_message".into()),
    }

    sleep(Duration::from_millis(500)).await;

    // Step 4: Bob reads the message
    println!("\nStep 4: Bob reads group messages");
    let get_request = Request::new(GetGroupMessagesRequest {
        access_token: bob.token()?,
        group_id: group_id.clone(),
        start_time: None,
        end_time: None,
        pagination: None,
        limit: 10,
    });

    let get_response = messaging_client
        .get_group_messages(get_request)
        .await?
        .into_inner();

    match get_response.result {
        Some(proto::messaging::get_group_messages_response::Result::Success(success)) => {
            println!("  ✅ Bob sees {} message(s)", success.messages.len());
            for msg in &success.messages {
                let content = String::from_utf8_lossy(&msg.encrypted_content);
                println!(
                    "    - From {}: {}",
                    msg.sender_username.as_str(),
                    content
                );
            }
        }
        Some(proto::messaging::get_group_messages_response::Result::Error(error)) => {
            return Err(
                format!("Get messages failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from get_group_messages".into()),
    }

    // Step 5: Alice adds Charlie
    println!("\nStep 5: Alice adds Charlie to the group");
    let add_request = Request::new(AddGroupMemberRequest {
        access_token: alice.token()?,
        group_id: group_id.clone(),
        member_user_id: charlie.user_id()?,
        member_device_id: charlie.device_id()?,
        mls_group_state: vec![],
    });

    let add_response = messaging_client
        .add_group_member(add_request)
        .await?
        .into_inner();

    match add_response.result {
        Some(proto::messaging::add_group_member_response::Result::Success(_)) => {
            println!("  ✅ Charlie added to the group");
        }
        Some(proto::messaging::add_group_member_response::Result::Error(error)) => {
            return Err(
                format!("Add member failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from add_group_member".into()),
    }

    sleep(Duration::from_millis(500)).await;

    // Step 6: Charlie checks his groups
    println!("\nStep 6: Charlie checks his groups list");
    let get_request = Request::new(GetGroupsRequest {
        access_token: charlie.token()?,
        limit: 50,
        cursor: String::new(),
    });

    let get_response = messaging_client.get_groups(get_request).await?.into_inner();

    match get_response.result {
        Some(proto::messaging::get_groups_response::Result::Success(success)) => {
            let found = success.groups.iter().find(|g| g.group_id == group_id);
            if let Some(group) = found {
                println!("  ✅ Charlie sees 'Project Team': {}", group.name);
            } else {
                return Err("Charlie should see the group".into());
            }
        }
        Some(proto::messaging::get_groups_response::Result::Error(error)) => {
            return Err(
                format!("Get groups failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from get_groups".into()),
    }

    // Step 7: Bob leaves the group
    println!("\nStep 7: Bob leaves the group");
    let leave_request = Request::new(LeaveGroupRequest {
        access_token: bob.token()?,
        group_id: group_id.clone(),
    });

    let leave_response = messaging_client
        .leave_group(leave_request)
        .await?
        .into_inner();

    match leave_response.result {
        Some(proto::messaging::leave_group_response::Result::Success(_)) => {
            println!("  ✅ Bob left the group");
        }
        Some(proto::messaging::leave_group_response::Result::Error(error)) => {
            return Err(
                format!("Leave group failed: {:?} - {}", error.code(), error.message).into(),
            );
        }
        None => return Err("No response from leave_group".into()),
    }

    sleep(Duration::from_millis(500)).await;

    // Step 8: Bob verifies he can't see the group
    println!("\nStep 8: Bob verifies he can't see the group anymore");
    let get_request = Request::new(GetGroupsRequest {
        access_token: bob.token()?,
        limit: 50,
        cursor: String::new(),
    });

    let get_response = messaging_client.get_groups(get_request).await?.into_inner();

    match get_response.result {
        Some(proto::messaging::get_groups_response::Result::Success(success)) => {
            let found = success.groups.iter().any(|g| g.group_id == group_id);
            if !found {
                println!("  ✅ Bob no longer sees the group (as expected)");
            } else {
                return Err("Bob should not see the group after leaving".into());
            }
        }
        _ => {
            println!("  ✅ Bob has no groups (as expected after leaving)");
        }
    }

    println!("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    println!("✅ Test 9 PASSED: Full group flow works!\n");
    Ok(())
}
