//! gRPC client for Auth Service communication
//!
//! Provides methods to interact with the auth-service for fetching user profiles
//! to get display names for call participants.

use crate::generated::guardyn::auth::{
    auth_service_client::AuthServiceClient, GetUserProfileRequest,
};
use anyhow::{Context, Result};
use std::collections::HashMap;
use tonic::transport::Channel;
use tracing::{debug, info, warn};

/// User profile information fetched from auth service
#[derive(Debug, Clone, Default)]
pub struct UserProfileInfo {
    #[allow(dead_code)]
    pub user_id: String,
    #[allow(dead_code)]
    pub username: String,
    pub display_name: String,
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
        debug!("Connecting to auth-service at {}", auth_service_url);

        let client = AuthServiceClient::connect(auth_service_url.to_string())
            .await
            .context("Failed to connect to auth-service")?;

        info!("Successfully connected to auth-service");

        Ok(Self { client })
    }

    /// Fetch user profile by user ID to get display name
    ///
    /// # Arguments
    /// * `user_id` - The user ID to look up
    ///
    /// # Returns
    /// * `Ok(UserProfileInfo)` - The user profile if found
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
            Some(crate::generated::guardyn::auth::get_user_profile_response::Result::Success(
                profile,
            )) => {
                let display_name = if profile.display_name.is_empty() {
                    profile.username.clone()
                } else {
                    profile.display_name.clone()
                };

                debug!(
                    "Successfully fetched profile for {}: display_name={}",
                    user_id, display_name
                );

                Ok(UserProfileInfo {
                    user_id: profile.user_id,
                    username: profile.username,
                    display_name,
                })
            }
            Some(crate::generated::guardyn::auth::get_user_profile_response::Result::Error(
                err,
            )) => {
                debug!(
                    "Auth service returned error for user {}: {}",
                    user_id, err.message
                );
                Err(anyhow::anyhow!(
                    "Failed to fetch user profile: {}",
                    err.message
                ))
            }
            None => {
                debug!("Auth service returned empty response for user {}", user_id);
                Err(anyhow::anyhow!(
                    "Empty response from auth service GetUserProfile"
                ))
            }
        }
    }

    /// Fetch display name for a user, falling back to user_id if not found
    ///
    /// # Arguments
    /// * `user_id` - The user ID to look up
    ///
    /// # Returns
    /// * The display name if found, or the user_id as fallback
    pub async fn get_display_name(&mut self, user_id: &str) -> String {
        match self.get_user_profile(user_id).await {
            Ok(profile) => profile.display_name,
            Err(e) => {
                warn!("Failed to get display name for {}: {}", user_id, e);
                user_id.to_string()
            }
        }
    }

    /// Fetch display names for multiple user IDs
    ///
    /// Returns a HashMap of user_id -> display_name
    /// For users that can't be found, their user_id is used as display name
    #[allow(dead_code)]
    pub async fn get_display_names(&mut self, user_ids: &[String]) -> HashMap<String, String> {
        let mut display_names = HashMap::new();

        for user_id in user_ids {
            let display_name = self.get_display_name(user_id).await;
            display_names.insert(user_id.clone(), display_name);
        }

        display_names
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
    }

    #[test]
    fn test_user_profile_info_creation() {
        let profile = UserProfileInfo {
            user_id: "user-123".to_string(),
            username: "johndoe".to_string(),
            display_name: "John Doe".to_string(),
        };
        assert_eq!(profile.user_id, "user-123");
        assert_eq!(profile.username, "johndoe");
        assert_eq!(profile.display_name, "John Doe");
    }
}
