/// gRPC client for Auth Service communication
///
/// Provides methods to interact with the auth-service, primarily for
/// fetching MLS key packages during group member addition and user profile lookups.

use crate::proto::auth::{
    auth_service_client::AuthServiceClient, GetMlsKeyPackageRequest, GetMlsKeyPackageResponse,
    GetUserProfileRequest,
};
use anyhow::{Context, Result};
use tonic::transport::Channel;
use tracing::{debug, error, info};

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
}

#[cfg(test)]
mod tests {
    use super::*;

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
}
