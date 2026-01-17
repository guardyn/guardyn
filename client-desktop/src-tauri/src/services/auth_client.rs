//! Authentication Service gRPC Client
//!
//! Handles user registration, login, logout, and key bundle management.

use crate::grpc::{GrpcClient, GrpcError};
use crate::proto::auth::{
    auth_service_client::AuthServiceClient, GetKeyBundleRequest, LoginRequest, LogoutRequest,
    RefreshTokenRequest, RegisterRequest, SearchUsersRequest, UploadMlsKeyPackageRequest,
    UploadPreKeysRequest,
};
use crate::proto::common::KeyBundle;
use std::sync::Arc;
use tonic::metadata::MetadataValue;
use tonic::transport::Channel;
use tonic::Request;
use tracing::{debug, info, warn};

/// Registration success response
#[derive(Debug, Clone)]
pub struct RegisterSuccess {
    pub user_id: String,
    pub device_id: String,
    pub access_token: String,
    pub access_token_expires_in: u32,
    pub refresh_token: String,
    pub refresh_token_expires_in: u32,
}

/// Login success response
#[derive(Debug, Clone)]
pub struct LoginSuccess {
    pub user_id: String,
    pub device_id: String,
    pub access_token: String,
    pub access_token_expires_in: u32,
    pub refresh_token: String,
    pub refresh_token_expires_in: u32,
    pub profile: Option<UserProfile>,
}

/// User profile
#[derive(Debug, Clone)]
pub struct UserProfile {
    pub user_id: String,
    pub username: String,
    pub email: String,
}

/// Token pair response
#[derive(Debug, Clone)]
pub struct TokenPair {
    pub access_token: String,
    pub access_token_expires_in: u32,
    pub refresh_token: String,
}

/// User search result
#[derive(Debug, Clone)]
pub struct UserSearchResult {
    pub user_id: String,
    pub username: String,
}

/// Authentication client for Guardyn backend
pub struct AuthClient {
    grpc: Arc<GrpcClient>,
}

impl AuthClient {
    /// Create a new auth client with the given gRPC connection manager
    pub fn new(grpc: Arc<GrpcClient>) -> Self {
        Self { grpc }
    }

    /// Create a gRPC client with authentication header
    async fn client(&self) -> Result<AuthServiceClient<Channel>, GrpcError> {
        let channel = self.grpc.get_channel().await?;
        Ok(AuthServiceClient::new(channel))
    }

    /// Add auth token to request
    fn with_auth<T>(&self, mut request: Request<T>) -> Result<Request<T>, GrpcError> {
        if let Some(token) = self.grpc.get_auth_token() {
            let value =
                MetadataValue::try_from(format!("Bearer {}", token)).map_err(|_| {
                    GrpcError::RequestFailed("Invalid auth token format".to_string())
                })?;
            request.metadata_mut().insert("authorization", value);
        }
        Ok(request)
    }

