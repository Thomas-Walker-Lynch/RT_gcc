#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "📦 Checking requisites for glibc headers installation."

missing_requisite_list=()
found_requisite_list=()

# ────────────────────────────────────────────────
# 1. Required tools for headers phase
#
required_tools=(
  "gcc"
  "g++"
  "make"
  "ld"
  "as"
)

for tool in "${required_tools[@]}"; do
  if location=$(command -v "$tool"); then
    found_requisite_list+=("$location")
  else
    missing_requisite_list+=("$tool")
  fi
done

# ────────────────────────────────────────────────
# 2. glibc source directory check
#
if [ -d "$GLIBC_SRC" ] && [ "$(ls -A "$GLIBC_SRC")" ]; then
  found_requisite_list+=("$GLIBC_SRC")
else
  missing_requisite_list+=("$GLIBC_SRC (empty or missing)")
fi

# ────────────────────────────────────────────────
# 3. Kernel headers required for bootstrap glibc
#
linux_headers=(
  "$SYSROOT/usr/include/linux/version.h"
  "$SYSROOT/usr/include/asm/unistd.h"
  "$SYSROOT/usr/include/bits/types.h"
)

for header in "${linux_headers[@]}"; do
  if [[ -f "$header" ]]; then
    found_requisite_list+=("$header")
  else
    missing_requisite_list+=("$header")
  fi
done

# ────────────────────────────────────────────────
# 4. Confirm SYSROOT write access for header install
#
if [[ -w "$SYSROOT/usr/include" ]]; then
  found_requisite_list+=("SYSROOT writable: $SYSROOT/usr/include")
else
  missing_requisite_list+=("SYSROOT not writable: $SYSROOT/usr/include")
fi

# ────────────────────────────────────────────────
# 5. Check C preprocessor is operational
#
echo '#include <stddef.h>' | gcc -E - > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
  found_requisite_list+=("C preprocessor operational: gcc -E works")
else
  missing_requisite_list+=("C preprocessor failed: gcc -E on <stddef.h> failed")
fi

# ────────────────────────────────────────────────
# Print results
#
if (( ${#found_requisite_list[@]} > 0 )); then
  echo "found:"
  for item in "${found_requisite_list[@]}"; do
    echo "  $item"
  done
fi

if (( ${#missing_requisite_list[@]} > 0 )); then
  echo "missing:"
  for item in "${missing_requisite_list[@]}"; do
    echo "  $item"
  done
fi

# Final verdict
if (( ${#missing_requisite_list[@]} > 0 )); then
  echo "❌ Missing requisites for glibc header install"
  exit 1
else
  echo "✅ All specified requisites found for glibc headers"
  exit 0
fi
