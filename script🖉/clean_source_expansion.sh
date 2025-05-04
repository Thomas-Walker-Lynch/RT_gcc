#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

for dir in "${SOURCE_DIR_LIST[@]}"; do
  if [[ -d "$dir" ]]; then
    echo "rm -rf $dir"
    rm -rf "$dir"
  fi
done

echo "✅ clean_source_expansion.sh"
