#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

# Create top-level project directories
for dir in "${PROJECT_DIR_LIST[@]}"; do
  echo "mkdir -p $dir"
  mkdir -p "$dir"
done

# Create subdirectories within SYSROOT
for subdir in "${PROJECT_SUBDIR_LIST[@]}"; do
  echo "mkdir -p $subdir"
  mkdir -p "$subdir"
done

# Ensure TMPDIR exists and add .gitignore
if [[ ! -d "$TMPDIR" ]]; then
  echo "mkdir -p $TMPDIR"
  mkdir -p "$TMPDIR"

  echo "echo $TMPDIR/ > $TMPDIR/.gitignore"
  echo "$TMPDIR/" > "$TMPDIR/.gitignore"
else
  echo "⚠️ TMPDIR already exists"
fi

# Create root-level .gitignore if missing
if [[ -f "$ROOT/.gitignore" ]]; then
  echo "⚠️ $ROOT/.gitignore already exists"
else
  echo "create $ROOT/.gitignore"
  {
    echo "# Ignore synthesized top-level directories"
    for dir in "${PROJECT_DIR_LIST[@]}"; do
      rel_path="${dir#$ROOT/}"
      echo "/$rel_path"
    done
    echo "# Ignore synthesized files"
    echo "/.gitignore"
  } > "$ROOT/.gitignore"
fi

echo "✅ setup_project.sh"
