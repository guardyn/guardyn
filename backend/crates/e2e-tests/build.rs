fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Get workspace root
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")?;
    let workspace_root = std::path::Path::new(&manifest_dir)
        .parent()
        .and_then(|p| p.parent())
        .ok_or("Cannot find workspace root")?;
    
    let proto_dir = workspace_root.join("proto");
    let common_proto = proto_dir.join("common.proto");
    let auth_proto = proto_dir.join("auth.proto");
    let messaging_proto = proto_dir.join("messaging.proto");

    // Compile proto files for tests
    tonic_build::configure()
        .build_server(false) // We only need client code for tests
        .compile_protos(
            &[
                auth_proto.as_path(),
                messaging_proto.as_path(),
                common_proto.as_path(),
            ],
            &[proto_dir.as_path()],
        )?;
    
    println!("cargo:rerun-if-changed={}", common_proto.display());
    println!("cargo:rerun-if-changed={}", auth_proto.display());
    println!("cargo:rerun-if-changed={}", messaging_proto.display());
    
    Ok(())
}
