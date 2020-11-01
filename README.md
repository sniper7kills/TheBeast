# TheBeast

Documentation for Personal PC Build

## Objectives

This PC was built to meet the following objectives:

- [] Streaming // Media Creation abilities
  - [] Editing Videos
  - [] Live Streaming on Twitch
  - [] Video Capture of other VM's
- [] Gaming
- [] Cyber Secutiy
  - [] Lab Environment
  - [] Linux Distro Install
- [] MacOS

Due to the vast difference in the different objectives, and the need to have multiple running at the same time I decided to go for a fully virtuallized desktop environment.

## Parts

- Monitors: [27\" 4K](https://)
- Case: [BeQuite 900](https://)
- Motherboard: [Gigabyte TRX40 Designare](https://)
- Processor: [AMD ThreadRipper 24 Core](https://)
- RAM: 4x [32G DDR4](https://)
- Storage:
  - 1x [1TB NVME](https://)
  - 3x [1TB SSD](https://)
- Video Cards:
  - 1x [AMD Radeon WX4100](https://)
  - 2x [NVidia 3080 Ti](https://)
- 1x [Black Magic 4HDMI Input](https://)
- Cooling:
  - 2x Radiator
  - Pump
  - CPU Block
  - GPU Block
- Power Supply

## Installation

### Hardware

TODO

### Software

#### **Operating System**

For the operating system, I went with Arch Linux; their [Install Guide](https://https://wiki.archlinux.org/index.php/installation_guide) is amazing, and as such I will only note any differences or specifications specific to my build. (It is also a rolling release system, so the install guide may change in the future.)

##### **Drives**

```bash
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda           8:0    0 953.9G  0 disk /srv/samba/sda
sdb           8:16   0 953.9G  0 disk /srv/samba/sdb
sdc           8:32   0 953.9G  0 disk /srv/samba/sdc
nvme0n1     259:0    0 931.5G  0 disk
├─nvme0n1p1 259:1    0   512M  0 part /boot/efi
├─nvme0n1p2 259:2    0   100G  0 part /
├─nvme0n1p3 259:3    0   400G  0 part /var/lib/libvirt
├─nvme0n1p4 259:4    0   200G  0 part /var/lib/docker
└─nvme0n1p5 259:5    0   200G  0 part /srv/samba
```

I started out with just `p1` & `p2`, slowly building out the system, but this is documentation of the proper state of things

##### **Base Packages**

```bash
pacstrap /mnt base linux linux-firmware vi amd-ucode openssh sudo iwctl
```

##### **Boot Loader**

GRUB was used for the bootloader

#### **Post Install**

Skipping over things such as connecting to wifi, and creating a user.

##### **Setup SSH**

```sh
systemctl enable sshd
systemctl start sshd
```

#### **Virtualization**

##### **Docker**

Docker was super simple to install. (All Defaults were kept)

```sh
sudo su
pacman -S docker docker-compose
systemctl enable docker
```

##### **Libvirt**

Libvirt was the tricky part because I only had a single GPU, but was thankfully able to get access to a copy of the ROM file.

For the most part I followed the guide for [OVMF passthrough](https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF); but am including my specific confugrations.

 `/etc/defaults/grub`

```sh
# GRUB boot loader configuration

GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Arch"
#GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
#video=vesafb:off
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=0 quite vfio-pci.ids=1002:67e3,1002:aae0 amd_iommu=on vfio_iommu_type1.allow_unsafe_interrupts=1 video=efifb:off pcie_aspm=off"
GRUB_CMDLINE_LINUX=""

# Preload both GPT and MBR modules so that they are not missed
GRUB_PRELOAD_MODULES="part_gpt part_msdos"

# Uncomment to enable booting from LUKS encrypted devices
#GRUB_ENABLE_CRYPTODISK=y

# Set to 'countdown' or 'hidden' to change timeout behavior,
# press ESC key to display menu.
GRUB_TIMEOUT_STYLE=menu

# Uncomment to use basic console
GRUB_TERMINAL_INPUT=console

# Uncomment to disable graphical terminal
#GRUB_TERMINAL_OUTPUT=console

# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command `vbeinfo'
GRUB_GFXMODE=auto

# Uncomment to allow the kernel use the same resolution used by grub
GRUB_GFXPAYLOAD_LINUX=keep

# Uncomment if you want GRUB to pass to the Linux kernel the old parameter
# format "root=/dev/xxx" instead of "root=/dev/disk/by-uuid/xxx"
#GRUB_DISABLE_LINUX_UUID=true

# Uncomment to disable generation of recovery mode menu entries
GRUB_DISABLE_RECOVERY=true

# Uncomment and set to the desired menu colors.  Used by normal and wallpaper
# modes only.  Entries specified as foreground/background.
#GRUB_COLOR_NORMAL="light-blue/black"
#GRUB_COLOR_HIGHLIGHT="light-cyan/blue"

# Uncomment one of them for the gfx desired, a image background or a gfxtheme
#GRUB_BACKGROUND="/path/to/wallpaper"
#GRUB_THEME="/path/to/gfxtheme"

# Uncomment to get a beep at GRUB start
#GRUB_INIT_TUNE="480 440 1"

# Uncomment to make GRUB remember the last selection. This requires
# setting 'GRUB_DEFAULT=saved' above.
#GRUB_SAVEDEFAULT="true"
```

`/etc/modprobe.d/vfio.conf`

```sh
options vfio_iommu_type1 allow_unsafe_interrupts=1
```

`/etc/mkinitcpio.conf`

```sh
# vim:set ft=sh
# MODULES
# The following modules are loaded before any boot hooks are
# run.  Advanced users may wish to specify all system modules
# in this array.  For instance:
#     MODULES=(piix ide_disk reiserfs)
MODULES=(vfio_pci vfio vfio_iommu_type1 vfio_virqfd)

# BINARIES
# This setting includes any additional binaries a given user may
# wish into the CPIO image.  This is run last, so it may be used to
# override the actual binaries included by a given hook
# BINARIES are dependency parsed, so you may safely ignore libraries
BINARIES=()

# FILES
# This setting is similar to BINARIES above, however, files are added
# as-is and are not parsed in any way.  This is useful for config files.
FILES=()

# HOOKS
# This is the most important setting in this file.  The HOOKS control the
# modules and scripts added to the image, and what happens at boot time.
# Order is important, and it is recommended that you do not change the
# order in which HOOKS are added.  Run 'mkinitcpio -H <hook name>' for
# help on a given hook.
# 'base' is _required_ unless you know precisely what you are doing.
# 'udev' is _required_ in order to automatically load modules
# 'filesystems' is _required_ unless you specify your fs modules in MODULES
# Examples:
##   This setup specifies all modules in the MODULES setting above.
##   No raid, lvm2, or encrypted root is needed.
#    HOOKS=(base)
#
##   This setup will autodetect all modules for your system and should
##   work as a sane default
#    HOOKS=(base udev autodetect block filesystems)
#
##   This setup will generate a 'full' image which supports most systems.
##   No autodetection is done.
#    HOOKS=(base udev block filesystems)
#
##   This setup assembles a pata mdadm array with an encrypted root FS.
##   Note: See 'mkinitcpio -H mdadm' for more information on raid devices.
#    HOOKS=(base udev block mdadm encrypt filesystems)
#
##   This setup loads an lvm2 volume group on a usb device.
#    HOOKS=(base udev block lvm2 filesystems)
#
##   NOTE: If you have /usr on a separate partition, you MUST include the
#    usr, fsck and shutdown hooks.
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)

# COMPRESSION
# Use this to compress the initramfs image. By default, gzip compression
# is used. Use 'cat' to create an uncompressed image.
#COMPRESSION="gzip"
#COMPRESSION="bzip2"
#COMPRESSION="lzma"
#COMPRESSION="xz"
#COMPRESSION="lzop"
#COMPRESSION="lz4"

# COMPRESSION_OPTIONS
# Additional options for the compressor
#COMPRESSION_OPTIONS=()
```
