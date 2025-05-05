#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

mkdir -p "$BINUTILS_BUILD"
pushd "$BINUTILS_BUILD"

  "$BINUTILS_SRC/configure" \
    --prefix="$TOOLCHAIN" \
    --with-sysroot="$SYSROOT" \
    --disable-nls \
    --disable-werror \
    --disable-multilib \
    --enable-deterministic-archives \
    --enable-plugins \
    --with-lib-path="$SYSROOT/lib:$SYSROOT/usr/lib"

  $MAKE
  $MAKE install

  # Verify installation
  if [[ -x "$TOOLCHAIN/bin/ld" ]]; then
    echo "✅ Binutils installed in $TOOLCHAIN/bin"
    exit 0
  fi

  echo "❌ Binutils install incomplete"
  exit 1

popd

