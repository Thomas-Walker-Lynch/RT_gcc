#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "📦 Preparing Linux kernel headers for glibc and GCC..."

pushd "$LINUX_SRC"

  $MAKE mrproper
  $MAKE headers_install ARCH=x86_64 INSTALL_HDR_PATH="$SYSROOT/usr"

  if [[ -f "$SYSROOT/usr/include/linux/version.h" ]]; then
    echo "✅ Linux headers installed to $SYSROOT/usr/include"
    exit 0
  fi

  echo "❌ Kernel headers not found at expected location."
  exit 1

popd
