#!/bin/bash
set -euo pipefail

echo "removing: build, source, upstream, and project directories"

source "$(dirname "$0")/environment.sh"

# Remove build
#
  "./clean_build.sh"
  ! ! rmdir "$BUILD_DIR" >& /dev/null && echo "rmdir $BUILD_DIR"

# Remove source 
#   note that repos are removed with clean_upstream
#
  "./clean_source.sh"
  "./clean_upstream.sh"
  
  ! ! rmdir "$SRC" >& /dev/null && echo "rmdir $SRC"
  ! ! rmdir "$UPSTREAM" >& /dev/null && echo "rmdir $UPSTREAM"

# Remove project directories
#
  for dir in "${PROJECT_SUBDIR_LIST[@]}" "${PROJECT_DIR_LIST[@]}"; do
    if [[ -d "$dir" ]]; then
      echo "rm -rf $dir"
      ! rm -rf "$dir" && echo "could not remove $dir"
    fi
  done

echo "✅ clean_dist.sh"
