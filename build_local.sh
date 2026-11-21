#!/bin/bash

export PATH="/root/samsung/toolchains/clang-11.0.1/bin:$PATH"
export ARCH=arm64
export SUBARCH=arm64
export CC=clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

make -C $(pwd) O=$(pwd)/out ARCH=arm64 CC=clang a04e_defconfig
make -C $(pwd) O=$(pwd)/out ARCH=arm64 CC=clang olddefconfig
make -C $(pwd) O=$(pwd)/out ARCH=arm64 CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip -j4

cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image
