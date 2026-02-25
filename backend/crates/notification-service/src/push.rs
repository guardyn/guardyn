//! Push notification delivery service
//!
//! Handles sending push notifications via FCM, APNs, and WebPush.

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use tracing::{debug, error, info, warn};
use web_push::{
    ContentEncoding, IsahcWebPushClient, SubscriptionInfo, VapidSignatureBuilder,
    WebPushClient as _, WebPushMessageBuilder,
};

use crate::ApnsConfig;

/// Push service for delivering notifications
pub struct PushService {
    fcm_server_key: Option<String>,
    apns_config: Option<ApnsConfig>,
    webpush_config: Option<WebPushConfig>,
    http_client: reqwest::Client,
    webpush_client: IsahcWebPushClient,
}

/// WebPush VAPID configuration
#[derive(Debug, Clone)]
pub struct WebPushConfig {
    /// VAPID private key (base64url encoded)
    pub vapid_private_key: String,
    /// VAPID public key (base64url encoded)  
    pub vapid_public_key: String,
    /// Contact email for VAPID
    pub contact_email: String,
}

/// FCM message format
#[derive(Debug, Serialize)]
struct FcmMessage {
    to: String,
    notification: FcmNotification,
    data: serde_json::Value,
    priority: String,
    time_to_live: i32,
}

#[derive(Debug, Serialize)]
struct FcmNotification {
    title: String,
    body: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    image: Option<String>,
    sound: String,
}

/// FCM response
#[derive(Debug, Deserialize)]
#[allow(dead_code)]
struct FcmResponse {
    success: i32,
    failure: i32,
    results: Vec<FcmResult>,
}

#[derive(Debug, Deserialize)]
#[allow(dead_code)]
struct FcmResult {
    message_id: Option<String>,
    error: Option<String>,
}

/// Push notification payload
#[derive(Debug, Clone)]
pub struct PushPayload {
    pub notification_id: String,
    pub title: String,
    pub body: String,
    pub image_url: Option<String>,
    pub conversation_id: String,
    pub is_group: bool,
    pub message_id: String,
    pub notification_type: String,
    pub priority: PushPriority,
    pub ttl_seconds: i32,
}

#[derive(Debug, Clone, Copy)]
#[allow(dead_code)]
pub enum PushPriority {
    Normal,
    High,
}

/// Device info for push delivery
#[derive(Debug, Clone)]
pub struct PushDevice {
    pub push_token: String,
    pub platform: PushPlatform,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum PushPlatform {
    Fcm,
    Apns,
    ApnsSandbox,
    WebPush,
}

/// WebPush subscription format (from browser Push API)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WebPushSubscription {
    pub endpoint: String,
    pub keys: WebPushKeys,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WebPushKeys {
    /// P-256 ECDH public key (base64url encoded)
    pub p256dh: String,
    /// Authentication secret (base64url encoded)
    pub auth: String,
}

impl PushService {
    /// Create a new push service
    pub fn new(
        fcm_server_key: Option<String>,
        apns_config: Option<ApnsConfig>,
        webpush_config: Option<WebPushConfig>,
    ) -> Self {
        Self {
            fcm_server_key,
            apns_config,
            webpush_config,
            http_client: reqwest::Client::new(),
            webpush_client: IsahcWebPushClient::new().expect("Failed to create WebPush client"),
        }
    }

    /// Send push notification to a device
    pub async fn send(&self, device: &PushDevice, payload: &PushPayload) -> Result<bool> {
        match device.platform {
            PushPlatform::Fcm => self.send_fcm(device, payload).await,
            PushPlatform::Apns | PushPlatform::ApnsSandbox => self.send_apns(device, payload).await,
            PushPlatform::WebPush => self.send_webpush(device, payload).await,
        }
    }

    /// Send notification via WebPush (NOTIF-001)
    async fn send_webpush(&self, device: &PushDevice, payload: &PushPayload) -> Result<bool> {
        let config = match &self.webpush_config {
            Some(cfg) => cfg,
            None => {
                warn!("WebPush VAPID configuration not provided");
                return Ok(false);
            }
        };

        // Parse the push token as subscription info
        // Expected format: JSON with endpoint, p256dh, and auth keys
        let subscription: WebPushSubscription = match serde_json::from_str(&device.push_token) {
            Ok(sub) => sub,
            Err(e) => {
                error!("Invalid WebPush subscription format: {}", e);
                return Ok(false);
            }
        };

        // Build subscription info for web-push crate
        let subscription_info = SubscriptionInfo::new(
            subscription.endpoint,
            subscription.keys.p256dh,
            subscription.keys.auth,
        );

        // Create notification payload as JSON
        let notification_json = serde_json::json!({
            "notification_id": payload.notification_id,
            "title": payload.title,
            "body": payload.body,
            "image": payload.image_url,
            "conversation_id": payload.conversation_id,
            "is_group": payload.is_group,
            "message_id": payload.message_id,
            "type": payload.notification_type,
        });
        let content = notification_json.to_string();

        // Build VAPID signature
        let mut sig_builder =
            VapidSignatureBuilder::from_base64(&config.vapid_private_key, &subscription_info)
                .context("Failed to build VAPID signature")?;

        sig_builder.add_claim("sub", format!("mailto:{}", config.contact_email));
        let vapid_signature = sig_builder
            .build()
            .context("Failed to create VAPID signature")?;

        // Build the WebPush message
        let mut builder = WebPushMessageBuilder::new(&subscription_info);
        builder.set_payload(ContentEncoding::Aes128Gcm, content.as_bytes());
        builder.set_vapid_signature(vapid_signature);
        builder.set_ttl(payload.ttl_seconds as u32);

        let message = builder.build().context("Failed to build WebPush message")?;

        // Send the notification
        match self.webpush_client.send(message).await {
            Ok(_response) => {
                info!(
                    "WebPush notification sent successfully: notification_id={}",
                    payload.notification_id
                );
                Ok(true)
            }
            Err(e) => {
                let error_str = format!("{:?}", e);
                error!("Failed to send WebPush notification: {}", error_str);
                // Check if subscription expired
                if error_str.contains("410") || error_str.contains("expired") {
                    warn!("WebPush subscription expired for device");
                }
                Ok(false)
            }
        }
    }

