{
  description = "Guardyn3 MVP reproducible environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
      in {
        devShells.default = pkgs.mkShell {
          name = "guardyn3-dev";
          nativeBuildInputs = with pkgs; [
            pkg-config
            openssl
            protobuf
            protoc-gen-go
            rust-bin.stable.latest.default
            rust-analyzer
            cargo
            cargo-audit
            cargo-deny
            wasm-pack
            nodejs_20
            kubectl
            kustomize
            helm
            just
            sops
            age
            k3d
            cosign
            trivy
            syft
          ];
          RUSTFLAGS = "-C opt-level=z";
        };
      }
    );
}
