/// gRPC client for Auth Service communication
///
/// Provides methods to interact with the auth-service, primarily for
/// fetching MLS key packages during group member addition and user profile lookups.

use crate::proto::auth::{
    auth_service_client::AuthServiceClient, GetMlsKeyPackageRequest, GetMlsKeyPackageResponse,
    GetUserProfileRequest, UserProfile,
};
use anyhow::{Context, Result};
use std::collections::HashMap;
use tonic::transport::Channel;
use tracing::{debug, error, info};

/// Complete user profile information fetched from auth service
#[derive(Debug, Clone, Default)]
pub struct UserProfileInfo {
    pub user_id: String,
    pub username: String,
    pub display_name: String,
    pub avatar_media_id: String,
    pub bio: String,
}

impl From<UserProfile> for UserProfileInfo {
    fn from(profile: UserProfile) -> Self {
        Self {
            user_id: profile.user_id,
            username: profile.username,
            display_name: profile.display_name,
            avatar_media_id: profile.avatar_media_id,
            bio: profile.bio,
        }
    }
}

/// Client wrapper for auth-service gRPC communication
pub struct AuthClient {
    client: AuthServiceClient<Channel>,
}

impl AuthClient {
    /// Create a new AuthClient connected to the specified URL
    ///
    /// # Arguments
    /// * `auth_service_url` - The URL of the auth service (e.g., "http://auth-service:50051")
    pub async fn new(auth_service_url: &str) -> Result<Self> {
        info!("Connecting to auth-service at {}", auth_service_url);

        let client = AuthServiceClient::connect(auth_service_url.to_string())
            .await
            .context("Failed to connect to auth-service")?;

        debug!("Successfully connected to auth-service");

        Ok(Self { client })
    }

    /// Fetch MLS key package for a specific user and device
    ///
    /// # Arguments
    /// * `user_id` - The target user ID
    /// * `device_id` - The target device ID (optional, will use latest if empty)
    ///
    /// # Returns
    /// * `Ok(Vec<u8>)` - The serialized MLS key package bytes
    /// * `Err(anyhow::Error)` - If the request fails or key package not found
    pub async fn fetch_mls_key_package(
        &mut self,
        user_id: &str,
        device_id: &str,
    ) -> Result<Vec<u8>> {
        debug!(
            "Fetching MLS key package for user_id={}, device_id={}",
            user_id, device_id
        );

        let request = tonic::Request::new(GetMlsKeyPackageRequest {
            user_id: user_id.to_string(),
            device_id: device_id.to_string(),
        });

        let response = self
            .client
            .get_mls_key_package(request)
            .await
            .context("gRPC call to GetMlsKeyPackage failed")?;

        let response_inner = response.into_inner();

        match response_inner.result {
            Some(crate::proto::auth::get_mls_key_package_response::Result::Success(success)) => {
                info!(
                    "Successfully fetched MLS key package for {}:{} (package_id: {})",
                    success.user_id, success.device_id, success.package_id
                );
                Ok(success.key_package)
            }
            Some(crate::proto::auth::get_mls_key_package_response::Result::Error(err)) => {
                error!(
                    "Auth service returned error: code={}, message={}",
                    err.code, err.message
                );
                Err(anyhow::anyhow!(
                    "Failed to fetch MLS key package: {}",
                    err.message
                ))
            }
            None => {
                error!("Auth service returned empty response");
                Err(anyhow::anyhow!(
                    "Empty response from auth service GetMlsKeyPackage"
                ))
            }
        }
    }

    /// Fetch MLS key package and return full response for inspection
    ///
    /// Useful for debugging or when you need additional metadata
    pub async fn fetch_mls_key_package_full(
        &mut self,
        user_id: &str,
        device_id: &str,
    ) -> Result<GetMlsKeyPackageResponse> {
        let request = tonic::Request::new(GetMlsKeyPackageRequest {
            user_id: user_id.to_string(),
            device_id: device_id.to_string(),
        });

        let response = self
            .client
            .get_mls_key_package(request)
            .await
            .context("gRPC call to GetMlsKeyPackage failed")?;

        Ok(response.into_inner())
    }

    /// Fetch user profile by user ID to get username
    ///
    /// # Arguments
    /// * `user_id` - The user ID to look up
    ///
    /// # Returns
    /// * `Ok(String)` - The username if found
    /// * `Err(anyhow::Error)` - If the request fails or user not found
    pub async fn get_username(&mut self, user_id: &str) -> Result<String> {
        debug!("Fetching username for user_id={}", user_id);

        let request = tonic::Request::new(GetUserProfileRequest {
            user_id: user_id.to_string(),
        });

        let response = self
            .client
            .get_user_profile(request)
            .await
            .context("gRPC call to GetUserProfile failed")?;

        let response_inner = response.into_inner();

        match response_inner.result {
            Some(crate::proto::auth::get_user_profile_response::Result::Success(success)) => {
                info!("Successfully fetched username for {}: {}", user_id, success.username);
                Ok(success.username)
            }
            Some(crate::proto::auth::get_user_profile_response::Result::Error(err)) => {
                debug!("Auth service returned error for user {}: {}", user_id, err.message);
                Err(anyhow::anyhow!("Failed to fetch user profile: {}", err.message))
            }
            None => {
                debug!("Auth service returned empty response for user {}", user_id);
                Err(anyhow::anyhow!("Empty response from auth service GetUserProfile"))
            }
        }
    }

