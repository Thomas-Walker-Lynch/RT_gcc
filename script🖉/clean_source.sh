#!/bin/bash
# removes project tarball expansions from source/
# git repos are part of `upstream` so are not removed

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

echo "✅ clean_source.sh"
