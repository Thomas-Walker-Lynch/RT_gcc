#!/bin/bash
set -euo pipefail

# Load shared environment
source "$(dirname "$0")/environment.sh"

echo "📦 Checking prerequisites for final GCC..."

# Required host tools
required_tools=(gcc g++ make curl tar gawk bison flex)
missing_tools=()

for tool in "${required_tools[@]}"; do
  if ! type -P "$tool" > /dev/null; then
    missing_tools+=("$tool")
  fi
done

if (( ${#missing_tools[@]} )); then
  echo "❌ Missing required tools: ${missing_tools[*]}"
  exit 1
fi

# Check for libc headers and startup objects in sysroot
required_headers=("$SYSROOT/include/stdio.h")
required_crt_objects=(
  "$SYSROOT/lib/crt1.o"
  "$SYSROOT/lib/crti.o"
  "$SYSROOT/lib/crtn.o"
)

for hdr in "${required_headers[@]}"; do
  if [ ! -f "$hdr" ]; then
    echo "❌ C library header missing: $hdr"
    exit 1
  fi
done

for obj in "${required_crt_objects[@]}"; do
  if [ ! -f "$obj" ]; then
    echo "❌ Startup object missing: $obj"
    exit 1
  fi
done

echo "✅ Prerequisites for final GCC met."
