#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"
SCRIPT_DIR="$PWD"

echo "loading environment"
source "$SCRIPT_DIR/environment.sh"

cd "$SCRIPT_DIR"

echo "cleaning ..."
  # Run before a rebuild; skips source deletion
  ./clean_build.sh

echo "setting up the project ..."
  # Creates directory structure; idempotent
  ./make_project_structure.sh

echo "downloading and expanding upstream sources"
  # Downloads tarballs and clones repos
  ./download_sources.sh

echo "building binutils"
  ./build_binutils_requisites.sh
  ./build_binutils.sh

echo "Step 3: glibc headers installed"
  ./build_linux_headers.sh
  ./prepare_glibc_sources.sh
  ./build_glibc_headers.sh

echo "Step 4: GCC Stage 1"
  ./build_gcc_stage1_requisites.sh
  ./build_gcc_stage1.sh

echo "Step 5: Build glibc (full libc build)"
  ./build_glibc_requisites.sh
  ./build_glibc.sh

echo "Step 6: Final GCC"
  ./build_gcc_final_requisites.sh
  ./build_gcc_final.sh

echo "✅ Toolchain build complete"
"$TOOLCHAIN/bin/gcc" --version
