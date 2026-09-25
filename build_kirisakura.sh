#!/bin/bash

echo
echo "Clean Build Directory"
echo 

#make clean && make mrproper
#rm -rf ./out_cfi

echo
echo "Issue Build Commands"
echo

mkdir -p out_cfi
export ARCH=arm64
export SUBARCH=arm64
export LOCALVERSION=""
if [ -d "/home/sibindev9746_gmail_com/Android_Build" ]; then
    TOOLCHAIN_BASE="/home/sibindev9746_gmail_com/Android_Build"
elif [ -d "/home/sibinsilva1993_gmail_com/quarantine/Android_Build_stray_duplicate_20260814" ]; then
    TOOLCHAIN_BASE="/home/sibinsilva1993_gmail_com/quarantine/Android_Build_stray_duplicate_20260814"
else
    echo "Error: Toolchains not found!"
    exit 1
fi
BASE_PATH=$TOOLCHAIN_BASE/Clang_Google/linux-x86/clang-r450784e
BASE_PATH_GCC=$TOOLCHAIN_BASE/GCC_Google_Arm64
BASE_PATH_GCC_32=$TOOLCHAIN_BASE/GCC_Google_Arm32
export DTC_EXT=/usr/bin/dtc
export CLANG_PATH=$BASE_PATH/clang-r450784e/bin
export PATH=${CLANG_PATH}:${BASE_PATH_GCC}/bin:${BASE_PATH_GCC_32}/bin:${PATH}

export CLANG_TRIPLE=aarch64-linux-gnu-

export CROSS_COMPILE=$BASE_PATH_GCC/bin/aarch64-linux-android-
export CROSS_COMPILE_COMPAT=$BASE_PATH_GCC_32/bin/arm-linux-androideabi-
export CROSS_COMPILE_ARM32=$BASE_PATH_GCC_32/bin/arm-linux-androideabi-

export CLANG_AR=$CLANG_PATH/llvm-ar
export CLANG_CC=$CLANG_PATH/clang
export CLANG_CCXX=$CLANG_PATH/clang++
export CLANG_LD=$CLANG_PATH/ld.lld
export CLANG_LDLTO=$CLANG_PATH/ld.lld
export CLANG_NM=$CLANG_PATH/llvm-nm
export CLANG_STRIP=$CLANG_PATH/llvm-strip
export CLANG_OC=$CLANG_PATH/llvm-objcopy
export CLANG_OD=$CLANG_PATH/llvm-objdump
export CLANG_OS=$CLANG_PATH/llvm-size
export CLANG_RE=$CLANG_PATH/llvm-readelf

export CC=$CLANG_CC
export HOST_CC=$CLANG_CC
export LD=$CLANG_LD

export ASUS_BUILD_PROJECT=ZS673KS
export ASUS_ZS673KS_PROJECT

MAKE_ARGS="ARCH=arm64 SUBARCH=arm64 LLVM=1 CLANG_TRIPLE=aarch64-linux-gnu- \
  CROSS_COMPILE=$CROSS_COMPILE CROSS_COMPILE_COMPAT=$CROSS_COMPILE_COMPAT CROSS_COMPILE_ARM32=$CROSS_COMPILE_ARM32 \
  CC=$CLANG_CC LD=$CLANG_LD AR=$CLANG_AR STRIP=$CLANG_STRIP OBJCOPY=$CLANG_OC NM=$CLANG_NM \
  OBJDUMP=$CLANG_OD OBJSIZE=$CLANG_OS READELF=$CLANG_RE HOSTCC=$CLANG_CC HOSTCXX=$CLANG_CCXX \
  HOSTAR=$CLANG_AR HOSTLD=$CLANG_LD O=out_cfi"

echo
echo "Set DEFCONFIG"
echo 

make $MAKE_ARGS kirisakura_defconfig

echo
echo "Build The Good Stuff"
echo 

make $MAKE_ARGS -j$(nproc)
