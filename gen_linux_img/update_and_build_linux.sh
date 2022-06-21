#!/bin/sh

sudo apt update
sudo apt upgrade
sudo apt install flex bison

CROSS_COMPILE_LINUX=/usr/bin/riscv64-linux-gnu-

cd ../linux
git reset --hard HEAD && git clean -d -f
git pull
cd ../gen_linux_img
cp -p patches/fpga-axi-eth.c  ../linux/drivers/net/ethernet
cp -p patches/fpga-axi-sdc.c  ../linux/drivers/mmc/host
cp -p patches/fpga-axi-uart.c ../linux/drivers/tty/serial
cp -p patches/linux.config    ../linux/.config
cp -p patches/linux.patch     ../linux/
sleep 2
cd ../linux
git pull
patch -p1 < linux.patch
echo "> make oldconfig ..."
make ARCH=riscv CROSS_COMPILE=${CROSS_COMPILE_LINUX} oldconfig
echo "> make all ..."
make ARCH=riscv CROSS_COMPILE=${CROSS_COMPILE_LINUX} all