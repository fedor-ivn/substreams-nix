# Substreams Nix

Nix packages for [Substreams](https://substreams.dev) and its official sinks.

## Packages

| Flake output              | Description                                              | Upstream                                                                  |
| ------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------- |
| `substreams` (`default`)  | Substreams CLI — stream processing engine for blockchain data | [streamingfast/substreams](https://github.com/streamingfast/substreams)           |
| `substreams-sink-sql`     | Sync Substreams data into PostgreSQL / ClickHouse       | [streamingfast/substreams-sink-sql](https://github.com/streamingfast/substreams-sink-sql)     |
| `substreams-sink-files`   | Sync Substreams data into flat files (CSV, JSONL, Parquet) | [streamingfast/substreams-sink-files](https://github.com/streamingfast/substreams-sink-files) |

Build any of them with `nix build .#<output>`, e.g. `nix build .#substreams-sink-sql`.

## Usage

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    substreams.url = "github:fedor-ivn/substreams-nix";
  };

  outputs = { nixpkgs, substreams, ... }: {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = [
        substreams.packages.x86_64-linux.substreams
        substreams.packages.x86_64-linux.substreams-sink-sql
        substreams.packages.x86_64-linux.substreams-sink-files
      ];
    };
  };
}
```

```bash
nix develop
substreams --version
```

## Template

For a complete Substreams development environment with Rust, protobuf, and tooling:

```bash
nix flake init -t github:fedor-ivn/substreams-nix#default
nix develop
```

See [`templates/default/README.md`](templates/default/README.md) for details.

## Supported Platforms

- Linux: `x86_64`, `aarch64`
- macOS: `x86_64`, `aarch64`

## Update Packages

Packages are updated automatically by a daily GitHub Actions workflow. To update
one manually:

```bash
nix run github:Mic92/nix-update -- --flake .#substreams --format
nix run github:Mic92/nix-update -- --flake .#substreams-sink-sql --format
nix run github:Mic92/nix-update -- --flake .#substreams-sink-files --format
```
