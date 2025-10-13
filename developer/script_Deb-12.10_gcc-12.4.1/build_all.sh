#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

source "$SCRIPT_DIR/environment.sh"

./project_setup.sh 
./project_download.sh
./project_extract.sh
./project_requisites.sh

./mv_libs_to_gcc.sh
./build_gcc.sh

echo "Toolchain build complete"
"$TOOLCHAIN/bin/gcc" --version

# test

./RT_extentions_libcpp_save.sh
./RT_extentions_install.sh
./rebuild_gcc.sh

echo "Toolchain built with RT_extensions installed"
"$TOOLCHAIN/bin/gcc" --version
