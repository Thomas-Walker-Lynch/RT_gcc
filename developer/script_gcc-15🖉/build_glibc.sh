#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "🔧 Building full glibc..."

mkdir -p "$GLIBC_BUILD"
pushd "$GLIBC_BUILD"

"$GLIBC_SRC/configure" \
  --prefix=/usr \
  --host="$TARGET" \
  --build="$(gcc -dumpmachine)" \
  --with-headers="$SYSROOT/usr/include" \
  --disable-multilib \
  --enable-static \
  --enable-shared \
  libc_cv_slibdir="/usr/lib"

$MAKE
DESTDIR="$SYSROOT" $MAKE install

popd

echo "✅ Full glibc installed in $SYSROOT"
