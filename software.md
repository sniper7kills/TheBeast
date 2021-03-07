# Software

[TOC]

## Overview

To enable virtualization, I choose to use libvirt (KVM) and docker virtualization.

KVM guests will be able to have a GPU passed though using PCI passthough so each VM I'm actively running can have its own dedicated graphics.

## Install Guide

Boot into the Arch Linux install environment.

### Base Install

Partition the drives as the following:

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

> NOTE: During install they should be mounted to `/mnt` not `/`. This output is from post install.

Mount Partitions for install

```bash
# Root partition
mount /dev/nvme0n1p2 /mnt
# EFI partition
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount /dev/nvme0n1p1 mnt/efi
# libvirt partition
mkdir /mnt/lib
mkdir /mnt/lib/libvirt
mount /dev/nvme0n1p3 /mnt/lib/libvirt
# docker partition
mkdir /mnt/lib/docker
mount /dev/nvme0n1p4 /mnt/lib/docker
# samba partition
mkdir /mnt/srv
mkdir /mnt/srv/samba
mount /dev/nvme0n1p5 /mnt/srv/samba
# sda
mkdir /mnt/srv/samba/sda
mount /dev/sda /mnt/srv/samba/sda
# sdb
mkdir /mnt/srv/samba/sdb
mount /dev/sdb /mnt/srv/samba/sdb
# sdc
mkdir /mnt/srv/samba/sdc
mount /dev/sdc /mnt/srv/samba/sdc
```

Pacstrap the base operating system.

```bash
pacstrap /mnt base linux linux-firmware iwd vi git sudo amd-ucode libvirt docker samba grub efibootmgr
```

Generate the filesystem

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

Change Root and finalize install

```bash
# Change into the new root
arch-chroot /mnt

# Get our isntall files
cd /opt
git clone https://github.com/sniper7kills/TheBeast.git
cd TheBeast

# Set TZ
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc

# Localization
cp ./etc/locale.gen /etc/locale.gen
locale-gen
cp ./etc/locale.conf /etc/locale.conf

# Hostname
cp ./etc/hostname /etc/hostname
cp ./etc/hosts /etc/hosts

# Enable iwd
systemctl enable iwd

# SSH Server
cp ./etc/ssh/sshd_config /etc/ssh/sshd_config
systemctl enable sshd

# configure sudo
cp ./etc/sudoers /etc/sudoers

# Initramfs
mkinitcpio -P

# Set Root password
passwd

# GRUB Install
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

exit
umount -R /mnt
reboot
```

After rebooting login and ensure you have networking.
If anything didn't install as expected, debug.

### User Creation

```bash
# Create user
useradd -m sniper7kills
# Give user sudo rights
usermod -aG wheel sniper7kills
```


### Viertualization setup

> NOTE `lspci --nnk` will show the needed ID's

**Example**

```bash
lspci -nnk
49:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Baffin [Radeon Pro WX 4100] [1002:67e3]
        Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Device [1002:0b0d]
        Kernel driver in use: amdgpu
        Kernel modules: amdgpu
49:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AMD/ATI] Baffin HDMI/DP Audio [Radeon RX 550 640SP / RX 560/560X] [1002:aae0]
        Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Baffin HDMI/DP Audio [Radeon RX 550 640SP / RX 560/560X] [1002:aae0]
        Kernel driver in use: snd_hda_intel
        Kernel modules: snd_hda_intel
# We need to take note of the following numbers `[1002:67e3]` and `[1002:aae0]` as we will use them to tell vfio to intercept these devices from their drivers.
```

```bash
# Install Required Packages
pacman -S qemu libvirt edk2-ovmf virt-manager ebstables dnsmasq
systemctl enable libvirtd virtlogd

# Copy vfio config files
cd /opt/TheBeast
# modprobe.d
cp ./etc/modprobe.d/vfio.conf /etc/modprobe.d/vfio.conf

# mkinitcpio
cp ./etc/mkinitcpio.conf /etc/mkinitcpio.conf
mkinitcpio -P

# Grub kernel lines Update
cp ./etc/default/grub /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Give user permissions for libvirt
usermod -aG libvirt sniper7kills
```

