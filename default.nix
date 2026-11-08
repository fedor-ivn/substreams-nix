# Compatibility shim for nixpkgs' `update-source-version`, which locates
# packages by `import ./.` rather than through the flake outputs.
{ system ? builtins.currentSystem
, pkgs ? import (builtins.getFlake (toString ./.)).inputs.nixpkgs { inherit system; }
}:

{
  substreams = pkgs.callPackage ./pkgs/substreams.nix { };
  substreams-sink-files = pkgs.callPackage ./pkgs/substreams-sink-files.nix { };
}
