{ lib
, stdenv
, fetchurl
, writeShellScript
, curl
, jq
, common-updater-scripts
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "substreams";
  version = "1.24.0";

  src = finalAttrs.passthru.sources.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/substreams
  '';

  passthru = {
    # Every platform's tarball is a fixed-output derivation built with the
    # *host* stdenv, so all of them can be realised (and their hashes
    # refreshed) on a single machine without emulation or remote builders.
    sources = {
      "x86_64-linux" = fetchurl {
        url = "https://github.com/streamingfast/substreams/releases/download/v${finalAttrs.version}/substreams_linux_x86_64.tar.gz";
        hash = "sha256-jtWKeFwAZX+3HHvDkLeBNXzRPkFUl+S08Bap4xXXUaY=";
      };
      "aarch64-linux" = fetchurl {
        url = "https://github.com/streamingfast/substreams/releases/download/v${finalAttrs.version}/substreams_linux_arm64.tar.gz";
        hash = "sha256-ortV3XUoMBd/C8Tiekq3HqKkQ+9KEcGvhdtnGvl1kks=";
      };
      "x86_64-darwin" = fetchurl {
        url = "https://github.com/streamingfast/substreams/releases/download/v${finalAttrs.version}/substreams_darwin_x86_64.tar.gz";
        hash = "sha256-a05PjOBH0iKgBTOUdCRVWg/4fhLx5U95//B8fdJgbC0=";
      };
      "aarch64-darwin" = fetchurl {
        url = "https://github.com/streamingfast/substreams/releases/download/v${finalAttrs.version}/substreams_darwin_arm64.tar.gz";
        hash = "sha256-RtJa8Itp+SwVMRlyqf8bXfSxsPle/NXYbDPpUctTvTM=";
      };
    };

    updateScript = writeShellScript "update-substreams" ''
      set -euo pipefail
      export PATH="${lib.makeBinPath [ curl jq common-updater-scripts ]}:$PATH"

      auth=()
      if [ -n "''${GITHUB_TOKEN:-}" ]; then
        auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
      fi

      # /releases/latest excludes drafts and prereleases.
      new_version=$(curl --silent --fail "''${auth[@]}" \
        https://api.github.com/repos/streamingfast/substreams/releases/latest \
        | jq -r '.tag_name | ltrimstr("v")')

      if [ -z "$new_version" ] || [ "$new_version" = "null" ]; then
        echo "Could not determine the latest substreams version." >&2
        exit 1
      fi

      if [ "${finalAttrs.version}" = "$new_version" ]; then
        echo "substreams is already at $new_version."
        exit 0
      fi

      for platform in ${lib.escapeShellArgs (builtins.attrNames finalAttrs.passthru.sources)}; do
        update-source-version substreams "$new_version" \
          --ignore-same-version \
          --source-key="sources.$platform"
      done

      # update-source-version writes a placeholder hash before fetching. If a
      # fetch aborts, that placeholder is left behind in the .nix file, so
      # confirm every platform's tarball actually realises at the new version.
      for platform in ${lib.escapeShellArgs (builtins.attrNames finalAttrs.passthru.sources)}; do
        if ! nix-build --no-out-link -A "substreams.passthru.sources.$platform" >/dev/null; then
          echo "Failed to realise the $platform source; the .nix file is likely corrupt." >&2
          exit 1
        fi
      done
    '';
  };

  meta = {
    description = "Substreams CLI - Stream processing engine for blockchain data";
    homepage = "https://substreams.dev";
    license = lib.licenses.mit;
    mainProgram = "substreams";
    platforms = builtins.attrNames finalAttrs.passthru.sources;
  };
})
