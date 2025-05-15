#!/bin/bash
set -euo pipefail

# Check ROOT is set
if [[ -z "${ROOT:-}" ]]; then
  echo "❌ ROOT environment variable is not set. Aborting."
  exit 1
fi

SRCDIR="$ROOT/script_gcc_min-12🖉/library"
DESTDIR="$ROOT/source/gcc-12.2.0/libcpp"

if [[ ! -d "$SRCDIR" ]]; then
  echo "❌ Source directory '$SRCDIR' does not exist."
  exit 1
fi

if [[ ! -d "$DESTDIR" ]]; then
  echo "❌ Destination directory '$DESTDIR' does not exist."
  exit 1
fi

FILES=(init.cc directives.cc macro.cc)

echo "📋 Installing files from $SRCDIR to $DESTDIR..."

for file in "${FILES[@]}"; do
  SRC="$SRCDIR/$file"
  DEST="$DESTDIR/$file"

  if [[ ! -f "$SRC" ]]; then
    echo "⚠️  Source file '$SRC' not found. Skipping."
    continue
  fi

  if [[ ! -f "$DEST" || "$SRC" -nt "$DEST" ]]; then
    echo "📥 Installing (newer or missing): $file"
    cp "$SRC" "$DEST"
  elif [[ "$DEST" -nt "$SRC" ]]; then
    echo "⚠️  Destination file '$file' is newer than the source."
    echo "🔍 Showing diff:"
    diff -u "$DEST" "$SRC" || true
    echo -n "❓ Overwrite destination '$file' with older source? [y/N]: "
    read -r response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
      echo "📥 Overwriting: $file"
      cp -p "$SRC" "$DEST"
    else
      echo "⏭️  Skipping: $file"
    fi
  else
    echo "✅ Up-to-date: $file"
  fi
done

echo "✅ Installation complete."
