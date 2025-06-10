#!/bin/bash
set -euo pipefail

# provides RT_CPP_FILES
source "$(dirname "$0")/environment.sh"

# Save original versions of libcpp files to prevent accidental loss
# Appends _orig after the .cc extension (e.g., macro.cc → macro.cc_orig)
# Files remain in place but can be manually diffed or restored if needed

if [[ -z "${DEVELOPER:-}" ]]; then
  echo "❌ DEVELOPER environment variable is not set. Aborting."
  exit 1
fi
if [[ -z "${SCRIPT_DIR:-}" ]]; then
  echo "❌ SCRIPT_DIR environment variable is not set. Aborting."
  exit 1
fi

TARGETDIR="$GCC_SRC/libcpp/"

if [[ ! -d "$TARGETDIR" ]]; then
  echo "❌ Target directory '$TARGETDIR' does not exist."
  exit 1
fi

echo "📦 Saving original copies of target files..."

for file in "${RT_CPP_FILES[@]}"; do
  SRC="$TARGETDIR/$file"
  BACKUP="$SRC"_orig

  if [[ ! -f "$SRC" ]]; then
    echo "⚠️  Source file '$SRC' not found. Skipping."
    continue
  fi

  if [[ -f "$BACKUP" ]]; then
    echo "✅ Already saved: $file → $(basename "$BACKUP")"
  else
    cp -p "$SRC" "$BACKUP"
    echo "📁 Saved: $file → $(basename "$BACKUP")"
  fi
done

echo "✅ All originals saved."
