//! Build script for Guardyn Desktop
//!
//! Compiles Protocol Buffers and builds Tauri application.

use std::io::Result;
use std::path::Path;

fn main() -> Result<()> {
    // Build Tauri
    tauri_build::build();

    // Compile Protocol Buffers for gRPC client
    let proto_root = "../../backend/proto";

    // Check if proto directory exists
    if !Path::new(proto_root).exists() {
        println!("cargo:warning=Proto directory not found at {}, skipping proto compilation", proto_root);
        return Ok(());
    }

    println!("cargo:rerun-if-changed={}", proto_root);

    // Create output directory
    let out_dir = "src/proto";
    std::fs::create_dir_all(out_dir)?;

    tonic_build::configure()
        .build_server(false) // Client only
        .build_client(true)
        .out_dir(out_dir)
        .compile_protos(
            &[
                format!("{}/common.proto", proto_root),
                format!("{}/auth.proto", proto_root),
                format!("{}/messaging.proto", proto_root),
                format!("{}/presence.proto", proto_root),
                format!("{}/media.proto", proto_root),
                format!("{}/calls.proto", proto_root),
                format!("{}/notifications.proto", proto_root),
            ],
            &[proto_root],
        )?;

    Ok(())
}
