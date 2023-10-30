#!/bin/bash
clear

#!/bin/bash
clear
echo "    _             _       ___           _        _ _ "
echo "   / \   _ __ ___| |__   |_ _|_ __  ___| |_ __ _| | |"
echo "  / _ \ | '__/ __| '_ \   | || '_ \/ __| __/ _' | | |"
echo " / ___ \| | | (__| | | |  | || | | \__ \ || (_| | | |"
echo "/_/   \_\_|  \___|_| |_| |___|_| |_|___/\__\__,_|_|_|"
echo ""


#set wifi
iwctl station wlan0 connect Kirkham --passphrase redoctober3290

#set variables

zoneinfo="America/New_York"
hostname="arch"

# Main user to create (by default, added to wheel group, and others).
USER_NAME='kirkham'

# larger font
# setfont ter-v24n

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
mkfs.btrfs -f -L arch /dev/$sda2

read -p "Press any key to resume ..."

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

# Set mount options for the subvolumes ...

export sv_opts="rw,noatime,compress-force=zstd:1,space_cache=v2"

#Options:
#noatime increases performance and reduces SSD writes.
#compress-force=zstd:1 is optimal for NVME devices. Omit the :1 to use the default level of 3. Zstd accepts a value range of 1-15, with higher levels trading speed and memory for higher compression ratios.
#space_cache=v2 creates cache in memory for greatly improved performance.

#Mount the new BTRFS root subvolume with subvol=@ ...
mount -o ${sv_opts},subvol=@ /dev/$sda2 /mnt

#Create mountpoints for the additional subvolumes ...
mkdir -p /mnt/{home,.snapshots,var/cache,var/lib/libvirt,var/log,var/tmp}

#Mount the additional subvolumes ...
mount -o ${sv_opts},subvol=@home /dev/$sda2 /mnt/home
mount -o ${sv_opts},subvol=@snapshots /dev/$sda2 /mnt/.snapshots
mount -o ${sv_opts},subvol=@cache /dev/$sda2 /mnt/var/cache
mount -o ${sv_opts},subvol=@libvirt /dev/$sda2 /mnt/var/lib/libvirt
mount -o ${sv_opts},subvol=@log /dev/$sda2 /mnt/var/log
mount -o ${sv_opts},subvol=@tmp /dev/$sda2 /mnt/var/tmp
mount -o defaults,noatime -m /dev/$sda1 /mnt/boot/efi

echo "file system created"

pacman -Syy
reflector --verbose --protocol https --latest 5 --sort rate --country US --country Germany --save /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel linux-headers intel-ucode btrfs-progs linux-zen linux-zen-firmware reflector networkmanager

#copy chroot script
cp config.sh /mnt

echo "starting FSTAB"
#Fstab
genfstab -U /mnt >> /mnt/etc/fstab
echo "finished FSTAB"
cat /mnt/etc/fstab

read -p "Pausing for a breath...Press any key to resume ..."

arch-chroot /mnt ./config.sh

# unmount partitions
umount /mnt/boot/efi /mnt


