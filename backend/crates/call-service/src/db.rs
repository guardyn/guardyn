//! Database layer for Call Service
//!
//! Manages active calls, call history, and participant state.

use anyhow::{Context, Result};
use chrono::{DateTime, Utc};
use scylla::{Session, SessionBuilder};
use std::sync::Arc;
use tracing::info;

/// Call record stored in database
#[derive(Debug, Clone)]
pub struct CallRecord {
    pub call_id: String,
    pub call_type: i32,
    pub is_group_call: bool,
    pub group_id: Option<String>,
    pub initiator_id: String,
    pub state: i32,
    #[allow(dead_code)]
    pub end_reason: Option<i32>,
    pub created_at: DateTime<Utc>,
    pub started_at: Option<DateTime<Utc>>,
    #[allow(dead_code)]
    pub ended_at: Option<DateTime<Utc>>,
    pub duration_seconds: i32,
}

/// Call participant record
#[derive(Debug, Clone)]
pub struct CallParticipantRecord {
    pub call_id: String,
    pub user_id: String,
    pub display_name: String,
    pub is_muted: bool,
    pub has_video: bool,
    pub is_screen_sharing: bool,
    pub joined_at: DateTime<Utc>,
    #[allow(dead_code)]
    pub left_at: Option<DateTime<Utc>>,
}

/// Call history entry for a user
#[derive(Debug, Clone)]
pub struct UserCallHistoryEntry {
    pub user_id: String,
    pub call_id: String,
    pub call_type: i32,
    pub is_group_call: bool,
    pub group_id: Option<String>,
    pub other_user_id: Option<String>,
    pub other_user_name: Option<String>,
    pub is_outgoing: bool,
    pub end_reason: i32,
    pub started_at: DateTime<Utc>,
    pub duration_seconds: i32,
}

/// Call database operations
pub struct CallDb {
    session: Arc<Session>,
}

impl CallDb {
    /// Create a new database connection
    pub async fn new(hosts: &[String]) -> Result<Self> {
        let session = SessionBuilder::new()
            .known_nodes(hosts)
            .build()
            .await
            .context("Failed to connect to ScyllaDB")?;

        let db = Self {
            session: Arc::new(session),
        };

        db.init_schema().await?;
        Ok(db)
    }

    /// Initialize database schema
    async fn init_schema(&self) -> Result<()> {
        // Create keyspace
        self.session
            .query_unpaged(
                r#"
                CREATE KEYSPACE IF NOT EXISTS guardyn_calls
                WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1}
                "#,
                &[],
            )
            .await
            .context("Failed to create keyspace")?;

        // Active calls table
        self.session
            .query_unpaged(
                r#"
                CREATE TABLE IF NOT EXISTS guardyn_calls.active_calls (
                    call_id text PRIMARY KEY,
                    call_type int,
                    is_group_call boolean,
                    group_id text,
                    initiator_id text,
                    state int,
                    end_reason int,
                    created_at timestamp,
                    started_at timestamp,
                    ended_at timestamp,
                    duration_seconds int
                )
                "#,
                &[],
            )
            .await
            .context("Failed to create active_calls table")?;

        // Call participants table
        self.session
            .query_unpaged(
                r#"
                CREATE TABLE IF NOT EXISTS guardyn_calls.call_participants (
                    call_id text,
                    user_id text,
                    display_name text,
                    is_muted boolean,
                    has_video boolean,
                    is_screen_sharing boolean,
                    joined_at timestamp,
                    left_at timestamp,
                    PRIMARY KEY (call_id, user_id)
                )
                "#,
                &[],
            )
            .await
            .context("Failed to create call_participants table")?;

        // User call history table
        self.session
            .query_unpaged(
                r#"
                CREATE TABLE IF NOT EXISTS guardyn_calls.user_call_history (
                    user_id text,
                    started_at timestamp,
                    call_id text,
                    call_type int,
                    is_group_call boolean,
                    group_id text,
                    other_user_id text,
                    other_user_name text,
                    is_outgoing boolean,
                    end_reason int,
                    duration_seconds int,
                    PRIMARY KEY (user_id, started_at)
                ) WITH CLUSTERING ORDER BY (started_at DESC)
                "#,
                &[],
            )
            .await
            .context("Failed to create user_call_history table")?;

        // Index for looking up calls by user
        self.session
            .query_unpaged(
                r#"
                CREATE INDEX IF NOT EXISTS ON guardyn_calls.call_participants (user_id)
                "#,
                &[],
            )
            .await
            .ok(); // Index may already exist

