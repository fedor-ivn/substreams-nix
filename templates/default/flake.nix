{
  description = "Substreams development environment template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    naersk.url = "github:nix-community/naersk/master";
    substreams-nix.url = "github:fedor-ivn/substreams-nix";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, naersk, substreams-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-analyzer" "rust-src" ];
          targets = [ "wasm32-unknown-unknown" ];
        };

        naersk-lib = pkgs.callPackage naersk {
          cargo = rustToolchain;
          rustc = rustToolchain;
        };
      in
      {
        packages.default = naersk-lib.buildPackage {
          src = ./.;
          CARGO_BUILD_TARGET = "wasm32-unknown-unknown";
        };

        devShells.default = pkgs.mkShell {
          name = "substreams-dev";

          buildInputs = [
            rustToolchain

            pkgs.protobuf
            pkgs.protoc-gen-prost
            pkgs.buf

            pkgs.toml-cli
            pkgs.nodejs_22
            pkgs.postgresql

            substreams-nix.packages.${system}.default

            pkgs.jq
            pkgs.curl
          ];

          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
        };
      }
    );
}
