#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

# Clean source expansions (but keep tarballs)
rm -rf "$LINUX_SRC" "$BINUTILS_SRC" "$GCC_SRC" "$GLIBC_SRC"

echo "✅ Cleared source expansions: $LINUX_SRC, $BINUTILS_SRC, $GCC_SRC, $GLIBC_SRC"
