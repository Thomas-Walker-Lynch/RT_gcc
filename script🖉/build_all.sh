#!/bin/bash
set -euo pipefail

echo "loading environment"
source "$SCRIPT_DIR/environment.sh"



echo "cleaning ..."
  # will force download of sources:
  # bash "$SCRIPT_DIR/clean_dist.sh"

  bash "$SCRIPT_DIR/clean_build.sh"

echo "setting up the project ..."
  bash "$SCRIPT_DIR/make_project_structure.sh"

echo "downloading and expanding upstream sources"
  bash "SCRIPT_DIR/download_expand_sources.sh"

echo "building binutils"
bash "$SCRIPT_DIR/build_binutils_requisites.sh"
bash "$SCRIPT_DIR/build_binutils.sh"

echo "Step 3: glibc headers installed"
# These provide just enough to bootstrap GCC Stage 1
bash "$SCRIPT_DIR/build_linux_headers.sh"
bash "$SCRIPT_DIR/prepare_glibc_sources.sh"
bash "$SCRIPT_DIR/build_glibc_headers.sh"


echo "Step 4: GCC Stage 1"
bash "$SCRIPT_DIR/build_gcc_stage1_requisites.sh"
bash "$SCRIPT_DIR/build_gcc_stage1.sh"

echo "Step 5: Build glibc (full libc build)"
bash "$SCRIPT_DIR/build_glibc_requisites.sh"
bash "$SCRIPT_DIR/build_glibc.sh"


echo "Step 6: Final GCC"
bash "$SCRIPT_DIR/build_gcc_final_requisites.sh"
bash "$SCRIPT_DIR/build_gcc_final.sh"


echo "🎉 Toolchain build complete!"
"$TOOLCHAIN/bin/gcc" --version
