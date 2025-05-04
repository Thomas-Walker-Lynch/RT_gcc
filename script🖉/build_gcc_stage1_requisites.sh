#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "📦 Checking prerequisites for stage 1 GCC (bootstrap)..."

required_tools=(gcc g++ make tar gawk bison flex)
missing=()

for tool in "${required_tools[@]}"; do
  if ! type -P "$tool" &>/dev/null; then
    missing+=("$tool")
  fi
done

if (( ${#missing[@]} )); then
  echo "❌ Missing required tools: ${missing[*]}"
  exit 1
fi

if [ ! -d "$GCC_SRC" ]; then
  echo "❌ GCC source not found at $GCC_SRC"
  echo "💡 You may need to run: prepare_gcc_sources.sh"
  exit 1
fi

echo "✅ Prerequisites for stage 1 GCC met."
