fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Compile Protocol Buffers for Media Service
    
    // Get the manifest directory (workspace root)
    let manifest_dir = std::env::var("CARGO_MANIFEST_DIR")?;
    let workspace_root = std::path::Path::new(&manifest_dir)
        .parent()
        .and_then(|p| p.parent())
        .ok_or("Cannot find workspace root")?;
    
    let proto_dir = workspace_root.join("proto");
    let common_proto = proto_dir.join("common.proto");
    let media_proto = proto_dir.join("media.proto");
    
    // Create generated directory if it doesn't exist
    let out_dir = std::path::Path::new(&manifest_dir).join("src/generated");
    std::fs::create_dir_all(&out_dir)?;
    
    println!("cargo:warning=Out dir: {:?}", out_dir);
    println!("cargo:warning=Proto files: {:?}, {:?}", common_proto, media_proto);
    
    // Compile with explicit paths
    let result = tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir(&out_dir)
        .compile_protos(
            &[
                common_proto.to_str().unwrap(),
                media_proto.to_str().unwrap(),
            ],
            &[proto_dir.to_str().unwrap()],
        );
    
    if let Err(e) = result {
        println!("cargo:warning=tonic_build error: {:?}", e);
        return Err(e.into());
    }

    println!("cargo:warning=tonic_build succeeded!");
    println!("cargo:rerun-if-changed={}", common_proto.display());
    println!("cargo:rerun-if-changed={}", media_proto.display());
    println!("cargo:rerun-if-changed={}", proto_dir.display());

    Ok(())
}
