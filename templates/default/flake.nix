{
  description = "Substreams development environment template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    substreams-nix.url = "github:fedor-ivn/substreams-nix";
  };

  outputs = { self, nixpkgs, flake-utils, substreams-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Rust toolchain with wasm32 target and rust-analyzer
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-analyzer" "rust-src" ];
          targets = [ "wasm32-unknown-unknown" ];
        };

        # Protobuf compiler with prost plugins
        protobuf = pkgs.protobuf;
        protoc-gen-prost = pkgs.buildRustPackage rec {
          pname = "protoc-gen-prost";
          version = "0.3.0";
          src = pkgs.fetchFromGitHub {
            owner = "tokio-rs";
            repo = "prost";
            rev = "v${version}";
            hash = "sha256-8fKFLmYbXvBdRfRzYKbLg8VqQZ3j2K1F4mN5pO6rS7tU=";
          };
          cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          subPackages = [ "protoc-gen-prost" "protoc-gen-prost-crate" ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "substreams-dev";

          buildInputs = [
            # Rust development
            rustToolchain

            # Protocol Buffers
            protobuf
            protoc-gen-prost
            pkgs.buf

            # TOML processing
            pkgs.toml-cli

            # Node.js for graph-cli and other tooling
            pkgs.nodejs_20

            # PostgreSQL client
            pkgs.postgresql

            # Substreams CLI from the substreams-nix flake
            substreams-nix.packages.${system}.default

            # Basic utilities
            pkgs.jq
            pkgs.curl
          ];

          shellHook = ''
            echo "Substreams development environment loaded!"
            echo ""
            echo "Available tools:"
            echo "  - Rust (stable) with wasm32-unknown-unknown target"
            echo "  - rust-analyzer for IDE support"
            echo "  - protoc, buf (Protocol Buffers)"
            echo "  - toml-cli"
            echo "  - Node.js ${pkgs.nodejs_20.version}"
            echo "  - PostgreSQL client"
            echo "  - substreams CLI"
            echo ""
            echo "To get started:"
            echo "  substreams init"
            echo ""
          '';

          # Note: If you need build tools (gcc, make, pkg-config, libclang),
          # add them to buildInputs above:
          #   pkgs.gcc pkgs.gnumake pkgs.pkg-config pkgs.libclang
        };
      }
    );
}
