fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Compile Protocol Buffers for Auth Service
    let proto_dir = std::path::Path::new("../../proto");
    
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir("src/generated")
        .compile(
            &[
                "../../proto/common.proto",
                "../../proto/auth.proto",
            ],
            &[proto_dir],
        )?;

    println!("cargo:rerun-if-changed=../../proto/common.proto");
    println!("cargo:rerun-if-changed=../../proto/auth.proto");
    println!("cargo:rerun-if-changed=../../proto");

    Ok(())
}
