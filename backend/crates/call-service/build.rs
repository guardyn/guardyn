//! Compile the wire contract into `OUT_DIR`.
//!
//! ADR-0008: no generated protobuf is committed. `tonic_build` writes into `OUT_DIR` and
//! `tonic::include_proto!` picks it up, so `backend/proto/*.proto` is the only editable
//! artefact and drift between contract and code is structurally impossible.

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // The proto directory moves with the build context: a workspace build sees
    // `backend/proto`, the Docker image sees `./proto` at its root.
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")?;
    let workspace_root = std::path::Path::new(&manifest_dir)
        .parent() // crates/
        .and_then(|p| p.parent()) // backend/
        .ok_or("cannot locate the workspace root")?;

    let candidates = [
        workspace_root.join("proto"),
        std::path::PathBuf::from("./proto"),
        std::path::PathBuf::from("../../proto"),
    ];
    let proto_dir = candidates
        .iter()
        .find(|p| p.join("common.proto").exists())
        .ok_or("no proto directory found: tried backend/proto, ./proto, ../../proto")?;

    let protos: Vec<std::path::PathBuf> = ["common.proto", "auth.proto", "calls.proto"]
        .iter()
        .map(|f| proto_dir.join(f))
        .collect();

    // Deliberately no .out_dir(): tonic_build then defaults to OUT_DIR. See ADR-0008.
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .compile_protos(&protos, &[proto_dir])?;

    for proto in &protos {
        println!("cargo:rerun-if-changed={}", proto.display());
    }
    println!("cargo:rerun-if-changed={}", proto_dir.display());

    Ok(())
}
