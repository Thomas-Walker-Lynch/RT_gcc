#!/bin/bash
# build_gcc.sh – Build GCC 12.2.0 using system libraries and headers

set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "🔧 Starting GCC build..."

mkdir -p "$GCC_BUILD"
pushd "$GCC_BUILD"

echo "gcc: $(command -v gcc)"
echo "toolchain: $TOOLCHAIN"

"$GCC_SRC/configure" \
  --with-pkgversion="RT_gcc standalone by Reasoning Technology" \
  --with-bugurl="https://github.com/Thomas-Walker-Lynch/RT_gcc/issues" \
  --with-documentation-root-url="https://gcc.gnu.org/onlinedocs/" \
  --with-changes-root-url="https://github.com/Thomas-Walker-Lynch/RT_gcc/releases/" \
  --host="$HOST" \
  --prefix="$TOOLCHAIN" \
  --enable-languages=c,c++ \
  --enable-threads=posix \
  --disable-multilib 

$MAKE -j"$MAKE_JOBS"
$MAKE install

popd

echo "✅ GCC installed to $TOOLCHAIN/bin"
"$TOOLCHAIN/bin/gcc" --version
