#!/bin/bash
set -euo pipefail

# Load environment
source "$(dirname "$0")/environment.sh"

echo "🔧 Starting final GCC build..."

mkdir -p "$GCC_BUILD_FINAL"
pushd "$GCC_BUILD_FINAL"

"$GCC_SRC/configure" \
  --prefix="$TOOLCHAIN" \
  --with-sysroot="$SYSROOT" \
  --with-native-system-header-dir=/usr/include \
  --target="$TARGET" \
  --enable-languages=c,c++ \
  --enable-threads=posix \
  --enable-shared \
  --disable-nls \
  --disable-multilib \
  --disable-bootstrap \
  --disable-libsanitizer \
  $CONFIGURE_FLAGS

$MAKE
$MAKE install

popd

echo "✅ Final GCC installed to $TOOLCHAIN/bin"
