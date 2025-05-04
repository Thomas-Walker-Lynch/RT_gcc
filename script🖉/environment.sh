# === environment.sh ===
# Source this file in each build script to ensure consistent paths and settings

echo "ROOT: $ROOT"
cd $SCRIPT_DIR

#--------------------------------------------------------------------------------
# tool versions

  export LINUX_VER=6.8
  export BINUTILS_VER=2.42
  export GCC_VER=15.1.0
  export GLIBC_VER=2.39

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

  # Synthesized directory lists
  PROJECT_DIR_LIST=(
    "$LOGDIR"
    "$SYSROOT" "$TOOLCHAIN" "$BUILD_DIR"
    "$UPSTREAM"
  )
  # list these in the order they can be deleted
  PROJECT_SUBDIR_LIST=(
    "$SYSROOT/usr/lib"
    "$SYSROOT/lib"
    "$SYSROOT/usr/include"
  )

  # Source directories
  export SRC=$ROOT/source
  export LINUX_SRC="$SRC/linux-$LINUX_VER"
  export BINUTILS_SRC="$SRC/binutils-$BINUTILS_VER"
  export GCC_SRC="$SRC/gcc-$GCC_VER"
  export GLIBC_SRC="$SRC/glibc-$GLIBC_VER"
  SOURCE_DIR_LIST=(
    "$LINUX_SRC"
    "$BINUTILS_SRC"
    "$GCC_SRC"
    "$GLIBC_SRC"
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

  # Tarballs
  export LINUX_TARBALL="linux-${LINUX_VER}.tar.xz"
  export BINUTILS_TARBALL="binutils-${BINUTILS_VER}.tar.gz"
  export GLIBC_TARBALL="glibc-${GLIBC_VER}.tar.gz"

  # Tarball Download Info (Name, URL, Destination Directory)
  export UPSTREAM_TARBALL_LIST=(
    "$LINUX_TARBALL"
    "https://cdn.kernel.org/pub/linux/kernel/v6.x/$LINUX_TARBALL"
    "$ROOT/linux-$LINUX_VER"
    
    "$BINUTILS_TARBALL"
    "https://ftp.gnu.org/gnu/binutils/$BINUTILS_TARBALL"
    "$ROOT/binutils-$BINUTILS_VER"
    
    "$GLIBC_TARBALL"
    "https://ftp.gnu.org/gnu/libc/$GLIBC_TARBALL"
    "$ROOT/glibc-$GLIBC_VER"
  )

  # Git Repositories (URL, Branch, Destination Directory)
  export GCC_REPO="git://gcc.gnu.org/git/gcc.git"
  export GCC_BRANCH="releases/gcc-15"

  # Git Repo Info: Repository URL, Branch, Destination Directory
  export UPSTREAM_GIT_REPO_LIST=(

    "$GCC_REPO"
    "$GCC_BRANCH"
    "$ROOT/gcc-$GCC_VER"

     #currently there is no second repo   
  )
 


#--------------------------------------------------------------------------------
# tools

  # machine target
  export HOST=$(gcc -dumpmachine)

  export MAKE_JOBS=$(nproc)
  export MAKE="make -j$MAKE_JOBS"

  # Compiler path prefixes
  export CC_FOR_BUILD=$(command -v gcc)
  export CXX_FOR_BUILD=$(command -v g++)