Before rebooting (Because this will remove any display) ensure that you are able to SSH into the box, and launch `virt-manager` with X11 Forwarding.
If you do not, fix this issue before rebooting.

Once the PC is rebooted, there will be no console displayed on the screens. Remote into the PC using ssh.

```bash
cd /opt/TheBeast
mkdir /var/lib/libvirt/roms
cp ./var/lib/libvirt/roms/AMD_Radeon_Pro_WX_4100.rom /var/lib/libivrt/roms/AMD_Radeon_Pro_WX_4100.rom

# Copy Windows 10 Install disk to /var/lib/libvirt/images/
virt-manager
```

At this point the `virt-manager` GUI will pop up.
Create a new VM, and at the final step check the `customize` box.

Remove all of the virtual displays, console, etc.

Add a PCI device(s) // USB Devices

#### libvirt XML Examples

##### AMD Radeon Pro WX 4100

`0000:49:00:0 Advanced Micro Devices, Inc. [AMD/ATI] Baffin [Radeon Pro WX 4100]`

```xml
<hostdev mode="subsystem" type="pci" managed="yes">
  <driver name="vfio"/>
  <source>
    <address domain="0x0000" bus="0x49" slot="0x00" function="0x0"/>
  </source>
  <rom bar="on" file="/var/lib/libvirt/roms/AMD_Radeon_Pro_WX_4100.rom"/>
  <address type="pci" domain="0x0000" bus="0x03" slot="0x00" function="0x0"/>
</hostdev>
```

`0000:49:00:1 Advanced Micro Devices, Inc. [AMD/ATI] Baffin HDMI/DP Audio [Radeon RX 550 640SP / RX 560/560X]`

```xml
<hostdev mode="subsystem" type="pci" managed="yes">
  <driver name="vfio"/>
  <source>
    <address domain="0x0000" bus="0x49" slot="0x00" function="0x1"/>
  </source>
  <address type="pci" domain="0x0000" bus="0x05" slot="0x00" function="0x0"/>
</hostdev>

```

##### Black Magic 4 HDMI Capture Card

`0000:02:00:0 Blackmagic Design DeckLink Quad HDMI Recorder`

```xml
<hostdev mode="subsystem" type="pci" managed="yes">
  <source>
    <address domain="0x0000" bus="0x02" slot="0x00" function="0x0"/>
  </source>
  <address type="pci" domain="0x0000" bus="0x06" slot="0x00" function="0x0"/>
</hostdev>
```

### Docker

```bash
usermod -aG docker sniper7kills
```

#### Remote Hosts (VM's)

1. Setup an SSH keypair and SSH login to the host from the VM
2. Create or [import](./windows/SSH Docker Forward.xml) the following task:
    1. General
        - Security Options -> Run whether user is logged on or not
            - DO NOT CHECK "Do not store password"
        - Check "Hidden"
    2. Triggers
        - At log on
    3. Actions
        - Action: Start a program
        - Program/script `ssh`
        - Add arguments: `-NL localhost:23750:/var/run/docker.sock sniper7kills@TheBeast`
    4. Conditions
        - Uncheck everything
    5. Settings
        - Check Allow task to be run on demand
        - Check Run task as soon as possible after a scheduled start is missed
        - Check If the fast fails restart every: `1 minute` Attempt to restart up to: `3` times
        - Uncheck Stop the task if it runs longer than
        - Check if the running task does not end when requested, force it to stop
        - Uncheck if the task is not schefuled to run again, delete it after
        - Change dropdown to `Do not start a new instance`
3. Create an environmental variable (User)
    - Variable: `DOCKER_HOST`
    - Value: `tcp://127.0.0.1:23750`