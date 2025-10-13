#!/bin/bash
set -euo pipefail

# provides RT_CPP_FILES
source "$(dirname "$0")/environment.sh"


echo "⚠️  You probably don't want to run this script. The files in \$DEVELOPER/script_Deb-12.10_gcc-12.4.1🖉/library are intended to be the authoritative copies."
echo "So you did the bad thing and edited the files directly in the GCC source tree? Then this script is for you. ;-)"
echo

echo -n "Continue❓ [y/N]: "
read -r response
if [[ "$response" == "y" || "$response" == "Y" ]]; then
  :
else
  exit 1
fi


if [[ -z "${DEVELOPER:-}" ]]; then
  echo "❌ DEVELOPER environment variable is not set. Aborting."
  exit 1
fi
if [[ -z "${SCRIPT_DIR:-}" ]]; then
  echo "❌ SCRIPT_DIR environment variable is not set. Aborting."
  exit 1
fi
SRCDIR="library/"
DESTDIR="$GCC_SRC/libcpp/"


SRCDIR="$DEVELOPER/source/gcc-12.2.0/libcpp"
DESTDIR="$DEVELOPER/script_Deb-12.10_gcc-12.4.1🖉/library"

if [[ ! -d "$SRCDIR" ]]; then
  echo "❌ Source directory '$SRCDIR' does not exist."
  exit 1
fi

if [[ ! -d "$DESTDIR" ]]; then
  echo "❌ Destination directory '$DESTDIR' does not exist."
  exit 1
fi

echo "📋 Checking files in $SRCDIR to copy to $DESTDIR..."

for file in "${RT_CPP_FILES[@]}"; do
  SRC="$SRCDIR/$file"
  DEST="$DESTDIR/$file"

  mkdir -p "$(dirname "$DEST")"

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
