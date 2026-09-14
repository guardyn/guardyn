//! The wire contract, compiled into `OUT_DIR` at build time.
//!
//! ADR-0008: no generated protobuf is committed. This module is only the shape the rest of
//! the crate already refers to - `crate::proto::messaging`, and so on - re-hung over what
//! `tonic::include_proto!` pulls out of `OUT_DIR`. Keeping the shape is what makes the
//! change to OUT_DIR invisible to every call site.

pub mod guardyn {
    pub mod common {
        tonic::include_proto!("guardyn.common");
    }

    pub mod auth {
        tonic::include_proto!("guardyn.auth");
    }

    pub mod messaging {
        tonic::include_proto!("guardyn.messaging");
    }

    pub mod presence {
        tonic::include_proto!("guardyn.presence");
    }

    pub mod media {
        tonic::include_proto!("guardyn.media");
    }

    pub mod calls {
        tonic::include_proto!("guardyn.calls");
    }

    pub mod notifications {
        tonic::include_proto!("guardyn.notifications");
    }
}

// Re-exports for convenience
pub use guardyn::auth;
pub use guardyn::calls;
pub use guardyn::common;
pub use guardyn::media;
pub use guardyn::messaging;
pub use guardyn::notifications;
pub use guardyn::presence;