    /// Fetch full user profile by user ID
    ///
    /// # Arguments
    /// * `user_id` - The user ID to look up
    ///
    /// # Returns
    /// * `Ok(UserProfileInfo)` - The complete user profile if found
    /// * `Err(anyhow::Error)` - If the request fails or user not found
    pub async fn get_user_profile(&mut self, user_id: &str) -> Result<UserProfileInfo> {
        debug!("Fetching user profile for user_id={}", user_id);

        let request = tonic::Request::new(GetUserProfileRequest {
            user_id: user_id.to_string(),
        });

        let response = self
            .client
            .get_user_profile(request)
            .await
            .context("gRPC call to GetUserProfile failed")?;

        let response_inner = response.into_inner();

        match response_inner.result {
            Some(crate::proto::auth::get_user_profile_response::Result::Success(profile)) => {
                info!(
                    "Successfully fetched profile for {}: username={}, display_name={}",
                    user_id, profile.username, profile.display_name
                );
                Ok(UserProfileInfo::from(profile))
            }
            Some(crate::proto::auth::get_user_profile_response::Result::Error(err)) => {
                debug!("Auth service returned error for user {}: {}", user_id, err.message);
                Err(anyhow::anyhow!("Failed to fetch user profile: {}", err.message))
            }
            None => {
                debug!("Auth service returned empty response for user {}", user_id);
                Err(anyhow::anyhow!("Empty response from auth service GetUserProfile"))
            }
        }
    }

    /// Fetch usernames for multiple user IDs
    ///
    /// Returns a HashMap of user_id -> username
    /// For users that can't be found, their entry will not be in the map
    pub async fn get_usernames(
        &mut self,
        user_ids: &[String],
    ) -> std::collections::HashMap<String, String> {
        let mut usernames = std::collections::HashMap::new();

        for user_id in user_ids {
            if let Ok(username) = self.get_username(user_id).await {
                usernames.insert(user_id.clone(), username);
            }
        }

        usernames
    }

    /// Fetch full user profiles for multiple user IDs
    ///
    /// Returns a HashMap of user_id -> UserProfileInfo
    /// For users that can't be found, their entry will not be in the map
    pub async fn get_user_profiles(
        &mut self,
        user_ids: &[String],
    ) -> HashMap<String, UserProfileInfo> {
        let mut profiles = HashMap::new();

        for user_id in user_ids {
            if let Ok(profile) = self.get_user_profile(user_id).await {
                profiles.insert(user_id.clone(), profile);
            }
        }

        debug!("Fetched {} user profiles out of {} requested", profiles.len(), user_ids.len());
        profiles
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_profile_info_default() {
        let profile = UserProfileInfo::default();
        assert!(profile.user_id.is_empty());
        assert!(profile.username.is_empty());
        assert!(profile.display_name.is_empty());
        assert!(profile.avatar_media_id.is_empty());
        assert!(profile.bio.is_empty());
    }

    #[test]
    fn test_user_profile_info_clone() {
        let profile = UserProfileInfo {
            user_id: "user-123".to_string(),
            username: "testuser".to_string(),
            display_name: "Test User".to_string(),
            avatar_media_id: "avatar-456".to_string(),
            bio: "Hello, world!".to_string(),
        };
        
        let cloned = profile.clone();
        assert_eq!(cloned.user_id, "user-123");
        assert_eq!(cloned.username, "testuser");
        assert_eq!(cloned.display_name, "Test User");
        assert_eq!(cloned.avatar_media_id, "avatar-456");
        assert_eq!(cloned.bio, "Hello, world!");
    }

    #[tokio::test]
    #[ignore] // Requires running auth-service
    async fn test_auth_client_connection() {
        let client = AuthClient::new("http://localhost:50051").await;
        assert!(client.is_ok(), "Should connect to auth-service");
    }

    #[tokio::test]
    #[ignore] // Requires running auth-service with test data
    async fn test_fetch_mls_key_package() {
        let mut client = AuthClient::new("http://localhost:50051")
            .await
            .expect("Failed to connect");

        let result = client
            .fetch_mls_key_package("test-user-id", "test-device-id")
            .await;

        // This will fail if no key package exists, which is expected in tests
        // In real usage, key packages should be uploaded first
        println!("Result: {:?}", result);
    }

    #[tokio::test]
    #[ignore] // Requires running auth-service with test data
    async fn test_get_user_profile() {
        let mut client = AuthClient::new("http://localhost:50051")
            .await
            .expect("Failed to connect");

        let result = client.get_user_profile("test-user-id").await;
        
        // This will fail if user doesn't exist
        println!("Result: {:?}", result);
    }
}
