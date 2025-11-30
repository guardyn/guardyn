/// NATS JetStream client for real-time message routing
use anyhow::{Context, Result};
use async_nats::jetstream::{self, consumer::PullConsumer, stream::Stream};
use futures::StreamExt; // For .next() on async streams
use serde::{Deserialize, Serialize};
use std::sync::Arc;

/// NATS message envelope
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MessageEnvelope {
    pub message_id: String,
    pub sender_user_id: String,
    pub sender_device_id: String,
    pub recipient_user_id: String,
    pub encrypted_content: Vec<u8>,
    pub timestamp: i64,
}

/// NATS client for message routing
pub struct NatsClient {
    client: async_nats::Client,
    context: jetstream::Context,
    messages_stream: Stream,
}

impl NatsClient {
    /// Connect to NATS and initialize JetStream
    pub async fn new(nats_url: &str) -> Result<Self> {
        // Connect to NATS
        let client = async_nats::connect(nats_url)
            .await
            .context("Failed to connect to NATS")?;

        // Create JetStream context
        let context = jetstream::new(client.clone());

        // Get or create MESSAGES stream
        let messages_stream = context
            .get_or_create_stream(jetstream::stream::Config {
                name: "MESSAGES".to_string(),
                subjects: vec!["messages.>".to_string()],
                max_age: std::time::Duration::from_secs(86400 * 7), // 7 days retention
                ..Default::default()
            })
            .await
            .context("Failed to create MESSAGES stream")?;

        tracing::info!("Connected to NATS JetStream");

        Ok(Self {
            client,
            context,
            messages_stream,
        })
    }

    /// Publish message to NATS
    pub async fn publish_message(&self, envelope: &MessageEnvelope) -> Result<()> {
        let subject = format!("messages.{}.{}",
            envelope.recipient_user_id,
            envelope.message_id
        );

        let payload = serde_json::to_vec(envelope)?;

        self.context
            .publish(subject, payload.into())
            .await
            .context("Failed to publish message to NATS")?
            .await
            .context("Failed to confirm message publication")?;

        tracing::debug!(
            "Published message {} to recipient {}",
            envelope.message_id,
            envelope.recipient_user_id
        );

        Ok(())
    }

    /// Publish message to NATS with custom subject (for group messages)
    pub async fn publish_message_to_subject(&self, subject: &str, envelope: &MessageEnvelope) -> Result<()> {
        let payload = serde_json::to_vec(envelope)?;

        self.context
            .publish(subject.to_string(), payload.into())
            .await
            .context("Failed to publish message to NATS")?
            .await
            .context("Failed to confirm message publication")?;

        tracing::debug!("Published message {} to subject {}", envelope.message_id, subject);

        Ok(())
    }

    /// Subscribe to messages for a specific user
    pub async fn subscribe_to_messages(&self, user_id: &str) -> Result<PullConsumer> {
        let consumer_name = format!("user-{}", user_id);
        let subject_filter = format!("messages.{}.*", user_id);

        let consumer = self
            .messages_stream
            .get_or_create_consumer(
                &consumer_name,
                jetstream::consumer::pull::Config {
                    filter_subject: subject_filter.clone(),
                    durable_name: Some(consumer_name.clone()),
                    ..Default::default()
                },
            )
            .await
            .context("Failed to create consumer")?;

        tracing::info!("Created consumer {} for user {}", consumer_name, user_id);

        Ok(consumer)
    }

    /// Fetch messages from consumer
    pub async fn fetch_messages(
        &self,
        consumer: &PullConsumer,
        batch_size: usize,
    ) -> Result<Vec<MessageEnvelope>> {
        let mut messages = consumer
            .batch()
            .max_messages(batch_size)
            .messages()
            .await
            .context("Failed to fetch messages")?;

        let mut envelopes = Vec::new();

        while let Some(msg) = messages.next().await {
            match msg {
                Ok(msg) => {
                    if let Ok(envelope) = serde_json::from_slice::<MessageEnvelope>(&msg.payload) {
                        envelopes.push(envelope);
                        // Acknowledge message
                        let _ = msg.ack().await;
                    }
                }
                Err(e) => {
                    tracing::error!("Error receiving message: {}", e);
                }
            }
        }

        Ok(envelopes)
    }

    /// Low-level publish method (used by MLS handlers)
    pub async fn publish(&self, subject: &str, payload: &[u8]) -> Result<()> {
        let payload_bytes = bytes::Bytes::copy_from_slice(payload);
        self.context
            .publish(subject.to_string(), payload_bytes)
            .await
            .context("Failed to publish to NATS")?
            .await
            .context("Failed to confirm NATS publish")?;
        Ok(())
    }

    /// Create a consumer for specific subject (used by E2EE handlers)
    pub async fn create_consumer(
        &self,
        consumer_name: &str,
        subject: &str,
    ) -> Result<PullConsumer> {
        let consumer = self
            .messages_stream
            .get_or_create_consumer(
                consumer_name,
                jetstream::consumer::pull::Config {
                    filter_subject: subject.to_string(),
                    durable_name: Some(consumer_name.to_string()),
                    ..Default::default()
                },
            )
            .await
            .context("Failed to create consumer")?;

        tracing::info!("Created consumer {} for subject {}", consumer_name, subject);

        Ok(consumer)
    }

    /// Get NATS connection state
    pub fn connection_state(&self) -> async_nats::connection::State {
        self.client.connection_state()
    }

    /// Publish raw bytes to a subject (for WebSocket handlers)
    pub async fn publish_raw(&self, subject: &str, payload: bytes::Bytes) -> Result<()> {
        self.context
            .publish(subject.to_string(), payload)
            .await
            .context("Failed to publish to NATS")?
            .await
            .context("Failed to confirm NATS publish")?;
        Ok(())
    }
}


