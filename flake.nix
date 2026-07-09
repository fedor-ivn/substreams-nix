{
  description = "Nix flake for Substreams CLI binary";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = pkgs.callPackage ./pkgs/substreams.nix { };
          substreams = pkgs.callPackage ./pkgs/substreams.nix { };
          substreams-sink-sql = pkgs.callPackage ./pkgs/substreams-sink-sql.nix { };
          substreams-sink-files = pkgs.callPackage ./pkgs/substreams-sink-files.nix { };
        };
      }
    ) // {
      templates = {
        default = {
          path = ./templates/default;
          description = "Substreams development environment with Rust, protobuf, and PostgreSQL";
        };
      };
    };
}
