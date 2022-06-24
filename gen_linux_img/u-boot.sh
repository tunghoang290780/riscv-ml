#!/bin/sh

CROSS_COMPILE_LINUX=/usr/bin/riscv64-linux-gnu-

# u-boot: u-boot/u-boot-nodtb.bin

# U_BOOT_SRC = $(wildcard patches/u-boot/*/*) \
#   patches/u-boot/vivado_riscv64_defconfig \
#   patches/u-boot/vivado_riscv64.h \
#   patches/u-boot.patch

# cp patches/u-boot/vivado_riscv64_defconfig u-boot/configs

# u-boot/configs/vivado_riscv64_defconfig: patches/u-boot/vivado_riscv64_defconfig Makefile
# 	cp patches/u-boot/vivado_riscv64_defconfig u-boot/configs
# ifeq ($(ROOTFS),NFS)
# 	echo 'CONFIG_USE_BOOTARGS=y' >>u-boot/configs/vivado_riscv64_defconfig
# 	echo 'CONFIG_BOOTCOMMAND="booti $${kernel_addr_r} - $${fdt_addr}"' >>u-boot/configs/vivado_riscv64_defconfig
# 	echo 'CONFIG_BOOTARGS="root=/dev/nfs rootfstype=nfs rw nfsroot='$(ROOTFS_URL)',nolock,vers=4,tcp ip=dhcp earlycon console=ttyAU0,115200n8 locale.LANG=en_US.UTF-8"' >>u-boot/configs/vivado_riscv64_defconfig


# u-boot-patch: u-boot/configs/vivado_riscv64_defconfig
# 	if [ -s patches/u-boot.patch ] ; then cd u-boot && ( git apply -R --check ../patches/u-boot.patch 2>/dev/null || git apply ../patches/u-boot.patch ) ; fi
# 	cp -p -r patches/u-boot/vivado_riscv64 u-boot/board/xilinx
# 	cp -p patches/u-boot/vivado_riscv64.h u-boot/include/configs

# u-boot/u-boot-nodtb.bin: u-boot-patch $(U_BOOT_SRC)
# 	make -C u-boot CROSS_COMPILE=${CROSS_COMPILE_LINUX} BOARD=vivado_riscv64 vivado_riscv64_config
# 	make -C u-boot \
# 	  BOARD=vivado_riscv64 \
# 	  CC=${CROSS_COMPILE_LINUX}gcc-11 \
# 	  CROSS_COMPILE=${CROSS_COMPILE_LINUX} \
# 	  KCFLAGS='-O1 -gno-column-info' \
# 	  all