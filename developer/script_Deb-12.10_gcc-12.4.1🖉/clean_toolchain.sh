#!/bin/bash
# clean_toolchain.sh – Remove installed GCC toolchain artifacts

set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "🧹 Cleaning installed toolchain at: $TOOLCHAIN"

if [[ -d "$TOOLCHAIN" ]]; then
  echo "rm -rf $TOOLCHAIN"
  rm -rf "$TOOLCHAIN"
else
  echo "⚠️ Toolchain directory not found: $TOOLCHAIN (nothing to remove)"
fi

echo "✅ Installed toolchain cleaned."
