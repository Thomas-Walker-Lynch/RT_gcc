#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "📦 Checking requisites for binutils (bootstrap)."

missing_requisite_list=()
found_requisite_list=()

# tool required for build
#
  required_tools=(
    "gcc"
    "g++"
    "make"
  )

  for tool in "${required_tools[@]}"; do
    location=$(command -v "$tool")  # Fixed this part to use $tool instead of "tool"
    if [ $? -eq 0 ]; then  # Check if the command was successful
      found_requisite_list+=("$location")
    else
      missing_requisite_list+=("$tool")
    fi
  done

# source code required for build
#
  if [ -d "$BINUTILS_SRC" ] && [ "$(ls -A "$BINUTILS_SRC")" ]; then
    found_requisite_list+=("$BINUTILS_SRC")
  else
    missing_requisite_list+=("$BINUTILS_SRC")
  fi

# print requisites found
#
  if (( ${#found_requisite_list[@]} != 0 )); then
    echo "found:"
    for found_requisite in "${found_requisite_list[@]}"; do
      echo "  $found_requisite"
    done
  fi

# print requisites missing
#
  if (( ${#missing_requisite_list[@]} != 0 )); then
    echo "missing:"
    for missing_requisite in "${missing_requisite_list[@]}"; do
      echo "  $missing_requisite"
    done
  fi

# in conclusion
#
  if (( ${#missing_requisite_list[@]} > 0 )); then
    echo "❌ Missing requisites"
    exit 1
  else
    echo "✅ All checked specified requisites found"
    exit 0
  fi
