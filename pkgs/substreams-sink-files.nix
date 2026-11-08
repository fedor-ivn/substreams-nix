{ lib
, stdenv
, fetchurl
, writeShellScript
, curl
, jq
, common-updater-scripts
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "substreams-sink-files";
  version = "2.3.1";

  src = finalAttrs.passthru.sources.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/substreams-sink-files
  '';

  passthru = {
    # Every platform's tarball is a fixed-output derivation built with the
    # *host* stdenv, so all of them can be realised (and their hashes
    # refreshed) on a single machine without emulation or remote builders.
    sources = {
      "x86_64-linux" = fetchurl {
        url = "https://github.com/streamingfast/substreams-sink-files/releases/download/v${finalAttrs.version}/substreams-sink-files_linux_x86_64.tar.gz";
        hash = "sha256-vqFiYFSZvBwiUyWmtDp6BEwBGoloQBMaeeVJiMupnOc=";
      };
      "aarch64-linux" = fetchurl {
        url = "https://github.com/streamingfast/substreams-sink-files/releases/download/v${finalAttrs.version}/substreams-sink-files_linux_arm64.tar.gz";
        hash = "sha256-Gj+ZLiEPVAvHMBAk6XfNwmjzkcnl9Ox9gpfhnL24uxg=";
      };
      "x86_64-darwin" = fetchurl {
        url = "https://github.com/streamingfast/substreams-sink-files/releases/download/v${finalAttrs.version}/substreams-sink-files_darwin_x86_64.tar.gz";
        hash = "sha256-AmlzlpwVI5dp6yyZa3ch/CQ2xZVTeQ+s5tZ7Ysv4Z7k=";
      };
      "aarch64-darwin" = fetchurl {
        url = "https://github.com/streamingfast/substreams-sink-files/releases/download/v${finalAttrs.version}/substreams-sink-files_darwin_arm64.tar.gz";
        hash = "sha256-JTEXyfTzqdOLeI9o9ot20ksyB5QmFerH+FDaJd/rIY8=";
      };
    };

    updateScript = writeShellScript "update-substreams-sink-files" ''
      set -euo pipefail
      export PATH="${lib.makeBinPath [ curl jq common-updater-scripts ]}:$PATH"

      auth=()
      if [ -n "''${GITHUB_TOKEN:-}" ]; then
        auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
      fi

      # /releases/latest excludes drafts and prereleases.
      new_version=$(curl --silent --fail "''${auth[@]}" \
        https://api.github.com/repos/streamingfast/substreams-sink-files/releases/latest \
        | jq -r '.tag_name | ltrimstr("v")')

      if [ -z "$new_version" ] || [ "$new_version" = "null" ]; then
        echo "Could not determine the latest substreams-sink-files version." >&2
        exit 1
      fi

      if [ "${finalAttrs.version}" = "$new_version" ]; then
        echo "substreams-sink-files is already at $new_version."
        exit 0
      fi

      for platform in ${lib.escapeShellArgs (builtins.attrNames finalAttrs.passthru.sources)}; do
        update-source-version substreams-sink-files "$new_version" \
          --ignore-same-version \
          --source-key="sources.$platform"
      done

      # update-source-version writes a placeholder hash before fetching. If a
      # fetch aborts, that placeholder is left behind in the .nix file, so
      # confirm every platform's tarball actually realises at the new version.
      for platform in ${lib.escapeShellArgs (builtins.attrNames finalAttrs.passthru.sources)}; do
        if ! nix-build --no-out-link -A "substreams-sink-files.passthru.sources.$platform" >/dev/null; then
          echo "Failed to realise the $platform source; the .nix file is likely corrupt." >&2
          exit 1
        fi
      done
    '';
  };

  meta = {
    description = "Substreams files sink - Sync Substreams data into flat files (CSV, JSONL, Parquet)";
    homepage = "https://github.com/streamingfast/substreams-sink-files";
    license = lib.licenses.asl20;
    mainProgram = "substreams-sink-files";
    platforms = builtins.attrNames finalAttrs.passthru.sources;
  };
})
