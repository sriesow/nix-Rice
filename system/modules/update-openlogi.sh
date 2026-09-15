#!/usr/bin/env bash
# Bumps openlogi-package.nix to the latest GitHub release: rewrites `version`
# and `sha256` in place. Nix's fetchurl needs the hash pinned ahead of time
# (fixed-output derivation), so this can't happen inside flake evaluation —
# run it before `nixos-rebuild`/`nixos-update` picks up the new pin.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/openlogi-package.nix"
repo="AprilNEA/OpenLogi"

release_json=$(curl -sL "https://api.github.com/repos/$repo/releases/latest")
latest_tag=$(grep -oP '(?<="tag_name": ")[^"]+' <<< "$release_json" | head -n1)
version="${latest_tag#v}"

current_version=$(grep -oP '(?<=version = ")[^"]+' "$package_file")
if [[ "$version" == "$current_version" ]]; then
  echo "openlogi already at $version"
  exit 0
fi

asset="openlogi-v${version}-linux-amd64.pkg.tar.zst"
sums=$(curl -sL "https://github.com/$repo/releases/download/$latest_tag/SHA256SUMS")
sha256=$(grep "$asset" <<< "$sums" | grep -oP '^[0-9a-f]{64}' | head -n1)

if [[ -z "$sha256" ]]; then
  echo "could not find sha256 for $asset" >&2
  exit 1
fi

sed -i \
  -e "s/version = \"$current_version\";/version = \"$version\";/" \
  -e "s/sha256 = \"[0-9a-f]\{64\}\";/sha256 = \"$sha256\";/" \
  "$package_file"

echo "openlogi bumped $current_version -> $version"
