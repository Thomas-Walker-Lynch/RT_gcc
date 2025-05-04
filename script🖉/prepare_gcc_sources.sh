#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/environment.sh"

mkdir -p "$GCC_SRC"
pushd "$GCC_SRC"

if [ ! -d .git ]; then
  echo "⤵️  Cloning GCC source..."
  git clone "$GCC_REPO" "$GCC_SRC"
  git checkout -b RT_mods origin/"$GCC_BRANCH"
else
  echo "✅ GCC repository already exists."
  git fetch origin
  if git show-ref --quiet refs/heads/RT_mods; then
    git checkout RT_mods
  else
    git checkout -b RT_mods origin/"$GCC_BRANCH"
  fi
fi

./contrib/download_prerequisites

popd
