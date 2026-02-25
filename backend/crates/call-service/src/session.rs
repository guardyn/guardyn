//! Call session manager
//!
//! Manages active call sessions in memory for fast access.

use chrono::{DateTime, Utc};
use dashmap::DashMap;
use parking_lot::RwLock;
use std::collections::HashMap;
use std::sync::Arc;
use uuid::Uuid;

/// Active call session
#[derive(Debug, Clone)]
pub struct CallSession {
    pub call_id: String,
    pub call_type: i32,
    pub is_group_call: bool,
    pub group_id: Option<String>,
    pub initiator_id: String,
    pub state: i32,
    pub created_at: DateTime<Utc>,
    pub started_at: Option<DateTime<Utc>>,
    pub participants: HashMap<String, SessionParticipant>,
    pub sframe_key_id: u32,
}

/// Participant in a session
#[derive(Debug, Clone)]
pub struct SessionParticipant {
    pub user_id: String,
    pub display_name: String,
    pub is_muted: bool,
    pub has_video: bool,
    pub is_screen_sharing: bool,
    pub is_speaking: bool,
    pub joined_at: DateTime<Utc>,
}

/// SFrame key material for a participant
#[derive(Debug, Clone)]
pub struct ParticipantKey {
    #[allow(dead_code)]
    pub user_id: String,
    #[allow(dead_code)]
    pub key_id: u32,
    #[allow(dead_code)]
    pub key_material: Vec<u8>,
}

/// Manages active call sessions
pub struct CallSessionManager {
    /// Active sessions by call_id
    sessions: DashMap<String, Arc<RwLock<CallSession>>>,
    /// User's active call (user_id -> call_id)
    user_calls: DashMap<String, String>,
    /// SFrame keys per call (call_id -> user_id -> key)
    sframe_keys: DashMap<String, HashMap<String, ParticipantKey>>,
}

impl CallSessionManager {
    /// Create a new session manager
    pub fn new() -> Self {
        Self {
            sessions: DashMap::new(),
            user_calls: DashMap::new(),
            sframe_keys: DashMap::new(),
        }
    }

    /// Create a new call session
    pub fn create_session(
        &self,
        call_type: i32,
        is_group_call: bool,
        group_id: Option<String>,
        initiator_id: &str,
        initiator_name: &str,
    ) -> (String, u32, Vec<u8>) {
        let call_id = Uuid::new_v4().to_string();
        let sframe_key_id = 1u32;
        let sframe_key = generate_sframe_key();

        let session = CallSession {
            call_id: call_id.clone(),
            call_type,
            is_group_call,
            group_id,
            initiator_id: initiator_id.to_string(),
            state: 1, // INITIATING
            created_at: Utc::now(),
            started_at: None,
            participants: HashMap::new(),
            sframe_key_id,
        };

        // Add initiator as first participant
        let mut session = session;
        session.participants.insert(
            initiator_id.to_string(),
            SessionParticipant {
                user_id: initiator_id.to_string(),
                display_name: initiator_name.to_string(),
                is_muted: false,
                has_video: call_type == 2, // VIDEO
                is_screen_sharing: false,
                is_speaking: false,
                joined_at: Utc::now(),
            },
        );

        self.sessions
            .insert(call_id.clone(), Arc::new(RwLock::new(session)));
        self.user_calls
            .insert(initiator_id.to_string(), call_id.clone());

        // Store initial SFrame key
        let mut keys = HashMap::new();
        keys.insert(
            initiator_id.to_string(),
            ParticipantKey {
                user_id: initiator_id.to_string(),
                key_id: sframe_key_id,
                key_material: sframe_key.clone(),
            },
        );
        self.sframe_keys.insert(call_id.clone(), keys);

        (call_id, sframe_key_id, sframe_key)
    }

    /// Get a session by call_id
    pub fn get_session(&self, call_id: &str) -> Option<Arc<RwLock<CallSession>>> {
        self.sessions.get(call_id).map(|s| s.clone())
    }

