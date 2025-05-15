#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "🔧 Starting stage 1 GCC build (native layout)..."

# 🧼 Clean optionally if forced
if [[ "${CLEAN_STAGE1:-0}" == "1" ]]; then
  echo "🧹 Forcing rebuild: cleaning $GCC_BUILD_STAGE1"
  rm -rf "$GCC_BUILD_STAGE1"
fi

mkdir -p "$GCC_BUILD_STAGE1"
pushd "$GCC_BUILD_STAGE1"

# 🛠️ Configure only if not yet configured
if [[ ! -f Makefile ]]; then
  echo "⚙️  Configuring GCC stage 1..."
  "$GCC_SRC/configure" \
    --prefix="$TOOLCHAIN" \
    --with-sysroot="$SYSROOT" \
    --with-build-sysroot="$SYSROOT" \
    --with-native-system-header-dir=/include \
    --enable-languages=c \
    --disable-nls \
    --disable-shared \
    --disable-threads \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libssp \
    --disable-multilib \
    --disable-bootstrap \
    --disable-libstdcxx \
    --disable-fixincludes \
    --without-headers \
    --with-newlib
else
  echo "✅ GCC already configured, skipping."
fi

# 🧾 Ensure proper sysroot handling for internal libgcc
export CFLAGS_FOR_TARGET="--sysroot=$SYSROOT"
export CXXFLAGS_FOR_TARGET="--sysroot=$SYSROOT"
export CPPFLAGS_FOR_TARGET="--sysroot=$SYSROOT"
export CFLAGS="--sysroot=$SYSROOT"
export CXXFLAGS="--sysroot=$SYSROOT"

# 🏗️ Build only if not built
if [[ ! -x "$TOOLCHAIN/bin/gcc" ]]; then
  echo "⚙️  Building GCC stage 1..."
  make -j"$(nproc)" all-gcc all-target-libgcc

  echo "📦 Installing GCC stage 1 to $TOOLCHAIN"
  make install-gcc install-target-libgcc
else
  echo "✅ GCC stage 1 already installed at $TOOLCHAIN/bin/gcc, skipping build."
fi

popd

# ✅ Final check
if [[ ! -x "$TOOLCHAIN/bin/gcc" ]]; then
  echo "❌ Stage 1 GCC not found at $TOOLCHAIN/bin/gcc — build may have failed."
  exit 1
fi

echo "✅ Stage 1 GCC successfully installed in $TOOLCHAIN/bin"
