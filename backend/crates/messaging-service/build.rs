fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Compile Protocol Buffers for Messaging Service
    // Support multiple build contexts:
    // 1. Local build from crate dir: ../../proto
    // 2. Local build from workspace root: proto (relative to CARGO_MANIFEST_DIR)
    // 3. Docker build: ./proto (relative to workspace root)

    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")
        .expect("CARGO_MANIFEST_DIR not set");
    let workspace_root = std::path::Path::new(&manifest_dir)
        .parent() // crates/
        .and_then(|p| p.parent()) // backend/
        .expect("Failed to find workspace root");

    // Try multiple potential proto locations
    let proto_paths = vec![
        workspace_root.join("proto"),           // backend/proto/ (most common)
        std::path::PathBuf::from("./proto"),    // Docker: /app/proto/
        std::path::PathBuf::from("../../proto"), // Fallback
    ];

    let proto_dir = proto_paths
        .iter()
        .find(|p| p.exists() && p.join("common.proto").exists())
        .expect("Proto directory not found! Searched: backend/proto, ./proto, ../../proto");

    let common_proto = proto_dir.join("common.proto");
    let messaging_proto = proto_dir.join("messaging.proto");

    // Don't specify out_dir - let tonic_build use default OUT_DIR
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .compile(
            &[common_proto.to_str().unwrap(), messaging_proto.to_str().unwrap()],
            &[proto_dir.to_str().unwrap()],
        )?;

    println!("cargo:rerun-if-changed={}", common_proto.display());
    println!("cargo:rerun-if-changed={}", messaging_proto.display());
    println!("cargo:rerun-if-changed={}", proto_dir.display());

    Ok(())
}