    /// Get user's active call
    #[allow(dead_code)]
    pub fn get_user_call(&self, user_id: &str) -> Option<String> {
        self.user_calls.get(user_id).map(|c| c.clone())
    }

    /// Check if user is in a call
    /// Also cleans up stale calls (calls that have been in INITIATING/RINGING state for too long)
    pub fn is_user_in_call(&self, user_id: &str) -> bool {
        if let Some(call_id_ref) = self.user_calls.get(user_id) {
            let call_id = call_id_ref.value().clone();
            drop(call_id_ref); // Release the lock before potentially calling end_session

            // Check if the call is stale (in INITIATING or RINGING state for more than 60 seconds)
            if let Some(session) = self.sessions.get(&call_id) {
                let session_guard = session.read();
                let age = Utc::now() - session_guard.created_at;
                let state = session_guard.state;
                drop(session_guard); // Release lock before removing

                // States: 1=INITIATING, 2=RINGING - if stuck for >60s, consider stale
                if (state == 1 || state == 2) && age.num_seconds() > 60 {
                    tracing::warn!(
                        "Cleaning up stale call {} for user {} (age: {}s, state: {})",
                        call_id,
                        user_id,
                        age.num_seconds(),
                        if state == 1 { "INITIATING" } else { "RINGING" }
                    );
                    drop(session); // Release the DashMap guard
                    self.end_session(&call_id);
                    return false;
                }
                return true;
            } else {
                // Session doesn't exist, clean up the user_calls entry
                tracing::warn!(
                    "Cleaning up orphaned user_call entry for user {} (call {} not found)",
                    user_id,
                    call_id
                );
                self.user_calls.remove(user_id);
                return false;
            }
        }
        false
    }

    /// Add participant to session
    pub fn add_participant(
        &self,
        call_id: &str,
        user_id: &str,
        display_name: &str,
        has_video: bool,
    ) -> Option<(u32, Vec<u8>)> {
        let session = self.get_session(call_id)?;
        let sframe_key = generate_sframe_key();

        {
            let mut session = session.write();
            session.participants.insert(
                user_id.to_string(),
                SessionParticipant {
                    user_id: user_id.to_string(),
                    display_name: display_name.to_string(),
                    is_muted: false,
                    has_video,
                    is_screen_sharing: false,
                    is_speaking: false,
                    joined_at: Utc::now(),
                },
            );
        }

        self.user_calls
            .insert(user_id.to_string(), call_id.to_string());

        // Store SFrame key
        let key_id = {
            let session = session.read();
            session.sframe_key_id
        };

        if let Some(mut keys) = self.sframe_keys.get_mut(call_id) {
            keys.insert(
                user_id.to_string(),
                ParticipantKey {
                    user_id: user_id.to_string(),
                    key_id,
                    key_material: sframe_key.clone(),
                },
            );
        }

        Some((key_id, sframe_key))
    }

    /// Remove participant from session
    pub fn remove_participant(&self, call_id: &str, user_id: &str) -> bool {
        if let Some(session) = self.get_session(call_id) {
            {
                let mut session = session.write();
                session.participants.remove(user_id);
            }
            self.user_calls.remove(user_id);

            if let Some(mut keys) = self.sframe_keys.get_mut(call_id) {
                keys.remove(user_id);
            }

            return true;
        }
        false
    }

    /// Update call state
    pub fn update_state(&self, call_id: &str, state: i32) -> bool {
        if let Some(session) = self.get_session(call_id) {
            let mut session = session.write();
            session.state = state;
            if state == 4 && session.started_at.is_none() {
                // CONNECTED
                session.started_at = Some(Utc::now());
            }
            return true;
        }
        false
    }

    /// Update participant mute status
    pub fn update_mute(&self, call_id: &str, user_id: &str, muted: bool) -> bool {
        if let Some(session) = self.get_session(call_id) {
            let mut session = session.write();
            if let Some(participant) = session.participants.get_mut(user_id) {
                participant.is_muted = muted;
                return true;
            }
        }
        false
    }