    /// Register a new user with key bundle
    pub async fn register(
        &self,
        username: String,
        password: String,
        email: Option<String>,
        device_name: String,
        device_type: String,
        key_bundle: KeyBundle,
    ) -> Result<RegisterSuccess, GrpcError> {
        info!("Registering user: {}", username);

        let request = RegisterRequest {
            username,
            password,
            email: email.unwrap_or_default(),
            device_name,
            device_type,
            key_bundle: Some(key_bundle),
        };

        let mut client = self.client().await?;
        let response = client
            .register(Request::new(request))
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::auth::register_response::Result::Success(success)) => {
                info!("Registration successful for user_id: {}", success.user_id);
                Ok(RegisterSuccess {
                    user_id: success.user_id,
                    device_id: success.device_id,
                    access_token: success.access_token,
                    access_token_expires_in: success.access_token_expires_in,
                    refresh_token: success.refresh_token,
                    refresh_token_expires_in: success.refresh_token_expires_in,
                })
            }
            Some(crate::proto::auth::register_response::Result::Error(error)) => {
                warn!("Registration failed: {:?}", error);
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Login with username and password
    pub async fn login(
        &self,
        username: String,
        password: String,
        device_id: Option<String>,
        device_name: String,
        device_type: String,
        key_bundle: Option<KeyBundle>,
    ) -> Result<LoginSuccess, GrpcError> {
        info!("Login attempt for user: {}", username);

        let request = LoginRequest {
            username,
            password,
            device_id: device_id.unwrap_or_default(),
            device_name,
            device_type,
            key_bundle,
        };

        let mut client = self.client().await?;
        let response = client
            .login(Request::new(request))
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::auth::login_response::Result::Success(success)) => {
                info!("Login successful for user_id: {}", success.user_id);

                // Store auth token
                self.grpc.set_auth_token(success.access_token.clone());

                Ok(LoginSuccess {
                    user_id: success.user_id,
                    device_id: success.device_id,
                    access_token: success.access_token,
                    access_token_expires_in: success.access_token_expires_in,
                    refresh_token: success.refresh_token.clone(),
                    refresh_token_expires_in: success.refresh_token_expires_in,
                    profile: success.profile.map(|p| UserProfile {
                        user_id: p.user_id,
                        username: p.username,
                        email: p.email,
                    }),
                })
            }
            Some(crate::proto::auth::login_response::Result::Error(error)) => {
                warn!("Login failed: {:?}", error);
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Logout (invalidate session)
    pub async fn logout(&self, all_devices: bool) -> Result<(), GrpcError> {
        info!("Logging out (all_devices: {})", all_devices);

        let token = self
            .grpc
            .get_auth_token()
            .ok_or(GrpcError::AuthRequired)?;

        let request = LogoutRequest {
            access_token: token,
            all_devices,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .logout(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        // Clear local auth token
        self.grpc.clear_auth_token();

        info!("Logout successful");
        Ok(())
    }

    /// Refresh access token
    pub async fn refresh_token(&self, refresh_token: String) -> Result<TokenPair, GrpcError> {
        debug!("Refreshing access token");

        let request = RefreshTokenRequest { refresh_token };

        let mut client = self.client().await?;
        let response = client
            .refresh_token(Request::new(request))
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::auth::refresh_token_response::Result::Success(success)) => {
                // Update stored token
                self.grpc.set_auth_token(success.access_token.clone());

                Ok(TokenPair {
                    access_token: success.access_token,
                    access_token_expires_in: success.access_token_expires_in,
                    refresh_token: success.refresh_token,
                })
            }
            Some(crate::proto::auth::refresh_token_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Get key bundle for a user (for E2EE session establishment)
    pub async fn get_key_bundle(&self, user_id: String) -> Result<KeyBundle, GrpcError> {
        debug!("Fetching key bundle for user: {}", user_id);

        let request = GetKeyBundleRequest {
            user_id,
            device_id: String::new(), // Request any available device
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .get_key_bundle(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::auth::get_key_bundle_response::Result::Success(success)) => {
                success
                    .key_bundle
                    .ok_or_else(|| GrpcError::RequestFailed("No key bundle found".to_string()))
            }
            Some(crate::proto::auth::get_key_bundle_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }

    /// Upload new one-time pre-keys (key rotation)
    pub async fn upload_pre_keys(&self, pre_keys: Vec<Vec<u8>>) -> Result<(), GrpcError> {
        debug!("Uploading {} pre-keys", pre_keys.len());

        let request = UploadPreKeysRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            one_time_pre_keys: pre_keys,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .upload_pre_keys(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        info!("Pre-keys uploaded successfully");
        Ok(())
    }

    /// Upload MLS key package for group chat
    pub async fn upload_mls_key_package(&self, key_package: Vec<u8>) -> Result<(), GrpcError> {
        debug!("Uploading MLS key package");

        let request = UploadMlsKeyPackageRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            key_package,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        client
            .upload_mls_key_package(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        info!("MLS key package uploaded successfully");
        Ok(())
    }

    /// Search for users by username
    pub async fn search_users(&self, query: String) -> Result<Vec<UserSearchResult>, GrpcError> {
        debug!("Searching users: {}", query);

        let request = SearchUsersRequest {
            access_token: self.grpc.get_auth_token().unwrap_or_default(),
            query,
            limit: 20,
        };

        let mut client = self.client().await?;
        let request = self.with_auth(Request::new(request))?;

        let response = client
            .search_users(request)
            .await
            .map_err(|e| GrpcError::RequestFailed(e.to_string()))?;

        let result = response.into_inner();

        match result.result {
            Some(crate::proto::auth::search_users_response::Result::Success(success)) => {
                Ok(success
                    .users
                    .into_iter()
                    .map(|u| UserSearchResult {
                        user_id: u.user_id,
                        username: u.username,
                    })
                    .collect())
            }
            Some(crate::proto::auth::search_users_response::Result::Error(error)) => {
                Err(GrpcError::RequestFailed(error.message))
            }
            None => Err(GrpcError::RequestFailed("Empty response".to_string())),
        }
    }
}
