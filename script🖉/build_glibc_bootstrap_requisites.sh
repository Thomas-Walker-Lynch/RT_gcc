#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "📦 Checking requisites for glibc startup file build (crt1.o, crti.o, crtn.o)."

missing_requisite_list=()
found_requisite_list=()

# ────────────────────────────────────────────────
# 1. Required tools
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
# 2. Required directories and sources
#
  if [ -d "$GLIBC_SRC" ] && [ "$(ls -A "$GLIBC_SRC")" ]; then
    found_requisite_list+=("$GLIBC_SRC")
  else
    missing_requisite_list+=("$GLIBC_SRC (empty or missing)")
  fi

# ────────────────────────────────────────────────
# 3. Required sysroot include path with Linux headers
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
# 4. Confirm SYSROOT write access
#
  if [[ -w "$SYSROOT/usr/include" ]]; then
    found_requisite_list+=("SYSROOT writable: $SYSROOT/usr/include")
  else
    missing_requisite_list+=("SYSROOT not writable: $SYSROOT/usr/include")
  fi

# ────────────────────────────────────────────────
# Additional sanity checks before header & crt build
#

  # 1. Check that the C preprocessor works and headers can be found
  echo '#include <stddef.h>' | gcc -E - > /dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    found_requisite_list+=("C preprocessor operational: gcc -E works")
  else
    missing_requisite_list+=("C preprocessor failed: gcc -E on <stddef.h> failed")
  fi

  # 2. Check that bits/stdio_lim.h exists after headers install (glibc marker)
  if [[ -f "$GLIBC_BUILD/bits/stdio_lim.h" ]]; then
    found_requisite_list+=("$GLIBC_BUILD/bits/stdio_lim.h (glibc headers marker found)")
  else
    missing_requisite_list+=("$GLIBC_BUILD/bits/stdio_lim.h missing — headers may not be fully installed")
  fi

  # 3. Check for crt objects already present (optional)
  for f in crt1.o crti.o crtn.o; do
    if [[ -f "$GLIBC_BUILD/csu/$f" ]]; then
      found_requisite_list+=("$GLIBC_BUILD/csu/$f (already built)")
    fi
  done

  # 4. Check that Makefile exists and is non-empty
  if [[ -f "$GLIBC_BUILD/Makefile" ]]; then
    if [[ -s "$GLIBC_BUILD/Makefile" ]]; then
      found_requisite_list+=("$GLIBC_BUILD/Makefile exists and is populated")
    else
      missing_requisite_list+=("$GLIBC_BUILD/Makefile exists but is empty — incomplete configure?")
    fi
  else
    missing_requisite_list+=("$GLIBC_BUILD/Makefile missing — did configure run?")
  fi

  # 5. Check that csu Makefile has rules for crt1.o
  if [[ -f "$GLIBC_BUILD/csu/Makefile" ]]; then
    if grep -q 'crt1\.o' "$GLIBC_BUILD/csu/Makefile"; then
      found_requisite_list+=("csu/Makefile defines crt1.o")
    else
      missing_requisite_list+=("csu/Makefile does not define crt1.o — possible misconfigure")
    fi
  else
    missing_requisite_list+=("csu/Makefile missing — subdir config likely failed")
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
  #
  if (( ${#missing_requisite_list[@]} > 0 )); then
    echo "❌ Missing requisites for glibc bootstrap"
    exit 1
  else
    echo "✅ All specified requisites found"
    exit 0
  fi