        info!("Call database schema initialized");
        Ok(())
    }

    /// Create a new call
    pub async fn create_call(&self, call: &CallRecord) -> Result<()> {
        self.session
            .query_unpaged(
                r#"
                INSERT INTO guardyn_calls.active_calls 
                (call_id, call_type, is_group_call, group_id, initiator_id, state, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                "#,
                (
                    &call.call_id,
                    call.call_type,
                    call.is_group_call,
                    &call.group_id,
                    &call.initiator_id,
                    call.state,
                    call.created_at.timestamp_millis(),
                ),
            )
            .await
            .context("Failed to create call")?;

        Ok(())
    }

    /// Get call by ID
    #[allow(clippy::type_complexity)]
    pub async fn get_call(&self, call_id: &str) -> Result<Option<CallRecord>> {
        let result = self
            .session
            .query_unpaged(
                r#"
                SELECT call_id, call_type, is_group_call, group_id, initiator_id, state, 
                       end_reason, created_at, started_at, ended_at, duration_seconds
                FROM guardyn_calls.active_calls
                WHERE call_id = ?
                "#,
                (call_id,),
            )
            .await
            .context("Failed to get call")?;

        if let Some(rows) = result.rows {
            if let Some(row) = rows.into_iter().next() {
                let (
                    call_id,
                    call_type,
                    is_group_call,
                    group_id,
                    initiator_id,
                    state,
                    end_reason,
                    created_at,
                    started_at,
                    ended_at,
                    duration_seconds,
                ): (
                    String,
                    i32,
                    bool,
                    Option<String>,
                    String,
                    i32,
                    Option<i32>,
                    i64,
                    Option<i64>,
                    Option<i64>,
                    Option<i32>,
                ) = row.into_typed().context("Failed to parse call row")?;

                return Ok(Some(CallRecord {
                    call_id,
                    call_type,
                    is_group_call,
                    group_id,
                    initiator_id,
                    state,
                    end_reason,
                    created_at: DateTime::from_timestamp_millis(created_at).unwrap_or_default(),
                    started_at: started_at.and_then(DateTime::from_timestamp_millis),
                    ended_at: ended_at.and_then(DateTime::from_timestamp_millis),
                    duration_seconds: duration_seconds.unwrap_or(0),
                }));
            }
        }

        Ok(None)
    }

    /// Update call state
    pub async fn update_call_state(&self, call_id: &str, state: i32) -> Result<()> {
        self.session
            .query_unpaged(
                "UPDATE guardyn_calls.active_calls SET state = ? WHERE call_id = ?",
                (state, call_id),
            )
            .await
            .context("Failed to update call state")?;

        Ok(())
    }

    /// Set call as connected
    #[allow(dead_code)]
    pub async fn set_call_connected(&self, call_id: &str) -> Result<()> {
        self.session
            .query_unpaged(
                "UPDATE guardyn_calls.active_calls SET state = ?, started_at = ? WHERE call_id = ?",
                (4, Utc::now().timestamp_millis(), call_id), // 4 = CONNECTED
            )
            .await
            .context("Failed to set call connected")?;

        Ok(())
    }

    /// End a call
    pub async fn end_call(&self, call_id: &str, end_reason: i32, duration: i32) -> Result<()> {
        self.session
            .query_unpaged(
                r#"
                UPDATE guardyn_calls.active_calls 
                SET state = ?, end_reason = ?, ended_at = ?, duration_seconds = ?
                WHERE call_id = ?
                "#,
                (
                    6, // ENDED
                    end_reason,
                    Utc::now().timestamp_millis(),
                    duration,
                    call_id,
                ),
            )
            .await
            .context("Failed to end call")?;

        Ok(())
    }

    /// Add a participant to a call
    pub async fn add_participant(&self, participant: &CallParticipantRecord) -> Result<()> {
        self.session
            .query_unpaged(
                r#"
                INSERT INTO guardyn_calls.call_participants 
                (call_id, user_id, display_name, is_muted, has_video, is_screen_sharing, joined_at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                "#,
                (
                    &participant.call_id,
                    &participant.user_id,
                    &participant.display_name,
                    participant.is_muted,
                    participant.has_video,
                    participant.is_screen_sharing,
                    participant.joined_at.timestamp_millis(),
                ),
            )
            .await
            .context("Failed to add participant")?;

        Ok(())
    }

    /// Update participant state
    pub async fn update_participant_mute(
        &self,
        call_id: &str,
        user_id: &str,
        muted: bool,
    ) -> Result<()> {
        self.session
            .query_unpaged(
                "UPDATE guardyn_calls.call_participants SET is_muted = ? WHERE call_id = ? AND user_id = ?",
                (muted, call_id, user_id),
            )
            .await
            .context("Failed to update participant mute")?;

        Ok(())
    }

    /// Update participant video state
    pub async fn update_participant_video(
        &self,
        call_id: &str,
        user_id: &str,
        video: bool,
    ) -> Result<()> {
        self.session
            .query_unpaged(
                "UPDATE guardyn_calls.call_participants SET has_video = ? WHERE call_id = ? AND user_id = ?",
                (video, call_id, user_id),
            )
            .await
            .context("Failed to update participant video")?;

        Ok(())
    }

    /// Update participant screen share state
    pub async fn update_participant_screen_share(
        &self,
        call_id: &str,
        user_id: &str,
        sharing: bool,
    ) -> Result<()> {
        self.session
            .query_unpaged(
                "UPDATE guardyn_calls.call_participants SET is_screen_sharing = ? WHERE call_id = ? AND user_id = ?",
                (sharing, call_id, user_id),
            )
            .await
            .context("Failed to update participant screen share")?;

        Ok(())
    }

    /// Mark participant as left
    pub async fn participant_left(&self, call_id: &str, user_id: &str) -> Result<()> {
        self.session
            .query_unpaged(
                "UPDATE guardyn_calls.call_participants SET left_at = ? WHERE call_id = ? AND user_id = ?",
                (Utc::now().timestamp_millis(), call_id, user_id),
            )
            .await
            .context("Failed to mark participant as left")?;

        Ok(())
    }

    /// Get call participants
    pub async fn get_call_participants(&self, call_id: &str) -> Result<Vec<CallParticipantRecord>> {
        let result = self
            .session
            .query_unpaged(
                r#"
                SELECT call_id, user_id, display_name, is_muted, has_video, is_screen_sharing, joined_at, left_at
                FROM guardyn_calls.call_participants
                WHERE call_id = ?
                "#,
                (call_id,),
            )
            .await
            .context("Failed to get call participants")?;

        let mut participants = Vec::new();
        if let Some(rows) = result.rows {
            for row in rows {
                let (
                    call_id,
                    user_id,
                    display_name,
                    is_muted,
                    has_video,
                    is_screen_sharing,
                    joined_at,
                    left_at,
                ): (String, String, String, bool, bool, bool, i64, Option<i64>) = row
                    .into_typed()
                    .context("Failed to parse participant row")?;

                // Only include active participants
                if left_at.is_none() {
                    participants.push(CallParticipantRecord {
                        call_id,
                        user_id,
                        display_name,
                        is_muted,
                        has_video,
                        is_screen_sharing,
                        joined_at: DateTime::from_timestamp_millis(joined_at).unwrap_or_default(),
                        left_at: None,
                    });
                }
            }
        }

        Ok(participants)
    }

    /// Add entry to user's call history
    pub async fn add_to_call_history(&self, entry: &UserCallHistoryEntry) -> Result<()> {
        self.session
            .query_unpaged(
                r#"
                INSERT INTO guardyn_calls.user_call_history 
                (user_id, started_at, call_id, call_type, is_group_call, group_id, 
                 other_user_id, other_user_name, is_outgoing, end_reason, duration_seconds)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                "#,
                (
                    &entry.user_id,
                    entry.started_at.timestamp_millis(),
                    &entry.call_id,
                    entry.call_type,
                    entry.is_group_call,
                    &entry.group_id,
                    &entry.other_user_id,
                    &entry.other_user_name,
                    entry.is_outgoing,
                    entry.end_reason,
                    entry.duration_seconds,
                ),
            )
            .await
            .context("Failed to add to call history")?;

        Ok(())
    }

    /// Get user's call history with cursor-based pagination
    ///
    /// The cursor is a timestamp (millis) - returns calls older than this timestamp
    #[allow(clippy::type_complexity)]
    pub async fn get_call_history(
        &self,
        user_id: &str,
        limit: i32,
        before_timestamp: Option<i64>,
    ) -> Result<Vec<UserCallHistoryEntry>> {
        let result = if let Some(ts) = before_timestamp {
            // Query with cursor - get calls older than the given timestamp
            self.session
                .query_unpaged(
                    r#"
                    SELECT user_id, started_at, call_id, call_type, is_group_call, group_id,
                           other_user_id, other_user_name, is_outgoing, end_reason, duration_seconds
                    FROM guardyn_calls.user_call_history
                    WHERE user_id = ? AND started_at < ?
                    LIMIT ?
                    "#,
                    (user_id, ts, limit),
                )
                .await
                .context("Failed to get call history with cursor")?
        } else {
            // Query without cursor - get most recent calls
            self.session
                .query_unpaged(
                    r#"
                    SELECT user_id, started_at, call_id, call_type, is_group_call, group_id,
                           other_user_id, other_user_name, is_outgoing, end_reason, duration_seconds
                    FROM guardyn_calls.user_call_history
                    WHERE user_id = ?
                    LIMIT ?
                    "#,
                    (user_id, limit),
                )
                .await
                .context("Failed to get call history")?
        };

        let mut history = Vec::new();
        if let Some(rows) = result.rows {
            for row in rows {
                let (
                    user_id,
                    started_at,
                    call_id,
                    call_type,
                    is_group_call,
                    group_id,
                    other_user_id,
                    other_user_name,
                    is_outgoing,
                    end_reason,
                    duration_seconds,
                ): (
                    String,
                    i64,
                    String,
                    i32,
                    bool,
                    Option<String>,
                    Option<String>,
                    Option<String>,
                    bool,
                    i32,
                    i32,
                ) = row.into_typed().context("Failed to parse history row")?;

                history.push(UserCallHistoryEntry {
                    user_id,
                    call_id,
                    call_type,
                    is_group_call,
                    group_id,
                    other_user_id,
                    other_user_name,
                    is_outgoing,
                    end_reason,
                    started_at: DateTime::from_timestamp_millis(started_at).unwrap_or_default(),
                    duration_seconds,
                });
            }
        }

        Ok(history)
    }
}
