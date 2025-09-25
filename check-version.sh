#!/usr/bin/env bash

set -euo pipefail

packages=$(yq -oy 'select(.packages != null) |  .packages | keys[]' cog.toml)
has_packages=$([[ -n "$packages" ]] && echo "true" || echo "false")

if [ "$has_packages" = "false" ]; then
  echo "No packages found in cog.toml"
  exit 0
fi

for package in $packages; do
  current_version=$(cog -v get-version --package "$package" --fallback "0.0.1")
  next_version=$(cog bump --auto --dry-run --skip-untracked --package "$package" 2>/dev/null || echo "$current_version")

  echo "Package: $package"
  echo "Current version: $current_version"
  #echo "Next version: $next_version"
done

echo "$packages"
echo $has_packages