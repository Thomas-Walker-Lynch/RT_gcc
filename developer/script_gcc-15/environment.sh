# === environment.sh ===
# Source this file in each build script to ensure consistent paths and settings

echo "ROOT: $ROOT"
cd $SCRIPT_DIR

#--------------------------------------------------------------------------------
# tools

  # machine target
  export HOST=$(gcc -dumpmachine)

#  export MAKE_JOBS=$(nproc)
#  export MAKE="make -j$MAKE_JOBS"
  export MAKE_JOBS=$(getconf _NPROCESSORS_ONLN)
  export MAKE=make


  # Compiler path prefixes
  export CC_FOR_BUILD=$(command -v gcc)
  export CXX_FOR_BUILD=$(command -v g++)

#--------------------------------------------------------------------------------
# tool versions

  export LINUX_VER=6.8
  export BINUTILS_VER=2.42
  export GCC_VER=15.1.0
  export GLIBC_VER=2.39

  # Library versions: required minimums or recommended tested versions
  export GMP_VER=6.3.0      # Compatible with GCC 15, latest stable from GMP site
  export MPFR_VER=4.2.1      # Latest stable, tested with GCC 15
  export MPC_VER=1.3.1       # Works with GCC 15, matches default in-tree
  export ISL_VER=0.26        # Matches upstream GCC infrastructure repo
  export ZSTD_VER=1.5.5      # Stable release, supported by GCC for LTO compression

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

  # Source directories
  export LINUX_SRC="$SRC/linux-$LINUX_VER"
  export BINUTILS_SRC="$SRC/binutils-$BINUTILS_VER"
  export GCC_SRC="$SRC/gcc-$GCC_VER"
  export GLIBC_SRC="$SRC/glibc-$GLIBC_VER"
  export GMP_SRC="$SRC/gmp-$GMP_VER"
  export MPFR_SRC="$SRC/mpfr-$MPFR_VER"
  export MPC_SRC="$SRC/mpc-$MPC_VER"
  export ISL_SRC="$SRC/isl-$ISL_VER"
  export ZSTD_SRC="$SRC/zstd-$ZSTD_VER"

  SOURCE_DIR_LIST=(
    "$LINUX_SRC"
    "$BINUTILS_SRC"
    "$GCC_SRC"
    "$GLIBC_SRC"
    "$GMP_SRC"
    "$MPFR_SRC"
    "$MPC_SRC"
    "$ISL_SRC"
    "$ZSTD_SRC"
  )

  # Build directories
  export BINUTILS_BUILD="$BUILD_DIR/binutils"
  export GCC_BUILD_STAGE1="$BUILD_DIR/gcc-stage1"
  export GCC_BUILD_FINAL="$BUILD_DIR/gcc-final"
  export GLIBC_BUILD="$BUILD_DIR/glibc"
  BUILD_DIR_LIST=(
    "$BINUTILS_BUILD"
    "$GCC_BUILD_STAGE1"
    "$GCC_BUILD_FINAL"
    "$GLIBC_BUILD"
  )

#--------------------------------------------------------------------------------
# upstream -> local stuff

  # see top of this file for the _VER variables

  # Tarball Download Info (Name, URL, Destination Directory)
  export UPSTREAM_TARBALL_LIST=(
    "linux-${LINUX_VER}.tar.xz"
    "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${LINUX_VER}.tar.xz"
    "$UPSTREAM/linux-$LINUX_VER"

    "binutils-${BINUTILS_VER}.tar.xz"
    "https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.xz"
    "$UPSTREAM/binutils-$BINUTILS_VER"

     # using repo
     # "gcc-${GCC_VER}.tar.xz"
     # "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz"
     # "$UPSTREAM/gcc-$GCC_VER"

    "glibc-${GLIBC_VER}.tar.xz"
    "https://ftp.gnu.org/gnu/libc/glibc-${GLIBC_VER}.tar.xz"
    "$UPSTREAM/glibc-$GLIBC_VER"

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
#    "https://gcc.gnu.org/pub/gcc/infrastructure/isl-${ISL_VER}.tar.bz2"
     "https://libisl.sourceforge.io/isl-0.26.tar.bz2"
#    "https://github.com/Meinersbur/isl/archive/refs/tags/isl-0.26.tar.gz"
    "$UPSTREAM/isl-$ISL_VER"

    "zstd-${ZSTD_VER}.tar.zst"
    "https://github.com/facebook/zstd/releases/download/v${ZSTD_VER}/zstd-${ZSTD_VER}.tar.zst"
    "$UPSTREAM/zstd-$ZSTD_VER"
  )


  # Git Repo Info
  # Each entry is triple:  Repository URL, Branch, Destination Directory
  # Repos clone directly into $SRC
  export UPSTREAM_GIT_REPO_LIST=(

    "git://gcc.gnu.org/git/gcc.git"
    "releases/gcc-15"
    "$SRC/gcc-$GCC_VER"

     #currently there is no second repo   
  )


