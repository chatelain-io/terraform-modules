#!/usr/bin/env bash

set -euo pipefail

# check if cog is not installed and raise error
if ! command -v cog &> /dev/null; then
  echo "Cocogitto is not installed. You must run the setup action."
  exit 1
fi

