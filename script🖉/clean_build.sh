#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

# Clean the build directories listed in BUILD_DIR_LISTECTORY_LIST
echo "🧹 Cleaning build directories..."

for dir in "${BUILD_DIR_LIST[@]}"; do
  if [[ -d "$dir" ]]; then
    echo "rm -rf $dir"
    rm -rf "$dir"
  fi
done

echo "✅ Build directories cleaned."
