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
if [ -d "$HOME/toolchains/clang/bin" ]; then
    CLANG_PATH="$HOME/toolchains/clang/bin"
    BASE_PATH_GCC="$HOME/toolchains/gcc-arm64"
    BASE_PATH_GCC_32="$HOME/toolchains/gcc-arm32"
elif [ -d "$PWD/toolchains/clang/bin" ]; then
    CLANG_PATH="$PWD/toolchains/clang/bin"
    BASE_PATH_GCC="$PWD/toolchains/gcc-arm64"
    BASE_PATH_GCC_32="$PWD/toolchains/gcc-arm32"
elif [ -d "/home/sibindev9746_gmail_com/Android_Build" ]; then
    BASE_PATH=/home/sibindev9746_gmail_com/Android_Build/Clang_Google/linux-x86/clang-r450784e
    BASE_PATH_GCC=/home/sibindev9746_gmail_com/Android_Build/GCC_Google_Arm64
    BASE_PATH_GCC_32=/home/sibindev9746_gmail_com/Android_Build/GCC_Google_Arm32
    CLANG_PATH=$BASE_PATH/clang-r450784e/bin
else
    BASE_PATH=/home/sibinsilva1993_gmail_com/Android_Build/Clang_Google/linux-x86/clang-r450784e
    BASE_PATH_GCC=/home/sibinsilva1993_gmail_com/Android_Build/GCC_Google_Arm64
    BASE_PATH_GCC_32=/home/sibinsilva1993_gmail_com/Android_Build/GCC_Google_Arm32
    CLANG_PATH=$BASE_PATH/clang-r450784e/bin
fi

export DTC_EXT=$(which dtc 2>/dev/null || echo "/usr/bin/dtc")
export PATH=${CLANG_PATH}:${BASE_PATH_GCC}/bin:${BASE_PATH_GCC_32}/bin:${PATH}

export CLANG_TRIPLE=aarch64-linux-gnu-

export CROSS_COMPILE=$BASE_PATH_GCC/bin/aarch64-linux-android-
export CROSS_COMPILE_COMPAT=$BASE_PATH_GCC_32/bin/arm-linux-androideabi-
export CROSS_COMPILE_ARM32=$BASE_PATH_GCC_32/bin/arm-linux-androideabi-

#export CROSS_COMPILE=$BASE_PATH/gas-linux-x86/aarch64-linux-gnu-
#export CROSS_COMPILE_ARM32=$BASE_PATH/gas-linux-x86/arm-linux-gnueabi-
#export CROSS_COMPILE_COMPAT=$CROSS_COMPILE_ARM32
#export LLVM_IAS=1

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

if command -v ccache >/dev/null 2>&1; then
    export CC="ccache $CLANG_CC"
    export USE_CCACHE=1
else
    export CC=$CLANG_CC
fi
if [ -d "$HOME/.local/opt/tools" ]; then
    export HOST_CC="$CLANG_CC --gcc-toolchain=$HOME/.local/opt/tools/usr -B$HOME/.local/opt/tools/usr/lib/gcc/x86_64-linux-gnu/15 -isystem $HOME/.local/opt/tools/usr/include -L$HOME/.local/opt/tools/usr/lib/x86_64-linux-gnu"
    export HOST_CXX="$CLANG_CCXX --gcc-toolchain=$HOME/.local/opt/tools/usr -B$HOME/.local/opt/tools/usr/lib/gcc/x86_64-linux-gnu/15 -isystem $HOME/.local/opt/tools/usr/include -L$HOME/.local/opt/tools/usr/lib/x86_64-linux-gnu"
    export LD_LIBRARY_PATH=$HOME/.local/opt/tools/usr/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH}
    export HOSTLDFLAGS="-L$HOME/.local/opt/tools/usr/lib/x86_64-linux-gnu"
else
    export HOST_CC=$CLANG_CC
    export HOST_CXX=$CLANG_CCXX
fi
export LD=$CLANG_LD

export ASUS_BUILD_PROJECT=ZS673KS
export ASUS_ZS673KS_PROJECT

#export LLVM=1

echo "Generating binary conversions"
#cd binaries
#./convert
#cd ..

echo
echo "Set DEFCONFIG"
echo 

#make CC=$CLANG_CC LD=$CLANG_LD LDLTO=$CLANG_LD AR=$CLANG_AR NM=$CLANG_NM OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip O=out_cfi kirisakura_defconfig
make LLVM=1 CC="$CC" LD=$CLANG_LD AR=$CLANG_AR STRIP=$CLANG_STRIP OBJCOPY=$CLANG_OC NM=$CLANG_NM OBJDUMP=$CLANG_OD OBJSIZE=$CLANG_OS READELF=$CLANG_RE HOSTCC="$HOST_CC" HOSTCXX="$HOST_CXX" HOSTAR=$CLANG_AR HOSTLD=$CLANG_LD HOSTLDFLAGS="$HOSTLDFLAGS" O=out_cfi kirisakura_defconfig
#make O=out_cfi kirisakura_defconfig

echo
echo "Build The Good Stuff"
echo 

#make CC=$CLANG_CC LD=$CLANG_LD LDLTO=$CLANG_LD AR=$CLANG_AR NM=$CLANG_NM OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip O=out_cfi -j24
make LLVM=1 CC="$CC" LD=$CLANG_LD AR=$CLANG_AR STRIP=$CLANG_STRIP OBJCOPY=$CLANG_OC NM=$CLANG_NM OBJDUMP=$CLANG_OD OBJSIZE=$CLANG_OS READELF=$CLANG_RE HOSTCC="$HOST_CC" HOSTCXX="$HOST_CXX" HOSTAR=$CLANG_AR HOSTLD=$CLANG_LD HOSTLDFLAGS="$HOSTLDFLAGS" O=out_cfi -j$(nproc)
#make O=out_cfi -j$(nproc)
