//! Kafka/Redpanda messaging client for Guardyn
//!
//! This module provides a high-level async interface for producing and consuming
//! messages from Kafka-compatible brokers (Redpanda).
//!
//! # Features
//! - Async producer with batching and compression
//! - Consumer groups with automatic offset management
//! - Graceful shutdown handling
//! - Tracing integration for observability
//!
//! # Usage
//! ```ignore
//! use guardyn_common::kafka::{KafkaProducer, KafkaConsumer, KafkaConfig};
//!
//! let config = KafkaConfig::from_env();
//! let producer = KafkaProducer::new(&config).await?;
//! producer.send("guardyn.messages", "key", message_bytes).await?;
//! ```

use rdkafka::config::ClientConfig;
use rdkafka::consumer::{Consumer, StreamConsumer};
use rdkafka::message::{Header, Headers, OwnedHeaders};
use rdkafka::producer::{FutureProducer, FutureRecord};
use rdkafka::Message;
use serde::{Deserialize, Serialize};
use std::time::Duration;
use thiserror::Error;
use tokio::sync::broadcast;
use tracing::{debug, error, info, instrument, warn};

/// Kafka-related errors
#[derive(Error, Debug)]
pub enum KafkaError {
    #[error("Failed to create producer: {0}")]
    ProducerCreation(String),

    #[error("Failed to create consumer: {0}")]
    ConsumerCreation(String),

    #[error("Failed to send message: {0}")]
    SendError(String),

    #[error("Failed to receive message: {0}")]
    ReceiveError(String),

    #[error("Serialization error: {0}")]
    Serialization(String),

    #[error("Configuration error: {0}")]
    Config(String),
}

pub type Result<T> = std::result::Result<T, KafkaError>;

/// Kafka client configuration
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KafkaConfig {
    /// Comma-separated list of brokers
    pub brokers: String,

    /// Consumer group ID
    pub group_id: String,

    /// Client ID for identification
    pub client_id: String,

    /// Enable SASL authentication
    pub sasl_enabled: bool,

    /// SASL username (if enabled)
    pub sasl_username: Option<String>,

    /// SASL password (if enabled)
    pub sasl_password: Option<String>,

    /// Message timeout in milliseconds
    pub message_timeout_ms: u64,

    /// Batch size for producer
    pub batch_size: usize,

    /// Linger time in milliseconds (wait before sending batch)
    pub linger_ms: u64,

    /// Compression type: none, gzip, snappy, lz4, zstd
    pub compression: String,
}

impl Default for KafkaConfig {
    fn default() -> Self {
        Self {
            brokers: "localhost:19092".to_string(),
            group_id: "guardyn-default".to_string(),
            client_id: "guardyn-client".to_string(),
            sasl_enabled: false,
            sasl_username: None,
            sasl_password: None,
            message_timeout_ms: 5000,
            batch_size: 16384,
            linger_ms: 5,
            compression: "lz4".to_string(),
        }
    }
}

impl KafkaConfig {
    /// Create configuration from environment variables
    pub fn from_env() -> Self {
        Self {
            brokers: std::env::var("REDPANDA_BROKERS")
                .or_else(|_| std::env::var("KAFKA_BROKERS"))
                .unwrap_or_else(|_| "localhost:19092".to_string()),
            group_id: std::env::var("KAFKA_GROUP_ID")
                .unwrap_or_else(|_| "guardyn-default".to_string()),
            client_id: std::env::var("KAFKA_CLIENT_ID")
                .or_else(|_| std::env::var("SERVICE_NAME"))
                .unwrap_or_else(|_| "guardyn-client".to_string()),
            sasl_enabled: std::env::var("KAFKA_SASL_ENABLED")
                .map(|v| v == "true")
                .unwrap_or(false),
            sasl_username: std::env::var("KAFKA_SASL_USERNAME").ok(),
            sasl_password: std::env::var("KAFKA_SASL_PASSWORD").ok(),
            message_timeout_ms: std::env::var("KAFKA_MESSAGE_TIMEOUT_MS")
                .ok()
                .and_then(|v| v.parse().ok())
                .unwrap_or(5000),
            batch_size: std::env::var("KAFKA_BATCH_SIZE")
                .ok()
                .and_then(|v| v.parse().ok())
                .unwrap_or(16384),
            linger_ms: std::env::var("KAFKA_LINGER_MS")
                .ok()
                .and_then(|v| v.parse().ok())
                .unwrap_or(5),
            compression: std::env::var("KAFKA_COMPRESSION").unwrap_or_else(|_| "lz4".to_string()),
        }
    }

