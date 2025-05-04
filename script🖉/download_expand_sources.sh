#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

# 🛠️ Function to check if the internet is accessible
check_internet_connection() {
  echo "🌐 Checking internet connection..."
  if curl -s --head http://google.com | head -n 1 | grep "HTTP/1.1 200 OK" > /dev/null; then
    echo "✅ Internet is reachable."
  else
    echo "❌ No internet connection detected. Proceeding with caution..."
  fi
}

# 🏰 Function to check if the server for the URL is reachable
check_server_reachability() {
  local url=$1
  echo "🌍 Checking if the server $url is reachable..."
  if curl -s --head "$url" | head -n 1 | grep "HTTP/1.1 200 OK" > /dev/null; then
    echo "✅ Server $url is reachable."
  else
    echo "❌ Cannot reach server $url. Proceeding with download attempt anyway..."
  fi
}

# 🏰 Function to check if file already exists in UPSTREAM
check_file_exists() {
  local file=$1
  if [[ -f "$UPSTREAM/$file" ]]; then
    echo "⚡ $file already exists in $UPSTREAM, skipping download."
    return 0  # File exists, so skip download
  else
    return 1  # File doesn't exist, needs to be downloaded
  fi
}

# 🛡️ Function to download a file from a URL
download_file() {
  local file=$1
  local url=$2

  echo "📥 Downloading $file..."
  curl -LO "$url"

  if [[ -f "$file" ]]; then
    echo "✅ Successfully downloaded $file."
  else
    echo "❌ Error downloading $file. Continuing with next source."
  fi
}

# 🌍 Main Function to download all sources
fetch_sources() {
  echo "🧙‍♂️ Fetching legendary sources for the build..."

  # Check for internet connection first
  check_internet_connection

  # Define source list (version-controlled)
  sources=(
    "$LINUX_TARBALL:$LINUX_URL"
    "$BINUTILS_TARBALL:$BINUTILS_URL"
    "$GCC_TARBALL:$GCC_REPO"  # Special case for Git repo
    "$GLIBC_TARBALL:$GLIBC_URL"
  )

  for source in "${sources[@]}"; do
    IFS=":" read -r tarball url <<< "$source"

    if check_file_exists "$tarball"; then
      continue  # Skip if file already exists
    fi

    # Check if we can reach the server before attempting download
    check_server_reachability "$url"

    # Special case for Git-based source (GCC)
    if [[ "$tarball" == *"gcc"* ]]; then
      echo "⚡ Fetching GCC source from Git repo: $GCC_REPO"
      git clone --branch "$GCC_BRANCH" "$GCC_REPO" "$UPSTREAM/gcc-$GCC_VER"
      echo "✅ GCC source fetched from Git."
    else
      download_file "$tarball" "$url"
    fi
  done

  echo "🛠️ All sources fetched and ready for build!"
}

# Start the fetching process
fetch_sources
