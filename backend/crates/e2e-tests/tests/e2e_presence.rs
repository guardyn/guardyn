//! E2E Tests for Presence Service
//!
//! Tests presence-related functionality:
//! - Online/offline status updates and retrieval
//! - Typing indicators
//! - Last seen persistence
//!
//! Prerequisites:
//! - k3d cluster running (guardyn-poc)
//! - Port-forwarding active:
//!   kubectl port-forward -n apps svc/auth-service 50051:50051 &
//!   kubectl port-forward -n apps svc/presence-service 50053:50053 &
//!
//! Run tests with:
//! ```bash
//! cd /home/anry/projects/guardyn/guardyn
//! nix --extra-experimental-features 'nix-command flakes' develop --command bash -c \
//!   "cd backend && cargo test -p guardyn-e2e-tests --test e2e_presence -- --nocapture --test-threads=1"
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
    pub mod presence {
        tonic::include_proto!("guardyn.presence");
    }
    pub mod common {
        tonic::include_proto!("guardyn.common");
    }
}

use proto::auth::{auth_service_client::AuthServiceClient, RegisterRequest};
use proto::common::{KeyBundle, Timestamp};
use proto::presence::{
    presence_service_client::PresenceServiceClient, GetStatusRequest, SetTypingRequest,
    UpdateLastSeenRequest, UpdateStatusRequest, UserStatus,
};

/// Test environment configuration
struct TestEnv {
    auth_endpoint: String,
    presence_endpoint: String,
}

impl TestEnv {
    fn new() -> Self {
        Self {
            auth_endpoint: std::env::var("AUTH_ENDPOINT")
                .unwrap_or_else(|_| "http://localhost:50051".to_string()),
            presence_endpoint: std::env::var("PRESENCE_ENDPOINT")
                .unwrap_or_else(|_| "http://localhost:50053".to_string()),
        }
    }

    async fn auth_client(&self) -> Result<AuthServiceClient<Channel>, Box<dyn std::error::Error>> {
        let channel = Channel::from_shared(self.auth_endpoint.clone())?
            .timeout(Duration::from_secs(10))
            .connect()
            .await?;
        Ok(AuthServiceClient::new(channel))
    }

    async fn presence_client(
        &self,
    ) -> Result<PresenceServiceClient<Channel>, Box<dyn std::error::Error>> {
        let channel = Channel::from_shared(self.presence_endpoint.clone())?
            .timeout(Duration::from_secs(10))
            .connect()
            .await?;
        Ok(PresenceServiceClient::new(channel))
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
        created_at: Some(Timestamp { seconds: now, nanos: 0 }),
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
    #[allow(dead_code)]
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
                    "✅ User '{}' registered (user_id: {}, device_id: {})",
                    self.username, success.user_id, success.device_id
                );
                Ok(())
            }
            Some(proto::auth::register_response::Result::Error(error)) => Err(format!(
                "Registration failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into()),
            None => Err("No response from registration".into()),
        }
    }

    fn token(&self) -> Result<String, Box<dyn std::error::Error>> {
        self.access_token
            .as_ref()
            .ok_or("User not authenticated".into())
            .map(|s| s.clone())
    }

    fn user_id(&self) -> Result<String, Box<dyn std::error::Error>> {
        self.user_id
            .as_ref()
            .ok_or("User ID not available".into())
            .map(|s| s.clone())
    }
}

//
// TEST SUITE
//

