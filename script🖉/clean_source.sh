#!/bin/bash
# removes only the tarball expansions from upstream
# git repos are removed with `clean_upstream`

set -euo pipefail


source "$(dirname "$0")/environment.sh"

i=0
while [ $i -lt ${#UPSTREAM_TARBALL_LIST[@]} ]; do
  tarball="${UPSTREAM_TARBALL_LIST[$i]}"
  # skip url
  i=$((i + 1))
  # skip explicit dest dir
  i=$((i + 1))

  base_name="${tarball%.tar.*}"
  dir="$SRC/$base_name"

  if [[ -d "$dir" ]]; then
    echo "rm -rf $dir"
    rm -rf "$dir"
  fi

  i=$((i + 1))
done

echo "✅ clean_source_expansion.sh"
