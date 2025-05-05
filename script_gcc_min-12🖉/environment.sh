# === environment.sh ===
# Source this file in each build script to ensure consistent paths and settings

echo "ROOT: $ROOT"
cd $SCRIPT_DIR

#--------------------------------------------------------------------------------
# tools

  # machine target
  export HOST=$(gcc -dumpmachine)

  export MAKE_JOBS=$(getconf _NPROCESSORS_ONLN)
  export MAKE=make

  # Compiler path prefixes
  export CC_FOR_BUILD=$(command -v gcc)
  export CXX_FOR_BUILD=$(command -v g++)

#--------------------------------------------------------------------------------
# Tool and library versions (optimized build with Graphite and LTO compression)

  export GCC_VER=12.2.0       # GCC version to build
  export GMP_VER=6.2.1        # Sufficient for GCC 12.2
  export MPFR_VER=4.1.0       # Stable version compatible with GCC 12.2
  export MPC_VER=1.2.1        # Recommended for GCC 12.2
  export ISL_VER=0.24         # GCC 12.x infra uses this; don't use 0.26+ unless patched
  export ZSTD_VER=1.5.5       # zstd compression for LTO bytecode

#--------------------------------------------------------------------------------
# project structure

  # temporary directory
  export TMPDIR="$ROOT/tmp"

  # Project directories
  export SYSROOT="$ROOT/sysroot"
  export TOOLCHAIN="$ROOT/toolchain"
  export BUILD_DIR="$ROOT/build"
  export LOGDIR="$ROOT/log"
  export UPSTREAM="$ROOT/upstream"
  export SRC=$ROOT/source

  # Synthesized directory lists
  PROJECT_DIR_LIST=(
    "$LOGDIR"
    "$SYSROOT" "$TOOLCHAIN" "$BUILD_DIR"
    "$UPSTREAM" "$SRC"
  )
  # list these in the order they can be deleted
  PROJECT_SUBDIR_LIST=(
    "$SYSROOT/usr/lib"
    "$SYSROOT/lib"
    "$SYSROOT/usr/include"
  )

#--------------------------------------------------------------------------------
# upstream -> local stuff

  # see top of this file for the _VER variables

  # Tarball Download Info (Name, URL, Destination Directory)
  export UPSTREAM_TARBALL_LIST=(
    "gmp-${GMP_VER}.tar.xz"
    "https://ftp.gnu.org/gnu/gmp/gmp-${GMP_VER}.tar.xz"
    "$UPSTREAM/gmp-$GMP_VER"

    "mpfr-${MPFR_VER}.tar.xz"
    "https://www.mpfr.org/mpfr-${MPFR_VER}/mpfr-${MPFR_VER}.tar.xz"
    "$UPSTREAM/mpfr-$MPFR_VER"

    "mpc-${MPC_VER}.tar.gz"
    "https://ftp.gnu.org/gnu/mpc/mpc-${MPC_VER}.tar.gz"
    "$UPSTREAM/mpc-$MPC_VER"

    "isl-${ISL_VER}.tar.bz2"
    "https://libisl.sourceforge.io/isl-${ISL_VER}.tar.bz2"
    "$UPSTREAM/isl-$ISL_VER"

    "zstd-${ZSTD_VER}.tar.zst"
    "https://github.com/facebook/zstd/releases/download/v${ZSTD_VER}/zstd-${ZSTD_VER}.tar.zst"
    "$UPSTREAM/zstd-$ZSTD_VER"
  )

  # Git Repo Info
  # Each entry is triple: Repository URL, Branch, Destination Directory
  export UPSTREAM_GIT_REPO_LIST=(

    "git://gcc.gnu.org/git/gcc.git"
    "releases/gcc-12"
    "$SRC/gcc-$GCC_VER"

     #no second repo entry
  )

#--------------------------------------------------------------------------------
# source

  # Source directories
  export GCC_SRC="$SRC/gcc-$GCC_VER"
  export GMP_SRC="$SRC/gmp-$GMP_VER"
  export MPFR_SRC="$SRC/mpfr-$MPFR_VER"
  export MPC_SRC="$SRC/mpc-$MPC_VER"
  export ISL_SRC="$SRC/isl-$ISL_VER"
  export ZSTD_SRC="$SRC/zstd-$ZSTD_VER"

  SOURCE_DIR_LIST=(
    "$GCC_SRC"
    "$GMP_SRC"
    "$MPFR_SRC"
    "$MPC_SRC"
    "$ISL_SRC"
    "$ZSTD_SRC"
  )

#--------------------------------------------------------------------------------
# build

  # Build directories
  export GCC_BUILD="$BUILD_DIR/gcc"
  BUILD_DIR_LIST=(
    "$GCC_BUILD"
  )



