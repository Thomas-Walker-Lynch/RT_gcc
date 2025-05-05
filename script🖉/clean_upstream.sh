#!/bin/bash
# run this to force repeat of the downloads
# removes project tarballs from upstream/
# removes project repos from source/
# does not remove non-project files

set -euo pipefail

source "$(dirname "$0")/environment.sh"

# Remove tarballs
i=0
while [ $i -lt ${#UPSTREAM_TARBALL_LIST[@]} ]; do
  tarball="${UPSTREAM_TARBALL_LIST[$i]}"
  path="$UPSTREAM/$tarball"

  if [[ -f "$path" ]]; then
    echo "rm $path"
    rm "$path"
  fi

  i=$((i + 3))
done

# Remove Git repositories
i=0
while [ $i -lt ${#UPSTREAM_GIT_REPO_LIST[@]} ]; do
  dir="${UPSTREAM_GIT_REPO_LIST[$((i+2))]}"

  if [[ -d "$dir" ]]; then
    echo "rm -rf $dir"
    rm -rf "$dir"
  fi

  i=$((i + 3))
done

echo "✅ clean_upstream.sh"
