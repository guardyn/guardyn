/// Presence Service Handlers
///
/// Contains all gRPC handler implementations for the presence service

mod update_status;
mod get_status;
mod get_bulk_status;
mod update_last_seen;
mod set_typing;
mod subscribe;

pub use update_status::handle_update_status;
pub use get_status::handle_get_status;
pub use get_bulk_status::handle_get_bulk_status;
pub use update_last_seen::handle_update_last_seen;
pub use set_typing::handle_set_typing;
pub use subscribe::handle_subscribe;
