fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Compile Protocol Buffers for Auth Service
    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir("src/generated")
        .compile(
            &[
                "../proto/common.proto",
                "../proto/auth.proto",
            ],
            &["../proto"],
        )?;

    println!("cargo:rerun-if-changed=../proto/common.proto");
    println!("cargo:rerun-if-changed=../proto/auth.proto");

    Ok(())
}
