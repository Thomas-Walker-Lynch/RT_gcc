#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

i=0
while [ $i -lt ${#UPSTREAM_TARBALL_LIST[@]} ]; do
  tarball="${UPSTREAM_TARBALL_LIST[$i]}"
  # url is unused
  src_path="$UPSTREAM/$tarball"

  # Strip compression suffix to guess subdirectory name
  base_name="${tarball%.tar.*}"
  target_dir="$SRC/$base_name"

  if [[ -d "$target_dir" ]]; then
    echo "⚠️ $target_dir already exists, skipping"
    i=$((i + 3))
    continue
  fi

  if [[ ! -f "$src_path" ]]; then
    echo "❌ Missing tarball: $src_path"
    i=$((i + 3))
    continue
  fi

  echo "tar -xf $tarball → $SRC"
  (
    cd "$SRC"
    tar -xf "$src_path"
  )

  if [[ -d "$target_dir" ]]; then
    echo "✅ Extracted to $target_dir"
  else
    echo "❌ Expected $target_dir not found after extraction"
  fi

  i=$((i + 3))
done

echo "✅ extract_from_tar.sh"
