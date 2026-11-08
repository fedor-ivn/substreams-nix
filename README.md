# Substreams Nix

Nix packages for [Substreams](https://substreams.dev) and its official sinks.

## Packages

| Flake output              | Description                                              | Upstream                                                                  |
| ------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------- |
| `substreams` (`default`)  | Substreams CLI — stream processing engine for blockchain data | [streamingfast/substreams](https://github.com/streamingfast/substreams)           |
| `substreams-sink-files`   | Sync Substreams data into flat files (CSV, JSONL, Parquet) | [streamingfast/substreams-sink-files](https://github.com/streamingfast/substreams-sink-files) |

Build any of them with `nix build .#<output>`, e.g. `nix build .#substreams-sink-files`.

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

Packages are updated automatically by a daily GitHub Actions workflow.

Each package exposes a `passthru.updateScript` that resolves the latest upstream
release and refreshes the hash for **every** supported platform in one pass. The
per-platform tarballs live in `passthru.sources` as fixed-output derivations
built with the host stdenv, so a single machine can update them all without
emulation or remote builders.

To update one manually:

```bash
# writeShellScript produces a plain file, not a $out/bin/ tree, so `nix run`
# cannot exec it directly - build it and run the resulting path.
script=$(nix build --no-link --print-out-paths .#substreams.passthru.updateScript)
"$script"

script=$(nix build --no-link --print-out-paths .#substreams-sink-files.passthru.updateScript)
"$script"
```

Set `GITHUB_TOKEN` to stay clear of the unauthenticated API rate limit.

`default.nix` is a compatibility shim for nixpkgs' `update-source-version`,
which locates packages via `import ./.` rather than through flake outputs.
