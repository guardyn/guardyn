//! The wire contract, compiled into `OUT_DIR` at build time.
//!
//! ADR-0008: no generated protobuf is committed. This module is only the shape the rest of
//! the crate already refers to - `generated::guardyn::calls`, and so on - re-hung over what
//! `tonic::include_proto!` pulls out of `OUT_DIR`. Keeping the shape is what makes the
//! change to OUT_DIR invisible to every call site.

pub mod guardyn {
    #[allow(dead_code, clippy::large_enum_variant, clippy::enum_variant_names)]
    pub mod auth {
        tonic::include_proto!("guardyn.auth");
    }

    #[allow(dead_code, clippy::large_enum_variant, clippy::enum_variant_names)]
    pub mod calls {
        tonic::include_proto!("guardyn.calls");
    }

    #[allow(dead_code, clippy::large_enum_variant, clippy::enum_variant_names)]
    pub mod common {
        tonic::include_proto!("guardyn.common");
    }
}
