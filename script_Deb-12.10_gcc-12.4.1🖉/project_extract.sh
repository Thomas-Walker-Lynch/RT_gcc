#!/bin/bash
# Will not extract if target already exists
# Delete any malformed extractions before running again

set -euo pipefail

source "$(dirname "$0")/environment.sh"

had_error=0
i=0

while [ $i -lt ${#UPSTREAM_TARBALL_LIST[@]} ]; do
  tarball="${UPSTREAM_TARBALL_LIST[$i]}"
  i=$((i + 3))

  src_path="$UPSTREAM/$tarball"

  # Strip compression suffix to guess subdirectory name
  base_name="${tarball%%.tar.*}"  # safer across .tar.gz, .tar.zst, etc.
  target_dir="$SRC/$base_name"

  if [[ -d "$target_dir" ]]; then
    echo "⚡ Already exists, skipping: $target_dir"
    continue
  fi

  if [[ ! -f "$src_path" ]]; then
    echo "❌ Missing tarball: $src_path"
    had_error=1
    continue
  fi

  echo "tar -xf $tarball"
  if ! (cd "$SRC" && tar -xf "$src_path"); then
    echo "❌ Extraction failed: $tarball"
    had_error=1
    continue
  fi

  if [[ -d "$target_dir" ]]; then
    echo "Extracted to: $target_dir"
  else
    echo "❌ Target not found after extraction: $target_dir"
    had_error=1
  fi
done

if [[ $had_error -eq 0 ]]; then
  echo "✅ All tarballs extracted successfully"
else
  echo "❌ Some extractions failed or were incomplete"
fi
