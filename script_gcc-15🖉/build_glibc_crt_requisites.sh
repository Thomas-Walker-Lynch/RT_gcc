#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "📦 Checking requisites for glibc crt (startup files)"

missing=()
found=()

# Core toolchain utilities
for tool in gcc g++ make ld as; do
  if command -v "$tool" >/dev/null; then
    found+=("tool: $tool at $(command -v "$tool")")
  else
    missing+=("missing tool: $tool")
  fi
done

# GLIBC source/csu
if [[ -d "$GLIBC_SRC/csu" ]]; then
  found+=("glibc source/csu present")
else
  missing+=("missing: $GLIBC_SRC/csu")
fi

# Expected headers from sysroot
for h in gnu/libc-version.h stdio.h unistd.h; do
  if [[ -f "$SYSROOT/usr/include/$h" ]]; then
    found+=("header present: $h")
  else
    missing+=("missing header: $SYSROOT/usr/include/$h")
  fi
done

# Writable sysroot lib dir
if [[ -w "$SYSROOT/usr/lib" ]]; then
  found+=("SYSROOT writable: $SYSROOT/usr/lib")
else
  missing+=("not writable: $SYSROOT/usr/lib")
fi

# Summary output
echo
if (( ${#found[@]} > 0 )); then
  echo "✅ Found:"
  for item in "${found[@]}"; do echo "  $item"; done
fi

echo
if (( ${#missing[@]} > 0 )); then
  echo "❌ Missing:"
  for item in "${missing[@]}"; do echo "  $item"; done
  echo
  echo "❌ Requisites check failed"
  exit 1
else
  echo "✅ All crt requisites satisfied"
  exit 0
fi
