#!/bin/bash
# This script can be run multiple times to download what was missed on prior invocations
# If there is a corrupt tarball, delete it and run this again
# Sometimes a connection test will fails, then the downloads runs anyway

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
  echo "checking is reachable: $url "

  # Attempt to get the HTTP response code without following redirects
  http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url")
  
  # If the HTTP code is between 200 and 299, consider it reachable
  if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
    echo "✅ Server reachable (HTTP $http_code): $url "
  else
    # If not 2xx, print the status code for transparency
    echo "⚠️ Server HTTP $http_code not 2xx, will try anyway:  $url"
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
    if file "$UPSTREAM/$file" | grep -qi 'html'; then
      echo "❌ Invalid download (HTML, not archive): $file"
      rm -f "$UPSTREAM/$file"
      return 1
    elif [[ -f "$UPSTREAM/$file" ]]; then
      echo "✅ Successfully downloaded: $file"
      return 0
    # Validate it's not an HTML error page
    else
      echo "❌ Did not appear after download: $file "
      return 1
    fi
  else
    echo "❌ Failed to download: $file"
    return 1
  fi
}

download_tarballs() {
  i=0
  while [ $i -lt ${#UPSTREAM_TARBALL_LIST[@]} ]; do
    tarball="${UPSTREAM_TARBALL_LIST[$i]}"
    url="${UPSTREAM_TARBALL_LIST[$((i+1))]}"
    i=$((i + 3))

    if check_file_exists "$tarball"; then
      echo "⚡ already exists, skipping download: $tarball "
      continue
    fi

    check_server_reachability "$url"

    if ! download_file "$tarball" "$url"; then
      echo "⚠️ Skipping due to previous error: $tarball "
    fi

  done
}

download_git_repos() {
  i=0
  while [ $i -lt ${#UPSTREAM_GIT_REPO_LIST[@]} ]; do
    repo="${UPSTREAM_GIT_REPO_LIST[$i]}"
    branch="${UPSTREAM_GIT_REPO_LIST[$((i+1))]}"
    dir="${UPSTREAM_GIT_REPO_LIST[$((i+2))]}"

    if [[ -d "$dir/.git" ]]; then
      echo "⚡ Already exists, skipping git clone: $dir "
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

# do the downloads

check_internet_connection

echo "Downloading tarballs:"
for ((i=0; i<${#UPSTREAM_TARBALL_LIST[@]}; i+=3)); do
  echo "  - ${UPSTREAM_TARBALL_LIST[i]}"
done
download_tarballs

echo "Cloning Git repositories:"
for ((i=0; i<${#UPSTREAM_GIT_REPO_LIST[@]}; i+=3)); do
  echo "  - ${UPSTREAM_GIT_REPO_LIST[i]} (branch ${UPSTREAM_GIT_REPO_LIST[i+1]})"
done
download_git_repos

echo "project_download.sh completed"
