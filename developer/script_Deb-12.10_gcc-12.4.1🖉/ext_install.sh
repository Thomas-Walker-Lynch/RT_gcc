#!/bin/bash
# transfer.sh – Install RT library files into GCC libcpp source tree.
# Usage:
#   ./transfer.sh             → transfers all files in RT_CPP_FILES
#   ./transfer.sh init.cc     → transfers only init.cc
#   ./transfer.sh init.cc macro.cc  → transfers just those

set -euo pipefail

# provides: $ROOT, $RT_CPP_FILES, $GCC_SRC
source "$(dirname "$0")/environment.sh"

SRCDIR="library"
DESTDIR="$GCC_SRC/libcpp"

# Validate environment
[[ -z "${ROOT:-}" ]] && { echo "❌ ROOT is not set. Aborting."; exit 1; }
[[ ! -d "$SRCDIR" ]] && { echo "❌ Source directory '$SRCDIR' missing."; exit 1; }
[[ ! -d "$DESTDIR" ]] && { echo "❌ Destination directory '$DESTDIR' missing."; exit 1; }

# Determine list of files to transfer
if [[ $# -eq 0 ]]; then
  file_list=("${RT_CPP_FILES[@]}")
else
  file_list=("$@")
fi

echo "📋 Transferring files to $DESTDIR..."

for file in "${file_list[@]}"; do
  src="$SRCDIR/$file"
  dest="$DESTDIR/$file"

  if [[ ! -f "$src" ]]; then
    echo "⚠️  Missing source file: $src"
    continue
  fi

  if [[ ! -f "$dest" || "$src" -nt "$dest" ]]; then
    echo "📥 Copying (newer or missing): $file"
    cp -p "$src" "$dest"
  elif [[ "$dest" -nt "$src" ]]; then
    echo "⚠️  Destination '$file' is newer than source."
    diff -u "$dest" "$src" || true
    echo -n "❓ Overwrite destination '$file'? [y/N]: "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      echo "📥 Overwriting: $file"
      cp -p "$src" "$dest"
    else
      echo "⏭️  Skipped: $file"
    fi
  else
    echo "✅ Up-to-date: $file"
  fi
done

echo "✅ Transfer complete."
