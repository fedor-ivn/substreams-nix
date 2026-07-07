# Substreams Development Template

Complete development environment for Substreams with Rust, Protocol Buffers, and PostgreSQL.

## Quick Start

```bash
nix flake init -t github:fedor-ivn/substreams-nix#default
nix develop
substreams init
```

## Included Tools

| Tool | Version |
|------|---------|
| Rust | stable + `wasm32-unknown-unknown` target |
| rust-analyzer | LSP support |
| protoc | Protocol Buffers compiler |
| buf | Protobuf linter |
| protoc-gen-prost | Rust codegen |
| toml-cli | TOML utilities |
| Node.js | 20 LTS |
| PostgreSQL | Client + libraries |
| substreams | Latest CLI |

## Customize

**Add build tools** (gcc, make, pkg-config):
```nix
buildInputs = [ pkgs.gcc pkgs.gnumake pkgs.pkg-config ];
```

**Change Rust version**:
```nix
rustToolchain = pkgs.rust-bin.stable."1.75.0".default.override {
  extensions = [ "rust-analyzer" "rust-src" ];
  targets = [ "wasm32-unknown-unknown" ];
};
```

## Update Template Reference

After initializing, update `flake.nix` to use the published template:

```nix
inputs.substreams-nix.url = "github:fedor-ivn/substreams-nix";
```
