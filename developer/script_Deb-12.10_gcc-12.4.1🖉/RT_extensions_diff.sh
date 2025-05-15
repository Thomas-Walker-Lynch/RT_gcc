#!/bin/bash
set -euo pipefail

# Provides RT_CPP_FILES
source "$(dirname "$0")/environment.sh"

if [[ -z "${ROOT:-}" ]]; then
  echo "❌ ROOT environment variable is not set. Aborting."
  exit 1
fi
if [[ -z "${SCRIPT_DIR:-}" ]]; then
  echo "❌ SCRIPT_DIR environment variable is not set. Aborting."
  exit 1
fi

SRCDIR="library/"
DESTDIR="$GCC_SRC/libcpp/"

if [[ ! -d "$SRCDIR" ]]; then
  echo "❌ Source directory '$SRCDIR' does not exist."
  exit 1
fi

if [[ ! -d "$DESTDIR" ]]; then
  echo "❌ Destination directory '$DESTDIR' does not exist."
  exit 1
fi

echo "🔍 Diffing library ↔ libcpp..."

for file in "${RT_CPP_FILES[@]}"; do
  SRC="$SRCDIR/$file"
  DEST="$DESTDIR/$file"

  echo "🔸 $file"

  if [[ ! -f "$SRC" ]]; then
    echo "  ⚠️  Missing in library/: $SRC"
    continue
  fi

  if [[ ! -f "$DEST" ]]; then
    echo "  ⚠️  Missing in libcpp/: $DEST"
    continue
  fi

  if cmp -s "$SRC" "$DEST"; then
    echo "  ✅ No differences."
  else
    echo "  ❗ Differences found:"
    diff -u "$DEST" "$SRC" || true
  fi
done

echo "✅ Diff check complete."
