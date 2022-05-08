# Build Linux 

## Additional steps to build Linux and burn image to sdcard

> Project is using build process from : https://github.com/cnrv/fpga-rocket-chip  

## Add Xilinx drivers to linux path
|DRIVER | PATH |
|-|-|
|spi-xilinx.c | <linux_dir>/drivers/spi |
|sdio.c | <linux_dir>/drivers/mmc/core/sdio.c |
|uartlite.c | <linux_dir>/drivers/tty/serial | 
* [uart](https://github.com/Xilinx/linux-xlnx/blob/master/drivers/tty/serial/uartlite.c)
* [sdio](https://github.com/Xilinx/linux-xlnx/blob/master/drivers/mmc/core/sdio.c)

### For [DTS step](https://github.com/cnrv/fpga-rocket-chip#13-preparing-the-project) please paste content of bootrom.dts to bbl file 
### Skip step [Adding Peri IPs](https://github.com/cnrv/fpga-rocket-chip)


## After Linux build -> check generated files :
1) rootfs.cpio.gz
2) boot.elf

## Create sdcard :
   ```
   # fdisk /dev/sdX

   Command (m for help): p
   Disk /dev/sdX: 29.74 GiB, 31914983424 bytes, 62333952 sectors
   Disk model: SD/MMC
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: dos
   Disk identifier: 0x67f480f9

   Device     Boot   Start      End  Sectors  Size Id Type
   /dev/sdX1          2048  2099199  2097152    1G  6 FAT16
   ...
   ```

   * Format the partition, mount it, and copy `rootfs.cpio.gz , bootl.elf` to it:

   ```
   mkdosfs /dev/sdX1
   mount /dev/sdX1 /mnt
   cp boot.elf rootfs.cpio.gz /mnt
   cd /mnt
   gzip -d rootfs.cpio.gz
   sync
   umount /mnt
   ```

