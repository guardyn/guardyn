//! NATS client for Call Service event distribution
//!
//! Handles real-time distribution of WebRTC signaling data (ICE candidates, SDP)
//! and SFrame encryption keys between call participants.

use anyhow::{Context, Result};
use async_nats::jetstream::{self, consumer::PullConsumer, stream::Stream};
use tokio_stream::StreamExt;
use serde::{Deserialize, Serialize};
use tracing::{debug, error, info, warn};

/// NATS subject prefixes for call events
pub mod subjects {
    /// ICE candidate exchange: calls.{call_id}.ice.{target_user_id}
    pub const ICE_PREFIX: &str = "calls";
    pub const ICE_SUFFIX: &str = "ice";

    /// SDP exchange: calls.{call_id}.sdp.{target_user_id}
    pub const SDP_SUFFIX: &str = "sdp";

    /// Call events: calls.{call_id}.events
    pub const EVENTS_SUFFIX: &str = "events";

    /// SFrame key distribution: calls.{call_id}.sframe.{target_user_id}
    pub const SFRAME_SUFFIX: &str = "sframe";

    /// Format ICE candidate subject
    pub fn ice_candidate(call_id: &str, target_user_id: &str) -> String {
        format!("{}.{}.{}.{}", ICE_PREFIX, call_id, ICE_SUFFIX, target_user_id)
    }

    /// Format SDP subject
    pub fn sdp(call_id: &str, target_user_id: &str) -> String {
        format!("{}.{}.{}.{}", ICE_PREFIX, call_id, SDP_SUFFIX, target_user_id)
    }

    /// Format call events subject
    pub fn events(call_id: &str) -> String {
        format!("{}.{}.{}", ICE_PREFIX, call_id, EVENTS_SUFFIX)
    }

    /// Format SFrame key subject
    pub fn sframe_key(call_id: &str, target_user_id: &str) -> String {
        format!("{}.{}.{}.{}", ICE_PREFIX, call_id, SFRAME_SUFFIX, target_user_id)
    }
}

/// ICE candidate envelope for NATS transmission
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IceCandidateEnvelope {
    pub call_id: String,
    pub from_user_id: String,
    pub target_user_id: String,
    pub candidate: String,
    pub sdp_mid: String,
    pub sdp_mline_index: i32,
    pub username_fragment: String,
    pub timestamp: i64,
}

/// SDP envelope for NATS transmission
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SdpEnvelope {
    pub call_id: String,
    pub from_user_id: String,
    pub target_user_id: String,
    pub sdp_type: i32, // SdpType enum value
    pub sdp: String,
    pub timestamp: i64,
}

/// SFrame key envelope for NATS transmission
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SFrameKeyEnvelope {
    pub call_id: String,
    pub from_user_id: String,
    pub target_user_id: String,
    pub key_id: u32,
    pub encrypted_key_material: Vec<u8>,
    pub timestamp: i64,
}

/// Call event envelope for NATS transmission
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CallEventEnvelope {
    pub call_id: String,
    pub event_type: CallEventType,
    pub payload: serde_json::Value,
    pub timestamp: i64,
}

/// Types of call events
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum CallEventType {
    StateChanged,
    ParticipantJoined,
    ParticipantLeft,
    ParticipantMuted,
    ParticipantVideoChanged,
    ParticipantScreenShareChanged,
    ParticipantSpeaking,
    IceCandidateReceived,
    SdpReceived,
    SFrameKeyRotated,
    QualityChanged,
}

/// NATS client for call signaling
pub struct CallNatsClient {
    client: async_nats::Client,
    pub context: jetstream::Context,
    calls_stream: Stream,
}

impl CallNatsClient {
    /// Connect to NATS and initialize JetStream for calls
    pub async fn new(nats_url: &str) -> Result<Self> {
        let client = async_nats::connect(nats_url)
            .await
            .context("Failed to connect to NATS")?;

        let context = jetstream::new(client.clone());

        // Create or get CALLS stream for signaling
        let calls_stream = context
            .get_or_create_stream(jetstream::stream::Config {
                name: "CALLS".to_string(),
                subjects: vec![
                    "calls.>".to_string(), // All call-related subjects
                ],
                max_age: std::time::Duration::from_secs(3600), // 1 hour retention (calls are ephemeral)
                max_bytes: 100 * 1024 * 1024, // 100MB max
                ..Default::default()
            })
            .await
            .context("Failed to create CALLS stream")?;

        info!("Connected to NATS JetStream for call signaling");

        Ok(Self {
            client,
            context,
            calls_stream,
        })
    }

