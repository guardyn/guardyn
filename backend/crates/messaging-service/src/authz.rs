//! Authorization for conversation-scoped and message-scoped reads.
//!
//! Three read handlers validated the caller's access token and then returned another
//! conversation's data to whoever asked (#172). The decision they were missing lives here
//! rather than inline in each handler, because it has to be testable: [`DatabaseClient`]
//! has private fields and one constructor that dials TiKV and ScyllaDB, so no test can
//! build one. [`ConversationAccess`] is the seam - deliberately two methods wide, not an
//! abstraction over the database.

use crate::db::DatabaseClient;
use crate::proto::common::{error_response::ErrorCode, ErrorResponse};
use tracing::error;

/// The two lookups an authorization decision needs.
///
/// **This trait must not become effectively public.** An `async fn` in a trait is accepted
/// here only because the trait stays crate-local. Making `mod authz` public, or hoisting
/// this to the crate root, trips rustc's `async_fn_in_trait` lint, which CI turns into a
/// build failure through `cargo clippy -- -D warnings`.
pub trait ConversationAccess {
    /// Whether `user_id` participates in `conversation_id`.
    async fn conversation_has_member(
        &self,
        conversation_id: &str,
        user_id: &str,
        is_group: bool,
    ) -> anyhow::Result<bool>;

    /// Whether `message_id` is stored under `conversation_id`.
    ///
    /// A message that does not exist and a message belonging to some other conversation
    /// both answer `false`. Collapsing the two is deliberate: telling them apart would
    /// hand the caller an existence oracle over messages it may not read.
    //
    // Unused until `authorize_message_read` stops trusting membership alone. The allow
    // comes off in the commit that calls it.
    #[allow(dead_code)]
    async fn message_is_in_conversation(
        &self,
        message_id: &str,
        conversation_id: &str,
        is_group: bool,
    ) -> anyhow::Result<bool>;
}

/// Why an authorization check refused a read.
//
// `NotAMember` and `WrongConversation` are unconstructed until the checks below stop
// discarding their lookups. The allow comes off in the same commit that constructs them,
// and its presence here marks the #172 defect rather than papering over it.
#[allow(dead_code)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Denial {
    /// The caller does not participate in the conversation.
    NotAMember,
    /// The message is not stored under the named conversation, or does not exist.
    WrongConversation,
    /// A lookup failed, so no decision could be reached. Fail closed.
    LookupFailed,
}

impl Denial {
    /// The wire error a refused read returns.
    ///
    /// `NotAMember` and `WrongConversation` are deliberately indistinguishable on the
    /// wire. A caller who is told "you are a member, but that message is not here" learns
    /// where a message it cannot read does not live, which is the same existence oracle
    /// [`ConversationAccess::message_is_in_conversation`] refuses to expose.
    pub fn to_error_response(self) -> ErrorResponse {
        match self {
            Denial::NotAMember | Denial::WrongConversation => ErrorResponse {
                code: ErrorCode::Forbidden as i32,
                message: "User is not a member of this conversation".to_string(),
                details: Default::default(),
            },
            Denial::LookupFailed => ErrorResponse {
                code: ErrorCode::InternalError as i32,
                message: "Failed to verify conversation membership".to_string(),
                details: Default::default(),
            },
        }
    }
}

/// Authorize a read scoped to an entire conversation.
///
/// Used by the handlers whose query is partitioned by `conversation_id`, so that
/// establishing membership is sufficient to bound what they return.
pub async fn authorize_conversation_read<A: ConversationAccess>(
    access: &A,
    conversation_id: &str,
    user_id: &str,
    is_group: bool,
) -> Result<(), Denial> {
    // #172, stated in code: the lookup runs and its answer is discarded, which is exactly
    // what the three getters did by never reading `_claims`. The next commit stops
    // discarding it.
    access
        .conversation_has_member(conversation_id, user_id, is_group)
        .await
        .map_err(|e| {
            error!("Failed to verify conversation membership: {}", e);
            Denial::LookupFailed
        })?;
    Ok(())
}

