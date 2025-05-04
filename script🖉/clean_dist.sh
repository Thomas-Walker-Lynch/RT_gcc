#!/bin/bash
set -euo pipefail

echo "removing: build, source, upstream, and project directories"

source "$(dirname "$0")/environment.sh"

# Remove build
#
  "./clean_build.sh"
  ! ! rmdir "$BUILD_DIR" >& /dev/null && echo "rmdir $BUILD_DIR"

# Remove source 
#
  for dir in "${SOURCE_DIR_LIST[@]}"; do
    if [[ -d "$dir" ]]; then
      echo "rm -r $dir"
      rm -r "$dir"
    fi
  done
  ! ! rmdir "$SRC" >& /dev/null && echo "rmdir $SRC"

# Remove upstream 
#
  # walk the UPSTREAM_TARBALL_LIST triples
  i=0
  while [ $i -lt ${#UPSTREAM_TARBALL_LIST[@]} ]; do
    tarball="${UPSTREAM_TARBALL_LIST[$i]}"
    # skip URL at index i+1
    dir="${UPSTREAM_TARBALL_LIST[$((i+2))]}"

    tarball_path="$dir/$tarball"
    if [[ -f "$tarball_path" ]]; then
      echo "rm $tarball_path"
      rm "$tarball_path"
    fi

    i=$((i + 3))
  done
  ! ! rmdir "$UPSTREAM" >& /dev/null && echo "rmdir $UPSTREAM"


# Remove project directories
#
  for dir in "${PROJECT_SUBDIR_LIST[@]}" "${PROJECT_DIR_LIST[@]}"; do
    if [[ -d "$dir" ]]; then
      echo "rm -rf $dir"
      rm -rf "$dir"
    fi
  done

echo "✅ clean_dist.sh"