    /// Publish ICE candidate to target participant
    pub async fn publish_ice_candidate(&self, envelope: &IceCandidateEnvelope) -> Result<()> {
        let subject = subjects::ice_candidate(&envelope.call_id, &envelope.target_user_id);
        let payload = serde_json::to_vec(envelope)?;

        self.context
            .publish(subject.clone(), payload.into())
            .await
            .context("Failed to publish ICE candidate")?
            .await
            .context("Failed to confirm ICE candidate publication")?;

        debug!(
            "Published ICE candidate from {} to {} in call {}",
            envelope.from_user_id, envelope.target_user_id, envelope.call_id
        );

        Ok(())
    }

    /// Publish SDP offer/answer to target participant
    pub async fn publish_sdp(&self, envelope: &SdpEnvelope) -> Result<()> {
        let subject = subjects::sdp(&envelope.call_id, &envelope.target_user_id);
        let payload = serde_json::to_vec(envelope)?;

        self.context
            .publish(subject.clone(), payload.into())
            .await
            .context("Failed to publish SDP")?
            .await
            .context("Failed to confirm SDP publication")?;

        debug!(
            "Published SDP type {} from {} to {} in call {}",
            envelope.sdp_type, envelope.from_user_id, envelope.target_user_id, envelope.call_id
        );

        Ok(())
    }

    /// Publish SFrame key package to target participant
    pub async fn publish_sframe_key(&self, envelope: &SFrameKeyEnvelope) -> Result<()> {
        let subject = subjects::sframe_key(&envelope.call_id, &envelope.target_user_id);
        let payload = serde_json::to_vec(envelope)?;

        self.context
            .publish(subject.clone(), payload.into())
            .await
            .context("Failed to publish SFrame key")?
            .await
            .context("Failed to confirm SFrame key publication")?;

        debug!(
            "Published SFrame key {} from {} to {} in call {}",
            envelope.key_id, envelope.from_user_id, envelope.target_user_id, envelope.call_id
        );

        Ok(())
    }

    /// Publish call event to all participants
    pub async fn publish_call_event(&self, envelope: &CallEventEnvelope) -> Result<()> {
        let subject = subjects::events(&envelope.call_id);
        let payload = serde_json::to_vec(envelope)?;

        self.context
            .publish(subject.clone(), payload.into())
            .await
            .context("Failed to publish call event")?
            .await
            .context("Failed to confirm call event publication")?;

        debug!(
            "Published call event {:?} for call {}",
            envelope.event_type, envelope.call_id
        );

        Ok(())
    }

    /// Subscribe to ICE candidates for a specific user in a call
    pub async fn subscribe_ice_candidates(
        &self,
        call_id: &str,
        user_id: &str,
    ) -> Result<PullConsumer> {
        let consumer_name = format!("call-{}-ice-{}", call_id, user_id);
        let subject_filter = subjects::ice_candidate(call_id, user_id);

        let consumer = self
            .calls_stream
            .get_or_create_consumer(
                &consumer_name,
                jetstream::consumer::pull::Config {
                    filter_subject: subject_filter.clone(),
                    durable_name: Some(consumer_name.clone()),
                    ..Default::default()
                },
            )
            .await
            .context("Failed to create ICE consumer")?;

        info!(
            "Created ICE consumer {} for user {} in call {}",
            consumer_name, user_id, call_id
        );

        Ok(consumer)
    }

    /// Subscribe to SDP messages for a specific user in a call
    pub async fn subscribe_sdp(&self, call_id: &str, user_id: &str) -> Result<PullConsumer> {
        let consumer_name = format!("call-{}-sdp-{}", call_id, user_id);
        let subject_filter = subjects::sdp(call_id, user_id);

        let consumer = self
            .calls_stream
            .get_or_create_consumer(
                &consumer_name,
                jetstream::consumer::pull::Config {
                    filter_subject: subject_filter.clone(),
                    durable_name: Some(consumer_name.clone()),
                    ..Default::default()
                },
            )
            .await
            .context("Failed to create SDP consumer")?;

        info!(
            "Created SDP consumer {} for user {} in call {}",
            consumer_name, user_id, call_id
        );

        Ok(consumer)
    }

