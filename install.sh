#!/bin/bash
clear

echo "    _             _       ___           _        _ _ "
echo "   / \   _ __ ___| |__   |_ _|_ __  ___| |_ __ _| | |"
echo "  / _ \ | '__/ __| '_ \   | || '_ \/ __| __/ _' | | |"
echo " / ___ \| | | (__| | | |  | || | | \__ \ || (_| | | |"
echo "/_/   \_\_|  \___|_| |_| |___|_| |_|___/\__\__,_|_|_|"
echo ""


#set wifi
#iwctl station wlan0 connect Kirkham --passphrase redoctober3290

#set time and date
timedatectl set-ntp true
timedatectl status

# ------------------------------------------------------
# Enter partition names
# ------------------------------------------------------
lsblk
read -p "Enter the name of the EFI partition (eg. sda1): " sda1
read -p "Enter the name of the ROOT partition (eg. sda2): " sda2

#format efi parition
mkfs.fat -F 32 /dev/$sda1

#formst root partition btrfs
mkfs.btrfs -f /dev/$sda2

#mount btrfs, create subvolumes and unmount
mount /dev/$sda2 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@cache
btrfs subvolume create /mnt/@libvirt
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@tmp

#Unmount the root partition ...
umount /mnt

mount -o subvol=/@,defaults,noatime,compress=zstd /dev/$sda2 /mnt 
mount -o subvol=/@home,defaults,noatime,compress=zstd -m /dev/$sda2 /mnt/home
mount -o subvol=/@snapshots,defaults,noatime,compress=zstd -m /dev/$sda2 /mnt/.snapshots
mount -o subvol=/@cache,defaults,noatime,compress=zstd -m /dev/$sda2 /mnt/var/cache 
mount -o subvol=/@libvirt,defaults,noatime,compress=zstd -m /dev/$sda2 /mnt/var/lib/libvirt
mount -o subvol=/@log,defaults,noatime,compress=zstd -m /dev/$sda2  /mnt/var/log
mount -o subvol=/@tmp,defaults,noatime,compress=zstd -m /dev/$sda2 /mnt/var/tmp
mount -o defaults,noatime -m /dev/$sda1 /mnt/boot/efi 

pacman -Syy
reflector --verbose --protocol https --latest 5 --sort rate --country US --country Germany --save /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel linux-headers intel-ucode btrfs-progs linux-zen linux-firmware

#Fstab
genfstab -U /mnt >> /mnt/etc/fstab

#copy chroot script and execute
mkdir /mnt/install
cp config.sh /mnt/install/
cp hyprland.sh /mnt/install/
cp wallpaper.sh /mnt/install/
cp hyprland.conf /mnt/install/
arch-chroot /mnt ./install/config.sh

exit
umount -f /mnt
reboot -h now

