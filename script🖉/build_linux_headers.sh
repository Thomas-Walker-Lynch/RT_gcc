#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "📦 Preparing Linux kernel headers for glibc and GCC..."

mkdir -p "$LINUX_SRC"
pushd "$LINUX_SRC"

if [ ! -f "$LINUX_TARBALL" ]; then
  echo "⤵️  Downloading Linux $LINUX_VER headers..."
  curl -LO "$LINUX_URL"
else
  echo "✅ Kernel tarball already exists."
fi

if [ ! -f Makefile ]; then
  echo "📂 Extracting kernel sources..."
  tar -xf "$LINUX_TARBALL" --strip-components=1
else
  echo "✅ Kernel source already extracted."
fi

$MAKE mrproper
$MAKE headers_install ARCH=x86_64 INSTALL_HDR_PATH="$SYSROOT/usr"

# Optional: check for successful header installation
if [[ ! -f "$SYSROOT/usr/include/linux/version.h" ]]; then
  echo "❌ Kernel headers not found at expected location."
  exit 1
fi

popd
echo "✅ Linux headers installed to $SYSROOT/usr/include"
