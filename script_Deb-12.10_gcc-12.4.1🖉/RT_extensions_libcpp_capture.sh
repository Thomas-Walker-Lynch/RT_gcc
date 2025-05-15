#!/bin/bash
set -euo pipefail

echo "⚠️  You probably don't want to run this script. The files in \$ROOT/script_gcc_min-12🖉/library are intended to be the authoritative copies."
echo "So you did the bad thing and edited the files directly in the GCC source tree? Then this script is for you. ;-)"
echo

# Check ROOT is set
if [[ -z "${ROOT:-}" ]]; then
  echo "❌ ROOT environment variable is not set. Aborting."
  exit 1
fi

SRCDIR="$ROOT/source/gcc-12.2.0/libcpp"
DESTDIR="$ROOT/script_gcc_min-12🖉/library"

if [[ ! -d "$SRCDIR" ]]; then
  echo "❌ Source directory '$SRCDIR' does not exist."
  exit 1
fi

if [[ ! -d "$DESTDIR" ]]; then
  echo "❌ Destination directory '$DESTDIR' does not exist."
  exit 1
fi

FILES=(init.cc directives.cc macro.cc)

echo "📋 Checking files in $SRCDIR to copy to $DESTDIR..."

for file in "${FILES[@]}"; do
  SRC="$SRCDIR/$file"
  DEST="$DESTDIR/$file"

  if [[ ! -f "$SRC" ]]; then
    echo "⚠️  Source file '$SRC' not found. Skipping."
    continue
  fi

  if [[ ! -f "$DEST" ]]; then
    echo "📤 No destination file. Copying: $file"
    cp -p "$SRC" "$DEST"
    continue
  fi

  if cmp -s "$SRC" "$DEST"; then
    echo "✅ No changes: $file"
    continue
  fi

  if [[ "$SRC" -nt "$DEST" ]]; then
    echo "📤 Source is newer and differs. Copying: $file"
    cp -p "$SRC" "$DEST"
  elif [[ "$DEST" -nt "$SRC" ]]; then
    echo "⚠️  Destination file '$file' is newer than source and differs."
    echo "🔍 Showing diff:"
    diff -u "$DEST" "$SRC" || true
    echo -n "❓ Overwrite the authoritative '$file' with the older source version? [y/N]: "
    read -r response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
      echo "📤 Overwriting with older source: $file"
      cp -p "$SRC" "$DEST"
    else
      echo "❌ Skipping: $file"
    fi
  else
    echo "⚠️  Files differ but timestamps are equal: $file"
    echo "🔍 Showing diff:"
    diff -u "$DEST" "$SRC" || true
    echo -n "❓ Overwrite anyway? [y/N]: "
    read -r response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
      cp -p "$SRC" "$DEST"
      echo "📤 Overwritten."
    else
      echo "❌ Skipped."
    fi
  fi
done

echo "✅ Capture complete."
