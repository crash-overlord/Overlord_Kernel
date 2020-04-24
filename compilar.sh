#!/bin/bash
cd /home/crash-overlord/Overlord-Kernel/New-cam-new-sources/kernel_sdm660/
echo "Limpiando basura de la ultima Compilacion"
make clean 
make mrproper
rm out/arch/arm64/boot/Image.gz-dtb
rm out/arch/arm64/boot/*.gz

echo "Agregando compiladores y variables"
KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb"
TANGGAL=$(date +"%Y%m%d-%H")
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PATH="/home/crash-overlord/Overlord-Kernel/toolchains/clang/bin:/home/crash-overlord/Overlord-Kernel/toolchains/gcc/bin:/home/crash-overlord/Overlord-Kernel/toolchains/gcc32/bin:${PATH}"
export KBUILD_COMPILER_STRING="/home/crash-overlord/Overlord-Kernel/toolchains/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export KBUILD_BUILD_USER=Crash-Overlord
export KBUILD_BUILD_HOST=Crash-Pc 

echo "Compilando configuraciones"
make -j$(nproc) O=out ARCH=arm64 lavender-perf_defconfig

echo "Compilando nucleo"
make -j$(nproc) O=out \
                    ARCH=arm64 \
                    CC=clang \
                    CLANG_TRIPLE=aarch64-linux-gnu- \
                    CROSS_COMPILE=aarch64-linux-android- \
                    CROSS_COMPILE_ARM32=arm-linux-androideabi-

echo "Limpiando y copiando imagen a Anykernel"

echo "Limpiando"
rm /home/crash-overlord/Overlord-Kernel/toolchains/AnyKernel/Image.gz-dtb
rm /home/crash-overlord/Overlord-Kernel/toolchains/AnyKernel/*.zip
echo "Copiando imagen"
cp out/arch/arm64/boot/Image.gz-dtb /home/crash-overlord/Overlord-Kernel/toolchains/AnyKernel/

echo "Compilando zip Overlord-Kernel"
cd /home/crash-overlord/Overlord-Kernel/toolchains/AnyKernel/
make
cd ..
cd ..
cd New-cam-new-sources/kernel_sdm660/out

echo "Limpiando basura de la ultima Compilacion"
make clean
make mrproper
cd ..
make clean
make mrproper
rm out/arch/arm64/boot/Image.gz-dtb
rm out/arch/arm64/boot/*.gz

echo "organizando git"
git add .

echo "Operacion terminada"
