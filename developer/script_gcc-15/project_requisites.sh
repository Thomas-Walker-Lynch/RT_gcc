#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "Checking requisites for native standalone GCC build."

if [ ! $(command -v pkg-config) ]; then
  echo "pkg-config command required for this script"
  echo "Debian: sudo apt install pkg-config"
  echo "Fedora: sudo dnf install pkg-config"
  exit 1
fi


missing_requisite_list=()
failed_pkg_config_list=()
found_reequisite_list=()

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
    missing_requisite_list+=("$tool")
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
    missing_requisite_list+=("$tool")
  fi
done

# --- Libraries ---
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
    found_reequisite_list+=("library: $lib => $(pkg-config --modversion "$lib")")
  else
    failed_pkg_config_list+=("library: $lib")
  fi
done

# --- Source Trees ---
required_sources=(
  "$GCC_SRC"
  "$BINUTILS_SRC"
  "$GLIBC_SRC"
  "$LINUX_SRC"
  "$GMP_SRC"
  "$MPFR_SRC"
  "$MPC_SRC"
  "$ISL_SRC"
  "$ZSTD_SRC"
)

echo "Checking for required source directories."
echo "These will be installed by download_sources.sh and extract_from_tar.sh"
for src in "${required_sources[@]}"; do
  if [[ -d "$src" && "$(ls -A "$src")" ]]; then
    found_reequisite_list+=("source: $src")
  else
    missing_requisite_list+=("source: $src")
  fi
done

# --- Python Modules (non-fatal) ---
optional_py_modules=(re sys os json gzip pathlib shutil time tempfile)

echo "Checking optional Python3 modules."
for mod in "${optional_py_modules[@]}"; do
  if python3 -c "import $mod" &>/dev/null; then
    found_reequisite_list+=("python: module $mod")
  else
    missing_requisite_list+=("python (optional): module $mod")
  fi
done

echo
echo "Summary:"
echo "--------"

# Found tools
for item in "${found_reequisite_list[@]}"; do
  echo "  found: $item"
done

# Missing essentials
for item in "${missing_requisite_list[@]:-}"; do
  echo "❌ missing required tool: $item"
done

# pkg-config failures
for item in "${failed_pkg_config_list[@]:-}"; do
  echo "⚠️ pkg-config could not find: $item"
done

# Final verdict
echo

if [[ ${#missing_requisite_list[@]} -eq 0 && ${#failed_pkg_config_list[@]} -eq 0 ]]; then
  echo "✅ All required tools and libraries found."
else
  echo "❌ Some requisites are missing."

  if [[ ${#failed_pkg_config_list[@]} -gt 0 ]]; then
    echo
    echo "Note: pkg-config did not find some libraries:"
    echo "  These are expected if you are building them from source:"
    echo "  - mpc"
    echo "  - isl"
    echo "  - zstd"
    echo "  If not, consider installing the corresponding dev packages."
    echo "    Debian: sudo apt install libmpc-dev libisl-dev libzstd-dev"
    echo "    Fedora: sudo dnf install libmpc-devel isl-devel libzstd-devel"
  fi
fi