    /// Build rdkafka ClientConfig from this configuration
    fn to_client_config(&self) -> ClientConfig {
        let mut config = ClientConfig::new();

        config
            .set("bootstrap.servers", &self.brokers)
            .set("client.id", &self.client_id)
            .set("message.timeout.ms", self.message_timeout_ms.to_string());

        if self.sasl_enabled {
            config.set("security.protocol", "SASL_PLAINTEXT");
            config.set("sasl.mechanism", "PLAIN");

            if let Some(ref username) = self.sasl_username {
                config.set("sasl.username", username);
            }
            if let Some(ref password) = self.sasl_password {
                config.set("sasl.password", password);
            }
        }

        config
    }
}

/// High-level Kafka producer
pub struct KafkaProducer {
    producer: FutureProducer,
    config: KafkaConfig,
}

impl KafkaProducer {
    /// Create a new Kafka producer
    #[instrument(skip(config), fields(brokers = %config.brokers))]
    pub fn new(config: &KafkaConfig) -> Result<Self> {
        let mut client_config = config.to_client_config();

        client_config
            .set("batch.size", config.batch_size.to_string())
            .set("linger.ms", config.linger_ms.to_string())
            .set("compression.type", &config.compression)
            .set("acks", "all") // Wait for all replicas
            .set("enable.idempotence", "true"); // Exactly-once semantics

        let producer: FutureProducer = client_config
            .create()
            .map_err(|e| KafkaError::ProducerCreation(e.to_string()))?;

        info!("Kafka producer created successfully");

        Ok(Self {
            producer,
            config: config.clone(),
        })
    }

    /// Send a message to a topic
    #[instrument(skip(self, payload), fields(topic = %topic, key = %key))]
    pub async fn send(&self, topic: &str, key: &str, payload: &[u8]) -> Result<()> {
        self.send_with_headers(topic, key, payload, None).await
    }

    /// Send a message with custom headers
    #[instrument(skip(self, payload, headers), fields(topic = %topic, key = %key))]
    pub async fn send_with_headers(
        &self,
        topic: &str,
        key: &str,
        payload: &[u8],
        headers: Option<Vec<(&str, &[u8])>>,
    ) -> Result<()> {
        let mut record = FutureRecord::to(topic).key(key).payload(payload);

        let owned_headers = headers.map(|h| {
            let mut owned = OwnedHeaders::new();
            for (k, v) in h {
                owned = owned.insert(Header {
                    key: k,
                    value: Some(v),
                });
            }
            owned
        });

        if let Some(ref h) = owned_headers {
            record = record.headers(h.clone());
        }

        let timeout = Duration::from_millis(self.config.message_timeout_ms);

        match self.producer.send(record, timeout).await {
            Ok((partition, offset)) => {
                debug!(partition, offset, "Message sent successfully");
                Ok(())
            }
            Err((e, _)) => {
                error!(error = %e, "Failed to send message");
                Err(KafkaError::SendError(e.to_string()))
            }
        }
    }

    /// Send a serializable message as JSON
    #[instrument(skip(self, message), fields(topic = %topic, key = %key))]
    pub async fn send_json<T: Serialize>(&self, topic: &str, key: &str, message: &T) -> Result<()> {
        let payload =
            serde_json::to_vec(message).map_err(|e| KafkaError::Serialization(e.to_string()))?;

        self.send(topic, key, &payload).await
    }
}

/// Received Kafka message
#[derive(Debug, Clone)]
pub struct ReceivedMessage {
    pub topic: String,
    pub partition: i32,
    pub offset: i64,
    pub key: Option<Vec<u8>>,
    pub payload: Vec<u8>,
    pub timestamp: Option<i64>,
    pub headers: Vec<(String, Vec<u8>)>,
}

impl ReceivedMessage {
    /// Get key as string
    pub fn key_str(&self) -> Option<&str> {
        self.key.as_ref().and_then(|k| std::str::from_utf8(k).ok())
    }

    /// Deserialize payload as JSON
    pub fn payload_json<T: for<'de> Deserialize<'de>>(
        &self,
    ) -> std::result::Result<T, serde_json::Error> {
        serde_json::from_slice(&self.payload)
    }
}

