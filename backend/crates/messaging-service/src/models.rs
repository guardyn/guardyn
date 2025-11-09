/// Data models for Messaging Service
use serde::{Deserialize, Serialize};

/// Message stored in ScyllaDB
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StoredMessage {
    pub message_id: String,
    pub conversation_id: String,
    pub sender_user_id: String,
    pub sender_device_id: String,
    pub recipient_user_id: String,
    pub recipient_device_id: Option<String>,
    pub encrypted_content: Vec<u8>,
    pub message_type: i32,
    pub server_timestamp: i64,
    pub client_timestamp: i64,
    pub delivery_status: i32,
    pub is_deleted: bool,
}

/// Delivery state tracked in TiKV
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeliveryState {
    pub message_id: String,
    pub sender_user_id: String,
    pub sender_device_id: String,
    pub recipient_user_id: String,
    pub recipient_device_id: Option<String>,
    pub status: DeliveryStatus,
    pub created_at: i64,
    pub updated_at: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum DeliveryStatus {
    Pending,
    Sent,
    Delivered,
    Read,
    Failed,
}

impl DeliveryStatus {
    pub fn to_i32(&self) -> i32 {
        match self {
            DeliveryStatus::Pending => 0,
            DeliveryStatus::Sent => 1,
            DeliveryStatus::Delivered => 2,
            DeliveryStatus::Read => 3,
            DeliveryStatus::Failed => 4,
        }
    }

    pub fn from_i32(value: i32) -> Self {
        match value {
            0 => DeliveryStatus::Pending,
            1 => DeliveryStatus::Sent,
            2 => DeliveryStatus::Delivered,
            3 => DeliveryStatus::Read,
            4 => DeliveryStatus::Failed,
            _ => DeliveryStatus::Pending,
        }
    }
}

/// Group chat metadata
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GroupMetadata {
    pub group_id: String,
    pub group_name: String,
    pub creator_user_id: String,
    pub created_at: i64,
    pub mls_group_id: Vec<u8>, // OpenMLS group identifier
    pub mls_epoch: u64,
}

/// Group member
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GroupMember {
    pub group_id: String,
    pub user_id: String,
    pub role: GroupRole,
    pub joined_at: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum GroupRole {
    Owner,
    Admin,
    Member,
}

impl GroupRole {
    pub fn to_string(&self) -> String {
        match self {
            GroupRole::Owner => "owner".to_string(),
            GroupRole::Admin => "admin".to_string(),
            GroupRole::Member => "member".to_string(),
        }
    }

    pub fn from_string(s: &str) -> Self {
        match s {
            "owner" => GroupRole::Owner,
            "admin" => GroupRole::Admin,
            _ => GroupRole::Member,
        }
    }
}

/// Group message stored in ScyllaDB
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GroupMessage {
    pub message_id: String,
    pub group_id: String,
    pub sender_user_id: String,
    pub sender_device_id: String,
    pub encrypted_content: Vec<u8>,
    pub message_type: i32,
    pub server_timestamp: i64,
    pub client_timestamp: i64,
    pub is_deleted: bool,
}
