#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/environment.sh"

echo "📦 Checking prerequisites for binutils (bootstrap)..."

required_tools=(gcc g++ make curl tar xz)
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

echo -e "✅ All required tools found: ${required_tools[*]}"


