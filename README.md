# Substreams Nix

Nix package for the [Substreams CLI](https://substreams.dev).

## Usage

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    substreams.url = "github:fedorivn/substreams-nix";
  };

  outputs = { nixpkgs, substreams, ... }: {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = [ substreams.packages.x86_64-linux.default ];
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
nix flake init -t github:fedorivn/substreams-nix#default
nix develop
```

See [`templates/default/README.md`](templates/default/README.md) for details.

## Supported Platforms

- Linux: `x86_64`, `aarch64`
- macOS: `x86_64`, `aarch64`

## Update Package

```bash
nix run github:Mic92/nix-update -- --flake .#substreams --format
```
