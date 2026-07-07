{ lib
, stdenv
, fetchurl
}:

let
  version = "1.19.0";

  # Platform mappings: Nix system -> release filename
  platformInfo = {
    "x86_64-linux" = "substreams_linux_x86_64.tar.gz";
    "aarch64-linux" = "substreams_linux_arm64.tar.gz";
    "x86_64-darwin" = "substreams_darwin_x86_64.tar.gz";
    "aarch64-darwin" = "substreams_darwin_arm64.tar.gz";
  };

  filename = platformInfo.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://github.com/streamingfast/substreams/releases/download/v${version}/${filename}";
    hash = "sha256-+D21dHDbnh2+pfngJqwezsRSWllUilgWrQcgpg33SRw=";
  };
in
stdenv.mkDerivation {
  pname = "substreams";
  inherit version src;

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/substreams
  '';

  meta = {
    description = "Substreams CLI - Stream processing engine for blockchain data";
    homepage = "https://substreams.dev";
    license = lib.licenses.mit;
    mainProgram = "substreams";
    platforms = builtins.attrNames platformInfo;
  };
}
