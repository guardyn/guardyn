pub mod add_group_member;
pub mod add_group_member_mls;
pub mod clear_chat;
pub mod create_group;
pub mod delete_group;
pub mod delete_message;
pub mod get_conversations;
pub mod get_group_by_id;
pub mod get_group_messages;
pub mod get_groups;
pub mod get_messages;
pub mod leave_group;
pub mod mark_as_read;
pub mod receive_messages;
pub mod receive_messages_e2ee;
pub mod remove_group_member;
pub mod send_group_message;
pub mod send_group_message_mls;
/// Message handlers for Messaging Service
pub mod send_message;
pub mod send_message_e2ee;
pub mod update_group;

// Phase 2: New feature handlers
pub mod disappearing_messages;
pub mod edit_message;
pub mod forward_message;
pub mod reactions;
pub mod read_receipts;
pub mod search_messages;

// Phase 3: User blocking and conversation deletion
pub mod block_user;
pub mod delete_conversation;
pub mod typing_indicator;

// Phase 4: Admin management
pub mod change_member_role;

pub use add_group_member::add_group_member;
pub use clear_chat::clear_chat;
pub use create_group::create_group;
pub use delete_group::delete_group;
pub use delete_message::delete_message;
pub use get_conversations::get_conversations;
pub use get_group_by_id::get_group_by_id;
pub use get_group_messages::get_group_messages;
pub use get_groups::get_groups;
pub use get_messages::get_messages;
pub use leave_group::leave_group;
pub use mark_as_read::mark_as_read;
pub use receive_messages::receive_messages;
pub use receive_messages_e2ee::receive_messages_e2ee;
pub use remove_group_member::remove_group_member;
pub use send_group_message::send_group_message;
pub use send_message::send_message;
pub use send_message_e2ee::send_message_e2ee;
pub use update_group::update_group;

// Phase 2: Re-exports
pub use disappearing_messages::{get_disappearing_config, set_disappearing_messages};
pub use edit_message::edit_message;
pub use forward_message::forward_message;
pub use reactions::{add_reaction, get_reactions, remove_reaction};
pub use read_receipts::{get_read_receipts, send_read_receipt};
pub use search_messages::{search_messages, SearchParams};

// Phase 3: Re-exports
pub use block_user::{block_user, get_blocked_users, unblock_user};
pub use delete_conversation::delete_conversation;
pub use typing_indicator::send_typing_indicator;

// Phase 4: Re-exports
pub use change_member_role::change_member_role;
