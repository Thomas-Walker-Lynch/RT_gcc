#!/bin/bash
# rebuild_gcc.sh – no structural changes, and build directory is still intact

set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "🔧 Starting GCC rebuild..."

pushd "$GCC_BUILD"

  echo "gcc: $(command -v gcc)"
  echo "toolchain: $TOOLCHAIN"

  $MAKE -j"$MAKE_JOBS"
  $MAKE install

popd

echo "✅ GCC re-installed to $TOOLCHAIN/bin"
"$TOOLCHAIN/bin/gcc" --version
