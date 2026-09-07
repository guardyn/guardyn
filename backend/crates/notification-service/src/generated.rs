//! The wire contract, compiled into `OUT_DIR` at build time.
//!
//! ADR-0008: no generated protobuf is committed. This module is only the shape the rest of
//! the crate already refers to - `generated::guardyn::notifications`, and so on - re-hung
//! over what `tonic::include_proto!` pulls out of `OUT_DIR`. Keeping the shape is what makes
//! the change to OUT_DIR invisible to every call site.

pub mod guardyn {
    pub mod notifications {
        tonic::include_proto!("guardyn.notifications");
    }

    #[allow(dead_code)]
    pub mod common {
        tonic::include_proto!("guardyn.common");
    }
}
