{ lib
, stdenv
, fetchurl
}:

let
  version = "2.3.1";

  # Platform mappings: Nix system -> release filename + hash
  platformInfo = {
    "x86_64-linux" = {
      filename = "substreams-sink-files_linux_x86_64.tar.gz";
      hash = "sha256-vqFiYFSZvBwiUyWmtDp6BEwBGoloQBMaeeVJiMupnOc=";
    };
    "aarch64-linux" = {
      filename = "substreams-sink-files_linux_arm64.tar.gz";
      hash = "sha256-Gj+ZLiEPVAvHMBAk6XfNwmjzkcnl9Ox9gpfhnL24uxg=";
    };
    "x86_64-darwin" = {
      filename = "substreams-sink-files_darwin_x86_64.tar.gz";
      hash = "sha256-AmlzlpwVI5dp6yyZa3ch/CQ2xZVTeQ+s5tZ7Ysv4Z7k=";
    };
    "aarch64-darwin" = {
      filename = "substreams-sink-files_darwin_arm64.tar.gz";
      hash = "sha256-JTEXyfTzqdOLeI9o9ot20ksyB5QmFerH+FDaJd/rIY8=";
    };
  };

  info = platformInfo.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://github.com/streamingfast/substreams-sink-files/releases/download/v${version}/${info.filename}";
    inherit (info) hash;
  };
in
stdenv.mkDerivation {
  pname = "substreams-sink-files";
  inherit version src;

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/substreams-sink-files
  '';

  meta = {
    description = "Substreams files sink - Sync Substreams data into flat files (CSV, JSONL, Parquet)";
    homepage = "https://github.com/streamingfast/substreams-sink-files";
    license = lib.licenses.asl20;
    mainProgram = "substreams-sink-files";
    platforms = builtins.attrNames platformInfo;
  };
}
