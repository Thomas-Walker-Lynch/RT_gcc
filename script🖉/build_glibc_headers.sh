#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "📚 Building glibc headers..."

# 🧹 Clean previous build artifacts to ensure idempotence
echo "🧼 Cleaning glibc build directory: $GLIBC_BUILD"
rm -rf "$GLIBC_BUILD"
mkdir -p "$GLIBC_BUILD"

pushd "$GLIBC_BUILD"

# 🏗️ Configure glibc for headers-only installation
echo "⚙️  Configuring glibc headers install..."
"$GLIBC_SRC/configure" \
  --prefix=/usr \
  --with-headers="$SYSROOT/usr/include" \
  --disable-multilib \
  --enable-static \
  --disable-shared \
  libc_cv_slibdir="/usr/lib"

# 📥 Install headers only
echo "🛠️  Installing glibc headers to sysroot..."
make install-headers -j"$(nproc)" DESTDIR="$SYSROOT"

# 📎 Verify critical header files and directories were installed
echo "📦 Verifying installed files..."

required_headers=(
  "$SYSROOT/usr/include/gnu/libc-version.h"
  "$SYSROOT/usr/include/stdio.h"
  "$SYSROOT/usr/include/unistd.h"
)

missing_files=()
for header in "${required_headers[@]}"; do
  if [[ ! -f "$header" ]]; then
    missing_files+=("$header")
  fi
done

if (( ${#missing_files[@]} > 0 )); then
  echo "❌ Missing required glibc headers:"
  printf '   %s\n' "${missing_files[@]}"
  exit 1
fi

# 📦 Verify the expected directory structure
if [[ ! -d "$SYSROOT/usr/include" ]]; then
  echo "❌ Expected include directory not found: $SYSROOT/usr/include"
  exit 1
fi

if [[ ! -d "$SYSROOT/usr/lib" ]]; then
  echo "❌ Expected lib directory not found: $SYSROOT/usr/lib"
  exit 1
fi

# 📚 Additional verification: check for key startup files
startup_files=(
  "$SYSROOT/usr/lib/crt1.o"
  "$SYSROOT/usr/lib/crti.o"
  "$SYSROOT/usr/lib/crtn.o"
)

for file in "${startup_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "❌ Missing startup file: $file"
    exit 1
  fi
done

popd

echo "✅ glibc headers successfully installed to $SYSROOT/usr/include"
