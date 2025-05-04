#!/bin/bash
set -euo pipefail

# Load shared environment
source "$(dirname "$0")/environment.sh"

mkdir -p "$BINUTILS_SRC"
pushd "$BINUTILS_SRC"

if [ ! -f "$BINUTILS_TARBALL" ]; then
  echo "⤵️  Downloading $BINUTILS_TARBALL..."
  curl -LO "$BINUTILS_URL"
else
  echo "✅ $BINUTILS_TARBALL already exists. Skipping download."
fi

if [ ! -f configure ]; then
  echo "📦 Extracting binutils..."
  tar -xzf "$BINUTILS_TARBALL" --strip-components=1
else
  echo "✅ Binutils source already extracted."
fi

popd

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

[[ -x "$TOOLCHAIN/bin/ld" ]] && echo "✅ Binutils installed in $TOOLCHAIN/bin" || {
  echo "❌ Binutils install incomplete"; exit 1;
}

popd
