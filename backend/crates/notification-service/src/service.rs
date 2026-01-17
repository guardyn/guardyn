//! gRPC service implementation for Notification Service

use std::sync::Arc;

use tonic::{Request, Response, Status};

use crate::db::NotificationDb;
use crate::generated::guardyn::notifications::notification_service_server::NotificationService;
use crate::generated::guardyn::notifications::*;
use crate::handlers;
use crate::push::PushService;

/// Notification service implementation
pub struct NotificationServiceImpl {
    db: Arc<NotificationDb>,
    push_service: Arc<PushService>,
    jwt_secret: String,
}

impl NotificationServiceImpl {
    /// Create a new notification service
    pub fn new(
        db: Arc<NotificationDb>,
        push_service: Arc<PushService>,
        jwt_secret: String,
    ) -> Self {
        Self {
            db,
            push_service,
            jwt_secret,
        }
    }
}

#[tonic::async_trait]
impl NotificationService for NotificationServiceImpl {
    async fn register_device(
        &self,
        request: Request<RegisterDeviceRequest>,
    ) -> Result<Response<RegisterDeviceResponse>, Status> {
        let response = handlers::register_device(&self.db, request.into_inner(), &self.jwt_secret).await;
        Ok(Response::new(response))
    }

    async fn unregister_device(
        &self,
        request: Request<UnregisterDeviceRequest>,
    ) -> Result<Response<UnregisterDeviceResponse>, Status> {
        let response = handlers::unregister_device(&self.db, request.into_inner(), &self.jwt_secret).await;
        Ok(Response::new(response))
    }

    async fn update_push_token(
        &self,
        request: Request<UpdatePushTokenRequest>,
    ) -> Result<Response<UpdatePushTokenResponse>, Status> {
        let response = handlers::update_push_token(&self.db, request.into_inner(), &self.jwt_secret).await;
        Ok(Response::new(response))
    }

    async fn get_notification_settings(
        &self,
        request: Request<GetNotificationSettingsRequest>,
    ) -> Result<Response<GetNotificationSettingsResponse>, Status> {
        let response = handlers::get_notification_settings(&self.db, request.into_inner(), &self.jwt_secret).await;
        Ok(Response::new(response))
    }

    async fn update_notification_settings(
        &self,
        request: Request<UpdateNotificationSettingsRequest>,
    ) -> Result<Response<UpdateNotificationSettingsResponse>, Status> {
        let response = handlers::update_notification_settings(&self.db, request.into_inner(), &self.jwt_secret).await;
        Ok(Response::new(response))
    }

    async fn mute_conversation(
        &self,
        request: Request<MuteConversationRequest>,
    ) -> Result<Response<MuteConversationResponse>, Status> {
        let response = handlers::mute_conversation(&self.db, request.into_inner(), &self.jwt_secret).await;
        Ok(Response::new(response))
    }

    async fn send_test_notification(
        &self,
        request: Request<SendTestNotificationRequest>,
    ) -> Result<Response<SendTestNotificationResponse>, Status> {
        let response = handlers::send_test_notification(
            &self.db,
            &self.push_service,
            request.into_inner(),
            &self.jwt_secret,
        )
        .await;
        Ok(Response::new(response))
    }

    async fn health(
        &self,
        _request: Request<HealthRequest>,
    ) -> Result<Response<crate::generated::guardyn::common::HealthStatus>, Status> {
        Ok(Response::new(crate::generated::guardyn::common::HealthStatus {
            status: "healthy".to_string(),
            version: env!("CARGO_PKG_VERSION").to_string(),
        }))
    }
}
