#!/bin/bash
# this script can be run multiple times so as to fetch what was missed on prior invocations
# if there is a corrupt tarball, delete it and run this again
# sometimes the connection test fails, then the data downloads anyway

set -uo pipefail  # no `-e`, we want to continue on error

source "$(dirname "$0")/environment.sh"

check_internet_connection() {
  if ! curl -s --connect-timeout 5 https://example.com > /dev/null; then
    echo "⚠️ No internet connection detected"
  fi
}

check_server_reachability() {
  local url=$1
  if ! curl -s --head "$url" | head -n 1 | grep -q "HTTP/1.1 200 OK"; then
    echo "⚠️ Cannot reach $url"
  fi
}

check_file_exists() {
  local file=$1
  [[ -f "$UPSTREAM/$file" ]]
}

download_file() {
  local file=$1
  local url=$2

  echo "curl -LO $url"
  if (cd "$UPSTREAM" && curl -LO "$url"); then
    if [[ -f "$UPSTREAM/$file" ]]; then
      return 0
    else
      echo "❌ $file did not appear after download"
      return 1
    fi
  else
    echo "❌ Failed to download $file"
    return 1
  fi
}

fetch_tarballs() {
  i=0
  while [ $i -lt ${#UPSTREAM_TARBALL_LIST[@]} ]; do
    tarball="${UPSTREAM_TARBALL_LIST[$i]}"
    url="${UPSTREAM_TARBALL_LIST[$((i+1))]}"

    if check_file_exists "$tarball"; then
      i=$((i + 3))
      continue
    fi

    check_server_reachability "$url"

    if ! download_file "$tarball" "$url"; then
      echo "⚠️ Skipping $tarball due to previous error"
    fi

    i=$((i + 3))
  done
}

fetch_git_repos() {
  i=0
  while [ $i -lt ${#UPSTREAM_GIT_REPO_LIST[@]} ]; do
    repo="${UPSTREAM_GIT_REPO_LIST[$i]}"
    branch="${UPSTREAM_GIT_REPO_LIST[$((i+1))]}"
    dir="${UPSTREAM_GIT_REPO_LIST[$((i+2))]}"

    if [[ -d "$dir/.git" ]]; then
      i=$((i + 3))
      continue
    fi

    echo "git clone --branch $branch $repo $dir"
    if ! git clone --branch "$branch" "$repo" "$dir"; then
      echo "❌ Failed to clone $repo → $dir"
    fi

    i=$((i + 3))
  done
}

check_internet_connection
fetch_tarballs
fetch_git_repos

echo "✅ download_expand_source.sh"
