fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Compile proto files for tests
    tonic_build::configure()
        .build_server(false) // We only need client code for tests
        .compile(
            &[
                "../../proto/auth.proto",
                "../../proto/messaging.proto",
                "../../proto/common.proto",
            ],
            &["../../proto"],
        )?;
    Ok(())
}