/// Test 1: Presence Flow - Online/Offline Status
///
/// Verifies:
/// - User A connects and updates status to online
/// - User A queries User B's status
/// - User B updates status to online, then offline
/// - User A receives correct status for User B
#[tokio::test]
async fn test_01_presence_flow_online_offline() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 1: Presence Flow - Online/Offline Status");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();

    // Create two test users with unique usernames
    let user_a_id = Uuid::new_v4().to_string().replace("-", "");
    let user_b_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user_a = TestUser::new(&format!("presence_a_{}", &user_a_id[..8]));
    let mut user_b = TestUser::new(&format!("presence_b_{}", &user_b_id[..8]));

    // Register both users
    user_a.register(&env).await?;
    user_b.register(&env).await?;

    let mut presence_client = env.presence_client().await?;

    // Step 1: User A sets status to ONLINE
    println!("📤 User A setting status to ONLINE...");
    let update_request = Request::new(UpdateStatusRequest {
        access_token: user_a.token()?,
        status: UserStatus::Online as i32,
        custom_status_text: "Working on Guardyn".to_string(),
    });

    let update_response = presence_client
        .update_status(update_request)
        .await?
        .into_inner();

    match update_response.result {
        Some(proto::presence::update_status_response::Result::Success(success)) => {
            assert_eq!(success.status, UserStatus::Online as i32);
            println!("✅ User A is now ONLINE");
        }
        Some(proto::presence::update_status_response::Result::Error(error)) => {
            return Err(format!(
                "Update status failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from update_status".into()),
    }

    // Step 2: User B sets status to ONLINE
    println!("📤 User B setting status to ONLINE...");
    let update_request_b = Request::new(UpdateStatusRequest {
        access_token: user_b.token()?,
        status: UserStatus::Online as i32,
        custom_status_text: "Testing presence".to_string(),
    });

    let update_response_b = presence_client
        .update_status(update_request_b)
        .await?
        .into_inner();

    match update_response_b.result {
        Some(proto::presence::update_status_response::Result::Success(_)) => {
            println!("✅ User B is now ONLINE");
        }
        Some(proto::presence::update_status_response::Result::Error(error)) => {
            return Err(format!(
                "Update status failed for User B: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from update_status for User B".into()),
    }

    // Wait for presence update propagation
    sleep(Duration::from_millis(500)).await;

    // Step 3: User A queries User B's status
    println!("🔍 User A querying User B's status...");
    let get_request = Request::new(GetStatusRequest {
        access_token: user_a.token()?,
        user_id: user_b.user_id()?,
    });

    let get_response = presence_client.get_status(get_request).await?.into_inner();

    match get_response.result {
        Some(proto::presence::get_status_response::Result::Success(success)) => {
            assert_eq!(success.status, UserStatus::Online as i32);
            assert_eq!(success.custom_status_text, "Testing presence");
            println!(
                "✅ User B status retrieved: ONLINE with custom text '{}'",
                success.custom_status_text
            );
        }
        Some(proto::presence::get_status_response::Result::Error(error)) => {
            return Err(format!(
                "Get status failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from get_status".into()),
    }

    // Step 4: User B goes OFFLINE
    println!("📤 User B setting status to OFFLINE...");
    let offline_request = Request::new(UpdateStatusRequest {
        access_token: user_b.token()?,
        status: UserStatus::Offline as i32,
        custom_status_text: String::new(),
    });

    let offline_response = presence_client
        .update_status(offline_request)
        .await?
        .into_inner();

    match offline_response.result {
        Some(proto::presence::update_status_response::Result::Success(success)) => {
            assert_eq!(success.status, UserStatus::Offline as i32);
            println!("✅ User B is now OFFLINE");
        }
        Some(proto::presence::update_status_response::Result::Error(error)) => {
            return Err(format!(
                "Offline update failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from offline update".into()),
    }

    // Wait for presence update propagation
    sleep(Duration::from_millis(500)).await;

    // Step 5: User A verifies User B is offline
    println!("🔍 User A verifying User B is OFFLINE...");
    let verify_request = Request::new(GetStatusRequest {
        access_token: user_a.token()?,
        user_id: user_b.user_id()?,
    });

    let verify_response = presence_client
        .get_status(verify_request)
        .await?
        .into_inner();

    match verify_response.result {
        Some(proto::presence::get_status_response::Result::Success(success)) => {
            assert_eq!(success.status, UserStatus::Offline as i32);
            println!("✅ User B status verified: OFFLINE");
        }
        Some(proto::presence::get_status_response::Result::Error(error)) => {
            return Err(format!(
                "Verify status failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from verify status".into()),
    }

    println!("✅ Test 1 PASSED: Presence flow online/offline works correctly");
    Ok(())
}

/// Test 2: Typing Indicators E2E
///
/// Verifies:
/// - User A starts typing to User B
/// - User B can see User A is typing
/// - User A stops typing
/// - User B can see User A stopped typing
#[tokio::test]
async fn test_02_typing_indicator_e2e() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 2: Typing Indicators E2E");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();

    // Create two test users
    let user_a_id = Uuid::new_v4().to_string().replace("-", "");
    let user_b_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user_a = TestUser::new(&format!("typing_a_{}", &user_a_id[..8]));
    let mut user_b = TestUser::new(&format!("typing_b_{}", &user_b_id[..8]));

    // Register both users
    user_a.register(&env).await?;
    user_b.register(&env).await?;

    let mut presence_client = env.presence_client().await?;

    // Set both users online first
    let _ = presence_client
        .update_status(Request::new(UpdateStatusRequest {
            access_token: user_a.token()?,
            status: UserStatus::Online as i32,
            custom_status_text: String::new(),
        }))
        .await?;

    let _ = presence_client
        .update_status(Request::new(UpdateStatusRequest {
            access_token: user_b.token()?,
            status: UserStatus::Online as i32,
            custom_status_text: String::new(),
        }))
        .await?;

    // Step 1: User A starts typing to User B
    println!("⌨️ User A starting to type to User B...");
    let typing_start_request = Request::new(SetTypingRequest {
        access_token: user_a.token()?,
        conversation_user_id: user_b.user_id()?,
        is_typing: true,
    });

    let typing_response = presence_client
        .set_typing(typing_start_request)
        .await?
        .into_inner();

    match typing_response.result {
        Some(proto::presence::set_typing_response::Result::Success(success)) => {
            assert!(success.acknowledged);
            println!("✅ Typing indicator sent (is_typing: true)");
        }
        Some(proto::presence::set_typing_response::Result::Error(error)) => {
            return Err(format!(
                "Set typing failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from set_typing".into()),
    }

    // Wait for typing indicator propagation
    sleep(Duration::from_millis(300)).await;

    // Step 2: User B checks if User A is typing (via get_status)
    println!("🔍 User B checking if User A is typing...");
    let check_typing_request = Request::new(GetStatusRequest {
        access_token: user_b.token()?,
        user_id: user_a.user_id()?,
    });

    let check_response = presence_client
        .get_status(check_typing_request)
        .await?
        .into_inner();

    match check_response.result {
        Some(proto::presence::get_status_response::Result::Success(success)) => {
            assert!(success.is_typing, "User A should be typing");
            println!("✅ User A is_typing: {}", success.is_typing);
        }
        Some(proto::presence::get_status_response::Result::Error(error)) => {
            return Err(format!(
                "Get typing status failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from get_status for typing check".into()),
    }

    // Step 3: User A stops typing
    println!("⌨️ User A stopping typing...");
    let typing_stop_request = Request::new(SetTypingRequest {
        access_token: user_a.token()?,
        conversation_user_id: user_b.user_id()?,
        is_typing: false,
    });

    let stop_response = presence_client
        .set_typing(typing_stop_request)
        .await?
        .into_inner();

    match stop_response.result {
        Some(proto::presence::set_typing_response::Result::Success(success)) => {
            assert!(success.acknowledged);
            println!("✅ Typing indicator sent (is_typing: false)");
        }
        Some(proto::presence::set_typing_response::Result::Error(error)) => {
            return Err(format!(
                "Set typing stop failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from set_typing stop".into()),
    }

    // Wait for typing indicator propagation
    sleep(Duration::from_millis(300)).await;

    // Step 4: User B verifies User A is not typing anymore
    println!("🔍 User B verifying User A stopped typing...");
    let verify_typing_request = Request::new(GetStatusRequest {
        access_token: user_b.token()?,
        user_id: user_a.user_id()?,
    });

    let verify_response = presence_client
        .get_status(verify_typing_request)
        .await?
        .into_inner();

    match verify_response.result {
        Some(proto::presence::get_status_response::Result::Success(success)) => {
            assert!(!success.is_typing, "User A should NOT be typing");
            println!("✅ User A is_typing: {} (stopped)", success.is_typing);
        }
        Some(proto::presence::get_status_response::Result::Error(error)) => {
            return Err(format!(
                "Verify typing stopped failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from verify typing stopped".into()),
    }

    println!("✅ Test 2 PASSED: Typing indicators work correctly");
    Ok(())
}

/// Test 3: Last Seen Persistence
///
/// Verifies:
/// - User updates last_seen timestamp
/// - Last_seen is persisted and can be retrieved
/// - Multiple last_seen updates work correctly
#[tokio::test]
async fn test_03_presence_persistence() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 3: Last Seen Persistence");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();

    // Create test users
    let user_a_id = Uuid::new_v4().to_string().replace("-", "");
    let user_b_id = Uuid::new_v4().to_string().replace("-", "");
    let mut user_a = TestUser::new(&format!("lastseen_a_{}", &user_a_id[..8]));
    let mut user_b = TestUser::new(&format!("lastseen_b_{}", &user_b_id[..8]));

    // Register both users
    user_a.register(&env).await?;
    user_b.register(&env).await?;

    let mut presence_client = env.presence_client().await?;

    // Step 1: User A sets status to ONLINE (this also updates last_seen)
    println!("📤 User A setting status to ONLINE...");
    let online_request = Request::new(UpdateStatusRequest {
        access_token: user_a.token()?,
        status: UserStatus::Online as i32,
        custom_status_text: String::new(),
    });

    let _ = presence_client.update_status(online_request).await?;
    println!("✅ User A is ONLINE");

    // Wait a moment
    sleep(Duration::from_secs(1)).await;

    // Step 2: User A updates last_seen explicitly
    println!("📤 User A updating last_seen timestamp...");
    let update_last_seen_request = Request::new(UpdateLastSeenRequest {
        access_token: user_a.token()?,
    });

    let last_seen_response = presence_client
        .update_last_seen(update_last_seen_request)
        .await?
        .into_inner();

    let first_last_seen = match last_seen_response.result {
        Some(proto::presence::update_last_seen_response::Result::Success(success)) => {
            println!(
                "✅ Last seen updated: {} seconds",
                success.last_seen.as_ref().map(|t| t.seconds).unwrap_or(0)
            );
            success.last_seen.as_ref().map(|t| t.seconds).unwrap_or(0)
        }
        Some(proto::presence::update_last_seen_response::Result::Error(error)) => {
            return Err(format!(
                "Update last_seen failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from update_last_seen".into()),
    };

    // Step 3: User B queries User A's status and verifies last_seen is present
    println!("🔍 User B querying User A's status to check last_seen...");
    let get_request = Request::new(GetStatusRequest {
        access_token: user_b.token()?,
        user_id: user_a.user_id()?,
    });

    let get_response = presence_client.get_status(get_request).await?.into_inner();

    match get_response.result {
        Some(proto::presence::get_status_response::Result::Success(success)) => {
            assert!(success.last_seen.is_some(), "Last seen should be present");
            let retrieved_last_seen = success.last_seen.as_ref().map(|t| t.seconds).unwrap_or(0);
            println!("✅ User A last_seen retrieved: {} seconds", retrieved_last_seen);
            
            // Last seen should be at least as recent as our first update
            assert!(
                retrieved_last_seen >= first_last_seen,
                "Retrieved last_seen should be >= first update"
            );
        }
        Some(proto::presence::get_status_response::Result::Error(error)) => {
            return Err(format!(
                "Get status failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from get_status".into()),
    }

    // Step 4: User A updates last_seen again after some time
    sleep(Duration::from_secs(2)).await;
    println!("📤 User A updating last_seen again...");

    let second_update_request = Request::new(UpdateLastSeenRequest {
        access_token: user_a.token()?,
    });

    let second_response = presence_client
        .update_last_seen(second_update_request)
        .await?
        .into_inner();

    let second_last_seen = match second_response.result {
        Some(proto::presence::update_last_seen_response::Result::Success(success)) => {
            let ts = success.last_seen.as_ref().map(|t| t.seconds).unwrap_or(0);
            println!("✅ Second last_seen update: {} seconds", ts);
            ts
        }
        Some(proto::presence::update_last_seen_response::Result::Error(error)) => {
            return Err(format!(
                "Second update last_seen failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from second update_last_seen".into()),
    };

    // Verify second last_seen is more recent
    assert!(
        second_last_seen > first_last_seen,
        "Second last_seen should be more recent than first"
    );
    println!(
        "✅ Last seen correctly updated: {} -> {} (+{} seconds)",
        first_last_seen,
        second_last_seen,
        second_last_seen - first_last_seen
    );

    // Step 5: User A goes offline and verify last_seen is preserved
    println!("📤 User A going OFFLINE...");
    let offline_request = Request::new(UpdateStatusRequest {
        access_token: user_a.token()?,
        status: UserStatus::Offline as i32,
        custom_status_text: String::new(),
    });

    let _ = presence_client.update_status(offline_request).await?;

    // Wait for update propagation
    sleep(Duration::from_millis(500)).await;

    // Query final status
    println!("🔍 Verifying last_seen is preserved after going offline...");
    let final_request = Request::new(GetStatusRequest {
        access_token: user_b.token()?,
        user_id: user_a.user_id()?,
    });

    let final_response = presence_client.get_status(final_request).await?.into_inner();

    match final_response.result {
        Some(proto::presence::get_status_response::Result::Success(success)) => {
            assert_eq!(success.status, UserStatus::Offline as i32);
            assert!(success.last_seen.is_some(), "Last seen should persist after going offline");
            let final_last_seen = success.last_seen.as_ref().map(|t| t.seconds).unwrap_or(0);
            println!(
                "✅ User A is OFFLINE with preserved last_seen: {} seconds",
                final_last_seen
            );
            
            // Last seen should be >= our second update
            assert!(
                final_last_seen >= second_last_seen,
                "Final last_seen should be >= second update"
            );
        }
        Some(proto::presence::get_status_response::Result::Error(error)) => {
            return Err(format!(
                "Final get status failed: {:?} - {}",
                error.code(),
                error.message
            )
            .into());
        }
        None => return Err("No response from final get_status".into()),
    }

    println!("✅ Test 3 PASSED: Last seen persistence works correctly");
    Ok(())
}

/// Health check test to verify presence service is reachable
#[tokio::test]
async fn test_00_presence_service_health() -> Result<(), Box<dyn std::error::Error>> {
    println!("\n🧪 Test 0: Presence Service Health Check");
    println!("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    let env = TestEnv::new();

    // Check Auth Service
    match env.auth_client().await {
        Ok(_) => println!("✅ Auth Service is reachable at {}", env.auth_endpoint),
        Err(e) => return Err(format!("❌ Auth Service unreachable: {}", e).into()),
    }

    // Check Presence Service
    match env.presence_client().await {
        Ok(_) => println!("✅ Presence Service is reachable at {}", env.presence_endpoint),
        Err(e) => return Err(format!("❌ Presence Service unreachable: {}", e).into()),
    }

    println!("✅ Test 0 PASSED: All services reachable");
    Ok(())
}
