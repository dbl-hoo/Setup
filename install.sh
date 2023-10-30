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

#formst root partition btrfs
# using existig efi partition
mkfs.btrfs -f -L arch /dev/$sda2

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
pacstrap /mnt base base-devel intel-ucode btrfs-progs linux-zen linux-firmware reflector linux-zen-headers

echo "starting FSTAB"
#Fstab
genfstab -U /mnt >> /mnt/etc/fstab
echo "finished FSTAB"
cat /mnt/etc/fstab
#Chroot into the base system to configure ...
arch-chroot /mnt

clear

# ------------------------------------------------------
# Set System Time
# ------------------------------------------------------
ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohc
# ------------------------------------------------------
# Update reflector
# ------------------------------------------------------
echo "Start reflector..."
reflector -c "US," -p https -a 3 --sort rate --save /etc/pacman.d/mirrorlist
# ------------------------------------------------------
# Synchronize mirrors
# ------------------------------------------------------
pacman -Syy
# ------------------------------------------------------
# Install Packages
# ------------------------------------------------------
pacman --noconfirm -S grub efibootmgr nano dracut vivaldi wpa_supplicant avahi nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack bash-completion openssh rsync reflector acpi acpi_call ipset acpid os-prober ntfs-3g terminus-font htop neofetch grub-btrfs xf86-video-amdgpu xf86-video-nouveau xf86-video-intel xf86-video-qxl man-db openssh pacman-contrib reflector sudo terminus-font brightnessctl pacman-contrib inxi
# ------------------------------------------------------
# set lang utf8 US
# ------------------------------------------------------
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
# ------------------------------------------------------
# Set Keyboard
# ------------------------------------------------------
echo "FONT=ter-v18n" >> /etc/vconsole.conf
#echo "KEYMAP=$keyboardlayout" >> /etc/vconsole.conf
# ------------------------------------------------------
# Set hostname and localhost
# ------------------------------------------------------
echo "$hostname" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts
clear
# ------------------------------------------------------
# Set Root Password
# ------------------------------------------------------
echo "Set root password"
passwd root
# ------------------------------------------------------
# Add User
# ------------------------------------------------------
echo "Add user $USER_NAME"
useradd -m -G wheel $USER_NAME
passwd $USER_NAME
# ------------------------------------------------------
# Enable Services
# ------------------------------------------------------
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable firewalld
systemctl enable acpid


#Set a system-wide default editor (example: neovim) ...
echo "EDITOR=nano" > /etc/environment

useradd -m -G wheel -s /bin/bash kirkham

#Activate wheel group access for sudo ...
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers

#set modules
MODULES=(crc32c-intel btrfs)

#set hooks
HOOKS=(base udev keyboard autodetect keymap consolefont modconf block filesystems fsck)

#create initramfs
dracut --hostonly --no-hostonly-cmdline /boot/initramfs-linux.img
dracut -N --force /boot/initramfs-linux-fallback.img

#install grub
grub-install --target=x86_64-efi --bootloader-id=Arch --efi-directory=/boot/efi/
grub-mkconfig -o /boot/grub/grub.cfg
sed -i '#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false' /etc/default/grub

exit
umount -R /mnt

clear
echo "     _                   "
echo "  __| | ___  _ __   ___  "
echo " / _' |/ _ \| '_ \ / _ \ "
echo "| (_| | (_) | | | |  __/ "
echo " \__,_|\___/|_| |_|\___| "
echo "                         "
echo ""

read -p "Press any key to resume ..."
reboot -h now
