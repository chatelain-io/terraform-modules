#!/usr/bin/env bash

set -euo pipefail


function has_packages() {
  local packages="$1"

  if [[ -z "$packages-" ]]; then
    return 1
  fi
}


function has_changes()  {
  local response="$1"

  if [[ -z "$response" ]]; then
    return 1
  fi

  if [[ "$response" == *"No conventional commits found"* ]]; then
    return 1
  fi

  return 0
}

response=$(cog bump --auto --dry-run --skip-untracked 2>/dev/null)

if ! has_changes "$response"; then
  echo "No changes found"
  exit 0
fi

packages=$(yq -oy 'select(.packages != null) |  .packages | keys[]' cog.toml)
if ! has_packages "$packages"; then
  echo "No packages found in cog.toml"
  exit 0
else
  echo "Found packages:"
  echo "$packages"
fi

# Generate a json object with jq.
# The key is the package name
# and it has current_version, next_version and hasChanges attributes
jq -n '{packages: {}}' > versions.json
for package in $packages; do
  current_version=$(cog -v get-version --package "$package" --fallback "0.0.1")
  next_version=$(cog bump --auto --dry-run --skip-untracked --package "$package" 2>/dev/null || echo "")
  has_changes=$(has_changes "$next_version" && echo "true" || echo "false")
  if ! has_changes "$next_version"; then
    next_version=""
  fi

  next_version=${next_version//$package-/}


  echo "Package: $package"
  echo "Current version: $current_version"
  echo "Next version: $next_version"
  echo "Has changes: $has_changes"

  jq --arg pkg "$package" \
     --arg curr_ver "$current_version" \
     --arg next_ver "$next_version" \
     --arg has_chg "$has_changes" \
     '.packages[$pkg] = {current_version: $curr_ver, next_version: $next_ver, hasChanges: ($has_chg | test("true"))}' \
     versions.json > tmp.$$.json && mv tmp.$$.json versions.json
done


# for package in $packages; do
#   current_version=$(cog -v get-version --package "$package" --fallback "0.0.1")
#   next_version=$(cog bump --auto --dry-run --skip-untracked --package "$package" 2>/dev/null || echo "$current_version")

#   echo "Package: $package"
#   echo "Current version: $current_version"
#   #echo "Next version: $next_version"
# done

# echo "$packages"
# echo $has_packages