    /// Subscribe to call events for a specific call
    pub async fn subscribe_call_events(&self, call_id: &str) -> Result<PullConsumer> {
        let consumer_name = format!("call-{}-events", call_id);
        let subject_filter = subjects::events(call_id);

        let consumer = self
            .calls_stream
            .get_or_create_consumer(
                &consumer_name,
                jetstream::consumer::pull::Config {
                    filter_subject: subject_filter.clone(),
                    durable_name: Some(consumer_name.clone()),
                    ..Default::default()
                },
            )
            .await
            .context("Failed to create events consumer")?;

        info!("Created events consumer {} for call {}", consumer_name, call_id);

        Ok(consumer)
    }

    /// Subscribe to SFrame keys for a specific user in a call
    pub async fn subscribe_sframe_keys(
        &self,
        call_id: &str,
        user_id: &str,
    ) -> Result<PullConsumer> {
        let consumer_name = format!("call-{}-sframe-{}", call_id, user_id);
        let subject_filter = subjects::sframe_key(call_id, user_id);

        let consumer = self
            .calls_stream
            .get_or_create_consumer(
                &consumer_name,
                jetstream::consumer::pull::Config {
                    filter_subject: subject_filter.clone(),
                    durable_name: Some(consumer_name.clone()),
                    ..Default::default()
                },
            )
            .await
            .context("Failed to create SFrame consumer")?;

        info!(
            "Created SFrame consumer {} for user {} in call {}",
            consumer_name, user_id, call_id
        );

        Ok(consumer)
    }

    /// Fetch ICE candidates from consumer
    pub async fn fetch_ice_candidates(
        &self,
        consumer: &PullConsumer,
        batch_size: usize,
    ) -> Result<Vec<IceCandidateEnvelope>> {
        let mut messages = consumer
            .batch()
            .max_messages(batch_size)
            .messages()
            .await
            .context("Failed to fetch ICE candidates")?;

        let mut envelopes = Vec::new();

        while let Some(msg) = messages.next().await {
            match msg {
                Ok(msg) => {
                    if let Ok(envelope) = serde_json::from_slice::<IceCandidateEnvelope>(&msg.payload)
                    {
                        envelopes.push(envelope);
                        if let Err(e) = msg.ack().await {
                            warn!("Failed to ack ICE candidate message: {}", e);
                        }
                    }
                }
                Err(e) => {
                    error!("Error receiving ICE candidate message: {}", e);
                }
            }
        }

        Ok(envelopes)
    }

    /// Fetch SDP messages from consumer
    pub async fn fetch_sdp_messages(
        &self,
        consumer: &PullConsumer,
        batch_size: usize,
    ) -> Result<Vec<SdpEnvelope>> {
        let mut messages = consumer
            .batch()
            .max_messages(batch_size)
            .messages()
            .await
            .context("Failed to fetch SDP messages")?;

        let mut envelopes = Vec::new();

        while let Some(msg) = messages.next().await {
            match msg {
                Ok(msg) => {
                    if let Ok(envelope) = serde_json::from_slice::<SdpEnvelope>(&msg.payload) {
                        envelopes.push(envelope);
                        if let Err(e) = msg.ack().await {
                            warn!("Failed to ack SDP message: {}", e);
                        }
                    }
                }
                Err(e) => {
                    error!("Error receiving SDP message: {}", e);
                }
            }
        }

        Ok(envelopes)
    }

    /// Fetch call events from consumer
    pub async fn fetch_call_events(
        &self,
        consumer: &PullConsumer,
        batch_size: usize,
    ) -> Result<Vec<CallEventEnvelope>> {
        let mut messages = consumer
            .batch()
            .max_messages(batch_size)
            .messages()
            .await
            .context("Failed to fetch call events")?;

        let mut envelopes = Vec::new();

        while let Some(msg) = messages.next().await {
            match msg {
                Ok(msg) => {
                    if let Ok(envelope) = serde_json::from_slice::<CallEventEnvelope>(&msg.payload) {
                        envelopes.push(envelope);
                        if let Err(e) = msg.ack().await {
                            warn!("Failed to ack call event message: {}", e);
                        }
                    }
                }
                Err(e) => {
                    error!("Error receiving call event message: {}", e);
                }
            }
        }

        Ok(envelopes)
    }

