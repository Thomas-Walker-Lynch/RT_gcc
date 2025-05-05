#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
SCRIPT_DIR="$PWD"

echo "loading environment"
source "$SCRIPT_DIR/environment.sh"

cd "$SCRIPT_DIR"

./project_setup.sh 
./project_download.sh
./project_extract.sh
./project_requisites.sh

./mv_libs_to_gcc.sh
./build_gcc.sh

echo "Toolchain build complete"
"$TOOLCHAIN/bin/gcc" --version
