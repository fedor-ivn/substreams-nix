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
          default = pkgs.callPackage ./package.nix { };
          substreams = pkgs.callPackage ./package.nix { };
          substreams-sink-sql = pkgs.callPackage ./package-sink-sql.nix { };
          substreams-sink-files = pkgs.callPackage ./package-sink-files.nix { };
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
