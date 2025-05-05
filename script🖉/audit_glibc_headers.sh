#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "🔎 Auditing glibc build state..."

declare -a missing
declare -a present

# GLIBC_BUILD sanity
[[ -d "$GLIBC_BUILD" ]] && present+=("GLIBC_BUILD exists: $GLIBC_BUILD") || missing+=("GLIBC_BUILD missing")

# Check for Makefile
if [[ -s "$GLIBC_BUILD/Makefile" ]]; then
  present+=("Makefile exists and non-empty")
else
  missing+=("Makefile missing or empty in $GLIBC_BUILD")
fi

# Check bits/stdio_lim.h
if [[ -f "$GLIBC_BUILD/bits/stdio_lim.h" ]]; then
  present+=("bits/stdio_lim.h exists (post-header install marker)")
else
  missing+=("bits/stdio_lim.h missing — make install-headers likely incomplete")
fi

# Check csu/Makefile
if [[ -f "$GLIBC_BUILD/csu/Makefile" ]]; then
  present+=("csu/Makefile exists")
  grep -q 'crt1\.o' "$GLIBC_BUILD/csu/Makefile" \
    && present+=("csu/Makefile defines crt1.o") \
    || missing+=("csu/Makefile missing rule for crt1.o")
else
  missing+=("csu/Makefile missing")
fi

# Show report
echo "✅ Present:"
for p in "${present[@]}"; do echo "  $p"; done

echo
if (( ${#missing[@]} )); then
  echo "❌ Missing:"
  for m in "${missing[@]}"; do echo "  $m"; done
  exit 1
else
  echo "🎉 All bootstrap prerequisites are in place"
  exit 0
fi
