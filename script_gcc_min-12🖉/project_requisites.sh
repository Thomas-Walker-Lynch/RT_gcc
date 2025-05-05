#!/bin/bash
# project_requisites.sh
# Checks that all required tools, libraries, and sources are available
# before proceeding with the GCC build.

set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "Checking requisites for native standalone GCC build."

if ! command -v pkg-config >/dev/null; then
  echo "❌ pkg-config command required for this script"
  echo "    Debian: sudo apt install pkg-config"
  echo "    Fedora: sudo dnf install pkg-config"
  exit 1
fi

missing_requisite_list=()
failed_pkg_config_list=()
found_requisite_list=()

# --- Required Script Tools (must be usable by this script itself) ---
script_tools=(
  bash
  awk
  sed
  grep
)

echo "Checking for essential script dependencies."
for tool in "${script_tools[@]}"; do
  location=$(command -v "$tool")
  if [ $? -eq 0 ]; then 
    found_requisite_list+=("$location")
  else
    missing_requisite_list+=("tool: $tool")
  fi
done

# --- Build Tools ---
build_tools=(
  gcc
  g++
  make
  tar
  gzip
  bzip2
  perl
  patch
  diff
  python3
)

echo "Checking for required build tools."
for tool in "${build_tools[@]}"; do
  location=$(command -v "$tool")
  if [ $? -eq 0 ]; then 
    found_requisite_list+=("$location")
  else
    missing_requisite_list+=("tool: $tool")
  fi
done

# --- Libraries via pkg-config ---
required_pkgs=(
  gmp
  mpfr
  mpc
  isl
  zstd
)

echo "Checking for required development libraries (via pkg-config)."
for lib in "${required_pkgs[@]}"; do
  if pkg-config --exists "$lib"; then
    libdir=$(pkg-config --variable=libdir "$lib" 2>/dev/null)
    soname="lib$lib.so"

    if [[ -f "$libdir/$soname" ]]; then
      found_requisite_list+=("library: $lib @ $libdir/$soname")
    else
      found_requisite_list+=("library: $lib @ (not found in $libdir)")
    fi
  else
    failed_pkg_config_list+=("library: $lib")
  fi
done

# --- Source Trees ---
echo "Checking for required source directories."
echo "These will be installed by project_download.sh and project_extract.sh"
for src in "${SOURCE_DIR_LIST[@]}"; do
  if [[ -d "$src" && "$(ls -A "$src")" ]]; then
    found_requisite_list+=("source: $src")
  else
    missing_requisite_list+=("source: $src")
  fi
done

# --- Optional Python Modules ---
optional_py_modules=(
  re sys os json gzip pathlib shutil time tempfile
)

echo "Checking optional Python3 modules."
for mod in "${optional_py_modules[@]}"; do
  if python3 -c "import $mod" &>/dev/null; then
    found_requisite_list+=("python: module $mod")
  else
    missing_requisite_list+=("python (optional): module $mod")
  fi
done

echo
echo "Summary:"
echo "--------"

for item in "${found_requisite_list[@]}"; do
  echo "  found: $item"
done

for item in "${missing_requisite_list[@]:-}"; do
  echo "❌ missing required: $item"
done

for item in "${failed_pkg_config_list[@]:-}"; do
  echo "⚠️ pkg-config could not find: $item"
done

echo

if [[ ${#missing_requisite_list[@]} -eq 0 && ${#failed_pkg_config_list[@]} -eq 0 ]]; then
  echo "✅ All required tools and sources are present."
else
  echo "❌ Some requisites are missing or unresolved."
  if [[ ${#failed_pkg_config_list[@]} -gt 0 ]]; then
    echo
    echo "Note: The following libraries were not found by pkg-config:"
    for item in "${failed_pkg_config_list[@]}"; do
      echo "  - $item"
    done
    echo
    echo "These may be expected if you are building them from source:"
    echo "  - mpc"
    echo "  - isl"
    echo "  - zstd"
    echo "If not, consider installing the appropriate development packages:"
    echo "    Debian: sudo apt install libmpc-dev libisl-dev libzstd-dev"
    echo "    Fedora: sudo dnf install libmpc-devel isl-devel libzstd-devel"
  fi
fi
