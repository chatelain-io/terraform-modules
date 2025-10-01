#!/usr/bin/env bash

# Installs Cocogitto CLI tool to $HOME/.local/bin for use in CI workflows or local use.
# This script does not check for CI environment variables; run it manually or in CI as needed.

set -euo pipefail

COCOGITTO_VERSION=${COCOGITTO_VERSION:-"6.3.0"}

if command -v cog &> /dev/null; then
  COCOGITTO_CURRENT_VERSION=$(cog --version | awk '{print $2}')

  if [[ "$COCOGITTO_CURRENT_VERSION" = "$COCOGITTO_VERSION" ]]; then
    echo "Cocogitto is already at the desired version $COCOGITTO_VERSION"
    exit 0
  else
    echo "Cocogitto version $COCOGITTO_CURRENT_VERSION is installed, but version $COCOGITTO_VERSION is required. Updating..."
  fi
else
  echo "Cocogitto is not installed. Installing version $COCOGITTO_VERSION..."
fi

COCOGITTO_ARCH="x86_64-unknown-linux-musl"
COCOGITTO_TAR="cocogitto-$COCOGITTO_VERSION-$COCOGITTO_ARCH.tar.gz"
COCOGITTO_BIN_DIR="$HOME/.local/bin"

mkdir -p "$COCOGITTO_BIN_DIR"
COCOGITTO_TMP_DIR=$(mktemp -d)
curl -L "https://github.com/cocogitto/cocogitto/releases/download/$COCOGITTO_VERSION/$COCOGITTO_TAR" -o "$COCOGITTO_TMP_DIR/$COCOGITTO_TAR"
tar --strip-components=1 -xzf "$COCOGITTO_TMP_DIR/$COCOGITTO_TAR" -C "$COCOGITTO_TMP_DIR" "$COCOGITTO_ARCH/cog"
mv "$COCOGITTO_TMP_DIR/cog" "$COCOGITTO_BIN_DIR"
rm -rf "$COCOGITTO_TMP_DIR"

# check if GITHUB_PATH, and if COCOGITTO_BIN_DIR is not already in PATH, then add it
if [[ -n "${GITHUB_PATH-}" ]]; then
  if ! grep -q "$COCOGITTO_BIN_DIR" <<< "${PATH:-}"; then
    echo "$COCOGITTO_BIN_DIR" >> "$GITHUB_PATH"
    echo "Added $COCOGITTO_BIN_DIR to GITHUB_PATH"
  fi
fi
