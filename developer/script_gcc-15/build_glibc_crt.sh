#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

# Use separate dir to avoid conflicts with headers
# this build variable should be moved to environment.sh, so that the clean scripts will work:
GLIBC_BUILD_CRT="$ROOT/build/glibc-crt"
rm -rf "$GLIBC_BUILD_CRT"
mkdir -p "$GLIBC_BUILD_CRT"
mkdir -p /home/Thomas/subu_data/developer/RT_gcc/build/glibc-crt/csu
touch /home/Thomas/subu_data/developer/RT_gcc/build/glibc-crt/csu/grcrt1.o
mkdir -p "$GLIBC_BUILD_CRT/include"
cp -r "$SYSROOT/usr/include"/* "$GLIBC_BUILD_CRT/include"


pushd "$GLIBC_BUILD_CRT"


  echo "🧱 Configuring glibc for startup file build..."

  # Invoke configure explicitly
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

  # Ensure csu/Makefile is generated
  #make -C "$GLIBC_SRC" objdir="$GLIBC_BUILD_CRT" csu/subdir_lib -j"$MAKE_JOBS"
  make -C "$GLIBC_SRC" objdir="$GLIBC_BUILD_CRT" csu/crt1.o csu/crti.o csu/crtn.o -j"$MAKE_JOBS"

  # Now check and continue
  if [[ ! -f "$GLIBC_BUILD_CRT/csu/Makefile" ]]; then
    echo "❌ csu/Makefile still not found after configure. Startup build failed."
    exit 1
  fi

  echo "🔨 Building crt objects..."
  make -C "$GLIBC_SRC" objdir="$GLIBC_BUILD_CRT" csu/crt1.o csu/crti.o csu/crtn.o -j"$MAKE_JOBS"

  echo "📦 Installing crt objects to sysroot..."
  install -m 644 "$GLIBC_BUILD_CRT/csu/crt1.o" "$GLIBC_BUILD_CRT/csu/crti.o" "$GLIBC_BUILD_CRT/csu/crtn.o" "$SYSROOT/usr/lib"
  touch "$SYSROOT/usr/lib/libc.so"

  for f in crt1.o crti.o crtn.o; do
    [[ -f "$SYSROOT/usr/lib/$f" ]] || { echo "❌ Missing $f after install"; exit 1; }
  done

popd
echo "✅ Startup files installed from isolated build dir: $GLIBC_BUILD_CRT"
