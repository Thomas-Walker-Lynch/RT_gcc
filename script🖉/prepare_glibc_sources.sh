#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

mkdir -p "$GLIBC_SRC"
pushd "$GLIBC_SRC"

if [ ! -f "$GLIBC_TARBALL" ]; then
  echo "⤵️  Downloading glibc $GLIBC_VER..."
  curl -LO "$GLIBC_URL"
else
  echo "✅ $GLIBC_TARBALL already exists."
fi

if [ ! -f configure ]; then
  echo "📦 Extracting glibc $GLIBC_VER..."
  tar -xzf "$GLIBC_TARBALL" --strip-components=1
  if [[ ! -f configure || ! -d elf ]]; then
    echo "❌ glibc extraction failed."
    exit 1
  fi
else
  echo "✅ glibc source already extracted."
fi

popd