    /// Update participant video status
    pub fn update_video(&self, call_id: &str, user_id: &str, video: bool) -> bool {
        if let Some(session) = self.get_session(call_id) {
            let mut session = session.write();
            if let Some(participant) = session.participants.get_mut(user_id) {
                participant.has_video = video;
                return true;
            }
        }
        false
    }

    /// Update participant screen share status
    pub fn update_screen_share(&self, call_id: &str, user_id: &str, sharing: bool) -> bool {
        if let Some(session) = self.get_session(call_id) {
            let mut session = session.write();
            if let Some(participant) = session.participants.get_mut(user_id) {
                participant.is_screen_sharing = sharing;
                return true;
            }
        }
        false
    }

    /// Update speaking indicator
    #[allow(dead_code)]
    pub fn update_speaking(&self, call_id: &str, user_id: &str, speaking: bool) -> bool {
        if let Some(session) = self.get_session(call_id) {
            let mut session = session.write();
            if let Some(participant) = session.participants.get_mut(user_id) {
                participant.is_speaking = speaking;
                return true;
            }
        }
        false
    }

    /// Get participants in a call
    pub fn get_participants(&self, call_id: &str) -> Vec<SessionParticipant> {
        if let Some(session) = self.get_session(call_id) {
            let session = session.read();
            return session.participants.values().cloned().collect();
        }
        Vec::new()
    }

    /// End a call session
    pub fn end_session(&self, call_id: &str) -> Option<CallSession> {
        if let Some((_, session)) = self.sessions.remove(call_id) {
            let session_data = {
                let mut session = session.write();
                session.state = 6; // ENDED
                session.clone()
            };

            // Remove all participants from user_calls
            for user_id in session_data.participants.keys() {
                self.user_calls.remove(user_id);
            }

            // Remove SFrame keys
            self.sframe_keys.remove(call_id);

            return Some(session_data);
        }
        None
    }

    /// Calculate call duration
    pub fn get_duration(&self, call_id: &str) -> i32 {
        if let Some(session) = self.get_session(call_id) {
            let session = session.read();
            if let Some(started) = session.started_at {
                return (Utc::now() - started).num_seconds() as i32;
            }
        }
        0
    }

    /// Rotate SFrame key for a participant
    pub fn rotate_sframe_key(&self, call_id: &str, user_id: &str) -> Option<(u32, Vec<u8>)> {
        if let Some(session) = self.get_session(call_id) {
            let new_key_id = {
                let mut session = session.write();
                session.sframe_key_id += 1;
                session.sframe_key_id
            };

            let new_key = generate_sframe_key();

            if let Some(mut keys) = self.sframe_keys.get_mut(call_id) {
                keys.insert(
                    user_id.to_string(),
                    ParticipantKey {
                        user_id: user_id.to_string(),
                        key_id: new_key_id,
                        key_material: new_key.clone(),
                    },
                );
            }

            return Some((new_key_id, new_key));
        }
        None
    }

    /// Get all SFrame keys for a call
    #[allow(dead_code)]
    pub fn get_sframe_keys(&self, call_id: &str) -> Vec<ParticipantKey> {
        self.sframe_keys
            .get(call_id)
            .map(|keys| keys.values().cloned().collect())
            .unwrap_or_default()
    }
}

impl Default for CallSessionManager {
    fn default() -> Self {
        Self::new()
    }
}

/// Generate random SFrame key material
fn generate_sframe_key() -> Vec<u8> {
    use std::time::{SystemTime, UNIX_EPOCH};

    // Simple key generation - in production use proper CSPRNG
    let mut key = vec![0u8; 32];
    let seed = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_nanos();

    for (i, byte) in key.iter_mut().enumerate() {
        *byte = ((seed >> (i % 8)) & 0xFF) as u8 ^ (i as u8);
    }

    key
}
