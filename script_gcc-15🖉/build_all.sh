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
./project_requisites

./build_binutils_requisites.sh
./build_binutils.sh

./build_linux_requisites.sh
./build_linux.sh

#./build_glibc_bootstrap_requisites.sh
./build_glibc_bootstrap.sh

./build_gcc_stage1_requisites.sh
./build_gcc_stage1.sh

./build_glibc_requisites.sh
./build_glibc.sh

./build_gcc_final_requisites.sh
./build_gcc_final.sh

echo "✅ Toolchain build complete"
"$TOOLCHAIN/bin/gcc" --version