/// High-level Kafka consumer
pub struct KafkaConsumer {
    consumer: StreamConsumer,
    shutdown_tx: broadcast::Sender<()>,
}

impl KafkaConsumer {
    /// Create a new Kafka consumer
    #[instrument(skip(config), fields(brokers = %config.brokers, group_id = %config.group_id))]
    pub fn new(config: &KafkaConfig) -> Result<Self> {
        let mut client_config = config.to_client_config();

        client_config
            .set("group.id", &config.group_id)
            .set("enable.auto.commit", "true")
            .set("auto.commit.interval.ms", "5000")
            .set("auto.offset.reset", "earliest")
            .set("session.timeout.ms", "45000");

        let consumer: StreamConsumer = client_config
            .create()
            .map_err(|e| KafkaError::ConsumerCreation(e.to_string()))?;

        let (shutdown_tx, _) = broadcast::channel(1);

        info!("Kafka consumer created successfully");

        Ok(Self {
            consumer,
            shutdown_tx,
        })
    }

    /// Subscribe to topics
    #[instrument(skip(self))]
    pub fn subscribe(&self, topics: &[&str]) -> Result<()> {
        self.consumer
            .subscribe(topics)
            .map_err(|e| KafkaError::ConsumerCreation(format!("Failed to subscribe: {}", e)))?;

        info!(?topics, "Subscribed to topics");
        Ok(())
    }

    /// Get a shutdown signal sender
    pub fn shutdown_signal(&self) -> broadcast::Sender<()> {
        self.shutdown_tx.clone()
    }

    /// Consume messages with a handler function
    #[instrument(skip(self, handler))]
    pub async fn consume<F, Fut>(&self, mut handler: F) -> Result<()>
    where
        F: FnMut(ReceivedMessage) -> Fut,
        Fut: std::future::Future<
            Output = std::result::Result<(), Box<dyn std::error::Error + Send + Sync>>,
        >,
    {
        use futures::StreamExt;

        let mut shutdown_rx = self.shutdown_tx.subscribe();
        let stream = self.consumer.stream();
        tokio::pin!(stream);

        loop {
            tokio::select! {
                Some(message_result) = stream.next() => {
                    match message_result {
                        Ok(borrowed_message) => {
                            let msg = ReceivedMessage {
                                topic: borrowed_message.topic().to_string(),
                                partition: borrowed_message.partition(),
                                offset: borrowed_message.offset(),
                                key: borrowed_message.key().map(|k| k.to_vec()),
                                payload: borrowed_message.payload().unwrap_or(&[]).to_vec(),
                                timestamp: borrowed_message.timestamp().to_millis(),
                                headers: borrowed_message
                                    .headers()
                                    .map(|h| {
                                        (0..h.count())
                                            .map(|i| {
                                                let header = h.get(i);
                                                (header.key.to_string(), header.value.unwrap_or(&[]).to_vec())
                                            })
                                            .collect()
                                    })
                                    .unwrap_or_default(),
                            };

                            if let Err(e) = handler(msg).await {
                                warn!(error = %e, "Message handler error");
                            }
                        }
                        Err(e) => {
                            error!(error = %e, "Error receiving message");
                        }
                    }
                }
                _ = shutdown_rx.recv() => {
                    info!("Shutdown signal received, stopping consumer");
                    break;
                }
            }
        }

        Ok(())
    }
}

/// Guardyn-specific topic names
pub mod topics {
    /// Encrypted messages between users
    pub const MESSAGES: &str = "guardyn.messages";

    /// User presence updates (online/offline/typing)
    pub const PRESENCE: &str = "guardyn.presence";

    /// Push notification events
    pub const NOTIFICATIONS: &str = "guardyn.notifications";

    /// Media upload and processing events
    pub const MEDIA: &str = "guardyn.media";

    /// Key bundle updates
    pub const KEYS: &str = "guardyn.keys";

    /// MLS group operations
    pub const GROUPS: &str = "guardyn.groups";

    /// Security audit events
    pub const AUDIT: &str = "guardyn.audit";
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_config_default() {
        let config = KafkaConfig::default();
        assert_eq!(config.brokers, "localhost:19092");
        assert!(!config.sasl_enabled);
    }

    #[test]
    fn test_topics() {
        assert_eq!(topics::MESSAGES, "guardyn.messages");
        assert_eq!(topics::PRESENCE, "guardyn.presence");
    }
}
