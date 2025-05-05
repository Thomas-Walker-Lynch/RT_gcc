#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "📦 Building and installing glibc headers..."

mkdir -p "$GLIBC_BUILD"
pushd "$GLIBC_BUILD"

  # Configure glibc with minimal bootstrap options
  "$GLIBC_SRC/configure" \
    --prefix=/usr \
    --build="$HOST" \
    --host="$HOST" \
    --with-headers="$SYSROOT/usr/include" \
    --disable-multilib \
    --enable-static \
    --disable-shared \
    --enable-kernel=4.4.0 \
    libc_cv_slibdir="/usr/lib"


  # Install headers into sysroot
  make install-headers -j"$MAKE_JOBS" DESTDIR="$SYSROOT"

  # ✅ Verify headers were installed
  required_headers=(
    "$SYSROOT/usr/include/gnu/libc-version.h"
    "$SYSROOT/usr/include/stdio.h"
    "$SYSROOT/usr/include/unistd.h"
  )

  missing=()
  for h in "${required_headers[@]}"; do
    [[ -f "$h" ]] || missing+=("$h")
  done

  if (( ${#missing[@]} > 0 )); then
    echo "❌ Missing required glibc headers:"
    printf '   %s\n' "${missing[@]}"
    exit 1
  fi

popd

echo "✅ glibc headers successfully installed to $SYSROOT/usr/include"
