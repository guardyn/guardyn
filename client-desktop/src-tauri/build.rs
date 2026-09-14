//! Build script for Guardyn Desktop.
//!
//! Builds the Tauri application and compiles the wire contract into `OUT_DIR`.
//!
//! ADR-0008: no generated protobuf is committed. `tonic_build` writes into `OUT_DIR` and
//! `tonic::include_proto!` picks it up, so `backend/proto/*.proto` is the only editable
//! artefact and drift between contract and code is structurally impossible.

fn main() -> Result<(), Box<dyn std::error::Error>> {
    tauri_build::build();

    // Anchored on CARGO_MANIFEST_DIR rather than the build script's working directory, so
    // the contract is found the same way whichever directory cargo was invoked from.
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")?;
    let proto_dir = std::path::Path::new(&manifest_dir)
        .parent() // client-desktop/
        .and_then(|p| p.parent()) // repository root
        .ok_or("cannot locate the repository root")?
        .join("backend/proto");

    // A missing contract is a hard error. This used to emit cargo:warning and skip codegen,
    // which was survivable only while a committed copy sat in the tree as a fallback. Under
    // OUT_DIR a skip surfaces as a missing include, which says nothing about the cause.
    if !proto_dir.join("common.proto").exists() {
        return Err(format!("no proto directory at {}", proto_dir.display()).into());
    }

    let protos: Vec<std::path::PathBuf> = [
        "common.proto",
        "auth.proto",
        "messaging.proto",
        "presence.proto",
        "media.proto",
        "calls.proto",
        "notifications.proto",
    ]
    .iter()
    .map(|f| proto_dir.join(f))
    .collect();

    // Deliberately no .out_dir(): tonic_build then defaults to OUT_DIR. See ADR-0008.
    tonic_build::configure()
        .build_server(false) // Client only
        .build_client(true)
        .compile_protos(&protos, &[&proto_dir])?;

    for proto in &protos {
        println!("cargo:rerun-if-changed={}", proto.display());
    }
    println!("cargo:rerun-if-changed={}", proto_dir.display());

    Ok(())
}