    /// Send notification via FCM
    async fn send_fcm(&self, device: &PushDevice, payload: &PushPayload) -> Result<bool> {
        let server_key = match &self.fcm_server_key {
            Some(key) => key,
            None => {
                warn!("FCM server key not configured");
                return Ok(false);
            }
        };

        let fcm_message = FcmMessage {
            to: device.push_token.clone(),
            notification: FcmNotification {
                title: payload.title.clone(),
                body: payload.body.clone(),
                image: payload.image_url.clone(),
                sound: "default".to_string(),
            },
            data: serde_json::json!({
                "notification_id": payload.notification_id,
                "conversation_id": payload.conversation_id,
                "is_group": payload.is_group,
                "message_id": payload.message_id,
                "type": payload.notification_type,
            }),
            priority: match payload.priority {
                PushPriority::High => "high".to_string(),
                PushPriority::Normal => "normal".to_string(),
            },
            time_to_live: payload.ttl_seconds,
        };

        let response = self
            .http_client
            .post("https://fcm.googleapis.com/fcm/send")
            .header("Authorization", format!("key={}", server_key))
            .header("Content-Type", "application/json")
            .json(&fcm_message)
            .send()
            .await
            .context("Failed to send FCM request")?;

        if !response.status().is_success() {
            let status = response.status();
            let body = response.text().await.unwrap_or_default();
            error!("FCM request failed: {} - {}", status, body);
            return Ok(false);
        }

        let fcm_response: FcmResponse = response
            .json()
            .await
            .context("Failed to parse FCM response")?;

        if fcm_response.success > 0 {
            debug!(
                "FCM notification sent successfully: {:?}",
                fcm_response.results
            );
            Ok(true)
        } else {
            warn!("FCM notification failed: {:?}", fcm_response.results);
            Ok(false)
        }
    }

    /// Send notification via APNs
    async fn send_apns(&self, device: &PushDevice, payload: &PushPayload) -> Result<bool> {
        let apns_config = match &self.apns_config {
            Some(config) => config,
            None => {
                warn!("APNs not configured");
                return Ok(false);
            }
        };

        // Build APNs URL
        let host = if apns_config.production {
            "api.push.apple.com"
        } else {
            "api.sandbox.push.apple.com"
        };
        let url = format!("https://{}:443/3/device/{}", host, device.push_token);

        // Build APNs payload
        let apns_payload = serde_json::json!({
            "aps": {
                "alert": {
                    "title": payload.title,
                    "body": payload.body,
                },
                "sound": "default",
                "badge": 1,
                "mutable-content": 1,
            },
            "notification_id": payload.notification_id,
            "conversation_id": payload.conversation_id,
            "is_group": payload.is_group,
            "message_id": payload.message_id,
            "type": payload.notification_type,
        });

        // Generate JWT for APNs authentication
        let jwt = self.generate_apns_jwt(apns_config)?;

        let response = self
            .http_client
            .post(&url)
            .header("authorization", format!("bearer {}", jwt))
            .header("apns-topic", &apns_config.bundle_id)
            .header("apns-push-type", "alert")
            .header(
                "apns-priority",
                if matches!(payload.priority, PushPriority::High) {
                    "10"
                } else {
                    "5"
                },
            )
            .header(
                "apns-expiration",
                (chrono::Utc::now().timestamp() + payload.ttl_seconds as i64).to_string(),
            )
            .json(&apns_payload)
            .send()
            .await
            .context("Failed to send APNs request")?;

        if response.status().is_success() {
            info!("APNs notification sent successfully");
            Ok(true)
        } else {
            let status = response.status();
            let body = response.text().await.unwrap_or_default();
            error!("APNs request failed: {} - {}", status, body);
            Ok(false)
        }
    }

    /// Generate JWT for APNs authentication
    fn generate_apns_jwt(&self, config: &ApnsConfig) -> Result<String> {
        use jsonwebtoken::{encode, Algorithm, EncodingKey, Header};

        #[derive(Serialize)]
        struct Claims {
            iss: String,
            iat: i64,
        }

        let mut header = Header::new(Algorithm::ES256);
        header.kid = Some(config.key_id.clone());

        let claims = Claims {
            iss: config.team_id.clone(),
            iat: chrono::Utc::now().timestamp(),
        };

        let key = EncodingKey::from_ec_pem(config.private_key.as_bytes())
            .context("Invalid APNs private key")?;

        encode(&header, &claims, &key).context("Failed to generate APNs JWT")
    }

    /// Send push notifications to multiple devices
    pub async fn send_to_devices(
        &self,
        devices: &[PushDevice],
        payload: &PushPayload,
    ) -> Result<i32> {
        let mut success_count = 0;

        for device in devices {
            match self.send(device, payload).await {
                Ok(true) => success_count += 1,
                Ok(false) => {
                    debug!("Push notification not delivered to {:?}", device.platform);
                }
                Err(e) => {
                    warn!("Failed to send push notification: {}", e);
                }
            }
        }

        Ok(success_count)
    }
}
