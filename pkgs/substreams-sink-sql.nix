{ lib
, stdenv
, fetchurl
}:

let
  version = "4.13.1";

  # Platform mappings: Nix system -> release filename + hash
  platformInfo = {
    "x86_64-linux" = {
      filename = "substreams-sink-sql_linux_x86_64.tar.gz";
      hash = "sha256-Ql5duvGZjUCGWXggJw2rET+qEK9WoUZzA2f0N0+5uxM=";
    };
    "aarch64-linux" = {
      filename = "substreams-sink-sql_linux_arm64.tar.gz";
      hash = "sha256-EvuSMRuLt/QCvTYi8EzhecSIxVWoVl/q4bnY5I7fR+A=";
    };
    "x86_64-darwin" = {
      filename = "substreams-sink-sql_darwin_x86_64.tar.gz";
      hash = "sha256-nS/6pZ17hoYNw+dff4sM4pF9fz7Vcb+VxLIgbDGikGs=";
    };
    "aarch64-darwin" = {
      filename = "substreams-sink-sql_darwin_arm64.tar.gz";
      hash = "sha256-qH46DdDCf34aVIjHvL5MV/M28bEx6UIpiAKtsbdtV7c=";
    };
  };

  info = platformInfo.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://github.com/streamingfast/substreams-sink-sql/releases/download/v${version}/${info.filename}";
    inherit (info) hash;
  };
in
stdenv.mkDerivation {
  pname = "substreams-sink-sql";
  inherit version src;

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/substreams-sink-sql
  '';

  meta = {
    description = "Substreams SQL sink - Sync Substreams data into PostgreSQL/Clickhouse";
    homepage = "https://github.com/streamingfast/substreams-sink-sql";
    license = lib.licenses.asl20;
    mainProgram = "substreams-sink-sql";
    platforms = builtins.attrNames platformInfo;
  };
}
