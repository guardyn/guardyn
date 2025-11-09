fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Compile Protocol Buffers for Messaging Service
    // Support both local builds (../../proto) and Docker builds (proto/)
    let proto_dir = if std::path::Path::new("../../proto").exists() {
        "../../proto"
    } else {
        "proto"
    };
    
    let common_proto = format!("{}/common.proto", proto_dir);
    let messaging_proto = format!("{}/messaging.proto", proto_dir);
    
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir("src/generated")
        .compile(
            &[&common_proto, &messaging_proto],
            &[proto_dir],
        )?;

    println!("cargo:rerun-if-changed={}", common_proto);
    println!("cargo:rerun-if-changed={}", messaging_proto);
    println!("cargo:rerun-if-changed={}", proto_dir);

    Ok(())
}