/// Authorize a read scoped to one message inside a conversation.
///
/// Membership is checked first and short-circuits, so a caller outside the conversation
/// never reaches the message lookup and cannot use it as an existence oracle.
pub async fn authorize_message_read<A: ConversationAccess>(
    access: &A,
    message_id: &str,
    conversation_id: &str,
    user_id: &str,
    is_group: bool,
) -> Result<(), Denial> {
    // #172, stated in code. See `authorize_conversation_read`.
    let _ = message_id;
    access
        .conversation_has_member(conversation_id, user_id, is_group)
        .await
        .map_err(|e| {
            error!("Failed to verify conversation membership: {}", e);
            Denial::LookupFailed
        })?;
    Ok(())
}

impl ConversationAccess for DatabaseClient {
    async fn conversation_has_member(
        &self,
        conversation_id: &str,
        user_id: &str,
        is_group: bool,
    ) -> anyhow::Result<bool> {
        // Spelled out rather than `self.is_conversation_member(..)`: the inherent method
        // would win name resolution anyway, but the explicit form cannot be misread as a
        // recursive call into this trait method.
        DatabaseClient::is_conversation_member(self, conversation_id, user_id, is_group).await
    }

    async fn message_is_in_conversation(
        &self,
        message_id: &str,
        conversation_id: &str,
        is_group: bool,
    ) -> anyhow::Result<bool> {
        // `get_message_owner` reads `guardyn.{messages,group_messages}` on the full
        // primary key `(conversation_id, message_id)`, so this is a point read. It is
        // also the only authoritative record of where a message lives - see the PR body
        // on why `guardyn.reactions.conversation_id` cannot be trusted for this.
        Ok(
            DatabaseClient::get_message_owner(self, message_id, conversation_id, is_group)
                .await?
                .is_some(),
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::cell::Cell;
    use std::collections::{HashMap, HashSet};

    /// In-memory stand-in for the database.
    #[derive(Default)]
    struct FakeAccess {
        /// `(conversation_id, user_id, is_group)` triples that are members.
        members: HashSet<(String, String, bool)>,
        /// `message_id` to the conversation it is stored under.
        messages: HashMap<String, String>,
        membership_fails: bool,
        message_lookup_fails: bool,
        /// How many times the message lookup was consulted.
        message_lookups: Cell<u32>,
    }

    impl FakeAccess {
        fn new() -> Self {
            Self::default()
        }

        fn with_member(mut self, conversation_id: &str, user_id: &str, is_group: bool) -> Self {
            self.members
                .insert((conversation_id.to_string(), user_id.to_string(), is_group));
            self
        }

        fn with_message(mut self, message_id: &str, conversation_id: &str) -> Self {
            self.messages
                .insert(message_id.to_string(), conversation_id.to_string());
            self
        }

        fn failing_membership(mut self) -> Self {
            self.membership_fails = true;
            self
        }

        fn failing_message_lookup(mut self) -> Self {
            self.message_lookup_fails = true;
            self
        }
    }

    impl ConversationAccess for FakeAccess {
        async fn conversation_has_member(
            &self,
            conversation_id: &str,
            user_id: &str,
            is_group: bool,
        ) -> anyhow::Result<bool> {
            if self.membership_fails {
                anyhow::bail!("membership lookup unavailable");
            }
            Ok(self
                .members
                .contains(&(conversation_id.to_string(), user_id.to_string(), is_group)))
        }

        async fn message_is_in_conversation(
            &self,
            message_id: &str,
            conversation_id: &str,
            _is_group: bool,
        ) -> anyhow::Result<bool> {
            self.message_lookups.set(self.message_lookups.get() + 1);
            if self.message_lookup_fails {
                anyhow::bail!("message lookup unavailable");
            }
            Ok(self.messages.get(message_id).map(String::as_str) == Some(conversation_id))
        }
    }

    #[tokio::test]
    async fn member_may_read_own_conversation() {
        let access = FakeAccess::new().with_member("conv-a", "alice", false);
        assert_eq!(
            authorize_conversation_read(&access, "conv-a", "alice", false).await,
            Ok(())
        );
    }

    #[tokio::test]
    async fn non_member_is_denied_conversation_read() {
        let access = FakeAccess::new().with_member("conv-a", "alice", false);
        assert_eq!(
            authorize_conversation_read(&access, "conv-a", "mallory", false).await,
            Err(Denial::NotAMember)
        );
    }

    #[tokio::test]
    async fn membership_lookup_failure_denies() {
        let access = FakeAccess::new()
            .with_member("conv-a", "alice", false)
            .failing_membership();
        assert_eq!(
            authorize_conversation_read(&access, "conv-a", "alice", false).await,
            Err(Denial::LookupFailed),
            "an unavailable lookup must fail closed, never fall through to Allow"
        );
    }

    #[tokio::test]
    async fn member_may_read_a_message_in_own_conversation() {
        let access = FakeAccess::new()
            .with_member("conv-a", "alice", false)
            .with_message("msg-1", "conv-a");
        assert_eq!(
            authorize_message_read(&access, "msg-1", "conv-a", "alice", false).await,
            Ok(())
        );
    }

    /// The #172 regression test.
    ///
    /// `db.get_reactions` ignores its `conversation_id` and queries `WHERE message_id = ?`,
    /// so a membership check alone leaves the hole open: a member of A names A, passes the
    /// check, and reads a message from B.
    #[tokio::test]
    async fn member_of_one_conversation_cannot_read_a_message_from_another() {
        let access = FakeAccess::new()
            .with_member("conv-a", "alice", false)
            .with_message("msg-in-b", "conv-b");
        assert_eq!(
            authorize_message_read(&access, "msg-in-b", "conv-a", "alice", false).await,
            Err(Denial::WrongConversation)
        );
    }

    #[tokio::test]
    async fn non_member_is_denied_before_the_message_lookup() {
        let access = FakeAccess::new()
            .with_member("conv-a", "alice", false)
            .with_message("msg-1", "conv-a");
        assert_eq!(
            authorize_message_read(&access, "msg-1", "conv-a", "mallory", false).await,
            Err(Denial::NotAMember)
        );
        assert_eq!(
            access.message_lookups.get(),
            0,
            "a non-member must not reach the message lookup, or it becomes an existence oracle"
        );
    }

    #[tokio::test]
    async fn message_lookup_failure_denies() {
        let access = FakeAccess::new()
            .with_member("conv-a", "alice", false)
            .with_message("msg-1", "conv-a")
            .failing_message_lookup();
        assert_eq!(
            authorize_message_read(&access, "msg-1", "conv-a", "alice", false).await,
            Err(Denial::LookupFailed)
        );
    }

    #[tokio::test]
    async fn unknown_message_is_indistinguishable_from_a_foreign_one() {
        let access = FakeAccess::new()
            .with_member("conv-a", "alice", false)
            .with_message("msg-in-b", "conv-b");

        let foreign = authorize_message_read(&access, "msg-in-b", "conv-a", "alice", false).await;
        let unknown =
            authorize_message_read(&access, "msg-nowhere", "conv-a", "alice", false).await;
        assert_eq!(foreign, unknown);

        let non_member =
            authorize_message_read(&access, "msg-in-b", "conv-a", "mallory", false).await;
        assert_eq!(
            foreign.unwrap_err().to_error_response(),
            non_member.unwrap_err().to_error_response(),
            "every refusal must look the same on the wire"
        );
    }

    #[tokio::test]
    async fn is_group_is_forwarded_unchanged() {
        let access = FakeAccess::new().with_member("group-a", "alice", true);
        assert_eq!(
            authorize_conversation_read(&access, "group-a", "alice", true).await,
            Ok(())
        );
        assert_eq!(
            authorize_conversation_read(&access, "group-a", "alice", false).await,
            Err(Denial::NotAMember),
            "is_group selects which table membership is read from; it must not be hardcoded"
        );
    }

    #[test]
    fn denials_map_to_forbidden_and_lookup_failures_to_internal_error() {
        assert_eq!(
            Denial::NotAMember.to_error_response().code,
            ErrorCode::Forbidden as i32
        );
        assert_eq!(
            Denial::WrongConversation.to_error_response().code,
            ErrorCode::Forbidden as i32
        );
        assert_eq!(
            Denial::LookupFailed.to_error_response().code,
            ErrorCode::InternalError as i32
        );
    }
}
