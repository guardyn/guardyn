/// Message handlers for Messaging Service
pub mod send_message;
pub mod send_message_e2ee;
pub mod get_messages;
pub mod get_conversations;
pub mod mark_as_read;
pub mod delete_message;
pub mod clear_chat;
pub mod receive_messages;
pub mod receive_messages_e2ee;
pub mod create_group;
pub mod add_group_member;
pub mod add_group_member_mls;
pub mod remove_group_member;
pub mod send_group_message;
pub mod send_group_message_mls;
pub mod get_group_messages;
pub mod get_groups;
pub mod get_group_by_id;
pub mod update_group;
pub mod leave_group;

// Phase 2: New feature handlers
pub mod reactions;
pub mod read_receipts;
pub mod forward_message;
pub mod edit_message;
pub mod search_messages;
pub mod disappearing_messages;

// Phase 3: User blocking and conversation deletion
pub mod block_user;
pub mod delete_conversation;
pub mod typing_indicator;

pub use send_message::send_message;
pub use send_message_e2ee::send_message_e2ee;
pub use get_messages::get_messages;
pub use get_conversations::get_conversations;
pub use mark_as_read::mark_as_read;
pub use delete_message::delete_message;
pub use clear_chat::clear_chat;
pub use receive_messages::receive_messages;
pub use receive_messages_e2ee::receive_messages_e2ee;
pub use create_group::create_group;
pub use add_group_member::add_group_member;
pub use add_group_member_mls::add_group_member_mls;
pub use remove_group_member::remove_group_member;
pub use send_group_message::send_group_message;
pub use send_group_message_mls::send_group_message_mls;
pub use get_group_messages::get_group_messages;
pub use get_groups::get_groups;
pub use get_group_by_id::get_group_by_id;
pub use update_group::update_group;
pub use leave_group::leave_group;

// Phase 2: Re-exports
pub use reactions::{add_reaction, remove_reaction, get_reactions};
pub use read_receipts::{send_read_receipt, get_read_receipts};
pub use forward_message::forward_message;
pub use edit_message::edit_message;
pub use search_messages::{search_messages, SearchParams};
pub use disappearing_messages::{set_disappearing_messages, get_disappearing_config};

// Phase 3: Re-exports
pub use block_user::{block_user, unblock_user, get_blocked_users};
pub use delete_conversation::delete_conversation;
pub use typing_indicator::send_typing_indicator;

