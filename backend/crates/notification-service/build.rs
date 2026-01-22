fn main() -> Result<(), Box<dyn std::error::Error>> {
    let proto_root = "../../proto";

    tonic_build::configure()
        .build_server(true)
        .build_client(true)
        .out_dir("src/generated")
        .compile_protos(
            &[
                &format!("{}/notifications.proto", proto_root),
                &format!("{}/common.proto", proto_root),
            ],
            &[proto_root],
        )?;

    println!("cargo:rerun-if-changed={}/notifications.proto", proto_root);
    println!("cargo:rerun-if-changed={}/common.proto", proto_root);

    Ok(())
}