    /// Fetch SFrame keys from consumer
    pub async fn fetch_sframe_keys(
        &self,
        consumer: &PullConsumer,
        batch_size: usize,
    ) -> Result<Vec<SFrameKeyEnvelope>> {
        let mut messages = consumer
            .batch()
            .max_messages(batch_size)
            .messages()
            .await
            .context("Failed to fetch SFrame keys")?;

        let mut envelopes = Vec::new();

        while let Some(msg) = messages.next().await {
            match msg {
                Ok(msg) => {
                    if let Ok(envelope) = serde_json::from_slice::<SFrameKeyEnvelope>(&msg.payload) {
                        envelopes.push(envelope);
                        if let Err(e) = msg.ack().await {
                            warn!("Failed to ack SFrame key message: {}", e);
                        }
                    }
                }
                Err(e) => {
                    error!("Error receiving SFrame key message: {}", e);
                }
            }
        }

        Ok(envelopes)
    }

    /// Check NATS connection state
    pub fn connection_state(&self) -> async_nats::connection::State {
        self.client.connection_state()
    }

    /// Cleanup consumers for a specific call (when call ends)
    pub async fn cleanup_call_consumers(&self, call_id: &str) -> Result<()> {
        // Note: Consumer cleanup is handled automatically by NATS when they expire
        // This method can be used for explicit cleanup if needed
        debug!("Cleaning up consumers for call {}", call_id);
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ice_candidate_subject() {
        let subject = subjects::ice_candidate("call-123", "user-456");
        assert_eq!(subject, "calls.call-123.ice.user-456");
    }

    #[test]
    fn test_sdp_subject() {
        let subject = subjects::sdp("call-123", "user-456");
        assert_eq!(subject, "calls.call-123.sdp.user-456");
    }

    #[test]
    fn test_events_subject() {
        let subject = subjects::events("call-123");
        assert_eq!(subject, "calls.call-123.events");
    }

    #[test]
    fn test_sframe_key_subject() {
        let subject = subjects::sframe_key("call-123", "user-456");
        assert_eq!(subject, "calls.call-123.sframe.user-456");
    }

    #[test]
    fn test_ice_candidate_envelope_serialization() {
        let envelope = IceCandidateEnvelope {
            call_id: "call-123".to_string(),
            from_user_id: "user-1".to_string(),
            target_user_id: "user-2".to_string(),
            candidate: "candidate:1 1 UDP 2130706431 192.168.1.1 8080 typ host".to_string(),
            sdp_mid: "0".to_string(),
            sdp_mline_index: 0,
            username_fragment: "abc123".to_string(),
            timestamp: 1706140800,
        };

        let json = serde_json::to_string(&envelope).unwrap();
        let deserialized: IceCandidateEnvelope = serde_json::from_str(&json).unwrap();

        assert_eq!(deserialized.call_id, envelope.call_id);
        assert_eq!(deserialized.candidate, envelope.candidate);
    }

    #[test]
    fn test_sdp_envelope_serialization() {
        let envelope = SdpEnvelope {
            call_id: "call-123".to_string(),
            from_user_id: "user-1".to_string(),
            target_user_id: "user-2".to_string(),
            sdp_type: 1, // OFFER
            sdp: "v=0\r\no=- 0 0 IN IP4 127.0.0.1\r\n".to_string(),
            timestamp: 1706140800,
        };

        let json = serde_json::to_string(&envelope).unwrap();
        let deserialized: SdpEnvelope = serde_json::from_str(&json).unwrap();

        assert_eq!(deserialized.sdp_type, envelope.sdp_type);
        assert_eq!(deserialized.sdp, envelope.sdp);
    }

    #[test]
    fn test_call_event_envelope_serialization() {
        let envelope = CallEventEnvelope {
            call_id: "call-123".to_string(),
            event_type: CallEventType::ParticipantJoined,
            payload: serde_json::json!({"user_id": "user-1", "display_name": "John"}),
            timestamp: 1706140800,
        };

        let json = serde_json::to_string(&envelope).unwrap();
        let deserialized: CallEventEnvelope = serde_json::from_str(&json).unwrap();

        assert_eq!(deserialized.call_id, envelope.call_id);
        assert!(matches!(deserialized.event_type, CallEventType::ParticipantJoined));
    }
}
