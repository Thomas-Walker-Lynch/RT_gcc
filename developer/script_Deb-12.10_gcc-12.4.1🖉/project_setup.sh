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

  echo "$TMPDIR/" > "$TMPDIR/.gitignore"
else
  echo "⚠️ TMPDIR already exists"
fi

# Create root-level .gitignore if missing
if [[ -f "$REPO_HOME/.gitignore" ]]; then
  echo "⚠️ $REPO_HOME/.gitignore already exists"
else
  echo "create $REPO_HOME/.gitignore"
  {
    echo "# Ignore synthesized top-level directories"
    for dir in "${PROJECT_DIR_LIST[@]}"; do
      rel_path="${dir#$REPO_HOME/}"
      echo "/$rel_path"
    done
    echo "# Ignore synthesized files"
    echo "/.gitignore"
  } > "$REPO_HOME/.gitignore"
fi

echo
echo "Created project structure:"
tree -L 2 "$REPO_HOME" 2>/dev/null || find "$REPO_HOME" -maxdepth 2

