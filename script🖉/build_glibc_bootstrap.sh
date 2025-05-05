#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "📦 Building glibc startup files (crt*.o)..."

pushd "$GLIBC_BUILD"

  # Confirm that required build artifacts are present
  if [[ ! -f bits/stdio_lim.h ]]; then
    echo "❌ Missing bits/stdio_lim.h — did you run build_glibc_headers.sh?"
    exit 1
  fi

  if [[ ! -f csu/Makefile ]]; then
    echo "❌ Missing csu/Makefile — glibc configure phase may have failed"
    exit 1
  fi

  # Attempt to build the crt startup object files
  make csu/crt1.o csu/crti.o csu/crtn.o -j"$MAKE_JOBS"

  # Install them to the sysroot
  install -m 644 csu/crt1.o csu/crti.o csu/crtn.o "$SYSROOT/usr/lib"

  # Create a dummy libc.so to satisfy linker if needed
  touch "$SYSROOT/usr/lib/libc.so"

  # ✅ Verify installation
  for f in crt1.o crti.o crtn.o; do
    if [[ ! -f "$SYSROOT/usr/lib/$f" ]]; then
      echo "❌ Missing startup file after install: $f"
      exit 1
    fi
  done

popd

echo "✅ glibc startup files installed to $SYSROOT/usr/lib"
