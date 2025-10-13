#!/bin/bash
# mv_libs_to_gcc.sh
# Move prerequisite libraries into the GCC source tree, replacing stale copies.
# This script can be run multiple times for incremental moves when more sources become available.

set -euo pipefail

source "$(dirname "$0")/environment.sh"

LIB_LIST=(
  "gmp"  "$GMP_SRC"
  "mpfr" "$MPFR_SRC"
  "mpc"  "$MPC_SRC"
  "isl"  "$ISL_SRC"
  "zstd" "$ZSTD_SRC"
)

i=0
while [ $i -lt ${#LIB_LIST[@]} ]; do
  lib="${LIB_LIST[$i]}"
  src="${LIB_LIST[$((i + 1))]}"
  dest="$GCC_SRC/$lib"
  i=$((i + 2))

  if [[ ! -d "$src" ]]; then
    echo "Source not found, skipping: $src"
    continue
  fi

  if [[ -d "$dest" ]]; then
    echo "Removing stale: $dest"
    rm -rf "$dest"
  fi

  echo "mv $src $dest"
  mv "$src" "$dest"
done

echo "completed mv_libs_to_gcc.sh"
