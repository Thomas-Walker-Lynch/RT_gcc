#!/bin/bash
# This script can be run multiple times to fetch what was missed on prior invocations
# If there is a corrupt tarball, delete it and run this again
# Sometimes the connection test fails, then the data downloads anyway

set -uo pipefail  # no `-e`, we want to continue on error

source "$(dirname "$0")/environment.sh"

check_internet_connection() {
  echo "🌐 Checking internet connection..."
  # Use a quick connection check without blocking the whole script
  if ! curl -s --connect-timeout 5 https://google.com > /dev/null; then
    echo "⚠️ No internet connection detected (proceeding with download anyway)"
  else
    echo "✅ Internet connection detected"
  fi
}

# check_server_reachability() {
#   local url=$1
#   if ! curl -s --head "$url" | head -n 1 | grep -q "HTTP/1.1 200 OK"; then
#     echo "⚠️ Cannot reach $url (proceeding with download anyway)"
#   fi
# }

check_server_reachability() {
  local url=$1
  
  # Attempt to get the HTTP response code without following redirects
  http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url")
  
  # If the HTTP code is between 200 and 299, consider it reachable
  if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
    echo "✅ Server $url is reachable (HTTP $http_code)"
  else
    # If not 2xx, print the status code for transparency
    echo "⚠️ Server $url returned HTTP $http_code (proceeding with download anyway)"
  fi
}

check_file_exists() {
  local file=$1
  [[ -f "$UPSTREAM/$file" ]]
}

download_file() {
  local file=$1
  local url=$2

  echo "Downloading $file from $url..."
  if (cd "$UPSTREAM" && curl -LO "$url"); then
    if [[ -f "$UPSTREAM/$file" ]]; then
      echo "✅ Successfully downloaded $file"
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
  echo "Starting to download tarballs..."

  i=0
  while [ $i -lt ${#UPSTREAM_TARBALL_LIST[@]} ]; do
    tarball="${UPSTREAM_TARBALL_LIST[$i]}"
    url="${UPSTREAM_TARBALL_LIST[$((i+1))]}"

    if check_file_exists "$tarball"; then
      echo "⚡ $tarball already exists, skipping download"
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
  echo "Starting to download Git repositories..."

  i=0
  while [ $i -lt ${#UPSTREAM_GIT_REPO_LIST[@]} ]; do
    repo="${UPSTREAM_GIT_REPO_LIST[$i]}"
    branch="${UPSTREAM_GIT_REPO_LIST[$((i+1))]}"
    dir="${UPSTREAM_GIT_REPO_LIST[$((i+2))]}"

    if [[ -d "$dir/.git" ]]; then
      echo "⚡ $dir already exists, skipping git clone"
      i=$((i + 3))
      continue
    fi

    echo "Cloning $repo into $dir..."
    if ! git clone --branch "$branch" "$repo" "$dir"; then
      echo "❌ Failed to clone $repo → $dir"
    fi

    i=$((i + 3))
  done
}

# Show what will be downloaded
echo "Preparing to download the following sources:"
echo "  - Linux kernel: $LINUX_TARBALL"
echo "  - Binutils: $BINUTILS_TARBALL"
echo "  - Glibc: $GLIBC_TARBALL"
echo "  - GCC source: $GCC_REPO (branch $GCC_BRANCH)"

check_internet_connection
fetch_tarballs
fetch_git_repos

echo "✅ download_expand_source.sh completed"
