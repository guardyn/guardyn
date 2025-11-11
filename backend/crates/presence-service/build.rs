fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Compile Protocol Buffers for Presence Service

    // Get the manifest directory (workspace root)
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")?;
    let workspace_root = std::path::Path::new(&manifest_dir)
        .parent()
        .and_then(|p| p.parent())
        .ok_or("Cannot find workspace root")?;

    let proto_dir = workspace_root.join("proto");
    let common_proto = proto_dir.join("common.proto");
    let presence_proto = proto_dir.join("presence.proto");

    // Create generated directory if it doesn't exist
    let out_dir = std::path::Path::new(&manifest_dir).join("src/generated");
    std::fs::create_dir_all(&out_dir)?;

    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir(&out_dir)
        .compile_protos(
            &[common_proto.as_path(), presence_proto.as_path()],
            &[proto_dir.as_path()],
        )?;

    println!("cargo:rerun-if-changed={}", common_proto.display());
    println!("cargo:rerun-if-changed={}", presence_proto.display());
    println!("cargo:rerun-if-changed={}", proto_dir.display());

    Ok(())
}
